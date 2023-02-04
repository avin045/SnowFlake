// JSON DDL Scripts
USE LIBRARY_CARD_CATALOG;

// Create an Ingestion Table for JSON Data
CREATE TABLE "LIBRARY_CARD_CATALOG"."PUBLIC"."AUTHOR_INGEST_JSON" 
(
  "RAW_AUTHOR" VARIANT
);

-- show tables;
--  Create a File Format to Load the JSON Data

//Create File Format for JSON Data
CREATE FILE FORMAT LIBRARY_CARD_CATALOG.PUBLIC.JSON_FILE_FORMAT 
TYPE = 'JSON' 
COMPRESSION = 'AUTO' 
ENABLE_OCTAL = FALSE
ALLOW_DUPLICATE = FALSE 
STRIP_OUTER_ARRAY = TRUE -- FALSE
STRIP_NULL_VALUES = FALSE 
IGNORE_UTF8_ERRORS = FALSE;

-- Load the Data into the New Table, Using the File Format You Created

-- create STAGE
CREATE OR REPLACE STAGE like_a_window_s3_bucket_AUTHOR_INGEST_JSON
URL = 's3://uni-lab-files';

-- COPY the FILE DATA from s3 to AUTHOR_INGEST_JSON
copy into AUTHOR_INGEST_JSON 
from @like_a_window_s3_bucket_AUTHOR_INGEST_JSON
files = ('author_with_header.json')
file_format = (format_name = JSON_FILE_FORMAT);

-- VIEW `AUTHOR_INGEST_JSON` Table
select * from AUTHOR_INGEST_JSON;

-- Query the JSON Data

//returns AUTHOR_UID value from top-level object's attribute
select raw_author:AUTHOR_UID
from author_ingest_json;

// //returns the data in a way that makes it look like a normalized table
SELECT raw_author:AUTHOR_UID::integer,
raw_author:FIRST_NAME::string as FIRST_NAME,
raw_author:LAST_NAME::string as LAST_NAME,
raw_author:MIDDLE_NAME::string as MIDDLE_NAME
from AUTHOR_INGEST_JSON;

-- DORA check
-- Set your worksheet drop lists. DO NOT EDIT THE DORA CODE.

USE ROLE ACCOUNTADMIN;
USE DATABASE DEMO_DB;

select GRADER(step, (actual = expected), actual, expected, description) as graded_results from
(
  SELECT 'DWW16' as step
  ,(select row_count 
    from LIBRARY_CARD_CATALOG.INFORMATION_SCHEMA.TABLES 
    where table_name = 'AUTHOR_INGEST_JSON') as actual
  ,6 as expected
  ,'Check number of rows' as description
 ); 