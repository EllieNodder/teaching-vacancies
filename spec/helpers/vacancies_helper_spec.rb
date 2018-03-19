require 'rails_helper'

RSpec.describe VacanciesHelper, type: :helper do
  describe '#salary_options' do
    it 'returns a hash of salary options' do
      expect(helper.salary_options).to eq('£20,000' => 20000,
                                          '£30,000' => 30000,
                                          '£40,000' => 40000,
                                          '£50,000' => 50000,
                                          '£60,000' => 60000,
                                          '£70,000' => 70000)
    end
  end

  describe '#working_pattern_options' do
    it 'returns an array of vacancy working patterns' do
      expect(helper.working_pattern_options).to eq([['Full time', 'full_time'], ['Part time', 'part_time']])
    end
  end

  describe '#school_phase_options' do
    it 'returns an array of school phase patterns' do
      expect(helper.school_phase_options).to eq(
        [
          ['Not applicable', 'not_applicable'],
          ['Nursery', 'nursery'],
          ['Primary', 'primary'],
          ['Middle deemed primary', 'middle_deemed_primary'],
          ['Secondary', 'secondary'],
          ['Middle deemed secondary', 'middle_deemed_secondary'],
          ['Sixteen plus', 'sixteen_plus'],
          ['All through', 'all_through']
        ]
      )
    end
  end

  describe '#link_to_sort_by' do
    it 'should return a link to the vacancies index with the new parameters' do
      sort = OpenStruct.new(column: 'maximum_salary')
      result = helper.link_to_sort_by('foo', column: 'starts_on', order: 'asc', sort: sort)
      expect(result).to eq('<a class="sortby--asc" href="/vacancies?sort_column=starts_on&amp;sort_order=asc">foo</a>')
    end

    context 'when the current sort column is the same as the given column' do
      it 'should output an active class and the reverse order of the sort object' do
        sort = OpenStruct.new(column: 'starts_on', reverse_order: 'desc')
        result = helper.link_to_sort_by('foo', column: 'starts_on', order: 'asc', sort: sort)
        expect(result)
          .to eq('<a class="sortby--desc active" href="/vacancies?sort_column=starts_on&amp;sort_order=desc">foo</a>')
      end
    end
  end

  describe '#pluralize_vacancy_count' do
    context 'when the count is 1' do
      it 'returns a singular count message' do
        result = helper.pluralize_vacancy_count(1, 'vacancies.vacancy_count')
        expect(result).to eql('There is 1 vacancy that matches your search.')
      end
    end

    context 'when the count is 0' do
      it 'returns an empty count message' do
        result = helper.pluralize_vacancy_count(0, 'vacancies.vacancy_count')
        expect(result).to eql('There are 0 vacancies that match your search.')
      end
    end

    context 'when the count is larger than 1' do
      it 'returns a plural count message' do
        result = helper.pluralize_vacancy_count(2, 'vacancies.vacancy_count')
        expect(result).to eql('There are 2 vacancies that match your search.')
      end
    end
  end
end
