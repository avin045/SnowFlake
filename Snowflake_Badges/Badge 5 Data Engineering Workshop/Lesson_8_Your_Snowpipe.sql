select * from ed_pipeline_logs;
select * from pl_logs;

/* 🥋 Create Your Snowpipe! */
CREATE OR REPLACE PIPE GET_NEW_FILES
auto_ingest=true
aws_sns_topic='arn:aws:sns:us-west-2:321463406630:dngw_topic'
AS 
COPY INTO ED_PIPELINE_LOGS
FROM (
    SELECT 
    METADATA$FILENAME as log_file_name 
  , METADATA$FILE_ROW_NUMBER as log_file_row_id 
  , current_timestamp(0) as load_ltz 
  , get($1,'datetime_iso8601')::timestamp_ntz as DATETIME_ISO8601
  , get($1,'user_event')::text as USER_EVENT
  , get($1,'user_login')::text as USER_LOGIN
  , get($1,'ip_address')::text as IP_ADDRESS    
  FROM @AGS_GAME_AUDIENCE.RAW.UNI_KISHORE_PIPELINE
)
file_format = (format_name = ff_json_logs);

-- DESCRIBE
DESCRIBE task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED;


/* 🎯 Update the LOAD_LOGS_ENHANCED Task */

create or replace task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED
	warehouse=COMPUTE_WH
	schedule='5 minute'
	as MERGE INTO ENHANCED.LOGS_ENHANCED e
USING (
SELECT logs.ip_address 
, logs.user_login as GAMER_NAME
, logs.user_event as GAME_EVENT_NAME
, logs."datetime_iso8601" as GAME_EVENT_UTC
, city
, region
, country
, timezone as GAMER_LTZ_NAME
, CONVERT_TIMEZONE( 'UTC',timezone,logs."datetime_iso8601") as game_event_ltz
, DAYNAME(game_event_ltz) as DOW_NAME
, TOD_NAME
from ags_game_audience.raw.ed_pipeline_logs logs
JOIN ipinfo_geoloc.demo.location loc 
ON ipinfo_geoloc.public.TO_JOIN_KEY(logs.ip_address) = loc.join_key
AND ipinfo_geoloc.public.TO_INT(logs.ip_address) 
BETWEEN start_ip_int AND end_ip_int
JOIN ags_game_audience.raw.TIME_OF_DAY_LU tod
ON HOUR(CONVERT_TIMEZONE( 'UTC',timezone,logs."datetime_iso8601")) = tod.hour
    ) r
ON r.GAMER_NAME = e.GAMER_NAME
AND r.GAME_EVENT_UTC = e.GAME_EVENT_UTC
AND r.GAME_EVENT_NAME = e.GAME_EVENT_NAME
WHEN NOT MATCHED THEN
INSERT (IP_ADDRESS,GAMER_NAME,GAME_EVENT_NAME,
       GAME_EVENT_UTC,CITY,REGION,COUNTRY
       ,GAMER_LTZ_NAME,GAME_EVENT_LTZ,
       DOW_NAME,TOD_NAME) VALUES
       (IP_ADDRESS,GAMER_NAME,GAME_EVENT_NAME,
       GAME_EVENT_UTC,CITY,REGION,COUNTRY
       ,GAMER_LTZ_NAME,GAME_EVENT_LTZ,
       DOW_NAME,TOD_NAME);  
       
create or replace task AGS_GAME_AUDIENCE.RAW.GET_NEW_FILES
	warehouse=COMPUTE_WH
	schedule='5 minute'
	as COPY INTO AGS_GAME_AUDIENCE.RAW.ED_PIPELINE_LOGS
FROM @AGS_GAME_AUDIENCE.RAW.UNI_KISHORE_PIPELINE
file_format = (format_name=ff_json_logs);
       
select $1 from @AGS_GAME_AUDIENCE.RAW.UNI_KISHORE_PIPELINE
(file_format => ff_json_logs);
----------------------------------------------------------------------------------

--Turning on a task is done with a RESUME command
alter task AGS_GAME_AUDIENCE.RAW.GET_NEW_FILES resume;
alter task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED resume;

/* ❕❕❕ You Have Tasks Running! */
--Keep this code handy for shutting down the tasks each day
alter task AGS_GAME_AUDIENCE.RAW.GET_NEW_FILES suspend;
alter task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED suspend;

describe task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED;

---------------------------------------------------------------------------------------

/* 🥋 Create a Stream */
--create a stream that will keep track of changes to the table
create or replace stream ags_game_audience.raw.ed_cdc_stream 
on table AGS_GAME_AUDIENCE.RAW.ED_PIPELINE_LOGS;

--look at the stream you created
show streams;

--check to see if any changes are pending
select system$stream_has_data('ed_cdc_stream');

-----------------------------------------------------------------------------------------
/* 🥋 View Our Stream Data */
--query the stream
select * 
from ags_game_audience.raw.ed_cdc_stream; 

--check to see if any changes are pending
select system$stream_has_data('ed_cdc_stream');

--if your stream remains empty for more than 10 minutes, make sure your PIPE is running
select SYSTEM$PIPE_STATUS('GET_NEW_FILES');

--if you need to pause or unpause your pipe
alter pipe GET_NEW_FILES set pipe_execution_paused = true;

DESCRIBE PIPE AGS_GAME_AUDIENCE.RAW.GET_NEW_FILES; --WON COMMAND
--alter pipe GET_NEW_FILES set pipe_execution_paused = false;

select * from ed_pipeline_logs;

/*
BACK UP
create table ed_pipeline_logs_backup clone ed_pipeline_logs;
select count(*) from ed_pipeline_logs_backup;
*/


------------------------------------------------------------------------------------

