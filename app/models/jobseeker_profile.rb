class JobseekerProfile < ApplicationRecord
  include ProfileSection

  belongs_to :jobseeker

  has_one :personal_details
  has_one :job_preferences
  has_many :employments
  has_many :qualifications

  delegate :all_roles, to: :job_preferences
  delegate :all_key_stages, to: :job_preferences
  delegate :all_working_patterns, to: :job_preferences
  delegate :first_name, :last_name, to: :personal_details, allow_nil: true

  scope :active, -> { where(active: true) }

  delegate :email, to: :jobseeker

  delegate :first_name, :last_name, to: :personal_details, allow_nil: true

  enum qualified_teacher_status: { yes: 0, no: 1, on_track: 2 }

  def self.copy_attributes(record, previous_application)
    record.assign_attributes(
      employments: previous_application.employments.map(&:duplicate),
      qualifications: previous_application.qualifications.map(&:duplicate),
      qualified_teacher_status_year: previous_application.qualified_teacher_status_year,
      qualified_teacher_status: previous_application.qualified_teacher_status,
    )
  end

  def self.prepare_associations(record)
    record.assign_attributes(
      job_preferences: JobPreferences.prepare(jobseeker_profile: record),
      personal_details: PersonalDetails.prepare(jobseeker_profile: record),
    )
  end

  def self.jobseeker(record)
    record.jobseeker
  end

  def deactivate!
    return unless active?

    update_column(:active, false)
  end

  def full_name
    [first_name, last_name].join(" ").presence || "Jobseeker"
  end

  def qts_status
    case qualified_teacher_status
    when "yes"
      "Awarded QTS #{qualified_teacher_status_year}"
    when "on_track"
      "On track to receive QTS"
    else
      ""
    end
  end
end
