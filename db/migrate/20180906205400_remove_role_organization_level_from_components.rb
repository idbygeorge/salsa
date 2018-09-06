class RemoveRoleOrganizationLevelFromComponents < ActiveRecord::Migration[5.1]
  def change
    remove_column :components, :role_organization_level, :integer
  end
end
