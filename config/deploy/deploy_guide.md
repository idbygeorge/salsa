## before each deploy or server update you should run these commands

### stoping the que(from the server)

  run

    sudo service cron stop  

  then kill the que

    ps aux | grep que  

  the with the pids from that

    kill <pids>

 check to see if the que stoped `ps aux | grep que` if the que is still running wait for the que job to finish or add `-9` to the kill command to force kill the que

 run `psql` on the server then run these queries

    SELECT                          
      pid,
      now() - pg_stat_activity.query_start AS duration,
      query,
      state
    FROM pg_stat_activity
    WHERE (now() - pg_stat_activity.query_start) > interval '5 minutes';

    SELECT pg_cancel_backend(<pid(s) from above query>);

    truncate que_jobs;
    truncate failed_jobs;

## Deploying

    cap <deploy-server-name> deploy

### after deploying

    sudo service cron start
