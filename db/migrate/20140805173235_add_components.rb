class AddComponents < ActiveRecord::Migration
  def change
    create_table :components do |t|
      t.string :name
      t.string :slug
      t.text :description
      t.string :category

      t.belongs_to :organization
      
      t.text :css
      t.text :js
      t.text :layout
      t.text :format

      t.text :gui_css
      t.text :gui_js
      t.text :gui_templates
      t.text :gui_controls
      t.text :gui_section_nav

      t.text :gui_help
      t.text :gui_example
      t.text :gui_footer
      t.text :gui_content_toolbar
      t.text :gui_header
 
      t.timestamps
    end

    add_index :components, [:slug, :organization_id], unique: true
    add_index :components, :category
    add_index :components, :organization_id

    add_column :documents, :component_id, :integer
    add_index :documents, :component_id

    add_column :documents, :component_version, :integer
  end
end
