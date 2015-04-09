class AddLmsIdToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :lms_id, :string
    add_index :organizations, :lms_id
  end
end
