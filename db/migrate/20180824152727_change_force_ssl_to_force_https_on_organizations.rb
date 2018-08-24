class ChangeForceSslToForceHttpsOnOrganizations < ActiveRecord::Migration[5.1]
  def change
    remove_column :organizations, :force_ssl, :boolean, default: false
    add_column :organizations, :force_https, :boolean, default: false
  end
end
