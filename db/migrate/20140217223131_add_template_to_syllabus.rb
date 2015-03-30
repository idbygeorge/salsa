class AddTemplateToSyllabus < ActiveRecord::Migration
  def change
    add_column :syllabuses, :template_id, :string
  end
end
