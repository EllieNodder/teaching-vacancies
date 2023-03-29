class Publishers::JobseekerProfilesController < Publishers::BaseController
  def index
    @pagy, @jobseeker_profiles = pagy(Search::JobseekerProfileSearch.new(jobseeker_profile_search_params).jobseeker_profiles)
    @form = Publishers::JobseekerProfileSearchForm.new(jobseeker_profile_search_params)
  end

  def show
    not_found unless visible_to_current_organisation?
  end

  private

  def jobseeker_profile_search_params
    params.permit(locations: [], qualified_teacher_status: [], roles: [], working_patterns: [], education_phases: [], key_stages: [], subjects: [])
          .transform_values(&:compact_blank)
          .merge(current_organisation:)
  end

  def profile
    @profile ||= JobseekerProfile.find(params[:id])
  end
  helper_method :profile

  def visible_to_current_organisation?
    profile.active? && visible_to_specific_org? && visible_to_associated_groups?
  end

  def visible_to_specific_org?
    profile.excluded_organisations.exclude?(current_organisation)
  end

  def visible_to_associated_groups?
    return true unless current_organisation.respond_to?(:school_groups)
    return true if (groups = current_organisation.school_groups).blank?

    profile.excluded_organisations & groups == []
  end
end
