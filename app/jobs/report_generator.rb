require "#{Rails.root}/lib/skip_retries"
class ReportGenerator < Que::Job
  prepend SkipRetries
  # Default settings for this job. These are optional - without them, jobs
  # will default to priority 100 and run immediately.
  # @priority = 10
  # @run_at = proc { 1.minute.from_now }

  def run(org_id, account_filter, params, report)
    org = Organization.find org_id
    Que.mode = :async
    ReportHelper.generate_report org.slug, account_filter, params, report
  end
end
