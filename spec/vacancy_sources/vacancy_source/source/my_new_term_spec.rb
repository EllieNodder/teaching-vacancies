require "rails_helper"

RSpec.describe VacancySource::Source::MyNewTerm do
  let(:response) { double("AuthenticationResponse", code: 200, body: { access_token: "valid_access_token" }.to_json) }
  let(:job_listings_response_body) { file_fixture("vacancy_sources/my_new_term.json").read }
  let(:job_listings_response) { double("JobListingResponse", code: 200, body: job_listings_response_body) }
  let!(:in_scope_school) { create(:school, urn: "111111") }
  let!(:school_group) { create(:school_group, name: "E-ACT", uid: "12345", schools: trust_schools) }
  let(:trust_schools) { [in_scope_school] }

  let(:vacancy) { subject.first }

  let(:expected_vacancy) do
    {
      job_title: "Head of Geography",
      job_advert: "Lorem ipsum dolor sit amet",
      salary: "£24,000 - £50,000 Annually",
      job_roles: ["teacher"],
      key_stages: %w[ks2 ks3],
      working_patterns: %w[full_time part_time],
      contract_type: "permanent",
      phases: %w[primary],
      subjects: %w[Geography],
      visa_sponsorship_available: true,
    }
  end

  before do
    allow(described_class)
      .to receive(:get)
      .with("#{described_class::BASE_URI}/auth/test-api-key")
      .and_return(response)

    allow(described_class)
      .to receive(:get)
      .with(
        "#{described_class::BASE_URI}/job-listings",
        headers: { "Authorization" => "Bearer valid_access_token", "Content-Type" => "application/json" },
        query: {},
      )
      .and_return(job_listings_response)
  end

  it "has the correct number of vacancies" do
    expect(subject.count).to eq(1)
  end

  it "yield a newly built vacancy the correct vacancy information" do
    expect(vacancy).not_to be_persisted
    expect(vacancy).to be_changed
  end

  it "assigns correct attributes from the feed" do
    expect(vacancy).to have_attributes(expected_vacancy)
  end

  it "sets important dates" do
    expect(vacancy.expires_at).to eq(Time.zone.parse("2023-02-10T23:59:00+00:00"))
    expect(vacancy.publish_on).to eq(Date.today)
  end

  context "when visa_sponsorship_available is not provided" do
    let(:job_listings_response_body) do
      hash = JSON.parse(super())
      hash["data"]["jobs"].first.delete("visaSponsorshipAvailable")
      hash.to_json
    end

    it "sets visa_sponsorship_available to false" do
      expect(vacancy.visa_sponsorship_available).to eq false
    end
  end

  describe "job roles mapping" do
    let(:job_listings_response_body) { super().gsub("teacher", source_role) }

    ["null", "", " "].each do |role|
      context "when the source role is '#{role}'" do
        let(:source_role) { role }

        it "the vacancy role is null" do
          expect(vacancy.job_roles).to eq([])
        end
      end
    end

    %w[deputy_headteacher_principal deputy_headteacher].each do |role|
      context "when the source role is '#{role}'" do
        let(:source_role) { role }

        it "maps the source role to '[deputy_headteacher]' in the vacancy" do
          expect(vacancy.job_roles).to eq(["deputy_headteacher"])
        end
      end
    end

    %w[assistant_headteacher_principal assistant_headteacher].each do |role|
      context "when the source role is '#{role}'" do
        let(:source_role) { role }

        it "maps the source role to '[assistant_headteacher]' in the vacancy" do
          expect(vacancy.job_roles).to eq(["assistant_headteacher"])
        end
      end
    end

    %w[headteacher_principal headteacher].each do |role|
      context "when the source role is '#{role}'" do
        let(:source_role) { role }

        it "maps the source role to '[headteacher]' in the vacancy" do
          expect(vacancy.job_roles).to eq(["headteacher"])
        end
      end
    end

    context "when the source role is 'senior_leader'" do
      let(:source_role) { "senior_leader" }

      it "maps the source role to '[headteacher, assistant_headteacher, deputy_headteacher]' in the vacancy" do
        expect(vacancy.job_roles).to contain_exactly("headteacher", "assistant_headteacher", "deputy_headteacher")
      end
    end

    %w[head_of_year_or_phase head_of_year].each do |role|
      context "when the source role is '#{role}'" do
        let(:source_role) { role }

        it "maps the source role to '[head_of_year_or_phase]' in the vacancy" do
          expect(vacancy.job_roles).to eq(["head_of_year_or_phase"])
        end
      end
    end

    context "when the source role is 'head_of_department_or_curriculum'" do
      let(:source_role) { "head_of_department_or_curriculum" }

      it "maps the source role to '[head_of_department_or_curriculum]' in the vacancy" do
        expect(vacancy.job_roles).to eq(["head_of_department_or_curriculum"])
      end
    end

    context "when the source role is 'middle_leader'" do
      let(:source_role) { "middle_leader" }

      it "maps the source role to '[head_of_year_or_phase, head_of_department_or_curriculum]' in the vacancy" do
        expect(vacancy.job_roles).to contain_exactly("head_of_year_or_phase", "head_of_department_or_curriculum")
      end
    end

    %w[learning_support other_support science_technician].each do |role|
      context "when the source role is '#{role}'" do
        let(:source_role) { role }

        it "maps the source role to '[education_support]' in the vacancy" do
          expect(vacancy.job_roles).to eq(["education_support"])
        end
      end
    end
  end

  describe "start date mapping" do
    let(:fixture_date) { "ASAP" }

    context "when the start date contains a specific date" do
      let(:job_listings_response_body) { super().gsub(fixture_date, "2022-11-21") }

      it "stores the specific start date" do
        expect(vacancy.starts_on.to_s).to eq "2022-11-21"
        expect(vacancy.start_date_type).to eq "specific_date"
      end
    end

    context "when the start date is blank" do
      let(:job_listings_response_body) { super().gsub(fixture_date, "") }

      it "doesn't store a start date" do
        expect(vacancy.starts_on).to be_nil
        expect(vacancy.start_date_type).to eq nil
      end
    end

    context "when the start date is not present" do
      let(:job_listings_response_body) { super().gsub(/"#{fixture_date}"/, "null") }

      it "doesn't store a start date" do
        expect(vacancy.starts_on).to be_nil
        expect(vacancy.start_date_type).to eq nil
      end
    end

    context "when the start date is a date with extra data" do
      let(:job_listings_response_body) { super().gsub(fixture_date, "2022-11-21 or later") }

      it "stores it as other start date details" do
        expect(vacancy.starts_on).to be_nil
        expect(vacancy.other_start_date_details).to eq("2022-11-21 or later")
        expect(vacancy.start_date_type).to eq "other"
      end
    end

    context "when the start date comes as a specific datetime" do
      let(:job_listings_response_body) { super().gsub(fixture_date, "2023-11-21T00:00:00") }

      it "stores it parsed as a specific date" do
        expect(vacancy.starts_on.to_s).to eq("2023-11-21")
        expect(vacancy.start_date_type).to eq "specific_date"
      end
    end

    context "when the start date comes as a specific date in a different format" do
      let(:job_listings_response_body) { super().gsub(fixture_date, "21.11.23") }

      it "stores it parsed as a specific date" do
        expect(vacancy.starts_on.to_s).to eq("2023-11-21")
        expect(vacancy.start_date_type).to eq "specific_date"
      end
    end

    context "when the start date is a text" do
      let(:job_listings_response_body) { super().gsub(fixture_date, "TBC") }

      it "stores it as other start date details" do
        expect(vacancy.starts_on).to be_nil
        expect(vacancy.other_start_date_details).to eq("TBC")
        expect(vacancy.start_date_type).to eq "other"
      end
    end
  end

  describe "phase mapping" do
    let(:job_listings_response_body) { super().gsub("primary", phase) }

    %w[16-19 16_19].each do |phase|
      context "when the phase is '#{phase}'" do
        let(:phase) { phase }

        it "maps the phase to '[sixth_form_or_college]' in the vacancy" do
          expect(vacancy.phases).to eq(["sixth_form_or_college"])
        end
      end
    end

    %w[through_school all_through].each do |phase|
      context "when the phase is '#{phase}'" do
        let(:phase) { phase }

        it "maps the phase to '[through]' in the vacancy" do
          expect(vacancy.phases).to eq(["through"])
        end
      end
    end
  end

  describe "vacancy organisation parsing" do
    let(:trust_uid) { school_group.uid }
    let(:school_urns) { [in_scope_school.urn] }

    let(:job_listings_response_body) do
      JSON.parse(super()).tap { |h|
        h["data"]["jobs"].first["schoolUrns"] = school_urns
        h["data"]["jobs"].first["trustUID"] = trust_uid
      }.to_json
    end

    context "when the vacancy belongs to a single school" do
      let(:school_urns) { [in_scope_school.urn] }

      it "assigns the vacancy to the correct school and organisation" do
        expect(vacancy.organisations.first).to eq(in_scope_school)

        expect(vacancy.external_source).to eq("my_new_term")
        expect(vacancy.external_advert_url).to eq("https://www.example.co.uk/jobs/URN/EDV-2023-MNT-12345")
        expect(vacancy.external_reference).to eq("561c8f63-c105-4142-ba14-4c345118e46b2")
      end
    end

    context "when associated with an out of scope school" do
      let(:out_of_scope_school) { create(:school, detailed_school_type: "Other independent school", urn: "000000") }
      let(:trust_schools) { [out_of_scope_school] }
      let(:school_urns) { [out_of_scope_school.urn] }

      it "does not import vacancy" do
        expect(subject.count).to eq(0)
      end
    end

    context "when the vacancy is associated with multiple schools from a trust" do
      let!(:school2) { create(:school, name: "Test School 2", urn: "222222", phase: :primary) }
      let(:trust_schools) { [in_scope_school, school2].sort_by(&:created_at) }
      let(:school_urns) { [in_scope_school.urn, school2.urn] }

      it "assigns the vacancy to both schools" do
        expect(vacancy.organisations).to contain_exactly(in_scope_school, school2)
      end

      it "assigns the vacancy job location to the first school from the group" do
        expect(vacancy.readable_job_location).to eq(in_scope_school.name)
      end
    end

    context "when the vacancy belongs to the central trust office instead of a particular/multiple school" do
      let(:school_urns) { [] }

      before do
        create(:school_group, name: "Wrong Trust", uid: "54321", schools: [])
      end

      it "the vacancy is valid" do
        expect(vacancy).to be_valid
      end

      it "assigns the vacancy to the school group" do
        expect(vacancy.organisations).to contain_exactly(school_group)
      end

      it "assigns the vacancy job location to the school group" do
        expect(vacancy.readable_job_location).to eq(school_group.name)
      end
    end

    context "when the school doesn't belong to a school group" do
      let(:school2) { create(:school, name: "Test School 2", urn: "222222", phase: :primary) }
      let(:school_urns) { [school2.urn] }
      let(:trust_uid) { nil }

      it "the vacancy is valid" do
        expect(vacancy).to be_valid
      end

      it "assigns the vacancy to the school" do
        expect(vacancy.organisations).to contain_exactly(school2)
      end

      it "assigns the vacancy job location to the school" do
        expect(vacancy.readable_job_location).to eq(school2.name)
      end
    end
  end
end
