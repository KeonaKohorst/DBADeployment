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

# Check if the SYS password was passed as an argument ($1)
if [ -z "$SYS_PASS" ]; then
    echo "NOTICE: SYS password not provided as argument. Prompting securely."
    
    # Prompt the user for the password securely
    echo -n "Please enter the SYS password: "
    read -r -s SYS_PASS # -s hides the input, -r prevents backslash escaping
    echo # Newline after hidden input
    
    # Check if the user entered an empty password after the prompt
    [ -z "$SYS_PASS" ] && { echo "ERROR: SYS password required. Aborting."; exit 1; }
fi

echo "=== Applying performance & monitoring suite ==="

# Oracle environment
export ORACLE_HOME=/u01/app/oracle/product/19.0.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH

SQLPLUS="$ORACLE_HOME/bin/sqlplus"

# --- 1. AWR + SQL Tuning Advisor ---
echo "--- 1. Configuring AWR Snapshot Settings and STA ---"
$SQLPLUS -s sys/"$SYS_PASS"@//localhost:1521/orclpdb.localdomain as sysdba <<'SQL'
WHENEVER SQLERROR EXIT FAILURE
ALTER SESSION SET CONTAINER = ORCLPDB;
EXEC DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS(retention => 20160, interval => 60);
BEGIN DBMS_AUTO_TASK_ADMIN.ENABLE('sql tuning advisor', NULL, NULL); END;
/
SQL
check_error "AWR/STA configuration"

# --- 2. Create table ---
echo "--- 2. Creating Top SQL Log Table as oracle user ---"
#sudo -u oracle "$SQLPLUS" -s monitoring/pass@ORCLPDB @/opt/dba_deployment/performance/create_top_sql_log.sql || true

SQL_COMMAND_2="$SQLPLUS -s monitoring/pass@ORCLPDB @/opt/dba_deployment/performance/create_top_sql_log.sql"
su - oracle -c "$SQL_COMMAND_2" || true

check_error "Top SQL Log Table Creation"

# --- 3. Grants ---
echo "--- 3. Applying Monitoring Grants as oracle user ---"
#sudo -u oracle "$SQLPLUS" -s sys/"$SYS_PASS"@ORCLPDB as sysdba @/opt/dba_deployment/performance/grants_monitoring.sql

SQL_COMMAND_3="$SQLPLUS -s sys/$SYS_PASS@ORCLPDB as sysdba @/opt/dba_deployment/performance/grants_monitoring.sql"
su - oracle -c "$SQL_COMMAND_3"

check_error "Grants application"

# --- 4. Jobs ---
echo "--- 4. Creating Monitoring Jobs as oracle user ---"
#sudo -u oracle "$SQLPLUS" -s monitoring/pass@ORCLPDB @/opt/dba_deployment/performance/create_mon_jobs_safe.sql

SQL_COMMAND_4="$SQLPLUS -s monitoring/pass@ORCLPDB @/opt/dba_deployment/performance/create_mon_jobs_safe.sql"
su - oracle -c "$SQL_COMMAND_4"

check_error "Job creation"

# If the script reaches this point, all steps were successful (or errors were intentionally ignored)
echo "=== Performance suite deployed successfully ==="
