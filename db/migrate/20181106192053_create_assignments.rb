class CreateAssignments < ActiveRecord::Migration[5.1]
  def change
    create_table :assignments do |t|
      t.belongs_to :user
      t.belongs_to :team_member
      t.boolean :cascades
      t.string :role
    end
  end
end
