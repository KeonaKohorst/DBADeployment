-- create_mon_jobs_safe.sql

BEGIN
  FOR j IN (SELECT job_name FROM user_scheduler_jobs WHERE job_name LIKE 'MON_%') LOOP
    DBMS_SCHEDULER.DROP_JOB(j.job_name, force => TRUE);
  END LOOP;
END;
/

-- MON_INVALID_FIX
EXEC DBMS_SCHEDULER.CREATE_JOB('MON_INVALID_FIX', job_type=>'PLSQL_BLOCK', job_action=>'BEGIN FOR i IN (SELECT index_name FROM user_indexes WHERE status=''UNUSABLE'') LOOP EXECUTE IMMEDIATE ''ALTER INDEX ''||i.index_name||'' REBUILD ONLINE''; END LOOP; END;', repeat_interval=>'FREQ=DAILY; BYHOUR=2', enabled=>TRUE, comments=>'Daily fix of unusable indexes');

-- MON_KILL_HOGS
BEGIN
  DBMS_SCHEDULER.CREATE_JOB(
    job_name => 'MON_KILL_HOGS',
    job_type => 'PLSQL_BLOCK',
    job_action => q'[BEGIN FOR r IN (SELECT sid, serial# FROM v$session WHERE username=USER AND ((status='INACTIVE' AND last_call_et>28800) OR (status='ACTIVE' AND last_call_et>7200)) AND type='USER') LOOP EXECUTE IMMEDIATE 'ALTER SYSTEM KILL SESSION '''||r.sid||','||r.serial#||''' IMMEDIATE'; END LOOP; END;]',
    repeat_interval => 'FREQ=DAILY; BYHOUR=1',
    enabled => TRUE,
    comments => 'Kill own zombie sessions'
  );
END;
/

-- MON_GATHER_STATS
EXEC DBMS_SCHEDULER.CREATE_JOB('MON_GATHER_STATS', job_type=>'PLSQL_BLOCK', job_action=>q'[BEGIN DBMS_STATS.GATHER_SCHEMA_STATS(ownname=>USER, estimate_percent=>DBMS_STATS.AUTO_SAMPLE_SIZE, cascade=>TRUE, degree=>4, options=>'GATHER AUTO'); END;]', repeat_interval=>'FREQ=WEEKLY; BYDAY=SAT; BYHOUR=3', enabled=>TRUE, comments=>'Weekly stats');

-- MON_TS_ALERT
BEGIN
  DBMS_SCHEDULER.CREATE_JOB(
    job_name => 'MON_TS_ALERT',
    job_type => 'PLSQL_BLOCK',
    job_action => q'[DECLARE v VARCHAR2(1000); BEGIN SELECT LISTAGG(tablespace_name||' '||ROUND(used_percent,1)||'%',', ') INTO v FROM dba_tablespace_usage_metrics WHERE used_percent>=85; IF v IS NOT NULL THEN RAISE_APPLICATION_ERROR(-20001,''TS Alert: ''||v); END IF; END;]',
    repeat_interval => 'FREQ=DAILY; BYHOUR=7',
    enabled => TRUE,
    comments => 'Tablespace >=85% alert'
  );
END;
/

-- MON_TOP_SQL
BEGIN
  DBMS_SCHEDULER.CREATE_JOB(
    job_name => 'MON_TOP_SQL',
    job_type => 'PLSQL_BLOCK',
    job_action => q'[BEGIN EXECUTE IMMEDIATE 'TRUNCATE TABLE monitoring.top_sql_log'; INSERT INTO monitoring.top_sql_log(sql_id,plan_hash,execs,disk_reads,lio,cpu_sec,ela_sec) SELECT sql_id,plan_hash_value,executions,disk_reads,buffer_gets,ROUND(cpu_time/1000000,2),ROUND(elapsed_time/1000000,2) FROM v$sql WHERE parsing_schema_name=USER AND executions>0 AND ROWNUM<=20 ORDER BY cpu_time DESC; COMMIT; END;]',
    repeat_interval => 'FREQ=DAILY; BYHOUR=23',
    enabled => TRUE,
    comments => 'Nightly top-20 SQL snapshot'
  );
END;
/
