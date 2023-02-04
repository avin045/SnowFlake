-- Lesson_6_Productionizing_Across_the_Pipeline

/* 🎯 Create A New Stage and a New Target Table! */

create stage UNI_KISHORE_PIPELINE 
url = 's3://uni-kishore-pipeline';

-- LIST THE STAGE
LIST @UNI_KISHORE_PIPELINE;

/* Create a table called PIPELINE_LOGS (put it in the RAW schema). 
It should have the same structure as the GAME_LOGS table. Same column(s) and column data type(s). */
CREATE table PIPELINE_LOGS as select * from GAME_LOGS;

-- DESCRIBE
desc table AGS_GAME_AUDIENCE.RAW.PIPELINE_LOGS;

/* 🎯 Create Your New COPY INTO => AGS_GAME_AUDIENCE.RAW.PIPELINE_LOGS */

copy into AGS_GAME_AUDIENCE.RAW.PIPELINE_LOGS
FROM @AGS_GAME_AUDIENCE.RAW.UNI_KISHORE_PIPELINE
file_format = (format_name=ff_json_logs);

-- VIEW table
select COUNT(*) from AGS_GAME_AUDIENCE.RAW.PIPELINE_LOGS; -- firstTIME => 1384 secondtime after run copy into(above) => 1394

---------------------------------------------------------------------------------------
/*  📓 Idempotent COPY INTO */

-- TO LOAD THE RECORD MULTIPLE TIMES
/* But, what if, for some crazy reason, you wanted to double-load your files? 
You could add a FORCE=TRUE; as the last line of your 
COPY INTO statement and then you would double the number of rows in your table. */
copy into AGS_GAME_AUDIENCE.RAW.PIPELINE_LOGS
FROM @AGS_GAME_AUDIENCE.RAW.UNI_KISHORE_PIPELINE
file_format = (format_name=ff_json_logs)
FORCE=FALSE;

/* 🎯 Create a New LOGS View */
create or replace view AGS_GAME_AUDIENCE.RAW.PL_LOGS(
	"datetime_iso8601",
	USER_EVENT,
	USER_LOGIN,
	IP_ADDRESS,
	RAW_LOG
) as (
   select
-- RAW_LOG:agent::text as AGENT,
RAW_LOG:datetime_iso8601::TIMESTAMP_NTZ as "datetime_iso8601", -- RAW_LOG:datetime_iso8601::datetime
RAW_LOG:user_event::text as USER_EVENT,
RAW_LOG:user_login::text as USER_LOGIN,
RAW_LOG:ip_address::text as IP_ADDRESS,
*
from game_logs where IP_ADDRESS IS NOT NULL
);

-- VIEW the view(PL_LOGS)
select * from pl_logs;

------------------------------------------------------------------------------
/*
🎯 Modify the Step 4 MERGE Task !
Look at the code you used in your Merge Task, LOAD_LOGS_ENHANCED. 

Does any of the code need to be changed to make it work with the PL_LOGS view instead of the old LOGS view?  If so, change it. 
*/

create or replace task AGS_GAME_AUDIENCE.RAW.GET_NEW_FILES
	warehouse=COMPUTE_WH
	schedule='5 minute'
	as COPY INTO AGS_GAME_AUDIENCE.RAW.PIPELINE_LOGS
FROM @AGS_GAME_AUDIENCE.RAW.UNI_KISHORE_PIPELINE
file_format = (format_name=ff_json_logs);

-- AFTER THE "TASK" was executed check with "PIPELINE_LOGS"
select count(*) from PIPELINE_LOGS; -- 1394 rows , AFTER TASK RUN (above) => 

---------------------------------------------------------------------------------------------
select * from ENHANCED.LOGS_ENHANCED;


---------------------------------------------------------------------------------------------

/* 📓 The Current State of Things
Our process is looking good. We have:

Step 1 TASK (invisible to you, but running every 5 minutes)
Step 2 TASK that will load the new files into the raw table every 5 minutes (as soon as we turn it on).
Step 3 VIEW that is kind of boring but it does some light transformation work for us.  
Step 4 TASK  that will load the new rows into the enhanced table every 5 minutes (as soon as we turn it on).*/

/* 🥋 Turn on Your Tasks! */
--Turning on a task is done with a RESUME command
alter task AGS_GAME_AUDIENCE.RAW.GET_NEW_FILES resume;
alter task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED resume;
-- OWN
execute task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED;
-- alter task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED_1 resume;

-- OWN TRY TO CHECK TASK HISTORY
select *
  from table(information_schema.task_history())
  order by scheduled_time desc;

/* ❕❕❕ You Have Tasks Running! */
--Keep this code handy for shutting down the tasks each day
alter task AGS_GAME_AUDIENCE.RAW.GET_NEW_FILES suspend;
alter task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED suspend;
-- OWN
alter task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED_1 suspend;

SELECT * from AGS_GAME_AUDIENCE.RAW.LOGS;
SELECT * FROM AGS_GAME_AUDIENCE.RAW.PL_LOGS;
SELECT * FROM AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED;

/* 🥋 Checking Tallies Along the Way */

--Step 1 - how many files in the bucket?
list @AGS_GAME_AUDIENCE.RAW.UNI_KISHORE_PIPELINE;

--Step 2 - number of rows in raw table (should be file count x 10)
select count(*) from AGS_GAME_AUDIENCE.RAW.PIPELINE_LOGS;

--Step 3 - number of rows in raw table (should be file count x 10)
select count(*) from AGS_GAME_AUDIENCE.RAW.PL_LOGS;

--Step 4 - number of rows in enhanced table (should be file count x 10 but fewer rows is okay)
select count(*) from AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED;



/* 🤖 Run This in Your Worksheet to Send a Report to DORA
NEVER EDIT THIS CODE TO GET A GREEN CHECK. EDIT YOUR LAB WORK.  */

select DEMO_DB.PUBLIC.GRADER(step, (actual = expected), actual, expected, description) as graded_results from
(
SELECT
'DNGW05' as step
 ,(
   select max(tally) from (
       select CASE WHEN SCHEDULED_FROM = 'SCHEDULE' 
                         and STATE= 'SUCCEEDED' 
              THEN 1 ELSE 0 END as tally 
   from table(ags_game_audience.information_schema.task_history (task_name=>'GET_NEW_FILES')))
  ) as actual
 ,1 as expected
 ,'Task succeeds from schedule' as description
 ); 