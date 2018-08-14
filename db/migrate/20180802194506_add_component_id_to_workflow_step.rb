class AddComponentIdToWorkflowStep < ActiveRecord::Migration[5.1]
  def change
    change_table :workflow_steps do |t|
      t.integer :component_id
    end
  end
end
