class CreateTemplates < ActiveRecord::Migration
  def change
    create_table :templates do |t|
      t.string :slug
      t.text :payload
      t.integer :organization_id
      t.timestamps
    end

    add_index :templates, [:slug, :organization_id], unique: true
  end
end
