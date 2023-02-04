-- Lesson_4_Extracting_Transforming_and_Loading

/* 🎯 Use Snowflake's PARSE_IP Function
" select parse_ip('<ip address>','inet'); "
*/

select parse_ip('212.77.102.236','inet');

/* 🎯 Pull Out PARSE_IP Results Fields
We can pull out the values from the PARSE_IP results by adding a colon and the name after the close parentheses,
like this:
*/
select parse_ip('107.217.231.17','inet'):host;
select parse_ip('107.217.231.17','inet'):family;
select parse_ip('107.217.231.17','inet'):ipv4;

/* USE "parse_ip" in LOG View */
select *,parse_ip(IP_ADDRESS,'inet'):ipv4 as ipv4_from_IP_ADDRESS from logs where user_login like '%prajina';

/* 🎯 Enhancement Infrastructure
Create a new schema in the database and call it ENHANCED */

create schema ENHANCED;

-- drop schema enhanced;
USE schema ENHANCED;

/* 🥋 Look Up Kishore's Time Zone */
--Look up Kishore's Time Zone in the IPInfo share using his headset's IP Address with the PARSE_IP function.

select start_ip, end_ip, start_ip_int, end_ip_int, city, region, country, timezone
from IPINFO_GEOLOC.demo.location
where parse_ip('63.235.15.153', 'inet'):ipv4 --Kishore's Headset's IP Address
BETWEEN start_ip_int AND end_ip_int;

/* 🥋 Look Up Everyone's Time Zone */
--Join the log and location tables to add time zone to each row using the PARSE_IP function.

-- The CARTESIAN is also called CROSS JOIN 
select logs.*
       , loc.city
       , loc.region
       , loc.country
       , loc.timezone
from AGS_GAME_AUDIENCE.RAW.LOGS logs
join IPINFO_GEOLOC.demo.location AS loc
where parse_ip(logs.ip_address, 'inet'):ipv4 
BETWEEN start_ip_int AND end_ip_int ; -- having user_login like '%prajina' /* QUERY TIME : 7.7 Seconds */

/* 🥋 Use the IPInfo Functions for a More Efficient Lookup 
--Use two functions supplied by IPShare to help with an efficient IP Lookup Process!

The TO_JOIN_KEY function reduces the IP Down to an integer that is helpful for joining with a range of rows that might match our IP Address.
The TO_INT function converts IP Addresses to integers so we don't have to try to compare them as strings! */

SELECT 
logs.ip_address
, logs.user_login
, logs.user_event
, logs."datetime_iso8601"
, city
, region
, country
, timezone 
from AGS_GAME_AUDIENCE.RAW.LOGS logs
JOIN IPINFO_GEOLOC.demo.location loc 
ON IPINFO_GEOLOC.public.TO_JOIN_KEY(logs.ip_address) = loc.join_key
AND IPINFO_GEOLOC.public.TO_INT(logs.ip_address) 
BETWEEN start_ip_int AND end_ip_int;

/* UNDERSTANDING of TO_JOIN_KEY(IP_ADDRESS to ipv4) function working */
desc table logs;
select * from logs;
select IPINFO_GEOLOC.PUBLIC.to_join_key(ip_address) from logs;

select before_to_join_key.ip_address,
IPINFO_GEOLOC.PUBLIC.to_join_key(after_to_join_key.ip_address) as after_to_join_key 
from logs as before_to_join_key 
join logs as after_to_join_key 
on 
before_to_join_key.ip_address = after_to_join_key.ip_address;
----------------------------------------------------------------------------------------

/* 📓 Create a Local Time Column! 
Now we have the local time zone for many of our gamers. 

These 3 pieces of information are exactly what we need to create a new column that contains the local date and time of the gaming event. 

Kishore will use a function he found on docs.snowflake.com called CONVERT_TIMEZONE. 
*/

/* 🎯 Add a Local Time Zone Column to Your Select
Add a column called GAME_EVENT_LTZ
After you create the new column, use the test rows created by Kishore's sister to make sure the conversion worked. 
*/
SELECT 
logs.ip_address
, logs.user_login
, logs.user_event
, logs."datetime_iso8601"
, city
, region
, country
, timezone
, convert_timezone('UTC',timezone,logs."datetime_iso8601") as game_event_ltz
from AGS_GAME_AUDIENCE.RAW.LOGS logs
JOIN IPINFO_GEOLOC.demo.location loc 
ON IPINFO_GEOLOC.public.TO_JOIN_KEY(logs.ip_address) = loc.join_key
AND IPINFO_GEOLOC.public.TO_INT(logs.ip_address) 
BETWEEN start_ip_int AND end_ip_int;

------------------------------------------------------------------------------------------------------
/* 🎯 Add A Column Called DOW_NAME */
SELECT DAYNAME("datetime_iso8601") FROM logs;
-- select * from logs;

------------------------------------------------------------------------------------------------------------------
/* 📓 Assigning a Time of Day */

/* 🥋 Create the Table and Fill in the Values */

-- Your role should be SYSADMIN
-- Your database menu should be set to AGS_GAME_AUDIENCE
-- The schema should be set to RAW

--a Look Up table to convert from hour number to "time of day name"
create table ags_game_audience.raw.time_of_day_lu
(  hour number
   ,tod_name varchar(25)
);

