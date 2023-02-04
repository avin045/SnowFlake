-- Lesson_3_Joining_Local_Data_With_Shared_Data

USE ROLE SYSADMIN;

CREATE DATABASE INTL_DB;
USE SCHEMA INTL_DB.PUBLIC;

-- 🥋 Create a Warehouse for Loading INTL_DB
CREATE WAREHOUSE INTL_WH 
WITH WAREHOUSE_SIZE = 'XSMALL' 
WAREHOUSE_TYPE = 'STANDARD' 
AUTO_SUSPEND = 600 
AUTO_RESUME = TRUE;

-- CHECK WAREHOUSE CREATED AND USING IT.
USE WAREHOUSE INTL_WH;

-- 🥋 Create Table INT_STDS_ORG_3661
CREATE OR REPLACE TABLE INTL_DB.PUBLIC.INT_STDS_ORG_3661 
(ISO_COUNTRY_NAME varchar(100), 
 COUNTRY_NAME_OFFICIAL varchar(200), 
 SOVEREIGNTY varchar(40), 
 ALPHA_CODE_2DIGIT varchar(2), 
 ALPHA_CODE_3DIGIT varchar(3), 
 NUMERIC_COUNTRY_CODE integer,
 ISO_SUBDIVISION varchar(15), 
 INTERNET_DOMAIN_CODE varchar(10)
);

-- 🥋 Create a File Format to Load the Table
CREATE OR REPLACE FILE FORMAT INTL_DB.PUBLIC.PIPE_DBLQUOTE_HEADER_CR 
  TYPE = 'CSV' 
  COMPRESSION = 'AUTO' 
  FIELD_DELIMITER = '|' 
  RECORD_DELIMITER = '\r' 
  SKIP_HEADER = 1 
  FIELD_OPTIONALLY_ENCLOSED_BY = '\042' 
  TRIM_SPACE = FALSE 
  ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE 
  ESCAPE = 'NONE' 
  ESCAPE_UNENCLOSED_FIELD = '\134'
  DATE_FORMAT = 'AUTO' 
  TIMESTAMP_FORMAT = 'AUTO' 
  NULL_IF = ('\\N');

-- check if the file format was created or not
USE DATABASE INTL_DB;
show file formats; -- CREATED

-- Load the ISO Table Using Your File Format3
create stage demo_db.public.like_a_window_into_an_s3_bucket 
url = "s3://uni-lab-files"; -- Already created in Badge_1 under VEGGIES schema

-- USE DEMO_DB TO CHECK THE stage is created or not. 
USE DATABASE DEMO_DB;
show stages;

-- COPY from S3 to SNOWFLAKE TABLE.
copy into INTL_DB.PUBLIC.INT_STDS_ORG_3661
from @like_a_window_into_an_s3_bucket
files = ('smew/ISO_Countries_UTF8_pipe.csv')
file_format = (format_name=INTL_DB.PUBLIC.PIPE_DBLQUOTE_HEADER_CR);


select * from INTL_DB.PUBLIC.INT_STDS_ORG_3661;

-- 🥋 Check That You Created and Loaded the Table Properly
SELECT count(*) as FOUND, '249' as EXPECTED 
FROM INTL_DB.PUBLIC.INT_STDS_ORG_3661;

/*
-- if DATABASE created with wrong spelling.
ALTER DATABASE INTRL_DB RENAME TO INTL_DB;
*/

-- 📓  How to Test Whether You Set Up Your Table in the Right Place with the Right Name
USE DATABASE INTL_DB;

select count(*) as OBJECTS_FOUND
FROM INTL_DB.INFORMATION_SCHEMA.TABLES
WHERE table_schema = 'PUBLIC'
AND table_name = 'INT_STDS_ORG_3661';

--  How to Test That You Loaded the Expected Number of Rows
--  (USING : row_count is a COLUMN in 'INTL_DB.INFORMATION_SCHEMA.TABLES')
select row_count
from INTL_DB.INFORMATION_SCHEMA.TABLES 
where table_schema='PUBLIC'
and table_name= 'INT_STDS_ORG_3661';

