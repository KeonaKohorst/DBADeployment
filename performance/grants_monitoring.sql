-- grants_monitoring.sql
-- Exact privileges currently granted to MONITORING user (captured from your PDB)

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
--GRANT SELECT ON SYS.UTL_MAIL                         TO monitoring;
--GRANT SELECT ON SYS.UTL_RECOMP                       TO monitoring;