--insert statement to add all 24 rows to the table
insert into time_of_day_lu
values
(6,'Early morning'),
(7,'Early morning'),
(8,'Early morning'),
(9,'Mid-morning'),
(10,'Mid-morning'),
(11,'Late morning'),
(12,'Late morning'),
(13,'Early afternoon'),
(14,'Early afternoon'),
(15,'Mid-afternoon'),
(16,'Mid-afternoon'),
(17,'Late afternoon'),
(18,'Late afternoon'),
(19,'Early evening'),
(20,'Early evening'),
(21,'Late evening'),
(22,'Late evening'),
(23,'Late evening'),
(0,'Late at night'),
(1,'Late at night'),
(2,'Late at night'),
(3,'Toward morning'),
(4,'Toward morning'),
(5,'Toward morning');

/* 🥋 Check the Table */
--Check your table to see if you loaded it properly
select tod_name, listagg(hour,',') AS time_in_railway_time /* group concat */
from time_of_day_lu
group by tod_name;

/*  TOD_NAME into his results.  */
SELECT 
logs.ip_address
, logs.user_login
, logs.user_event
, logs."datetime_iso8601"
, city
, region
, country
, timezone
, convert_timezone('UTC',timezone,logs."datetime_iso8601") as game_event_ltz
, DAYNAME(game_event_ltz) as DOW_NAME
, tod_name
from AGS_GAME_AUDIENCE.RAW.LOGS logs
JOIN IPINFO_GEOLOC.demo.location loc 
ON IPINFO_GEOLOC.public.TO_JOIN_KEY(logs.ip_address) = loc.join_key
AND IPINFO_GEOLOC.public.TO_INT(logs.ip_address) 
BETWEEN start_ip_int AND end_ip_int
JOIN time_of_day_lu time
on hour("datetime_iso8601") = time.hour;

/* 🎯 A Join with a Function as per snowflake REPLACEMENT for above statement */
SELECT 
logs.ip_address
, logs.user_login as GAMER_NAME
, logs.user_event as GAME_EVENT_NAME
, logs."datetime_iso8601" as GAME_EVENT_UTC
, city
, region
, country
, timezone as GAMER_LTZ_NAME
, convert_timezone('UTC',timezone,logs."datetime_iso8601") as game_event_ltz
, DAYNAME("datetime_iso8601") as DOW_NAME
, hour("datetime_iso8601")as "Hour"
, time.hour
, tod_name
from AGS_GAME_AUDIENCE.RAW.LOGS logs
JOIN IPINFO_GEOLOC.demo.location loc 
ON IPINFO_GEOLOC.public.TO_JOIN_KEY(logs.ip_address) = loc.join_key
AND IPINFO_GEOLOC.public.TO_INT(logs.ip_address) 
BETWEEN start_ip_int AND end_ip_int
JOIN time_of_day_lu time
on Hour = time.hour;

/* 🥋 Convert a Select to a Table */
--Wrap any Select in a CTAS statement

create or replace table ags_game_audience.enhanced.logs_enhanced as(
select logs.ip_address
,logs.user_login as GAMER_NAME
,logs.user_event as GAME_EVENT_NAME
,logs."datetime_iso8601" as GAME_EVENT_UTC
,city
,region
,country
,timezone as GAMER_LTZ_NAME
,convert_timezone('UTC',timezone,logs."datetime_iso8601") as game_event_ltz
,dayname(game_event_ltz) as DOW_NAME
, TOD_NAME
from AGS_GAME_AUDIENCE.RAW.LOGS AS logs
JOIN IPINFO_GEOLOC.DEMO.LOCATION as loc
ON IPINFO_GEOLOC.public.TO_JOIN_KEY(logs.ip_address) = loc.join_key
AND IPINFO_GEOLOC.public.TO_INT(logs.ip_address)
between start_ip_int AND end_ip_int
JOIN AGS_GAME_AUDIENCE.RAW.TIME_OF_DAY_LU AS tdl
on tdl.hour = HOUR(convert_timezone('UTC',timezone,logs."datetime_iso8601"))
);

-- drop table ags_game_audience.enhanced.logs_enhanced;
-- view the VIEW
-- select * from ags_game_audience.enhanced.logs_enhanced;

/* 🤖 Run this DORA Check  */
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from
(
  SELECT
   'DNGW03' as step
   ,( select count(*) 
      from ags_game_audience.enhanced.logs_enhanced
      where dow_name = 'Sat'
      and tod_name = 'Early evening'   
      and gamer_name like '%prajina'
     ) as actual
   ,2 as expected
   ,'Playing the game on a Saturday evening' as description
); 

-- CHECKING -----------------------------------------------------------------------------------------------------

select count(*) 
      from ags_game_audience.enhanced.logs_enhanced
      where dow_name = 'Sat'
      and tod_name = 'Early evening'   
      and gamer_name like '%prajina';
      
select * from TIME_OF_DAY_LU;

select logs.ip_address
,logs.user_login
,logs.user_event
,logs."datetime_iso8601"
,city
,region
,country
,timezone
,convert_timezone('UTC',timezone,logs."datetime_iso8601") as game_event_ltz
,dayname(game_event_ltz) as DOW_NAME
, hour(game_event_ltz) as coverted
, tdl.hour
, TOD_NAME
from AGS_GAME_AUDIENCE.RAW.LOGS AS logs
JOIN IPINFO_GEOLOC.DEMO.LOCATION as loc
ON IPINFO_GEOLOC.public.TO_JOIN_KEY(logs.ip_address) = loc.join_key
AND IPINFO_GEOLOC.public.TO_INT(logs.ip_address)
between start_ip_int AND end_ip_int
JOIN AGS_GAME_AUDIENCE.RAW.TIME_OF_DAY_LU AS tdl
on tdl.hour = HOUR(convert_timezone('UTC',timezone,logs."datetime_iso8601"))
;

select * from ags_game_audience.enhanced.logs_enhanced;