class JobPreferences < ApplicationRecord
  belongs_to :jobseeker_profile
  has_many :locations, dependent: :destroy

  def vacancies(scope = Vacancy.all)
    JobScope.new(scope, self).call
  end
end
