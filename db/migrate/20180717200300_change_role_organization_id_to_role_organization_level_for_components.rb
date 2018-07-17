class ChangeRoleOrganizationIdToRoleOrganizationLevelForComponents < ActiveRecord::Migration[5.1]
  def change
    remove_column :components, :role_organization_id, :integer
    add_column :components, :role_organization_level, :integer
  end
end
