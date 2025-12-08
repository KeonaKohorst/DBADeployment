-- create_top_sql_log.sql
CREATE GLOBAL TEMPORARY TABLE monitoring.top_sql_log (
  snap_time DATE DEFAULT SYSDATE,
  sql_id    VARCHAR2(13),
  plan_hash NUMBER,
  execs     NUMBER,
  disk_reads NUMBER,
  lio       NUMBER,
  cpu_sec   NUMBER,
  ela_sec   NUMBER
) ON COMMIT PRESERVE ROWS;
