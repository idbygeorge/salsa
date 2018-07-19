class AddUserIdToDocument < ActiveRecord::Migration[5.1]
  def change
    change_table :documents do |t|
      t.integer :user_id
    end
  end
end
