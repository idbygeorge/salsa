class AddLmsIdToOrganization < ActiveRecord::Migration[4.2]
  def change
    add_column :organizations, :lms_id, :string
    add_index :organizations, :lms_id
  end
end
