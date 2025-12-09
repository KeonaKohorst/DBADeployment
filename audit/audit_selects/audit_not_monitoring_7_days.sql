-- show all entries from all users except monitoring in the last 7 days

SET linesize 500;
COLUMN username FORMAT a20;
COLUMN extended_timestamp FORMAT a20;
COLUMN action_name FORMAT a15;
COLUMN obj_name FORMAT a20;
COLUMN sql_text FORMAT a200;
SELECT username, extended_timestamp, action_name, obj_name, sql_text 
FROM DBA_AUDIT_TRAIL
WHERE username != 'MONITORING' AND
	extended_timestamp >= SYSDATE - 7
ORDER BY extended_timestamp ASC;