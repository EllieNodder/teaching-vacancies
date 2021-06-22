class AddClosedAccountToJobseekers < ActiveRecord::Migration[6.1]
  def change
    add_column :jobseekers, :closed_account, :boolean, null: false, default: false
  end
end
