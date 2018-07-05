class CreateSyllabuses < ActiveRecord::Migration[4.2]
  def change
    create_table :syllabuses do |t|
    	t.string :name
      t.string :edit_id
      t.string :view_id
      t.text :payload
      t.timestamps
    end
  end
end
