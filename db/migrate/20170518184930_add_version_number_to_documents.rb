class AddVersionNumberToDocuments < ActiveRecord::Migration[5.0]
  def change
    add_column :documents, :version, :integer
  end
end
