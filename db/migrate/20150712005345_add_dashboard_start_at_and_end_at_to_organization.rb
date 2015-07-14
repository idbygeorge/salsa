class AddDashboardStartAtAndEndAtToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :dashboard_start_at, :datetime
    add_column :organizations, :dashboard_end_at, :datetime
  end
end
