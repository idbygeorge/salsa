class CreateSyllabuses < ActiveRecord::Migration
  def change
    create_table :syllabuses do |t|
      t.text :payload

      t.timestamps
    end
  end
end
