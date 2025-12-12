-- Filename: /opt/dba_deployment/performance/grants_monitoring.sql
-- Author(s): Alex Anthony
-- Date created: 2025-11-26
-- Date Last Modified: 2025-12-11

-- Copyright: (c) Keona Gagnier
-- This software is licensed under the MIT license, located in the root directory of this project

-- Description:
-- Grants privileges required for the MONITORING user to query performance views.

GRANT CREATE SESSION TO monitoring;
GRANT CREATE TABLE TO monitoring;
GRANT CREATE JOB TO monitoring;
GRANT CREATE EXTERNAL JOB TO monitoring;

GRANT SELECT ON STOCK_USER.STOCKS                    TO monitoring;
GRANT SELECT ON SYS.DBA_TABLESPACE_USAGE_METRICS     TO monitoring;
GRANT SELECT ON SYS.V_$SESSION                       TO monitoring;
GRANT SELECT ON SYS.V_$SESSTAT                       TO monitoring;
GRANT SELECT ON SYS.V_$SQL                           TO monitoring;
GRANT SELECT ON SYS.V_$STATNAME                      TO monitoring;
GRANT SELECT ON SYS.V_$SYSSTAT                       TO monitoring;
GRANT SELECT ON SYS.V_$PGASTAT                       TO monitoring;
-- GRANT SELECT ON SYS.UTL_MAIL                         TO monitoring;
-- GRANT SELECT ON SYS.UTL_RECOMP                       TO monitoring;
