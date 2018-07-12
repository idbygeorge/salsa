class AddRoleToComponents < ActiveRecord::Migration[5.1]
  def change
    change_table :components do |t|
      t.string :role 
    end
  end
end
