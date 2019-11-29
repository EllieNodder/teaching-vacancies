require 'rails_helper'

RSpec.feature 'Filtering vacancies' do
  context 'when filtering by location', elasticsearch: true do
    scenario 'search radius defaults to 20' do
      visit jobs_path

      within '.filters-form' do
        expect(page).to have_select('radius', selected: 'Within 20 miles')
      end
    end

    scenario 'search results can be filtered by the selected location and radius' do
      allow(LocationCategory).to receive(:include?).with('enfield').and_return(false)
      expect(Geocoder).to receive(:coordinates).with('enfield')
                                               .and_return([51.6622925, -0.1180655])
      enfield_vacancy = create(:vacancy, :published,
                               school: build(:school, name: 'St James School',
                                                      town: 'Enfield',
                                                      geolocation: '(51.6580645, -0.0448643)'))
      penzance_vacancy = create(:vacancy, :published, school: build(:school, name: 'St James School',
                                                                             town: 'Penzance'))

      Vacancy.__elasticsearch__.client.indices.flush
      visit jobs_path

      within '.filters-form' do
        fill_in 'location', with: 'enfield'
        select 'Within 25 miles'
        page.find('.govuk-button[type=submit]').click
      end

      expect(page).to have_content(enfield_vacancy.job_title)
      expect(page).not_to have_content(penzance_vacancy.job_title)
    end
  end

  scenario 'search results can be filtered by the location category' do
    london_region = Region.find_or_create_by(name: 'London')
    camden_vacancy = create(:vacancy, :published,
      school: build(:school, region: london_region, local_authority: 'Camden'))
    victoria_vacancy = create(:vacancy, :published,
      school: build(:school, region: london_region, local_authority: 'Victoria'))

    Vacancy.__elasticsearch__.client.indices.flush
    visit jobs_path

    within '.filters-form' do
      fill_in 'location', with: 'camden'
      page.find('.govuk-button[type=submit]').click
    end

    expect(page).to have_content(camden_vacancy.job_title)
    expect(page).not_to have_content(victoria_vacancy.job_title)
  end

  context 'with jobs with various job titles and subjects', elasticsearch: true do
    let!(:headmaster_vacancy) { create(:vacancy, :published, job_title: 'Headmaster') }
    let!(:english_title_vacancy) { create(:vacancy, :published, job_title: 'English Language') }
    let!(:english_subject_vacancy) do
      create(:vacancy, job_title: 'Foo Tutor', subject: create(:subject, name: 'English'))
    end
    let!(:arts_vacancy) do
      create(:vacancy, job_title: 'Arts Tutor', subject: create(:subject, name: 'Arts'),
                       first_supporting_subject: create(:subject, name: 'English'))
    end
    let!(:maths_vacancy) do
      create(:vacancy, job_title: 'Maths Subject Leader', subject: create(:subject, name: 'Maths'))
    end

    before(:each) { Vacancy.__elasticsearch__.client.indices.flush }

    scenario 'is filterable by subject' do
      visit jobs_path

      within '.filters-form' do
        fill_in 'subject', with: 'English'
        page.find('.govuk-button[type=submit]').click
      end

      expect(page).not_to have_content(headmaster_vacancy.job_title)
      expect(page).not_to have_content(maths_vacancy.job_title)
      expect(page).to have_content(english_title_vacancy.job_title)
      expect(page).to have_content(arts_vacancy.job_title)
      expect(page).to have_content(english_subject_vacancy.job_title)
    end

    scenario 'is filterable by job title' do
      visit jobs_path

      within '.filters-form' do
        fill_in 'job_title', with: 'Tutor'
        page.find('.govuk-button[type=submit]').click
      end

      expect(page).not_to have_content(headmaster_vacancy.job_title)
      expect(page).not_to have_content(maths_vacancy.job_title)
      expect(page).not_to have_content(english_title_vacancy.job_title)
      expect(page).to have_content(arts_vacancy.job_title)
      expect(page).to have_content(english_subject_vacancy.job_title)
    end
  end

  scenario 'is filterable by working pattern', elasticsearch: true do
    part_time_vacancy = create(:vacancy, :published, working_patterns: ['part_time'])
    full_time_vacancy = create(:vacancy, :published, working_patterns: ['full_time'])
    full_and_part_time_vacancy = create(:vacancy, :published, working_patterns: ['full_time', 'part_time'])

    Vacancy.__elasticsearch__.client.indices.flush
    visit jobs_path

    within '.filters-form' do
      select 'Part-time', from: 'working_pattern'
      page.find('.govuk-button[type=submit]').click
    end

    expect(page).to have_content(part_time_vacancy.job_title)
    expect(page).to have_content(full_and_part_time_vacancy.job_title)
    expect(page).not_to have_content(full_time_vacancy.job_title)
  end

  context 'with jobs with education phases', elasticsearch: true do
    let!(:nursery_vacancy) { create(:vacancy, :published, school: build(:school, :nursery)) }
    let!(:primary_vacancy) { create(:vacancy, :published, school: build(:school, :primary)) }
    let!(:secondary_vacancy) { create(:vacancy, :published, school: build(:school, :secondary)) }

    before(:each) { Vacancy.__elasticsearch__.client.indices.flush }

    scenario 'is filterable by single education phase selection' do
      visit jobs_path

      within '.filters-form' do
        check 'Primary', name: 'phases[]'
        page.find('.govuk-button[type=submit]').click
      end

      expect(page).not_to have_content(nursery_vacancy.job_title)
      expect(page).to have_content(primary_vacancy.job_title)
      expect(page).not_to have_content(secondary_vacancy.job_title)
    end

    scenario 'is filterable by multiple education phase selections' do
      visit jobs_path

      within '.filters-form' do
        check 'Primary', name: 'phases[]'
        check 'Secondary', name: 'phases[]'
        page.find('.govuk-button[type=submit]').click
      end

      expect(page).not_to have_content(nursery_vacancy.job_title)
      expect(page).to have_content(primary_vacancy.job_title)
      expect(page).to have_content(secondary_vacancy.job_title)
    end

    scenario 'displays all available jobs when "Any" education phase selected' do
      visit jobs_path

      within '.filters-form' do
        check 'Any', name: 'phases[]'
        page.find('.govuk-button[type=submit]').click
      end

      expect(page).to have_content(nursery_vacancy.job_title)
      expect(page).to have_content(primary_vacancy.job_title)
      expect(page).to have_content(secondary_vacancy.job_title)
    end
  end

  context 'when filtering by minimum salary', elasticsearch: true do
    scenario 'displays vacancies with a maximum salary that is higher than or equal to the filter value' do
      low_paying_vacancy = create(:vacancy, :published, minimum_salary: 10000, maximum_salary: 29000)
      medium_paying_vacancy = create(:vacancy, :published, minimum_salary: 18000, maximum_salary: 30000)
      high_paying_vacancy = create(:vacancy, :published, minimum_salary: 20000, maximum_salary: 45000)

      Vacancy.__elasticsearch__.client.indices.flush
      visit jobs_path

      within '.filters-form' do
        select '£30,000', from: 'minimum_salary'
        page.find('.govuk-button[type=submit]').click
      end

      expect(page).to have_content(medium_paying_vacancy.job_title)
      expect(page).to have_content(high_paying_vacancy.job_title)
      expect(page).not_to have_content(low_paying_vacancy.job_title)
    end

    scenario 'displays all vacancies that have no maximum salary, regardless of their minimum salary' do
      vacancy_one = create(:vacancy, :published, minimum_salary: 19000, maximum_salary: nil)
      vacancy_two = create(:vacancy, :published, minimum_salary: 30000, maximum_salary: nil)
      vacancy_three = create(:vacancy, :published, minimum_salary: 40000, maximum_salary: nil)

      Vacancy.__elasticsearch__.client.indices.flush
      visit jobs_path

      within '.filters-form' do
        select '£30,000', from: 'minimum_salary'
        page.find('.govuk-button[type=submit]').click
      end

      expect(page).to have_content(vacancy_one.job_title)
      expect(page).to have_content(vacancy_two.job_title)
      expect(page).to have_content(vacancy_three.job_title)
    end
  end

  context 'when filtering by newly qualified teacher', elasticsearch: true do
    scenario 'search results can be filtered by NQT suitability' do
      nqt_suitable_vacancy = create(:vacancy, :published, newly_qualified_teacher: true)
      not_nqt_suitable_vacancy = create(:vacancy, :published, newly_qualified_teacher: false)

      Vacancy.__elasticsearch__.client.indices.flush
      visit jobs_path

      within '.filters-form' do
        check 'newly_qualified_teacher'
        page.find('.govuk-button[type=submit]').click
      end

      expect(page).to have_content(nqt_suitable_vacancy.job_title)
      expect(page).not_to have_content(not_nqt_suitable_vacancy.job_title)
      expect(page).to have_field('newly_qualified_teacher', checked: true)
    end

    scenario 'displays all available jobs when NQT suitable is unchecked', elasticsearch: true do
      nqt_suitable_vacancy = create(:vacancy, :published, newly_qualified_teacher: true)
      not_nqt_suitable_vacancy = create(:vacancy, :published, newly_qualified_teacher: false)

      Vacancy.__elasticsearch__.client.indices.flush
      visit jobs_path

      within '.filters-form' do
        check 'newly_qualified_teacher'
        uncheck 'newly_qualified_teacher'
        page.find('.govuk-button[type=submit]').click
      end

      expect(page).to have_content(not_nqt_suitable_vacancy.job_title)
      expect(page).to have_content(nqt_suitable_vacancy.job_title)
      expect(page).to have_field('newly_qualified_teacher', checked: false)
    end
  end

  context 'when searching triggers a job to write a search_event to the audit Spreadsheet', elasticsearch: true do
    scenario 'correctly logs the number of non-paginated results' do
      create_list(:vacancy, 3, :published, job_title: 'Physics', newly_qualified_teacher: true)
      create(:vacancy, :published, newly_qualified_teacher: false)
      timestamp = Time.zone.now.iso8601

      Vacancy.__elasticsearch__.client.indices.flush

      data = {
        total_count: 3,
        location: '',
        radius: '20',
        keyword: nil,
        minimum_salary: '',
        maximum_salary: nil,
        working_pattern: nil,
        phases: nil,
        newly_qualified_teacher: 'true',
        subject: 'Physics',
        job_title: ''
      }

      expect(AuditSearchEventJob).to receive(:perform_later)
        .with(data)

      visit jobs_path

      Timecop.freeze(timestamp) do
        within '.filters-form' do
          check 'newly_qualified_teacher'
          fill_in 'subject', with: 'Physics'
          page.find('.govuk-button[type=submit]').click
        end
      end
    end

    scenario 'correctly logs the total results when pagination is used', elasticsearch: true do
      create_list(:vacancy, 12, :published, job_title: 'Math', newly_qualified_teacher: true)
      timestamp = Time.zone.now.iso8601

      Vacancy.__elasticsearch__.client.indices.flush

      data = {
        total_count: 12,
        location: '',
        radius: '20',
        keyword: nil,
        minimum_salary: '',
        maximum_salary: nil,
        working_pattern: nil,
        phases: nil,
        newly_qualified_teacher: 'true',
        subject: 'Math',
        job_title: ''
      }

      expect(AuditSearchEventJob).to receive(:perform_later)
        .with(data)

      visit jobs_path

      Timecop.freeze(timestamp) do
        within '.filters-form' do
          check 'newly_qualified_teacher'
          fill_in 'subject', with: 'Math'
          page.find('.govuk-button[type=submit]').click
        end
      end
    end
  end

  context 'when resetting search filters', elasticsearch: true do
    it 'hiring staff can reset search after filtering' do
      create(:vacancy, :published, job_title: 'Physics Teacher')

      Vacancy.__elasticsearch__.client.indices.flush
      visit jobs_path

      within '.filters-form' do
        fill_in 'subject', with: 'Physics'
        page.find('.govuk-button[type=submit]').click
      end

      expect(page).to have_content(I18n.t('jobs.filters.clear_filters'))

      select I18n.t('jobs.sort_by_earliest_closing_date')
      click_button I18n.t('jobs.sort_submit')

      expect(page).to have_content(I18n.t('jobs.filters.clear_filters'))
    end

    it 'hiring staff can reset search after adding any filter params to the url' do
      create(:vacancy, :published, job_title: 'Physics Teacher')
      Vacancy.__elasticsearch__.client.indices.flush

      visit jobs_path(subject: 'Other')

      expect(page).to have_content(I18n.t('jobs.filters.clear_filters'))
    end
  end
end
