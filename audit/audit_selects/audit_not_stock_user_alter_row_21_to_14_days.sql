-- show updates, inserts and deletes from any user except stock_user in the last 21 to 14 days

SET linesize 500;
COLUMN username FORMAT a20;
COLUMN extended_timestamp FORMAT a20;
COLUMN action_name FORMAT a15;
COLUMN obj_name FORMAT a20;
COLUMN sql_text FORMAT a200;
SELECT username, extended_timestamp, action_name, obj_name, sql_text 
FROM DBA_AUDIT_TRAIL
WHERE username != 'MONITORING' AND
	extended_timestamp BETWEEN SYSDATE - 21 AND SYSDATE - 14 AND 
	action_name IN ('UPDATE', 'INSERT', 'DELETE')
ORDER BY extended_timestamp ASC;