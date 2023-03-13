class JobPreferences < ApplicationRecord
  class JobScope
    def initialize(scope, job_preferences)
      @scope = scope
      @job_preferences = job_preferences
    end

    def call
      scope
        .where(job_role: job_preferences.roles)
        .where("phases <@ ARRAY[?]::int[]", Vacancy.phases.values_at(*job_preferences.phases))
        .then(&method(:apply_key_stages))
        .then(&method(:apply_subjects))
        .where("working_patterns && ARRAY[?]::int[]", Vacancy.working_patterns.values_at(*job_preferences.working_patterns))

    end

    private

    attr_reader :scope, :job_preferences

    def apply_key_stages(scope)
      scope.where(key_stages: nil).or(
        scope.where("key_stages <@ ARRAY[?]::integer[]", Vacancy.key_stages.values_at(*job_preferences.key_stages))
      )
    end

    def apply_subjects(scope)
      return scope unless job_preferences.subjects.any?

      scope.where("subjects && ARRAY[?]::varchar[]", job_preferences.subjects).or(
        scope.where(subjects: [])
      )
    end
  end
end
