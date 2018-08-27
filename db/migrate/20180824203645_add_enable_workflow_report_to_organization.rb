class AddEnableWorkflowReportToOrganization < ActiveRecord::Migration[5.1]
  def change
    add_column :organizations, :enable_workflow_report, :boolean, default: false 
  end
end
