class AddStartPointToWorkflowSteps < ActiveRecord::Migration[5.1]
  def change
    change_table :workflow_steps do |t|
      t.boolean :start_step, default: false
      t.boolean :end_step, default: false
    end
  end
end
