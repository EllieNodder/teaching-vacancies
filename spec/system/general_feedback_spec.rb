require "rails_helper"

RSpec.describe "Giving general feedback for the service", recaptcha: true do
  let(:comment) { "Keep going!" }
  let(:email) { "test@example.com" }
  let(:occupation) { "teacher" }
  let(:visit_purpose_comment) { "testing" }

  context "when all required fields are complete" do
    scenario "can submit feedback" do
      visit new_feedback_path
      expect(page).to have_content(I18n.t("general_feedbacks.new.heading"))

      fill_in_general_feedback

      expect { click_button I18n.t("buttons.submit_feedback") }.to change {
        Feedback.where(comment: comment,
                       email: email,
                       occupation: occupation,
                       feedback_type: "general",
                       rating: "highly_satisfied",
                       recaptcha_score: 0.9,
                       user_participation_response: "interested",
                       visit_purpose: "other_purpose",
                       visit_purpose_comment: visit_purpose_comment).count
      }.by(1)

      expect(page).to have_content(I18n.t("general_feedbacks.create.success"))
    end
  end

  context "when all required fields are not complete" do
    scenario "can not submit feedback" do
      visit new_feedback_path
      click_on I18n.t("buttons.submit_feedback")
      expect(page).to have_content("There is a problem")
    end
  end

  context "when recaptcha is invalid" do
    before do
      allow_any_instance_of(ApplicationController).to receive(:verify_recaptcha).and_return(false)
    end

    context "and the form is valid" do
      scenario "redirects to invalid_recaptcha path" do
        visit new_feedback_path
        fill_in_general_feedback
        click_on I18n.t("buttons.submit_feedback")
        expect(page).to have_current_path(invalid_recaptcha_path(form_name: "General feedback form"))
      end
    end

    context "and the form is invalid" do
      scenario "does not redirect to invalid_recaptcha path" do
        visit new_feedback_path
        click_on I18n.t("buttons.submit_feedback")
        expect(page).to have_content("There is a problem")
      end
    end
  end

  def fill_in_general_feedback
    choose name: "general_feedback_form[report_a_problem]", option: "yes"
    choose I18n.t("helpers.label.general_feedback_form.visit_purpose_options.other_purpose")
    choose I18n.t("helpers.label.general_feedback_form.rating.highly_satisfied")

    fill_in "general_feedback_form[visit_purpose_comment]", with: visit_purpose_comment
    fill_in "general_feedback_form[comment]", with: comment

    choose name: "general_feedback_form[user_participation_response]", option: "interested"
    fill_in "email", with: email
    fill_in "occupation", with: occupation
  end
end
