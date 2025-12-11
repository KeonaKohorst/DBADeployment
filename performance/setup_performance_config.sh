#!/bin/bash
# ================================================================================================================
# Filename: /opt/dba_deployment/performance/setup_performance.config.sh
# Author(s): Alex Anthony
# Date created: 2025-11-26
# Date Last Modified: 2025-12-11
# Use of AI: Gemini AI was used to troubleshoot and improve the script. All AI suggestions were verified and
# 	     tested before use.
# ================================================================================================================
# Copyright: (c) Keona Gagnier
# This software is licensed under the MIT license, located in the root directory of this project
# ================================================================================================================
# Description:
# Called by deploy.sh. Changes default AWR 7-day retention to 14 days. Turns on Automatic SQL Tuning Advisor to
# run daily. Deploys monitoring suite (global temporary table, grants, scheduler jobs).

#
SYS_PASS="$1"
[ -z "$SYS_PASS" ] && { echo "ERROR: SYS password required"; exit 1; }

echo "=== Applying performance & monitoring suite ==="

# Oracle environment
export ORACLE_HOME=/u01/app/oracle/product/19.0.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH

SQLPLUS="$ORACLE_HOME/bin/sqlplus"

# 1. AWR + SQL Tuning Advisor
$SQLPLUS -s sys/"$SYS_PASS"@//localhost:1521/orclpdb.localdomain as sysdba <<'SQL'
WHENEVER SQLERROR EXIT FAILURE
ALTER SESSION SET CONTAINER = ORCLPDB;
EXEC DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS(retention => 20160, interval => 60);
BEGIN DBMS_AUTO_TASK_ADMIN.ENABLE('sql tuning advisor', NULL, NULL); END;
/
SQL

# 2. Create table
sudo -u oracle "$SQLPLUS -s monitoring/pass@ORCLPDB @/opt/dba_deployment/performance/create_top_sql_log.sql" || true

# 3. Grants
sudo -u oracle "$SQLPLUS -s sys/$SYS_PASS@ORCLPDB as sysdba @/opt/dba_deployment/performance/grants_monitoring.sql"

# 4. Jobs
sudo -u oracle "$SQLPLUS -s monitoring/pass@ORCLPDB @/opt/dba_deployment/performance/create_mon_jobs_safe.sql"

echo "=== Performance suite deployed successfully ==="
