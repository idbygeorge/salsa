class AddReportFiltersToReportArchive < ActiveRecord::Migration[4.2]
  def change
    change_table :report_archives do |t|
      t.column :report_filters, :json
    end
  end
end
