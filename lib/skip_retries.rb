module SkipRetries
  def run(*args)
    super
  rescue
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

    Que.execute sql, @attrs.values_at(:queue, :priority, :run_at, :job_id)

    raise # Reraises caught error.
  end
end
