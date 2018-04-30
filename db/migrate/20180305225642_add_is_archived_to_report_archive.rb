class AddIsArchivedToReportArchive < ActiveRecord::Migration[5.1]
  def change
    change_table :report_archives do |t|
      t.boolean :is_archived, default: false
    end
  end
end
