//Create a new database to hold the Twitter file
CREATE DATABASE SOCIAL_MEDIA_FLOODGATES 
COMMENT = 'There\'s so much data from social media - flood warning';

USE DATABASE SOCIAL_MEDIA_FLOODGATES;

//Create a table in the new database
CREATE TABLE SOCIAL_MEDIA_FLOODGATES.PUBLIC.TWEET_INGEST 
("RAW_STATUS" VARIANT) 
COMMENT = 'Bring in tweets, one row per tweet or status entity';

//Create a JSON file format in the new database
CREATE FILE FORMAT SOCIAL_MEDIA_FLOODGATES.PUBLIC.JSON_FILE_FORMAT 
TYPE = 'JSON' 
COMPRESSION = 'AUTO' 
ENABLE_OCTAL = FALSE 
ALLOW_DUPLICATE = FALSE 
STRIP_OUTER_ARRAY = TRUE 
STRIP_NULL_VALUES = FALSE 
IGNORE_UTF8_ERRORS = FALSE;

USE DATABASE SOCIAL_MEDIA_FLOODGATES;
DESC TABLE TWEET_INGEST;
SELECT * FROM TWEET_INGEST;

-- COPY DATA FROM S3 TO TABLE via STAGE.
CREATE OR REPLACE STAGE s3_to_table
url = 's3://uni-lab-files';

--  COPY INTO
COPY INTO TWEET_INGEST
from @s3_to_table 
files = ('nutrition_tweets.json')
file_format = (format_name = SOCIAL_MEDIA_FLOODGATES.PUBLIC.JSON_FILE_FORMAT);

-- SELECT STATMENT
select * from TWEET_INGEST;

//select statements as seen in the video
SELECT RAW_STATUS
FROM TWEET_INGEST;

SELECT RAW_STATUS:entities
FROM TWEET_INGEST;

SELECT RAW_STATUS:entities:hashtags
FROM TWEET_INGEST;

-- select `text` which is INSIDE `hashtags`
SELECT RAW_STATUS:entities:hashtags[0]:text
FROM TWEET_INGEST;

-- select `text` which is INSIDE `hashtags` where the `text` IS NOT NULL
SELECT RAW_STATUS:entities:hashtags[0]:text
FROM TWEET_INGEST WHERE RAW_STATUS:entities:hashtags[0]:text IS NOT NULL;

-- OWN TRY WITH `id`,`created_at`
SELECT RAW_STATUS:id::integer as ID,
RAW_STATUS:created_at::DATETIME AS "CREATED AT",
RAW_STATUS:entities:hashtags[0]:text::text AS "Message Content"
FROM TWEET_INGEST 
WHERE RAW_STATUS:entities:hashtags[0]:text IS NOT NULL;

//Perform a simple CAST on the created_at key
//Add an ORDER BY clause to sort by the tweet's creation date

SELECT RAW_STATUS:created_at::DATE
FROM TWEET_INGEST
ORDER BY RAW_STATUS:created_at::DATE;


//Flatten statements that return the whole hashtag entity -- PROCEED
SELECT *
FROM TWEET_INGEST
,LATERAL FLATTEN
(input => RAW_STATUS:entities:hashtags);

SELECT value
FROM TWEET_INGEST
,TABLE(FLATTEN(RAW_STATUS:entities:hashtags));

//Flatten statement that restricts the value to just the TEXT of the hashtag
SELECT value:text
FROM TWEET_INGEST
,LATERAL FLATTEN
(input => RAW_STATUS:entities:hashtags);

//Flatten and return just the hashtag text, CAST the text as VARCHAR
SELECT value:text::varchar
from TWEET_INGEST
,LATERAL flatten(input=>RAW_STATUS:entities:hashtags);

//Flatten and return just the hashtag text, CAST the text as VARCHAR
// Use the AS command to name the column
SELECT value:text::varchar AS THE_HASHTAG
FROM TWEET_INGEST,
LATERAL FLATTEN(input => RAW_STATUS:entities:hashtags);

//Add the Tweet ID and User ID to the returned table
SELECT RAW_STATUS:user:id AS USER_ID,
RAW_STATUS:id AS TWEET_ID,
value:text::varchar AS HASHTAG_TEXT
from TWEET_INGEST
,LATERAL FLATTEN(input => RAW_STATUS:entities:hashtags);

-- DORA CHECKUP
USE ROLE ACCOUNTADMIN;
USE DATABASE DEMO_DB;
USE SCHEMA PUBLIC;
-- Set your worksheet drop lists. DO NOT EDIT THE DORA CODE.
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from
(
   SELECT 'DWW18' as step
  ,(select row_count 
    from SOCIAL_MEDIA_FLOODGATES.INFORMATION_SCHEMA.TABLES 
    where table_name = 'TWEET_INGEST') as actual
  , 9 as expected
  ,'Check number of rows' as description  
 ); 

-- --------------------------------------------------------------

--  // Create a View of the Tweet Data Looking "Normalized"
-- Set your worksheet drop lists. DO NOT EDIT THE DORA CODE.
create or replace view SOCIAL_MEDIA_FLOODGATES.PUBLIC.HASHTAGS_NORMALIZED as
(SELECT RAW_STATUS:user:id AS USER_ID
,RAW_STATUS:id AS TWEET_ID
,value:text::VARCHAR AS HASHTAG_TEXT
FROM TWEET_INGEST
,LATERAL FLATTEN
(input => RAW_STATUS:entities:hashtags)
);

-- DORA CHECKUP
-- Set your worksheet drop lists. DO NOT EDIT THE DORA CODE.

select GRADER(step, (actual = expected), actual, expected, description) as graded_results from
(
  SELECT 'DWW19' as step
  ,(select count(*) 
    from SOCIAL_MEDIA_FLOODGATES.INFORMATION_SCHEMA.VIEWS 
    where table_name = 'HASHTAGS_NORMALIZED') as actual
  , 1 as expected
  ,'Check number of rows' as description
 );
