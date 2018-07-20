class AddEnableWorkflowsToOrganization < ActiveRecord::Migration[5.1]
  def change
    change_table :organizations do |t|
      t.boolean :enable_workflows
      t.boolean :inherit_workflows_from_parents
    end
  end
end
