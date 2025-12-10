/*
 ===========================================
 Filename: V1.0.0__create_tablespaces.sql
 
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
# This creates the tablespaces for the database. It is used as the first step in the Flyway
# Automated deployment.
*/

CREATE TABLESPACE STOCKS_DATA

DATAFILE 'stocks_data01.dbf'

SIZE 4G

AUTOEXTEND ON NEXT 1G MAXSIZE 20G;



CREATE TABLESPACE STOCKS_INDEX

DATAFILE 'stocks_index01.dbf'

SIZE 5G 

AUTOEXTEND ON NEXT 1G MAXSIZE 10G;


 

CREATE TABLESPACE STOCKS_DATA

DATAFILE 'stocks_data01.dbf'

SIZE 4G

AUTOEXTEND ON NEXT 1G MAXSIZE 20G;



CREATE TABLESPACE STOCKS_INDEX

DATAFILE 'stocks_index01.dbf'

SIZE 5G 

AUTOEXTEND ON NEXT 1G MAXSIZE 10G;


