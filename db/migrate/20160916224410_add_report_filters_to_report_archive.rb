class AddReportFiltersToReportArchive < ActiveRecord::Migration
  def change
    add_column :report_archives, :report_filters, :json
  end
end
