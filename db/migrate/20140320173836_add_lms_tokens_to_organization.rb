class AddLmsTokensToOrganization < ActiveRecord::Migration
  def change
  	add_column :organizations, :lms_authentication_source, :string
  	add_column :organizations, :lms_authentication_id, :string
  	add_column :organizations, :lms_authentication_key, :string
  end
end
