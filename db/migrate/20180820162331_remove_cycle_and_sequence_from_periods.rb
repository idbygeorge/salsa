class RemoveCycleAndSequenceFromPeriods < ActiveRecord::Migration[5.1]
  def change
    remove_column :periods, :sequence, :integer
    remove_column :periods, :cycle, :string
  end
end
