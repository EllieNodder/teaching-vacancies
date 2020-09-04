class Jobseekers::SchoolOverviewComponent < ViewComponent::Base
  include OrganisationHelper
  include VacanciesHelper

  def initialize(vacancy:)
    @vacancy = vacancy
  end

  def render?
    @vacancy.at_one_school?
  end
end
