-- Lesson_5_Productionizing_Our_Work

/* 🥋 SYSADMIN Privileges for Executing Tasks */


--You have to run this grant or you won't be able to test your tasks while in SYSADMIN role
--this is true even if SYSADMIN owns the task!!
grant execute task on account to role SYSADMIN;

--Now you should be able to run the task, even if your role is set to SYSADMIN
execute task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED;

--the SHOW command might come in handy to look at the task 
show tasks in account;

--you can also look at any task more in depth using DESCRIBE
describe task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED;

/* 🥋 Execute the Task a Few More Times */

--Run the task a few times to see changes in the RUN HISTORY
execute task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED;

/* 🥋 Executing the Task to Load More Rows */
--make a note of how many rows you have in the table
select count(*)
from AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED; -- 184 records before task execution

-- OWN
select *
from AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED where gamer_name like '%princ%';
-- OWN END

--Run the task to load more rows
execute task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED;

--check to see how many rows were added
select count(*)
from AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED;

-----------------------------------------------------------------------------------
/* 🥋 Trunc & Reload Like It's Y2K! */
--first we dump all the rows out of the table
truncate table ags_game_audience.enhanced.LOGS_ENHANCED;

--then we put them all back in
INSERT INTO ags_game_audience.enhanced.LOGS_ENHANCED (
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
from ags_game_audience.raw.LOGS logs
JOIN ipinfo_geoloc.demo.location loc 
ON ipinfo_geoloc.public.TO_JOIN_KEY(logs.ip_address) = loc.join_key
AND ipinfo_geoloc.public.TO_INT(logs.ip_address) 
BETWEEN start_ip_int AND end_ip_int
JOIN ags_game_audience.raw.TIME_OF_DAY_LU tod
ON HOUR(CONVERT_TIMEZONE( 'UTC',timezone,logs."datetime_iso8601")) = tod.hour);

--we should do this every 5 minutes from now until the next millenium - Y3K!!!

----------------------------------------------------------------------------------------------
/* 📓 Rebuild and Replace */

/* 🥋 Create a Backup Copy of the Table */

--clone the table to save this version as a backup
--since it holds the records from the UPDATED FEED file, we'll name it _UF
create table ags_game_audience.enhanced.LOGS_ENHANCED_UF 
clone ags_game_audience.enhanced.LOGS_ENHANCED;

-- MERGE SYNTAX 
/* But this code will return an error because each gamer_name has more than one row in our table currently.  What will we need to add to allow our merge to find unique records?*/
MERGE INTO ENHANCED.LOGS_ENHANCED e
USING RAW.LOGS r
ON r.user_login = e.GAMER_NAME
WHEN MATCHED THEN
UPDATE SET IP_ADDRESS = 'Hey I updated matching rows!';

/* 📓 A Working Update Merge */
MERGE INTO ENHANCED.LOGS_ENHANCED e /* UPDATED WORKS ON => ENHANCED.LOGS_ENHANCED */
USING RAW.LOGS r
ON r.user_login = e.GAMER_NAME
AND r."datetime_iso8601" = e.GAME_EVENT_UTC
AND r.user_event = e.GAME_EVENT_NAME
WHEN MATCHED THEN
UPDATE SET IP_ADDRESS = 'Hey I updated matching rows!';

select * FROM raw.logs;
select * from AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED; -- 
select * from AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED_UF; -- CLONED version of AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED

--------------------------------------------------------------------------------------------------------------------------------------

/* 🥋 Truncate Again for a Fresh Start */

--let's truncate so we can start the load over again
-- remember we have that cloned back up so it's fine
truncate table AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED;

/* 🥋 Build Your Insert Merge */
MERGE INTO ENHANCED.LOGS_ENHANCED e
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
from ags_game_audience.raw.LOGS logs
JOIN ipinfo_geoloc.demo.location loc 
ON ipinfo_geoloc.public.TO_JOIN_KEY(logs.ip_address) = loc.join_key
AND ipinfo_geoloc.public.TO_INT(logs.ip_address) 
BETWEEN start_ip_int AND end_ip_int
JOIN ags_game_audience.raw.TIME_OF_DAY_LU tod
ON HOUR(CONVERT_TIMEZONE( 'UTC',timezone,logs."datetime_iso8601")) = tod.hour
    ) r
ON r.GAMER_NAME = e."GAMER_NAME"
AND r."GAME_EVENT_UTC" = e.GAME_EVENT_UTC
AND r."GAME_EVENT_NAME" = e.GAME_EVENT_NAME
WHEN NOT MATCHED THEN
INSERT (IP_ADDRESS,GAMER_NAME,GAME_EVENT_NAME,
       GAME_EVENT_UTC,CITY,REGION,COUNTRY
       ,GAMER_LTZ_NAME,GAME_EVENT_LTZ,
       DOW_NAME,TOD_NAME) VALUES
       (IP_ADDRESS,GAMER_NAME,GAME_EVENT_NAME,
       GAME_EVENT_UTC,CITY,REGION,COUNTRY
       ,GAMER_LTZ_NAME,GAME_EVENT_LTZ,
       DOW_NAME,TOD_NAME);
       
