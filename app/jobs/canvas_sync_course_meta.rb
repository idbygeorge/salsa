
class CanvasSyncCourseMeta < Que::Job
  # Default settings for this job. These are optional - without them, jobs
  # will default to priority 100 and run immediately.
  # @priority = 10
  # @run_at = proc { 1.minute.from_now }

  def run(org_slug, canvas_token)
    ActiveRecord::Base.transaction do

      CanvasHelper.courses_sync org_slug, canvas_token

      destroy
    end
  end
end
