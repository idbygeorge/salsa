class CreateFailedJobsFromQueJobs < ActiveRecord::Migration[5.1]
  def change
    execute "CREATE TABLE failed_jobs AS SELECT * FROM que_jobs LIMIT 0"
  end
end
