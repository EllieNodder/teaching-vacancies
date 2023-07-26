class AddOrganisationsIdLocalAuthorityPublisherSchoolsSchoolIdFk < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_foreign_key :local_authority_publisher_schools, :organisations, column: :school_id, primary_key: :id, validate: false
    validate_foreign_key :local_authority_publisher_schools, :organisations
  end
end
