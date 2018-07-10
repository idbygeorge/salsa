class AddDefaultWorkflowStepToOrganization < ActiveRecord::Migration[5.1]
  def change
    change_table :organizations do |t|
      t.integer :default_workflow_step_id
    end
  end
end
