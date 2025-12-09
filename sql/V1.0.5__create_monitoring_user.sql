-- V1.0.1.1__create_monitoring_user.sql
-- Create the dedicated monitoring user used by the performance suite

CREATE USER monitoring IDENTIFIED BY pass;
GRANT CREATE SESSION, CREATE TABLE, CREATE JOB, CREATE EXTERNAL JOB TO monitoring;
ALTER USER monitoring QUOTA UNLIMITED ON USERS;

-- Basic privileges needed for the monitoring jobs
GRANT SELECT ON STOCK_USER.STOCKS                    TO monitoring;
GRANT SELECT ON SYS.DBA_TABLESPACE_USAGE_METRICS     TO monitoring;
GRANT SELECT ON SYS.V_$SESSION                       TO monitoring;
GRANT SELECT ON SYS.V_$SESSTAT                       TO monitoring;
GRANT SELECT ON SYS.V_$SQL                           TO monitoring;
GRANT SELECT ON SYS.V_$STATNAME                      TO monitoring;
GRANT SELECT ON SYS.V_$SYSSTAT                       TO monitoring;
GRANT SELECT ON SYS.V_$PGASTAT                       TO monitoring;
GRANT SELECT ON SYS.DBA_TABLESPACE_USAGE_METRICS     TO monitoring;

-- GRANT EXECUTE ON SYS.UTL_MAIL                         TO monitoring;
-- GRANT EXECUTE ON SYS.UTL_RECOMP                       TO monitoring;
