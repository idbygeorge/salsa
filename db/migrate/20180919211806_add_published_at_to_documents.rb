class AddPublishedAtToDocuments < ActiveRecord::Migration[5.1]
  def change
    add_column :documents, :published_at, :datetime
  end
end
