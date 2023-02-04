-- Lesson 11_Nested_Semi-Structured_Data

USE ROLE ACCOUNTADMIN;
USE DATABASE LIBRARY_CARD_CATALOG;
-- CREATE DATABASE SOCIAL_MEDIA_FLOODGATES;
-- USE DATABASE SOCIAL_MEDIA_FLOODGATES;

-- Create a Table & File Format for Nested JSON Data
CREATE OR REPLACE TABLE LIBRARY_CARD_CATALOG.PUBLIC.NESTED_INGEST_JSON 
(
  "RAW_NESTED_BOOK" VARIANT
);

-- -----------------------------------------------------------------
//Create File Format for JSON Data
CREATE FILE FORMAT LIBRARY_CARD_CATALOG.PUBLIC.NESTED_JSON_FILE_FORMAT 
TYPE = 'JSON' 
COMPRESSION = 'AUTO' 
ENABLE_OCTAL = FALSE
ALLOW_DUPLICATE = FALSE 
STRIP_OUTER_ARRAY = TRUE -- FALSE
STRIP_NULL_VALUES = FALSE 
IGNORE_UTF8_ERRORS = FALSE;

-- Create a Snowflake Stage Object
 create stage LIBRARY_CARD_CATALOG.PUBLIC.stage_object_s3 
 url = 's3://uni-lab-files';

-- COPY INTO
COPY INTO NESTED_INGEST_JSON
from @stage_object_s3
files = ('json_book_author_nested.json')
file_format = (format_name = NESTED_JSON_FILE_FORMAT);

-- SELECT
select * from NESTED_INGEST_JSON;


-- ------------------------------------
SELECT RAW_NESTED_BOOK
FROM NESTED_INGEST_JSON;

-- Access the Keys (authors,book_title,years_published)
SELECT RAW_NESTED_BOOK:year_published
FROM NESTED_INGEST_JSON;

select RAW_NESTED_BOOK:book_title
FROM NESTED_INGEST_JSON;

-- TRYING DIFFERENT THINGS
select RAW_NESTED_BOOK:authors from nested_ingest_json;

-- OWN TRY TO ACCESS `NESTED JSON`
SELECT RAW_NESTED_BOOK:authors[0]:first_name from nested_ingest_json; -- RAW_NESTED_BOOK:authors[0].first_name

// -------- FLATTEN --------
SELECT value:first_name
FROM NESTED_INGEST_JSON
,LATERAL FLATTEN(input => RAW_NESTED_BOOK:authors);

SELECT value:first_name,value:last_name
FROM NESTED_INGEST_JSON
,table(flatten(RAW_NESTED_BOOK:authors));

//Add a CAST command to the fields returned
SELECT value:first_name::VARCHAR, value:last_name::VARCHAR
FROM NESTED_INGEST_JSON
,LATERAL FLATTEN(input => RAW_NESTED_BOOK:authors);

//Assign new column  names to the columns using "AS"
SELECT value:first_name::VARCHAR AS FIRST_NM
, value:last_name::VARCHAR AS LAST_NM
FROM NESTED_INGEST_JSON
,LATERAL FLATTEN(input => RAW_NESTED_BOOK:authors);

show external functions;

-- DORA CHECKUP
USE DATABASE DEMO_DB;
USE SCHEMA PUBLIC;

select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (   
     SELECT 'DWW17' as step 
      ,(select row_count 
        from LIBRARY_CARD_CATALOG.INFORMATION_SCHEMA.TABLES 
        where table_name = 'NESTED_INGEST_JSON') as actual 
      , 5 as expected 
      ,'Check number of rows' as description  
); 