-----------------------------------------------------------------------------------------

/* 📓 One Bite at a Time FINAL TASK*/

create or replace task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED
	warehouse=COMPUTE_WH
	schedule='5 minute'
    as
    MERGE INTO ENHANCED.LOGS_ENHANCED e
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
from ags_game_audience.raw.LOGS logs
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
       
-----------------------------------------------------------------------------------------------

/* 🥋 Testing Cycle (Optional) */
--Testing cycle for MERGE. Use these commands to make sure the Merge works as expected

--Write down the number of records in your table 
select * from AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED;

--Run the Merge a few times. No new rows should be added at this time 
EXECUTE TASK AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED;

--Check to see if your row count changed 
select * from AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED;

--Insert a test record into your Raw Table 
--You can change the user_event field each time to create "new" records 
--editing the ip_address or datetime_iso8601 can complicate things more than they need to 
--editing the user_login will make it harder to remove the fake records after you finish testing 
INSERT INTO ags_game_audience.raw.game_logs 
select PARSE_JSON('{"datetime_iso8601":"2025-01-01 00:00:00.000", "ip_address":"196.197.196.255", "user_event":"fake event", "user_login":"fake user"}');

--After inserting a new row, run the Merge again 
EXECUTE TASK AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED;

--Check to see if any rows were added 
select * from AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED;

--When you are confident your merge is working, you can delete the raw records 
delete from ags_game_audience.raw.game_logs where raw_log like '%fake user%';

--You should also delete the fake rows from the enhanced table
delete from AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED
where gamer_name = 'fake user';

--Row count should be back to what it was in the beginning
select * from AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED; 

/* 🤖 Run This in Your Worksheet to Send a Report to DORA */
-- NEVER CHANGE DORA CODE TO GET A GREEN CHECK. CHANGE YOUR LAB WORK.

select DEMO_DB.PUBLIC.GRADER(step, (actual = expected), actual, expected, description) as graded_results from
(
SELECT
'DNGW04' as step
 ,(select count(*)/count(*)
  from table(ags_game_audience.information_schema.task_history
              (task_name=>'LOAD_LOGS_ENHANCED'))) as actual
 ,1 as expected
 ,'Task exists and has been run at least once' as description
 ); 
    
-----------------------------------------------------------------------------------
-- create or replace task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED_1
-- 	warehouse=COMPUTE_WH
-- 	schedule='5 minute'
--     as
--     MERGE INTO ENHANCED.LOGS_ENHANCED e
-- USING (
-- SELECT logs.ip_address 
-- , logs.user_login as GAMER_NAME
-- , logs.user_event as GAME_EVENT_NAME
-- , logs."datetime_iso8601" as GAME_EVENT_UTC
-- , city
-- , region
-- , country
-- , timezone as GAMER_LTZ_NAME
-- , CONVERT_TIMEZONE( 'UTC',timezone,logs."datetime_iso8601") as game_event_ltz
-- , DAYNAME(game_event_ltz) as DOW_NAME
-- , TOD_NAME
-- from ags_game_audience.raw.LOGS logs
-- JOIN ipinfo_geoloc.demo.location loc 
-- ON ipinfo_geoloc.public.TO_JOIN_KEY(logs.ip_address) = loc.join_key
-- AND ipinfo_geoloc.public.TO_INT(logs.ip_address) 
-- BETWEEN start_ip_int AND end_ip_int
-- JOIN ags_game_audience.raw.TIME_OF_DAY_LU tod
-- ON HOUR(CONVERT_TIMEZONE( 'UTC',timezone,logs."datetime_iso8601")) = tod.hour
--     ) r
-- ON r.GAMER_NAME = e.GAMER_NAME
-- AND r.GAME_EVENT_UTC = e.GAME_EVENT_UTC
-- AND r.GAME_EVENT_NAME = e.GAME_EVENT_NAME
-- WHEN NOT MATCHED THEN
-- INSERT (IP_ADDRESS,GAMER_NAME,GAME_EVENT_NAME,
--        GAME_EVENT_UTC,CITY,REGION,COUNTRY
--        ,GAMER_LTZ_NAME,GAME_EVENT_LTZ,
--        DOW_NAME,TOD_NAME) VALUES
--        (IP_ADDRESS,GAMER_NAME,GAME_EVENT_NAME,
--        GAME_EVENT_UTC,CITY,REGION,COUNTRY
--        ,GAMER_LTZ_NAME,GAME_EVENT_LTZ,
--        DOW_NAME,TOD_NAME);