class AddReportArchives < ActiveRecord::Migration[4.2]
  def change
    create_table :report_archives do |t|
      t.text :payload
      t.datetime :generating_at
      t.integer :organization_id
      t.timestamps
     end

     add_index :report_archives, :organization_id
  end
end
