class RemoveUniqueConstraintOnUserAssignments < ActiveRecord::Migration[4.2]
  def change
    remove_index :user_assignments, :column => [:username, :organization_id]
  end
end
