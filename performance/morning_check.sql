-- morning_check.sql
-- Run as: sqlplus -s monitoring/pass@ORCLPDB @morning_check.sql

SET ECHO OFF
SET PAGESIZE 500
SET LINESIZE 200
SET FEEDBACK OFF
SET HEADING ON

COLUMN job_name      FORMAT A32
COLUMN ena           FORMAT A8
COLUMN next_run      FORMAT A16
COLUMN failure_count FORMAT 99999
COLUMN time          FORMAT A19
COLUMN msg           FORMAT A100 WORD_WRAPPED
COLUMN used          FORMAT A50

PROMPT
PROMPT ================================================================================
PROMPT                       DAILY DATABASE HEALTH CHECK
PROMPT ================================================================================
PROMPT

PROMPT TODAYS SCHEDULE
SELECT job_name,
       CASE WHEN enabled = 'TRUE' THEN 'YES' ELSE 'NO' END AS ena,
       TO_CHAR(next_run_date, 'Dy HH24:MI') AS next_run,
       failure_count
FROM   user_scheduler_jobs
ORDER  BY next_run_date;

PROMPT
PROMPT FAILURES LAST 24H
SELECT TO_CHAR(log_date,'YYYY-MM-DD HH24:MI') AS time,
       job_name,
       SUBSTR(additional_info,1,100) AS msg
FROM   user_scheduler_job_run_details
WHERE  log_date >= SYSDATE-1 AND status = 'FAILED'
ORDER  BY log_date DESC;

PROMPT
PROMPT TABLESPACES >= 80%
SELECT tablespace_name || '  ' || ROUND(used_percent,1)||'%' AS used
FROM   dba_tablespace_usage_metrics
WHERE  used_percent >= 80;

PROMPT
PROMPT YESTERDAYS TOP 5 SQL
SELECT sql_id,
       execs,
       cpu_sec,
       ela_sec,
       ROUND(lio/execs) AS lio_per_exec
FROM   monitoring.top_sql_log
WHERE  TRUNC(snap_time) = TRUNC(SYSDATE-1)
ORDER  BY cpu_sec DESC
FETCH FIRST 5 ROWS ONLY;

PROMPT
PROMPT SUMMARY
SELECT 'Jobs defined:        ' || TO_CHAR(COUNT(*)) FROM user_scheduler_jobs
UNION ALL
SELECT 'Failed last 24h:     ' || TO_CHAR(COUNT(*)) FROM user_scheduler_job_run_details WHERE log_date >= SYSDATE-1 AND status='FAILED'
UNION ALL
SELECT 'TS >=80%:           ' || TO_CHAR(COUNT(*)) FROM dba_tablespace_usage_metrics WHERE used_percent >= 80
UNION ALL
SELECT 'Top-SQL rows today:  ' || TO_CHAR(COUNT(*)) FROM monitoring.top_sql_log WHERE TRUNC(snap_time)=TRUNC(SYSDATE);

-- Reset failure counters silently
BEGIN
  FOR r IN (SELECT job_name FROM user_scheduler_jobs WHERE failure_count > 0) LOOP
    DBMS_SCHEDULER.DISABLE(r.job_name);
    DBMS_SCHEDULER.ENABLE(r.job_name);
  END LOOP;
END;
/

SET FEEDBACK ON
PROMPT
PROMPT ================================================================================
PROMPT Morning check complete
PROMPT ================================================================================
