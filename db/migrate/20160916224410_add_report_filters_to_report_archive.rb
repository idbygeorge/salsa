class AddReportFiltersToReportArchive < ActiveRecord::Migration
  def change
    change_table :report_archives do |t|
      t.column :report_filters, :json
    end
  end
end
