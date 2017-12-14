class AddTemplateToSyllabus < ActiveRecord::Migration[4.2]
  def change
    add_column :syllabuses, :template_id, :string
  end
end
