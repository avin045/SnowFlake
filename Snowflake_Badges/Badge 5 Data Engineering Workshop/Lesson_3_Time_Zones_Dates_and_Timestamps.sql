-- Lesson_3_Time_Zones_Dates_and_Timestamps

SELECT current_timestamp();

/* 🥋 Change the Time Zone for Your Current Worksheet */
--what time zone is your account(and/or session) currently set to? Is it -0700?
select current_timestamp();

-- CHECKS which TimeZone
show parameters like '%timezone%';

--worksheets are sometimes called sessions -- we'll be changing the worksheet time zone
alter session set timezone = 'UTC';
select current_timestamp();

--how did the time differ after changing the time zone for the worksheet?
alter session set timezone = 'Africa/Nairobi';
select current_timestamp();

alter session set timezone = 'Pacific/Funafuti';
select current_timestamp();

alter session set timezone = 'Asia/Shanghai';
select current_timestamp();

--show the account parameter called timezone
show parameters like 'timezone';

-- CHANGE UTC TO IST //OWN
SELECT '2020-02-29 23:59:57' AS Date, 
convert_timezone('GMT','Asia/Kolkata', '2020-02-29 23:59:57') IST_datetime,
cast(convert_timezone('GMT','Asia/Kolkata', '2020-02-29 23:59:57') AS datetime) IST_date;

/* 📓 Time Zones in Agnie's Data */
select * from logs;


------------------------------------------------------------------------------------------

/* LIST STAGES */
list @uni_kishore;

-- COPY NEW ROWS TO game_logs TABLE.
copy into ags_game_audience.raw.game_logs
from @uni_kishore/updated_feed
file_format = (format_name = FF_JSON_LOGS);

/* 📓 Wrapping New View  */
   select
RAW_LOG:agent::text as AGENT,
RAW_LOG:datetime_iso8601::TIMESTAMP_NTZ as "datetime_iso8601", -- RAW_LOG:datetime_iso8601::datetime
RAW_LOG:user_event::text as USER_EVENT,
RAW_LOG:user_login::text as USER_LOGIN,
RAW_LOG:ip_address::text as IP_ADDRESS,
*
from game_logs;

CREATE OR REPLACE VIEW LOGS as (
   select
-- RAW_LOG:agent::text as AGENT,
RAW_LOG:datetime_iso8601::TIMESTAMP_NTZ as "datetime_iso8601", -- RAW_LOG:datetime_iso8601::datetime
RAW_LOG:user_event::text as USER_EVENT,
RAW_LOG:user_login::text as USER_LOGIN,
RAW_LOG:ip_address::text as IP_ADDRESS,
*
from game_logs where IP_ADDRESS IS NOT NULL
);

/*
🎯 CHALLENGE: Filter Out the Old Rows
Can you write a select statement that will filter out the old rows? Remember that one column was added and another was removed. Using one or both of these fields can you write a SELECT that will return only rows from the second file? 

Two possible solutions are listed on the next page. Take your time and try to solve this on your own before proceeding. 
*/

select * from logs where IP_ADDRESS is not null;


/* 🥋 Two Filtering Options */
--looking for empty AGENT column
select * 
from ags_game_audience.raw.LOGS
where agent is null;

--looking for non-empty IP_ADDRESS column
select 
RAW_LOG:ip_address::text as IP_ADDRESS
,*
from ags_game_audience.raw.LOGS
where RAW_LOG:ip_address::text is not null;


/*
🎯 CHALLENGE: Update Your LOG View
Change the LOG view definition so that it no longer contains an AGENT column. 
Change the LOG view definition so that it now contains the IP_ADDRESS column. 
Add a WHERE clause that will remove the first set of records from the view results. Do NOT remove the rows from the table. 
*/

select * from logs;

/* Find "Prajina" Record */
select * from logs where USER_LOGIN like '%prajina'; -- ENDSWITH

/* 🤖 Run this DORA Check 
NEVER CHANGE DORA CODE TO GET A GREEN CHECK. CHANGE YOUR LAB WORK. */

select GRADER(step, (actual = expected), actual, expected, description) as graded_results from
(
SELECT
   'DNGW02' as step
   ,( select sum(tally) from(
        select (count(*) * -1) as tally
        from ags_game_audience.raw.logs 
        union all
        select count(*) as tally
        from ags_game_audience.raw.game_logs)     
     ) as actual
   ,250 as expected
   ,'View is filtered' as description
); 