use database demo_db;
use schema demo_schema;

/*----------------D5_1 Hands-on----------------
1) Introduce Databases & schemas
2) Understand table and view types
----------------------------------------------*/

/* Update: As of November 2022 Snowflake no longer includes 
the default warehouse 'COMPUTE_WH' for some regions. 
The following commands will create an idential warehouse
we can use throughout the hands-on in its place.  */

  USE ROLE ACCOUNTADMIN;

  CREATE WAREHOUSE COMPUTE_WH WAREHOUSE_SIZE=XSMALL;

  GRANT ALL PRIVILEGES ON WAREHOUSE COMPUTE_WH TO ROLE SYSADMIN;
  GRANT ALL PRIVILEGES ON WAREHOUSE COMPUTE_WH TO ROLE SECURITYADMIN;
  GRANT ALL PRIVILEGES ON WAREHOUSE COMPUTE_WH TO ROLE USERADMIN;
  GRANT ALL PRIVILEGES ON WAREHOUSE COMPUTE_WH TO ROLE PUBLIC;

/* End of Update */

-- Set context 
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE SNOWFLAKE_SAMPLE_DATA;
USE SCHEMA TPCH_SF1;

--"SNOWFLAKE_SAMPLE_DATA"."WEATHER"."DAILY_14_TOTAL"

-- Describe table schema
DESC TABLE CUSTOMER;

-- Provide details on all tables in current context
SHOW TABLES;

-- Filter output of SHOW TABLES using LIKE string matching
SHOW TABLES LIKE 'CUSTOMER';

SELECT "name", "database_name", "schema_name", "kind", "is_external", "retention_time" FROM TABLE(result_scan(last_query_id()));

-- Create demo database & schema 
CREATE DATABASE DEMO_DB;
CREATE SCHEMA DEMO_SCHEMA;

USE DATABASE DEMO_DB;
USE SCHEMA DEMO_SCHEMA;

-- Create three table types

-- PERMANENT TABLE (Default Table Type)
CREATE OR REPLACE TABLE PERMANENT_TABLE 
(
  NAME STRING,
  AGE INT
  );
 
-- TEMPORARY TABLE 
create or replace temporary table TEMPORARY_TABLE
(
    NAME STRING,
    AGE INT
);

-- TRANSIENT TABLE
create or replace transient table TRANSIENT_TABLE
(NAME STRING , AGE INT);

desc table TRANSIENT_TABLE;

-- SHOW TABLES
SHOW TABLES;

-- LAST RUNNED QUERY
SELECT * FROM TABLE(result_scan(last_query_id())); -- OWN (select *)
SELECT "name", "database_name", "schema_name", "kind", "is_external", "retention_time" FROM TABLE(result_scan(last_query_id()));

-- Successful (Alter the Time Travel Period for Permanent Table):
ALTER TABLE PERMANENT_TABLE SET DATA_RETENTION_TIME_IN_DAYS = 90;

-- Invalid Value (Alter the Time Travel Period for TRANSIENT Table)
ALTER TABLE TRANSIENT_TABLE SET DATA_RETENTION_TIME_IN_DAYS = 2;

-- Create external table "SYNTAX"
CREATE EXTERNAL TABLE EXT_TABLE
(
 	
  col1 varchar as (value:col1::varchar),
  col2 varchar as (value:col2::int)
  col3 varchar as (value:col3::varchar)

)
LOCATION=@s1/logs/
FILE_FORMAT = (type = parquet); 

-- ------------------------------------------------------------------------------------------------------------------------------------

/* EXTERNAL TABLE */
 create or replace stage demo_db.demo_schema.s3_bucket_files
 url = 's3://uni-lab-files/dabw/';
 
 -- FILE FORMAT
 create or replace file format csv_fmt
 TYPE = 'CSV';

-- select specific file name "PATTERN" parameter
CREATE OR REPLACE EXTERNAL TABLE my_ext_table
  WITH LOCATION = @s3_bucket_files/
  FILE_FORMAT = (TYPE = CSV  SKIP_HEADER = 1)
  PATTERN='.*Color_Names.*[.]csv';
 
select value from my_ext_table;

select value:c1::int as COLOR_UID,value:c2::varchar as COLOR_NAME from my_ext_table;

-- CREATE EXTERNAL TABLE WITH "columns"

create or replace external table my_external_table_with_cols(
    COLOR_UID int as (value:c1::int),
    COLOR_NAME varchar as (value:c2::varchar)
) with location = @s3_bucket_files
file_format = (TYPE = CSV SKIP_HEADER=1)
PATTERN = '.*Color_Names.*[.]csv';

select * from my_external_table_with_cols;
-- ------------------------------------------------------------------------------------------------------------------------------------

/* VIEWS */
-- STANDARD VIEW
create view standard_view as
select * from permanent_table;

-- SECURE VIEW
create or replace secure view secure_view as
select * from permanent_table;

-- MATERIALIZED VIEW
create materialized view materialized_view as
select * from permanent_table;

SHOW VIEWS;

select * from table(result_scan(last_query_id()));
select "name","database_name","schema_name","is_secure","is_materialized" from table(result_scan(last_query_id()));

-- ----------------------------------------------------------------------------------------------------------------------------------

-- SECURE VIEW FUNCTIONS

GRANT USAGE ON DATABASE DEMO_DB TO ROLE SYSADMIN;
GRANT USAGE ON SCHEMA DEMO_SCHEMA TO ROLE SYSADMIN;
GRANT SELECT, REFERENCES ON TABLE STANDARD_VIEW TO ROLE SYSADMIN;
GRANT SELECT, REFERENCES ON TABLE SECURE_VIEW TO ROLE SYSADMIN;

-- DDL(Data Definition Language) that returns from secure view 

select get_ddl('view','secure_view');

-- CHANGE role to SYSADMIN
use role SYSADMIN;

-- SECURE VIEW will not work with SYSADMIN role as only ownership role can view DDL
-- if secure view was created under SYSADMIN it'll work. -- NOT CONFIRM
select get_ddl('view','secure_view');

/*create schema sys_admin_schema;
CREATE OR REPLACE SECURE VIEW SECURE_VIEW_IN_SYSADMIN as
SELECT * FROM PERMANENT_TABLE;*/

-- standard view will work with SYSADMIN role as only ownership role can view DDL.
select get_ddl('view','standard_view');

-- set context
use role ACCOUNTADMIN;
