class AddRoleOrganizationLevelToComponents < ActiveRecord::Migration[5.1]
  def change
    change_table :components do |t|
      t.integer :role_organization_id
    end
  end
end
