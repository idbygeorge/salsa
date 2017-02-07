class AddDefaultAccountFilterToOrganization < ActiveRecord::Migration
  def change
    change_table :organizations do |t|
      t.column :default_account_filter, :json
    end
  end
end
