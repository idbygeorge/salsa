class AddLmsTokensToOrganization < ActiveRecord::Migration[4.2]
  def change
  	add_column :organizations, :lms_authentication_source, :string
  	add_column :organizations, :lms_authentication_id, :string
  	add_column :organizations, :lms_authentication_key, :string
  end
end
