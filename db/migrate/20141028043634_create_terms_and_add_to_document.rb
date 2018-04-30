class CreateTermsAndAddToDocument < ActiveRecord::Migration[4.2]
  def change
    create_table :terms do |t|
      t.string :slug
      t.string :name
      t.integer :organization_id
      t.datetime :start_date
      t.integer :duration
      t.string :cycle
      t.integer :sequence
      t.boolean :is_default
      t.timestamps
    end

    add_index :terms, [:slug, :organization_id], unique: true

    add_column :documents, :term_id, :string
    add_index :documents, :term_id
  end
end
