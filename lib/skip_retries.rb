module SkipRetries
  def run(*args)
    super
  rescue => error
    sql = <<-SQL
      WITH failed AS (
        DELETE
        FROM   que_jobs
        WHERE  queue    = $1::text
        AND    priority = $2::smallint
        AND    run_at   = $3::timestamptz
        AND    job_id   = $4::bigint
        RETURNING *
      )
      INSERT INTO failed_jobs
        SELECT * FROM failed;
    SQL
    update_sql = <<-SQL
      UPDATE failed_jobs
        SET last_error = $1::text
        WHERE job_id = $2::bigint
    SQL
    
    @attrs[:last_error] = "#{error}"
    Que.execute sql, @attrs.values_at(:queue, :priority, :run_at, :job_id)
    Que.execute update_sql, @attrs.values_at(:last_error, :job_id)
    print error
  end
end
