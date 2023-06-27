require "rails_helper"

RSpec.describe "Jobseekers can sign up to an account" do
  let(:jobseeker) { build(:jobseeker) }
  let(:created_jobseeker) { Jobseeker.first }

  describe "creating an account" do
    it "validates and submits the form, triggers account created event, sends confirmation email and redirects to check your email page" do
      visit new_jobseeker_registration_path
      click_on I18n.t("buttons.create_account")
      expect(page).to have_content("There is a problem")
      expect { sign_up_jobseeker }.to have_triggered_event(:jobseeker_account_created).with_data(
        user_anonymised_jobseeker_id: anything,
        email_identifier: anything,
      ).and change { delivered_emails.count }.by(1)
      expect(current_path).to eq(jobseekers_check_your_email_path)
    end

    it "allows jobseekers to reset their password" do
      visit root_path
      find(:xpath, "//a[@href='/jobseekers/sign_up']").click
      fill_in "jobseeker[email]", with: jobseeker.email
      fill_in "jobseeker[password]", with: "Jobseeker1234"
      click_on I18n.t("buttons.create_account")

      expect(page).to have_content I18n.t("jobseekers.registrations.check_your_email.title")

      click_on I18n.t("jobseekers.registrations.check_your_email.resend_link")
      expect(page).to have_content I18n.t("jobseekers.registrations.check_your_email.resent_email_confirmation")

      visit first_link_from_last_mail
      click_on "Confirm"

      expect(current_path).to eq(confirmation_jobseekers_account_path)
    end
  end

  describe "confirming email address" do
    before do
      visit new_jobseeker_registration_path
      sign_up_jobseeker
    end

    context "when the confirmation token is valid" do
      it "confirms email, triggers email confirmed event and redirects to jobseeker account confirmation interstitial" do
        expect { confirm_email_address }.to have_triggered_event(:jobseeker_email_confirmed).with_base_data(
          user_anonymised_jobseeker_id: StringAnonymiser.new(created_jobseeker.id).to_s,
        )
        expect(current_path).to eq(confirmation_jobseekers_account_path)
        expect(page).to have_content(I18n.t("jobseekers.accounts.confirmation.page_title"))
        expect(page).to have_link(I18n.t("jobseekers.accounts.confirmation.apply_for_jobs_link_text"), href: jobs_path)
        expect(page).to have_link(I18n.t("jobseekers.accounts.confirmation.create_profile.heading"), href: jobseekers_profile_path)
        expect(page).not_to have_content(I18n.t("devise.confirmations.confirmed"))
      end
    end

    context "when the confirmation token is invalid" do
      context "when the confirmation period has expired" do
        before { travel_to 15.days.from_now }

        context "when the confirmation email is resent" do
          it "resends confirmation email and redirects to check your email page" do
            expect { resend_confirmation_email }.to change { delivered_emails.count }.by(1)
            expect(current_path).to eq(jobseekers_check_your_email_path)
          end
        end
      end
    end
  end
end
