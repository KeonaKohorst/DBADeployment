-- =================================================================================
-- Filename: V1.0.3__create_table_partitions.sql

-- Copyright (c) 2025 Emilio Iturbide Gonzalez
-- This software is licensed under the MIT License, located in the root directory 
-- of this project (LICENSE file).
-- ---------------------------------------------------------------------------------
-- Author(s): Emilio Iturbide Gonzalez
-- Date Created: November 18, 2025
-- Date Last Modified: December 9, 2025
--
-- Use of AI: 
-- Gemini AI was used to help debug for the implementation of the script.
-- All AI-generated suggestions were reviewed, verified, and modified by the author
-- before inclusion.
--
-- Description:
-- This script modifies the STOCKS table to implement range partitioning based on
-- the trade_date column. It sets up partitions for quarterly intervals in 2025
-- and specifies that new partitions should be created every three months.
-- =================================================================================

-- Set partitions by range (trade_date)
-- Interval option will continue to create partitions on a 3-month basis after the last partition.
-- ONLINE options guarantees very minimal if not null downtime.

ALTER TABLE STOCK_USER.STOCKS
	MODIFY PARTITION BY RANGE (trade_date)
	INTERVAL (NUMTOYMINTERVAL(3, 'MONTH'))
	(
		PARTITION STOCKS_BEFORE_2025 VALUES LESS THAN (TIMESTAMP '2025-01-01 00:00:00') TABLESPACE stocks_data,
		PARTITION STOCKS_Q1_2025 VALUES LESS THAN (TIMESTAMP '2025-04-01 00:00:00') TABLESPACE stocks_data,
		PARTITION STOCKS_Q2_2025 VALUES LESS THAN (TIMESTAMP '2025-07-01 00:00:00') TABLESPACE stocks_data,
		PARTITION STOCKS_Q3_2025 VALUES LESS THAN (TIMESTAMP '2025-10-01 00:00:00') TABLESPACE stocks_data,
		PARTITION STOCKS_Q4_2025 VALUES LESS THAN (TIMESTAMP '2026-01-01 00:00:00') TABLESPACE stocks_data
	)
	ONLINE
	UPDATE INDEXES;