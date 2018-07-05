class AddDashboardStartAtAndEndAtToOrganization < ActiveRecord::Migration[4.2]
  def change
    add_column :organizations, :dashboard_start_at, :datetime
    add_column :organizations, :dashboard_end_at, :datetime
  end
end
