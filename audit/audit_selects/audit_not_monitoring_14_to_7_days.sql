-- =============================================
-- Author: Cody Jorgenson    
-- Create date: December 4, 2025
-- last modified: December 7, 2025
-- Description: show all entries from all users except monitoring in the last 14 to 7 days ago
-- =============================================



SET linesize 500;
COLUMN username FORMAT a20;
COLUMN extended_timestamp FORMAT a20;
COLUMN action_name FORMAT a15;
COLUMN obj_name FORMAT a20;
COLUMN sql_text FORMAT a200;
SELECT username, extended_timestamp, action_name, obj_name, sql_text 
FROM DBA_AUDIT_TRAIL
WHERE username != 'MONITORING' AND
	extended_timestamp BETWEEN SYSDATE-14 AND SYSDATE - 7
ORDER BY extended_timestamp ASC;