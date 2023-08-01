class ChangeSavedJobsVacancyIdNullConstraint < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    add_not_null_constraint :saved_jobs, :vacancy_id, name: "saved_jobs_vacancy_id_null", validate: false
    validate_not_null_constraint :saved_jobs, :vacancy_id, name: "saved_jobs_vacancy_id_null"

    change_column_null :saved_jobs, :vacancy_id, false
    remove_check_constraint :saved_jobs, name: "saved_jobs_vacancy_id_null"
  end

  def down
    change_column_null :saved_jobs, :vacancy_id, true
  end
end

