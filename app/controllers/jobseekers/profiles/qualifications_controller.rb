class Jobseekers::Profiles::QualificationsController < Jobseekers::ProfilesController
  include Jobseekers::QualificationFormConcerns

  helper_method :category, :form, :jobseeker_profile, :qualification, :secondary?, :qualification_form_param_key

  def submit_category
    if form.valid?
      redirect_to new_jobseekers_profile_qualification_path(qualification_params)
    else
      render :select_category
    end
  end

  def new; end

  def create
    if form.valid?
      profile.qualifications.create(qualification_params)
      redirect_to review_jobseekers_profile_qualifications_path
    else
      render :new
    end
  end

  def edit; end

  def review; end

  def update
    if form.valid?
      qualification.update(qualification_params)
      redirect_to review_jobseekers_profile_qualifications_path
    else
      render :edit
    end
  end

  def destroy
    qualification.destroy
    redirect_to review_jobseekers_profile_qualifications_path, success: t(".success")
  end

  def confirm_destroy; end

  private

  def form
    @form ||= category_form_class(category).new(form_attributes)
  end

  def form_attributes
    case action_name
    when "new"
      { category: category }
    when "select_category", "confirm_destroy"
      {}
    when "edit"
      qualification
        .slice(:category, :finished_studying, :finished_studying_details, :grade, :institution, :name, :subject, :year, :qualification_results)
        .reject { |_, v| v.blank? && v != false }
    when "create", "update", "submit_category"
      qualification_params
    end
  end

  def qualification_params
    case action_name
    when "new", "select_category", "submit_category", "confirm_destroy"
      (params[qualification_form_param_key(category)] || params).permit(:category)
    when "create", "edit", "update"
      params.require(qualification_form_param_key(category))
            .permit(:category, :finished_studying, :finished_studying_details, :grade, :institution, :name, :subject, :year, qualification_results_attributes: %i[id subject grade])
    end
  end

  def category
    @category ||= action_name.in?(%w[edit update]) ? qualification.category : category_param
  end

  def category_param
    params.permit(:category)[:category]
  end

  def qualification
    @qualification ||= profile.qualifications.find(params[:id] || params[:qualification_id])
  end

  def secondary?
    category.in?(Qualification::SECONDARY_QUALIFICATIONS)
  end
end
