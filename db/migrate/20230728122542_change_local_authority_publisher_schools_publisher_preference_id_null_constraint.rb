class ChangeLocalAuthorityPublisherSchoolsPublisherPreferenceIdNullConstraint < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    add_not_null_constraint :local_authority_publisher_schools, :publisher_preference_id, name: "local_authority_publisher_schools_publisher_preference_id_null", validate: false
    validate_not_null_constraint :local_authority_publisher_schools, :publisher_preference_id, name: "local_authority_publisher_schools_publisher_preference_id_null"

    change_column_null :local_authority_publisher_schools, :publisher_preference_id, false
    remove_check_constraint :local_authority_publisher_schools, name: "local_authority_publisher_schools_publisher_preference_id_null"
  end

  def down
    change_column_null :local_authority_publisher_schools, :publisher_preference_id, true
  end
end
