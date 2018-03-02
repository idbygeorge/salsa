class CreateFailedJobsFromQueJobs < ActiveRecord::Migration[5.1]
  def change
    create_table "failed_jobs", id: false, force: :cascade do |t|
      t.integer :priority
      t.datetime :run_at
      t.bigint :job_id
      t.text :job_class
      t.json :args
      t.integer :error_count
      t.text :last_error
      t.text :queue
    end
  end
end
