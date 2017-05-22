class AddRepublishedAtToOrganizationsTable < ActiveRecord::Migration[5.0]
  def change
      add_column :organizations, :republished_at, :datetime, null: true
  end
end
