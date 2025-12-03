#!/bin/bash
# setup_performance_config.sh - called by deploy.sh
SYS_PASS="$1"
[ -z "$SYS_PASS" ] && { echo "ERROR: SYS password required"; exit 1; }

echo "=== Applying performance & monitoring suite ==="

# 1. Oracle built-in tuning (AWR + SQL Tuning Advisor)
sqlplus -s sys/"$SYS_PASS"@//localhost:1521/ORCLPDB as sysdba <<SQL
WHENEVER SQLERROR EXIT FAILURE
ALTER SESSION SET CONTAINER = ORCLPDB;
EXEC DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS(retention => 20160, interval => 60);
BEGIN DBMS_AUTO_TASK_ADMIN.ENABLE('sql tuning advisor', NULL, NULL); END;
/
SQL

# 2. Create the log table
su - oracle -c "sqlplus monitoring/pass@ORCLPDB @/opt/dba_deployment/performance/create_top_sql_log.sql" || true

# 3. Apply grants to monitoring
su - oracle -c "sqlplus sys/$SYS_PASS@ORCLPDB as sysdba @/opt/dba_deployment/performance/grants_monitoring.sql"

# 4. Create all 5 MON_* jobs
su - oracle -c "sqlplus monitoring/pass@ORCLPDB @/opt/dba_deployment/performance/create_mon_jobs_safe.sql"

echo "=== Performance suite deployed successfully ==="
