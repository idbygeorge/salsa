class RemoveUniqueConstraintOnUserAssignments < ActiveRecord::Migration
  def change
    remove_index :user_assignments, :column => [:username, :organization_id]
  end
end
