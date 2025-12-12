-- Filename: create_top_sql_log.sql
-- Author(s): Alex Anthony
-- Date created: 2025-11-26
-- Date Last Modified: 2025-12-11

-- Copyright: (c) Keona Gagnier
-- This software is licensed under the MIT license, located in the root directory of this project

-- Description:
-- Creates a global temporary table used by the MON_TOP_SQL scheduler job to store the daily top-20 CPU intensive queries.

CREATE GLOBAL TEMPORARY TABLE monitoring.top_sql_log (
  snap_time DATE DEFAULT SYSDATE,
  sql_id    VARCHAR2(13),
  plan_hash NUMBER,
  execs     NUMBER,
  disk_reads NUMBER,
  lio       NUMBER,
  cpu_sec   NUMBER,
  ela_sec   NUMBER
) ON COMMIT PRESERVE ROWS;
