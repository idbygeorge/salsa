class AddUsersAndOrganizationAssignments < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name

      t.timestamps
    end

    create_table :user_assignments do |t|
      t.belongs_to :user
      t.belongs_to :organization
      t.string :username
      t.boolean :cascades
      t.string :role
    end

    add_index :user_assignments, [:username, :organization_id], unique: true
  end
end
