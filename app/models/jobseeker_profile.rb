class JobseekerProfile < ApplicationRecord
  belongs_to :jobseeker
  has_one :personal_details

  enum qualified_teacher_status: { yes: 0, no: 1, on_track: 2 }
end
