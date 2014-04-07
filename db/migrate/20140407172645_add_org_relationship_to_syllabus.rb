class AddOrgRelationshipToSyllabus < ActiveRecord::Migration
  def change
    add_column :syllabuses, :organization_id, :integer
    add_index :syllabuses, :organization_id
  end
end
