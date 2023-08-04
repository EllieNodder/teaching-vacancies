namespace :db do # rubocop:disable Metrics/BlockLength
  desc "Set job role and ect_status from old job_roles field"
  task set_new_job_role_and_ect_status: :environment do
    main_job_roles = [0, 1, 4, 5, 6, 7]
    Vacancy.published.find_each do |v|
      v.update_columns job_role: (v.job_roles&.find { |r| r.in? main_job_roles } || 0),
                       ect_status: v.job_roles&.include?(3) ? :ect_suitable : :ect_unsuitable
    end
  end

  # TODO: remove phase field from vacancies table once this is done
  desc "Set phases from schools or old readable_phases field and benefits"
  task set_new_phases_and_benefits: :environment do
    Vacancy.find_each do |v|
      phases =
        if v.school_phases.any?
          v.school_phases.map { |p| Vacancy.phases[p] }
        else
          v.readable_phases.map { |p| p.in?(["16-19", "16 to 19"]) ? 4 : Vacancy.phases[p] }
        end
      v.update_columns phases: phases, benefits: v.benefits_details.present?
    end
  end

  desc "Replaces removed jobseeker job preferences roles with all the roles they were split into"
  task split_jobseeker_job_preferences_roles: :environment do
    # Senior leader got split into 3 new roles.
    JobPreferences.where("'senior_leader' = ANY(roles)")
                  .update_all("roles = array_cat(array_remove(roles, 'senior_leader'),
                                                 '{headteacher, deputy_headteacher, assistant_headteacher}')")
    # Middle leader got split into 2 new roles.
    JobPreferences.where("'middle_leader' = ANY(roles)")
                  .update_all("roles = array_cat(array_remove(roles, 'middle_leader'),
                                                '{head_of_year_or_phase, head_of_department_or_curriculum}')")
  end

  desc "Asynchronously import organisations from GIAS and seed the database"
  task async_seed: :environment do
    SeedDatabaseJob.perform_later
  end

  desc "Reset markers"
  task reset_markers: :environment do
    Vacancy.published.applicable.find_each(&:reset_markers)
  end

  desc "Generates 1000 random vacancies for testing purposes"
  task create_random_vacancies: :environment do
    1000.times do
      school = School.not_closed.order(Arel.sql("RANDOM()")).first
      FactoryBot.create(:vacancy, organisations: [school])
    end
  end

  desc "Add FriendlyId slugs to Organisation records"
  task add_friendlyid_organisation_slugs: :environment do
    SetOrganisationSlugsJob.perform_now
  end

  desc "Set other_start_date_details and start_date_type for vacancies"
  task set_start_date_fields: :environment do
    Vacancy.find_each do |v|
      start_date_type =
        if v.starts_asap
          "other"
        elsif v.starts_on.present?
          "specific_date"
        else
          "undefined"
        end

      v.update_column :start_date_type, start_date_type

      if v.starts_asap
        other_start_date_details = "As soon as possible"
        v.update_column :other_start_date_details, other_start_date_details
      end
    end
  end

  desc "Set vacancy fields for new listing process"
  task set_new_vacancy_fields: :environment do
    Vacancy.find_each do |v|
      v.update_columns(contact_number_provided: v.contact_number.present?,
                       include_additional_documents: v.supporting_documents.attachments&.any?,
                       school_visits: v.school_visits_details.present?)
    end
  end

  desc "Delete alert runs belonging to deleted subscriptions"
  task delete_alert_runs_for_deleted_subscriptions: :environment do
    AlertRun.left_joins(:subscription).where(subscription: { id: nil }).delete_all
  end

  task delete_feedbacks_for_deleted_associations: :environment do
    Feedback.left_joins(:jobseeker).where.not(jobseeker_id: nil).where(jobseeker: { id: nil }).delete_all
    Feedback.left_joins(:subscription).where.not(subscription_id: nil).where(subscription: { id: nil }).delete_all
  end

  desc "Set vacancies job roles array from job_role"
  task set_job_roles_from_job_role: :environment do
    # Based on Vacancy job_role/job_roles enum values
    # Using numeral value of the array enum in the DB as update_columns doesn't have access to array_enum strings.
    mappings = {
      nil => [],
      "teacher" => [0],
      "senior_leader" => [1, 2, 3],
      "middle_leader" => [4, 5],
      "teaching_assistant" => [6],
      "higher_level_teaching_assistant" => [7],
      "education_support" => [8],
      "sendco" => [9],
    }
    Vacancy.find_each { |v| v.update_columns(job_roles: mappings[v.job_role]) }
  end
end

namespace :dsi do
  desc "Update DfE Sign-in users data"
  task update_users: :environment do
    require "update_dsi_users_in_db"
    UpdateDSIUsersInDb.new.run!
  end
end

namespace :gias do
  desc "Import schools, trusts and local authorities data"
  task import_schools: :environment do
    ImportOrganisationDataJob.perform_now
    SetOrganisationSlugsJob.perform_now
  end
end

namespace :google do
  desc "Remove expired vacancies from the Google index"
  task remove_expired_vacancies_google_index: :environment do
    RemoveExpiredVacanciesFromGoogleIndexJob.perform_later
  end
end

namespace :ons do
  desc "Import all ONS areas"
  task import_all: %i[import_counties import_cities import_regions create_composites]

  desc "Import ONS counties"
  task import_counties: :environment do
    OnsDataImport::ImportCounties.new.call
  end

  desc "Import ONS cities"
  task import_cities: :environment do
    OnsDataImport::ImportCities.new.call
  end

  desc "Import ONS regions"
  task import_regions: :environment do
    OnsDataImport::ImportRegions.new.call
  end

  desc "Create composites from ONS polygons"
  task create_composites: :environment do
    OnsDataImport::CreateComposites.new.call
  end
end

namespace :publishers do
  desc "Reset 'New features' attributes so all publishers are shown 'New features' page"
  task reset_new_features_attributes: :environment do
    Publisher.update_all(dismissed_new_features_page_at: nil)
  end
end
