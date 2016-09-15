namespace :report do
  desc "generate default report (must provide an organization id, and an account filter)"
  task :generate_report, [:org_id, :account_filter] => :environment do |t, args|
    org_id = args[:org_id]
    account_filter = args[:account_filter]
    #hardcoded to match params passed when user generates default report.
    #Done so that users can regenerate automated default report

    run_report org_id, account_filter
  end

  def run_report org_id, account_filter
    params = {
      "rebuild" => "true",
      "controller" => "admin",
      "action" => "canvas"
    }

    jobs = Que.execute("select run_at, job_id, error_count, last_error, queue, args from que_jobs where job_class = 'ReportGenerator'")
    arguments = [ org_id, account_filter, params ]
    jobs.each do |job|
      if job['args'] == arguments
        return
      end
    end

    ReportHelper.generate_report_as_job org_id, account_filter, params
  end

end
