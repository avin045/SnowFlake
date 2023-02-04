-- Lesson_2_Project_Kick-Off_and_Database_Set_Up

/*
🎯 Create the Project Infrastructure
1. Use SYSADMIN.
2. Create a database named AGS_GAME_AUDIENCE
3. Drop the PUBLIC schema.
4. Create a schema named RAW.
*/

create database AGS_GAME_AUDIENCE;

use AGS_GAME_AUDIENCE;

DROP SCHEMA public;

create schema AGS_GAME_AUDIENCE.RAW;

-- Table Creation
create table GAME_LOGS (
    RAW_LOG VARIANT
    -- , <col2_name> <col2_type>
    -- supported types: https://docs.snowflake.com/en/sql-reference/intro-summary-data-types.html
    );
    -- comment = '<comment>';

-- Create a Stage for above Table.
create stage uni_kishore
url = 's3://uni-kishore';

/* 🥋 Test the Stage */
list @uni_kishore;

/* 🎯 Create a File Format */

create or replace file format AGS_GAME_AUDIENCE.RAW.FF_JSON_LOGS
TYPE = 'json'
strip_outer_array = true;

/* ------------------ use own method to read file ----------------- */
-- Oh Yeah! We have to turn them on, first
alter stage uni_kishore 
set directory = (enable = true);

select count(*) from @uni_kishore/kickoff
(file_format => FF_JSON_LOGS);

/* 🥋 Load the File Into The Table => Using COPY INTO */
copy into ags_game_audience.raw.game_logs
from @uni_kishore/kickoff
file_format = (format_name = FF_JSON_LOGS);

select * from game_logs;

/* 🥋 Build a Select Statement that Separates Every Attribute into It's Own Column */
-- RAW_LOG:agent,RAW_LOG:datetime_iso8601,RAW_LOG:user_event,RAW_LOG:user_login
select RAW_LOG:agent,
RAW_LOG:datetime_iso8601,
RAW_LOG:user_event,
RAW_LOG:user_login
from game_logs;

-- WITH DATATYPE
select RAW_LOG:agent::text,
RAW_LOG:datetime_iso8601::TIMESTAMP_NTZ, -- RAW_LOG:datetime_iso8601::datetime
RAW_LOG:user_event::text,
RAW_LOG:user_login::text
from game_logs;

-- SNOWFLAKE ANSWER
select
RAW_LOG:agent::text as AGENT,
RAW_LOG:datetime_iso8601::TIMESTAMP_NTZ as "datetime_iso8601", -- RAW_LOG:datetime_iso8601::datetime
RAW_LOG:user_event::text as USER_EVENT,
RAW_LOG:user_login::text as USER_LOGIN,
*
from game_logs;

/* 📓 Wrapping Selects in Views  */
CREATE OR REPLACE VIEW LOGS as (
   select
RAW_LOG:agent::text as AGENT,
RAW_LOG:datetime_iso8601::TIMESTAMP_NTZ as "datetime_iso8601", -- RAW_LOG:datetime_iso8601::datetime
RAW_LOG:user_event::text as USER_EVENT,
RAW_LOG:user_login::text as USER_LOGIN,
*
from game_logs
);

-- drop view MY_VIEW;

-- view the VIEW
select * from logs;

/* 🤖 Run This in Your Worksheet to Send a Report to DORA 
NEVER CHANGE DORA CODE TO GET A GREEN CHECK. CHANGE YOUR LAB WORK. */
-- DO NOT EDIT THIS CODE
USE ROLE ACCOUNTADMIN;
USE DATABASE DEMO_DB;
USE SCHEMA PUBLIC;
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from
(
 SELECT
 'DNGW01' as step
  ,(
      select count(*)  
      from ags_game_audience.raw.logs
      where is_timestamp_ntz(to_variant(datetime_iso8601))= TRUE 
   ) as actual
, 250 as expected
, 'Project DB and Log File Set Up Correctly' as description
); 

 select count(*)  
      from ags_game_audience.raw.logs where is_timestamp_ntz(to_variant(datetime_iso8601))= TRUE;