-- Join Local Data with Shared Data
SELECT  iso_country_name, country_name_official,alpha_code_2digit,r_name as region
FROM INTL_DB.PUBLIC.INT_STDS_ORG_3661 i
LEFT JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION n
ON UPPER(i.iso_country_name)=n.n_name
LEFT JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.REGION r
ON n_regionkey = r_regionkey;

-- 🥋 Convert the Select Statement into a View(Stores the join result into an VIEW)
CREATE VIEW NATIONS_SAMPLE_PLUS_ISO 
( iso_country_name,country_name_official,alpha_code_2digit,region) AS
SELECT  iso_country_name, country_name_official,alpha_code_2digit,r_name as region
FROM INTL_DB.PUBLIC.INT_STDS_ORG_3661 i
LEFT JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION n
ON UPPER(i.iso_country_name)=n.n_name
LEFT JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.REGION r
ON n_regionkey = r_regionkey;

-- QUERY THE VIEW 'NATIONS_SAMPLE_PLUS_ISO'
select * from INTL_DB.PUBLIC.NATIONS_SAMPLE_PLUS_ISO;
-- DROP VIEW DEMO_DB.PUBLIC.NATIONS_SAMPLE_PLUS_ISO;

-- 🥋 Create Table Currencies
CREATE TABLE INTL_DB.PUBLIC.CURRENCIES 
(
  CURRENCY_ID INTEGER, 
  CURRENCY_CHAR_CODE varchar(3), 
  CURRENCY_SYMBOL varchar(4), 
  CURRENCY_DIGITAL_CODE varchar(3), 
  CURRENCY_DIGITAL_NAME varchar(30)
)
  COMMENT = 'Information about currencies including character codes, symbols, digital codes, etc.';
  
-- 🥋 Create Table Country to Currency
CREATE TABLE INTL_DB.PUBLIC.COUNTRY_CODE_TO_CURRENCY_CODE 
  (
    COUNTRY_CHAR_CODE Varchar(3), 
    COUNTRY_NUMERIC_CODE INTEGER, 
    COUNTRY_NAME Varchar(100), 
    CURRENCY_NAME Varchar(100), 
    CURRENCY_CHAR_CODE Varchar(3), 
    CURRENCY_NUMERIC_CODE INTEGER
  ) 
  COMMENT = 'Many to many code lookup table';
  
-- Create a File Format to Process files with Commas, Linefeeds and a Header Row
  CREATE FILE FORMAT INTL_DB.PUBLIC.CSV_COMMA_LF_HEADER
  TYPE = 'CSV'
  COMPRESSION = 'AUTO' 
  FIELD_DELIMITER = ',' 
  RECORD_DELIMITER = '\n' 
  SKIP_HEADER = 1 
  FIELD_OPTIONALLY_ENCLOSED_BY = 'NONE' 
  TRIM_SPACE = FALSE 
  ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE 
  ESCAPE = 'NONE' 
  ESCAPE_UNENCLOSED_FIELD = '\134' 
  DATE_FORMAT = 'AUTO' 
  TIMESTAMP_FORMAT = 'AUTO' 
  NULL_IF = ('\\N');
  
-- LOADING DATA INTO TABLES
COPY INTO INTL_DB.PUBLIC.CURRENCIES
FROM @demo_db.public.like_a_window_into_an_s3_bucket
files = ('smew/currencies.csv') -- only 'smew/currencies.csv' -> single quotes
file_format = (format_name = INTL_DB.PUBLIC.CSV_COMMA_LF_HEADER);

COPY INTO INTL_DB.PUBLIC.COUNTRY_CODE_TO_CURRENCY_CODE
FROM @demo_db.public.like_a_window_into_an_s3_bucket
files = ('smew/country_code_to_currency_code.csv') -- only 'smew/currencies.csv' -> single quotes
file_format = (format_name = INTL_DB.PUBLIC.CSV_COMMA_LF_HEADER);

select * from INTL_DB.PUBLIC.COUNTRY_CODE_TO_CURRENCY_CODE;
select * from INTL_DB.PUBLIC.CURRENCIES;

