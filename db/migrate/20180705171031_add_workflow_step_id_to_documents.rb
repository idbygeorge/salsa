class AddWorkflowStepIdToDocuments < ActiveRecord::Migration[5.1]
  def change
    change_table :documents do |t|
      t.integer :workflow_step_id
    end
  end
end
