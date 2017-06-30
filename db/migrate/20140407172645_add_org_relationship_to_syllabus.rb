class AddOrgRelationshipToSyllabus < ActiveRecord::Migration[4.2]
  def change
    add_column :syllabuses, :organization_id, :integer
    add_index :syllabuses, :organization_id
  end
end
