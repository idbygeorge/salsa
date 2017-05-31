class AddRepublishedAtToOrganizationsTable < ActiveRecord::Migration[5.0]
  def change
      add_column :organizations, :republish_at, :datetime, :null => true
  end
end
