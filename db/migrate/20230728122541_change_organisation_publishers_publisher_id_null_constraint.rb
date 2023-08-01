class ChangeOrganisationPublishersPublisherIdNullConstraint < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    add_not_null_constraint :organisation_publishers, :publisher_id, name: "organisation_publishers_publisher_id_null", validate: false
    validate_not_null_constraint :organisation_publishers, :publisher_id, name: "organisation_publishers_publisher_id_null"

    change_column_null :organisation_publishers, :publisher_id, false
    remove_check_constraint :organisation_publishers, name: "organisation_publishers_publisher_id_null"
  end

  def down
    change_column_null :organisation_publishers, :publisher_id, true
  end
end
