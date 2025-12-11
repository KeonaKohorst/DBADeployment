-- =============================================
-- Author: Cody Jorgenson    
-- Create date: December 4, 2025
-- last modified: December 7, 2025
-- Description: show updates, inderts and deletes from stock_user in last 21 days
-- =============================================



SET linesize 500;
COLUMN username FORMAT a20;
COLUMN extended_timestamp FORMAT a20;
COLUMN action_name FORMAT a15;
COLUMN obj_name FORMAT a20;
COLUMN sql_text FORMAT a200;
SELECT username, extended_timestamp, action_name, obj_name, sql_text 
FROM DBA_AUDIT_TRAIL
WHERE username = 'stock_user' AND
	extended_timestamp >= SYSDATE - 21 AND 
	action_name IN ('UPDATE', 'INSERT', 'DELETE')
ORDER BY extended_timestamp ASC;