--  Create a View that Will Return The Result Set Shown
CREATE VIEW INTL_DB.PUBLIC.SIMPLE_CURRENCY(CTY_CODE,CUR_CODE) AS 
select COUNTRY_CHAR_CODE as CTY_CODE,CURRENCY_CHAR_CODE AS CUR_CODE from INTL_DB.PUBLIC.COUNTRY_CODE_TO_CURRENCY_CODE;

-- VIEW that 'SIMPLE_CURRENCY' View.
SELECT * FROM INTL_DB.PUBLIC.SIMPLE_CURRENCY;











-- -----------------------------------------------------------------------------------------
-- DORA CHECK UPs
-- checkup 1
use role accountadmin;

-- set your worksheet drop lists to the location of your GRADER function using commands
-- change the next two lines (if needed) to the location of your GRADER function
use database demo_db;
use schema public;

--DO NOT EDIT BELOW THIS LINE
select grader(step, (actual = expected), actual, expected, description) as graded_results from( 
 SELECT 'SMEW01' as step
 ,(select count(*) 
   from snowflake.account_usage.databases
   where database_name = 'INTL_DB' 
   and deleted is null) as actual
 , 1 as expected
 ,'Created INTL_DB' as description
 );
 
 /* select count(*) 
   from snowflake.account_usage.databases
   where database_name = 'INTL_DB' 
   and deleted is null;

select * from snowflake.account_usage.databases order by DATABASE_ID; */

use role accountadmin;

-- set your worksheet drop lists to the location of your GRADER function using commands
-- change the next two lines (if needed) to the location of your GRADER function
use database demo_db;
use schema public;

--DO NOT EDIT BELOW THIS LINE
select grader(step, (actual = expected), actual, expected, description) as graded_results from(
SELECT 'SMEW02' as step
 ,(select count(*) 
   from INTL_DB.INFORMATION_SCHEMA.TABLES 
   where table_schema = 'PUBLIC' 
   and table_name = 'INT_STDS_ORG_3661') as actual
 , 1 as expected
 ,'ISO table created' as description
);

-- set your worksheet drop lists to the location of your GRADER function 
-- you can use code or you can manually set the drop lists 
-- DO NOT EDIT BELOW THIS LINE 
select grader(step, (actual = expected), actual, expected, description) as graded_results from( 
SELECT 'SMEW03' as step 
 ,(select row_count 
   from INTL_DB.INFORMATION_SCHEMA.TABLES  
   where table_name = 'INT_STDS_ORG_3661') as actual 
 , 249 as expected 
 ,'ISO Table Loaded' as description 
); 

--DO NOT EDIT BELOW THIS LINE
select grader(step, (actual = expected), actual, expected, description) as graded_results from(
SELECT 'SMEW04' as step
 ,(select count(*) 
   from INTL_DB.PUBLIC.NATIONS_SAMPLE_PLUS_ISO) as actual
 , 249 as expected
 ,'Nations Sample Plus Iso' as description
);

--DO NOT EDIT BELOW THIS LINE
select grader(step, (actual = expected), actual, expected, description) as graded_results from(
SELECT 'SMEW05' as step
 ,(select row_count 
  from INTL_DB.INFORMATION_SCHEMA.TABLES 
  where table_schema = 'PUBLIC' 
  and table_name = 'COUNTRY_CODE_TO_CURRENCY_CODE') as actual
 , 265 as expected
 ,'CCTCC Table Loaded' as description
);


--DO NOT EDIT BELOW THIS LINE
select grader(step, (actual = expected), actual, expected, description) as graded_results from(
SELECT 'SMEW06' as step
 ,(select row_count 
  from INTL_DB.INFORMATION_SCHEMA.TABLES 
  where table_schema = 'PUBLIC' 
  and table_name = 'CURRENCIES') as actual
 , 151 as expected
 ,'Currencies table loaded' as description
);

--DO NOT EDIT BELOW THIS LINE
select grader(step, (actual = expected), actual, expected, description) as graded_results from(
 SELECT 'SMEW07' as step 
,(select count(*) 
  from INTL_DB.PUBLIC.SIMPLE_CURRENCY ) as actual
, 265 as expected
,'Simple Currency Looks Good' as description
);
-- -----------------------------------------------------------------------------------------
