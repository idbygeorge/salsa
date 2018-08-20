class AddPeriodIdToDocument < ActiveRecord::Migration[5.1]
  def change
    change_table :documents do |t|
      t.integer :period_id
    end
  end
end
