class AddOrganizationMeta < ActiveRecord::Migration
  def change
  	create_table :organization_meta do |t|
  		t.integer :organization_id
  		t.string :key
  		t.string :value
  		t.integer :lms_organization_id
  		t.integer :root_id
	   end
  end
end
