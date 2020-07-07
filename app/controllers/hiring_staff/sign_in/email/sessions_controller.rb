class HiringStaff::SignIn::Email::SessionsController < HiringStaff::SignIn::BaseSessionsController
  EMERGENCY_LOGIN_KEY_DURATION = 10.minutes

  skip_before_action :check_session
  skip_before_action :check_terms_and_conditions

  before_action :redirect_signed_in_users,
    only: %i[new create check_your_email choose_organisation]
  before_action :redirect_for_dsi_authentication,
    only: %i[new create check_your_email change_organisation choose_organisation]
  before_action :redirect_unauthorised_users, only: %i[create]

  def new; end

  def create
    session.update(urn: get_urn, uid: get_uid)
    Rails.logger.info("Updated session with URN #{session[:urn]} or UID #{session[:uid]}")
    redirect_to_organisation_path
  end

  def destroy
    Rails.logger.info("Hiring staff clicked sign out via fallback authentication: #{session[:oid]}")
    end_session_and_redirect
  end

  def check_your_email
    user = User.find_by(email: params.dig(:user, :email).downcase.strip)
    send_login_key(user: user) if user
  end

  def change_organisation
    key = generate_login_key(user: current_user)
    session.destroy
    redirect_to auth_email_choose_organisation_path(login_key: key.id)
  end

  def choose_organisation
    information = GetInformationFromLoginKey.new(get_key)
    @reason_for_failing_sign_in = information.reason_for_failing_sign_in
    @schools, @school_groups = information.schools, information.school_groups
    update_session_without_urn_or_uid(information.details_to_update_in_session)
    # .to_i used to convert nil to 0
    only_one_organisation? = @schools&.count.to_i + @school_groups&.count.to_i == 1
    redirect_to auth_email_create_session_path(urn: @schools&.first&.urn, uid: @school_groups&.first&.uid) if
      only_one_organisation?
  end

  private

  def update_session_without_urn_or_uid(options)
    return unless options[:oid]
    session.update(
      session_id: options[:oid],
      multiple_schools: options[:has_multiple_schools]
    )
    Rails.logger.warn("Hiring staff signed in via fallback authentication: #{options[:oid]}")
  end

  def get_uid
    params.dig(:uid)
  end

  def get_urn
    params.dig(:urn)
  end

  def get_key
    params_login_key = params.dig(:login_key)
    EmergencyLoginKey.find(params_login_key) rescue nil
  end

  def send_login_key(user:)
    AuthenticationFallbackMailer.sign_in_fallback(
      login_key: generate_login_key(user: user),
      email: user.email
    ).deliver_later
  end

  def generate_login_key(user:)
    user.emergency_login_keys.create(not_valid_after: Time.zone.now + EMERGENCY_LOGIN_KEY_DURATION)
  end

  def redirect_for_dsi_authentication
    redirect_to new_identifications_path unless AuthenticationFallback.enabled?
  end

  def redirect_unauthorised_users
    redirect_to new_auth_email_path unless user_authorised?
  end

  def user_authorised?
    user = User.find_by(oid: session[:session_id]) rescue nil
    user&.dsi_data&.dig('school_group_uids')&.include?(get_uid) || user&.dsi_data&.dig('school_urns')&.include?(get_urn)
  end
end