/* 🥋 Process the Rows from the Stream */
--make a note of how many rows are in the stream
select * 
from ags_game_audience.raw.ed_cdc_stream; 

-- backup
-- CREATE table ed_cdc_stream_backup as select * from ed_cdc_stream;
-- select * from ed_cdc_stream_backup;

 
--process the stream by using the rows in a merge 
MERGE INTO AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED e
USING (
        SELECT cdc.ip_address 
        , cdc.user_login as GAMER_NAME
        , cdc.user_event as GAME_EVENT_NAME
        , cdc.datetime_iso8601 as GAME_EVENT_UTC
        , city
        , region
        , country
        , timezone as GAMER_LTZ_NAME
        , CONVERT_TIMEZONE( 'UTC',timezone,cdc.datetime_iso8601) as game_event_ltz
        , DAYNAME(game_event_ltz) as DOW_NAME
        , TOD_NAME
        from ags_game_audience.raw.ed_cdc_stream cdc
        JOIN ipinfo_geoloc.demo.location loc 
        ON ipinfo_geoloc.public.TO_JOIN_KEY(cdc.ip_address) = loc.join_key
        AND ipinfo_geoloc.public.TO_INT(cdc.ip_address) 
        BETWEEN start_ip_int AND end_ip_int
        JOIN AGS_GAME_AUDIENCE.RAW.TIME_OF_DAY_LU tod
        ON HOUR(CONVERT_TIMEZONE( 'UTC',timezone,cdc.datetime_iso8601)) = tod.hour
      ) r
ON r.GAMER_NAME = e.GAMER_NAME
AND r.GAME_EVENT_UTC = e.GAME_EVENT_UTC
AND r.GAME_EVENT_NAME = e.GAME_EVENT_NAME 
WHEN NOT MATCHED THEN 
INSERT (IP_ADDRESS, GAMER_NAME, GAME_EVENT_NAME
        , GAME_EVENT_UTC, CITY, REGION
        , COUNTRY, GAMER_LTZ_NAME, GAME_EVENT_LTZ
        , DOW_NAME, TOD_NAME)
        VALUES
        (IP_ADDRESS, GAMER_NAME, GAME_EVENT_NAME
        , GAME_EVENT_UTC, CITY, REGION
        , COUNTRY, GAMER_LTZ_NAME,GAME_EVENT_LTZ
        , DOW_NAME, TOD_NAME);
 
--Did all the rows from the stream disappear? 
select * 
from ags_game_audience.raw.ed_cdc_stream; 

/* 🥋 Create a CDC-Fueled, Time-Driven Task */
--turn off the other task (we won't need it anymore)
alter task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED suspend;

--Create a new task that uses the MERGE you just tested
create or replace task AGS_GAME_AUDIENCE.RAW.CDC_LOAD_LOGS_ENHANCED
	USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE='XSMALL'
	SCHEDULE = '5 minutes'
    WHEN system$stream_has_data('ed_cdc_stream')
	as 
MERGE INTO AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED e
USING (
        SELECT cdc.ip_address 
        , cdc.user_login as GAMER_NAME
        , cdc.user_event as GAME_EVENT_NAME
        , cdc.datetime_iso8601 as GAME_EVENT_UTC
        , city
        , region
        , country
        , timezone as GAMER_LTZ_NAME
        , CONVERT_TIMEZONE( 'UTC',timezone,cdc.datetime_iso8601) as game_event_ltz
        , DAYNAME(game_event_ltz) as DOW_NAME
        , TOD_NAME
        from ags_game_audience.raw.ed_cdc_stream cdc
        JOIN ipinfo_geoloc.demo.location loc 
        ON ipinfo_geoloc.public.TO_JOIN_KEY(cdc.ip_address) = loc.join_key
        AND ipinfo_geoloc.public.TO_INT(cdc.ip_address) 
        BETWEEN start_ip_int AND end_ip_int
        JOIN AGS_GAME_AUDIENCE.RAW.TIME_OF_DAY_LU tod
        ON HOUR(game_event_ltz) = tod.hour
      ) r
ON r.GAMER_NAME = e.GAMER_NAME
AND r.GAME_EVENT_UTC = e.GAME_EVENT_UTC
AND r.GAME_EVENT_NAME = e.GAME_EVENT_NAME 
WHEN NOT MATCHED THEN 
INSERT (IP_ADDRESS, GAMER_NAME, GAME_EVENT_NAME
        , GAME_EVENT_UTC, CITY, REGION
        , COUNTRY, GAMER_LTZ_NAME, GAME_EVENT_LTZ
        , DOW_NAME, TOD_NAME)
        VALUES
        (IP_ADDRESS, GAMER_NAME, GAME_EVENT_NAME
        , GAME_EVENT_UTC, CITY, REGION
        , COUNTRY, GAMER_LTZ_NAME, GAME_EVENT_LTZ
        , DOW_NAME, TOD_NAME);
        
--Resume the task so it is running
alter task AGS_GAME_AUDIENCE.RAW.CDC_LOAD_LOGS_ENHANCED resume;
alter task AGS_GAME_AUDIENCE.RAW.CDC_LOAD_LOGS_ENHANCED suspend;

select count(*) from ed_pipeline_logs;


/* DORA CHECKUP */
select DEMO_DB.PUBLIC.GRADER(step, (actual = expected), actual, expected, description) as graded_results from
(
SELECT
'DNGW06' as step
 ,(
   select CASE WHEN pipe_status:executionState::text = 'RUNNING' THEN 1 ELSE 0 END 
   from(
   select parse_json(SYSTEM$PIPE_STATUS( 'ags_game_audience.raw.GET_NEW_FILES' )) as pipe_status)
  ) as actual
 ,1 as expected
 ,'Pipe exists and is RUNNING' as description
 ); 