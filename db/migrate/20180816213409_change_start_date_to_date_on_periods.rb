class ChangeStartDateToDateOnPeriods < ActiveRecord::Migration[5.1]
  def change
    remove_column :periods, :start_date, :datetime
    change_table :periods do |t|
      t.date :start_date
    end
  end
end
