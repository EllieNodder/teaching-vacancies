require "rails_helper"

RSpec.describe GeneralFeedbackForm, type: :model do
  subject { described_class.new(params) }
  let(:email) { "helpful@user.com" }
  let(:user_participation_response) { "uninterested" }
  let(:visit_purpose) { "find_teaching_job" }
  let(:visit_purpose_comment) { nil }
  let(:params) do
    {
      comment: "Fancy",
      email: email,
      report_a_problem: "no",
      user_participation_response: user_participation_response,
      visit_purpose: visit_purpose,
      visit_purpose_comment: visit_purpose_comment,
    }
  end

  it { is_expected.to validate_presence_of(:comment) }
  it { is_expected.to validate_length_of(:comment).is_at_most(1200) }
  it { is_expected.to validate_inclusion_of(:report_a_problem).in_array(%w[yes no]) }
  it {
    is_expected.to validate_inclusion_of(:user_participation_response)
                  .in_array(Feedback.user_participation_responses.keys)
  }
  it { is_expected.to validate_inclusion_of(:visit_purpose).in_array(Feedback.visit_purposes.keys) }
  it { is_expected.to validate_length_of(:visit_purpose_comment).is_at_most(1200) }

  describe "#email" do
    context "when the jobseeker is interested in participating in research" do
      before { allow(subject).to receive(:user_participation_response).and_return("interested") }

      it { is_expected.to validate_presence_of(:email) }
      it { is_expected.to_not allow_value("invalid@email@com").for(:email) }
    end

    context "when the jobseeker is uninterested in participating in research" do
      before { allow(subject).to receive(:user_participation_response).and_return("uninterested") }

      it { is_expected.not_to validate_presence_of(:email) }
    end
  end

  describe "#visit_purpose_comment" do
    context "when the visit purpose is not 'other_purpose'" do
      it { is_expected.not_to validate_presence_of(:visit_purpose_comment) }
    end

    context "when the visit purpose is 'other_purpose'" do
      let(:visit_purpose) { "other_purpose" }

      it { is_expected.to validate_presence_of(:visit_purpose_comment) }
    end
  end
end
