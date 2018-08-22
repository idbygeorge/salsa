class AddForceHttpsSettingToOrganization < ActiveRecord::Migration[5.1]
  def change
    add_column :organizations, :force_https, :boolean, default: false
  end
end
