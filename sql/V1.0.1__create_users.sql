/*
 ===========================================
 Filename: V1.0.1__create_users.sql
 
# Copyright (c) 2025 Keona Gagnier
# This software is licensed under the MIT License, located in the root directory
# of this project (LICENSE file).
# ------------------------------------------------------------------------------
# Author(s): Keona Gagnier
# Date Created: Nov 28 2025
# Last Modified: December 12 2025
#
# Use of AI: 
# Gemini AI was used to help debug and improve the script. 
# All AI-generated suggestions were reviewed, verified, and modified by the author 
# before inclusion.
#
# Description:
# This creates the users and assigns their roles/privileges/quotas for the database. 
  It is used as the first step in the Flyway Automated deployment.
*/

-- Create Users

CREATE USER APP_READONLY IDENTIFIED BY "pass";

CREATE USER ML_ANALYST IDENTIFIED BY "pass";

CREATE USER ML_DEVELOPER IDENTIFIED BY "pass";

CREATE USER STOCK_USER IDENTIFIED BY "pass";



-- Allow sessions

GRANT CREATE SESSION TO APP_READONLY;

GRANT CREATE SESSION TO ML_ANALYST;

GRANT CREATE SESSION TO ML_DEVELOPER;

GRANT CREATE SESSION TO STOCK_USER;



-- APP_READONLY ROLE: Dashboards / Power BI / APIs

-- Read-only access: only SELECT allowed

GRANT SELECT ANY TABLE TO APP_READONLY;



-- No quotas since user should not write to any tablespace

ALTER USER APP_READONLY QUOTA 0 ON USERS;



-- prevent object creation entirely

GRANT READ ANY TABLE TO APP_READONLY;



-- Give stock user unlimited quota on stocks data tablespace

ALTER USER STOCK_USER QUOTA UNLIMITED ON STOCKS_DATA;
ALTER USER STOCK_USER QUOTA UNLIMITED ON STOCKS_INDEX;

GRANT CREATE TABLE TO STOCK_USER;
GRANT CREATE SEQUENCE TO STOCK_USER;


-- ML_ANALYST ROLE: Querying, aggregation, materialized views

GRANT SELECT ANY TABLE TO ML_ANALYST;

GRANT CREATE MATERIALIZED VIEW TO ML_ANALYST;

GRANT CREATE SYNONYM TO ML_ANALYST;



-- No table creation required, so set quota to 0

ALTER USER ML_ANALYST QUOTA 0 ON USERS;



-- ML_DEVELOPER ROLE: Exploratory modeling & experimentation

GRANT SELECT ANY TABLE TO ML_DEVELOPER;



-- Allow experimentation (local scratch tables)

GRANT CREATE TABLE TO ML_DEVELOPER;

GRANT CREATE VIEW TO ML_DEVELOPER;



-- Allow them to save experimental objects in USERS tablespace

ALTER USER ML_DEVELOPER QUOTA UNLIMITED ON USERS;




