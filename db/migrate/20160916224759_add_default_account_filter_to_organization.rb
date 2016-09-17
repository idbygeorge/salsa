class AddDefaultAccountFilterToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :default_account_filter, :json
  end
end
