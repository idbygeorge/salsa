class AddDocumentMeta < ActiveRecord::Migration[4.2]
  def change
  	create_table :document_meta do |t|
  		t.integer :document_id
  		t.string :key
  		t.string :value
  		t.integer :lms_organization_id
  		t.integer :lms_course_id
  		t.integer :root_organization_id
	   end
  end
end
