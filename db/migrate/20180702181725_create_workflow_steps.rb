class CreateWorkflowSteps < ActiveRecord::Migration[5.1]
  def change
    create_table :workflow_steps do |t|
      t.string :name
      t.string :slug
      t.integer :organization_id
      t.integer :next_workflow_step_id
      t.timestamps
    end
  end
end
