-- =============================================
-- Author: Cody Jorgenson    
-- Create date: December 4, 2025
-- last modified: December 7, 2025
-- Description: show update, insert and delete entries from the enteres user between the entered day range, requires input at runtime
-- =============================================



SET linesize 500;
COLUMN username FORMAT a20;
COLUMN extended_timestamp FORMAT a20;
COLUMN action_name FORMAT a15;
COLUMN obj_name FORMAT a20;
COLUMN sql_text FORMAT a200;
ACCEPT user CHAR PROMPT 'Enter username of the auditee: '
ACCEPT start NUMBER PROMPT 'Enter the start of the day range (number of days ago): '
ACCEPT end NUMBER PROMPT 'Enter the end of the day range (number of days ago): '
SELECT username, extended_timestamp, action_name, obj_name, sql_text 
FROM DBA_AUDIT_TRAIL
WHERE username = '&user' AND 
	extended_timestamp BETWEEN SYSDATE - &start AND SYSDATE - &end AND 
	action_name IN ('UPDATE', 'INSERT', 'DELETE')
ORDER BY extended_timestamp ASC;