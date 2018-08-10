class ChangeStartStepAndEndStepToStepTypesOnWorkflowSteps < ActiveRecord::Migration[5.1]
  def change
    remove_column :workflow_steps, :start_step, :boolean
    remove_column :workflow_steps, :end_step, :boolean
    change_table :workflow_steps do |t|
      t.string :step_type, default: "default_step"
    end
  end
end
