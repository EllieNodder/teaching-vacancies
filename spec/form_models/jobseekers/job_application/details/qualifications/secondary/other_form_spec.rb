require "rails_helper"

RSpec.describe Jobseekers::JobApplication::Details::Qualifications::Secondary::OtherForm, type: :model do
  it { is_expected.to validate_presence_of(:category) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:institution) }
  it { is_expected.to validate_numericality_of(:year).is_less_than_or_equal_to(Time.current.year) }

  describe "#subject_and_grade_correspond?" do
    # TODO: Add test when functionality is finished
  end
end
