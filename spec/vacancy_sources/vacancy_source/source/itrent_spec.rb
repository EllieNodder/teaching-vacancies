require "rails_helper"

RSpec.describe VacancySource::Source::Itrent do
  let!(:school1) { create(:school, name: "Test School", urn: "12345", phase: :primary) }
  let!(:school_group) { create(:school_group, name: "E-ACT", uid: "456789", schools: schools) }
  let(:schools) { [school1] }

  let(:response_requisition_body) { file_fixture("vacancy_sources/itrent_requisition.json").read }
  let(:response_udf_body) { file_fixture("vacancy_sources/itrent_udf.json").read }
  let(:requisition_response) { double("ItrentHttpResponse", success?: true, body: response_requisition_body) }
  let(:udf_response) { double("ItrentHttpResponse", success?: true, body: response_udf_body) }

  before do
    allow(HTTParty).to receive(:get).with("http://example.com/feed.json", anything).and_return(requisition_response)
    allow(HTTParty).to receive(:get).with("http://example.com/udf.json", anything).and_return(udf_response)
  end

  describe "enumeration" do
    let(:vacancy) { subject.first }
    let(:expected_vacancy) do
      {
        job_title: "Class Teacher",
        job_advert: "<p>Lorem Ipsum dolor sit amet</p>",
        salary: "£24,000 to £30,000 depending on working knowledge",
        job_roles: ["teacher"],
        key_stages: %w[ks2],
        working_patterns: %w[full_time],
        contract_type: "fixed_term",
        phases: %w[secondary],
        subjects: ["maths", "advanced maths"],
        visa_sponsorship_available: false,
        benefits: true,
        benefits_details: "TLR2a",
        ect_status: "ect_suitable",
      }
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

    it "assigns the vacancy to the correct school and organisation" do
      expect(vacancy.organisations.first).to eq(school1)

      expect(vacancy.external_source).to eq("itrent")
      expect(vacancy.external_advert_url).to eq("https://teachvacs.itrentdemo.co.uk/ttrent_webrecruitment/wrd/run/ETREC179GF.open?WVID=2750500Wqk&VACANCY_ID=5116820Y9h")
      expect(vacancy.external_reference).to eq("FF00067")

      expect(vacancy.organisations).to eq(schools)
    end

    it "sets important dates" do
      expect(vacancy.expires_at).to eq(Time.zone.parse("2023-06-30"))
      expect(vacancy.publish_on).to eq(Date.parse("2023-08-07"))
    end

    describe "job roles mapping" do
      let(:response_udf_body) { super().gsub("Teacher", source_role) }

      ["null", "", " "].each do |role|
        context "when the source role is '#{role}'" do
          let(:source_role) { role }

          it "the vacancy roles are empty" do
            expect(vacancy.job_roles).to eq([])
          end
        end
      end

      %w[head_of_year head_of_year_or_phase].each do |role|
        context "when the source role is '#{role}'" do
          let(:source_role) { role }

          it "maps the source role to '[head_of_year_or_phase]' in the vacancy" do
            expect(vacancy.job_roles).to eq(["head_of_year_or_phase"])
          end
        end
      end

      context "when the source role is 'learning_support'" do
        let(:source_role) { "learning_support" }

        it "maps the source role to 'education_support' in the vacancy" do
          expect(vacancy.job_roles).to eq(["education_support"])
        end
      end
    end

    describe "start date mapping" do
      let(:fixture_date) { "2023-05-01" }

      it "stores the specific start date" do
        expect(vacancy.starts_on.to_s).to eq "2023-05-01"
        expect(vacancy.start_date_type).to eq "specific_date"
      end

      context "when the start date is blank" do
        let(:response_requisition_body) { super().gsub(fixture_date, "") }

        it "doesn't store a start date" do
          expect(vacancy.starts_on).to be_nil
          expect(vacancy.start_date_type).to eq nil
        end
      end

      context "when the start date is not present" do
        let(:response_requisition_body) { super().gsub(/"#{fixture_date}"/, "null") }

        it "doesn't store a start date" do
          expect(vacancy.starts_on).to be_nil
          expect(vacancy.start_date_type).to eq nil
        end
      end

      context "when the start date is a date with extra data" do
        let(:response_requisition_body) { super().gsub(fixture_date, "2022-11-21 or later") }

        it "stores it as other start date details" do
          expect(vacancy.starts_on).to be_nil
          expect(vacancy.other_start_date_details).to eq("2022-11-21 or later")
          expect(vacancy.start_date_type).to eq "other"
        end
      end

      context "when the start date comes as a specific datetime" do
        let(:response_requisition_body) { super().gsub(fixture_date, "2023-11-21T00:00:00") }

        it "stores it parsed as a specific date" do
          expect(vacancy.starts_on.to_s).to eq("2023-11-21")
          expect(vacancy.start_date_type).to eq "specific_date"
        end
      end

      context "when the start date comes as a specific date in a different format" do
        let(:response_requisition_body) { super().gsub(fixture_date, "21.11.23") }

        it "stores it parsed as a specific date" do
          expect(vacancy.starts_on.to_s).to eq("2023-11-21")
          expect(vacancy.start_date_type).to eq "specific_date"
        end
      end

      context "when the start date is a text" do
        let(:response_requisition_body) { super().gsub(fixture_date, "TBC") }

        it "stores it as other start date details" do
          expect(vacancy.starts_on).to be_nil
          expect(vacancy.other_start_date_details).to eq("TBC")
          expect(vacancy.start_date_type).to eq "other"
        end
      end
    end

    describe "phase mapping" do
      let(:response_udf_body) { super().gsub("secondary", phase) }

      %w[16-19 16_19].each do |phase|
        context "when the phase is '#{phase}'" do
          let(:phase) { phase }

          it "maps the phase to '[sixth_form_or_college]' in the vacancy" do
            expect(vacancy.phases).to eq(["sixth_form_or_college"])
          end
        end
      end

      context "when the phase is 'through_school'" do
        let(:phase) { "through_school" }

        it "maps the phase to '[through]' in the vacancy" do
          expect(vacancy.phases).to eq(["through"])
        end
      end
    end

    context "when the same vacancy has been imported previously" do
      let!(:existing_vacancy) do
        create(
          :vacancy,
          :external,
          phases: %w[secondary],
          external_source: "itrent",
          external_reference: "FF00067",
          organisations: schools,
          job_title: "Class Teacher",
        )
      end

      it "yields the existing vacancy with updated information" do
        expect(vacancy.id).to eq(existing_vacancy.id)
        expect(vacancy).to be_persisted
        expect(vacancy).to be_changed

        expect(vacancy.job_title).to eq("Class Teacher")
      end
    end

    context "when multiple school" do
      let!(:school2) { create(:school, name: "Test School 2", urn: "22222", phase: :primary) }
      let(:schools) { [school1, school2] }

      context "when the vacancy is for one school" do
        it "assigns the vacancy job location to the school" do
          expect(vacancy.readable_job_location).to eq(school1.name)
        end

        it "the vacancy gets associated to the school" do
          expect(vacancy.organisations).to eq([school1])
        end
      end

      context "when the vacancy is for both schools" do
        let(:response_udf_body) { super().gsub("12345", "12345,22222") }

        it "assigns the vacancy job location to the first school" do
          expect(vacancy.readable_job_location).to eq(school1.name)
        end

        it "the vacancy gets associated to both schools" do
          expect(vacancy.organisations).to contain_exactly(school1, school2)
        end
      end

      context "when the vacancy is for no particular school" do
        let(:response_udf_body) { super().gsub("12345", "") }

        it "assigns the vacancy job location to the central trust" do
          expect(vacancy.readable_job_location).to eq(school_group.name)
        end

        it "the vacancy gets associated to the central trust" do
          expect(vacancy.organisations).to eq([school_group])
        end
      end
    end
  end

  describe "parsing error" do
    let(:vacancy) { subject.first }
    let(:response_udf_body) { super().gsub("secondary", "") }
    let(:response_requisition_body) { super().gsub("Class Teacher", "") }

    context "when incorrect values are provided" do
      it "adds an error to the vacancy object" do
        expect(vacancy.errors.count).to eq(1)
      end
    end
  end
end
