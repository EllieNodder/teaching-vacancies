class ChangePublisherPreferencesPublisherIdNullConstraint < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    add_not_null_constraint :publisher_preferences, :publisher_id, name: "publisher_preferences_publisher_id_null", validate: false
    validate_not_null_constraint :publisher_preferences, :publisher_id, name: "publisher_preferences_publisher_id_null"

    change_column_null :publisher_preferences, :publisher_id, false
    remove_check_constraint :publisher_preferences, name: "publisher_preferences_publisher_id_null"
  end

  def down
    change_column_null :publisher_preferences, :publisher_id, true
  end
end
