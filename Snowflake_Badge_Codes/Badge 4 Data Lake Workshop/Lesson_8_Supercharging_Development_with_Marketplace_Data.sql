-- Lesson_8_Supercharging_Development_with_Marketplace_Data

/* 🥋 Using Variables in Snowflake Worksheets  */

-- Melanie's Location into a 2 Variables (mc for melanies cafe)
set mc_lat='-104.97300245114094';
set mc_lng='39.76471253574085';

--Confluence Park into a Variable (loc for location)
set loc_lat='-105.00840763333615'; 
set loc_lng='39.754141917497826';

--Test your variables to see if they work with the Makepoint function
select st_makepoint($mc_lat,$mc_lng) as melanies_cafe_point;
select st_makepoint($loc_lat,$loc_lng) as confluent_park_point;

--use the variables to calculate the distance from 
--Melanie's Cafe to Confluent Park
select st_distance(
        st_makepoint($mc_lat,$mc_lng)
        ,st_makepoint($loc_lat,$loc_lng)
        ) as mc_to_cp; -- OUTPUT distance as metres(3246.663099525 metre)


/* 📓 Variables are Cool, But Constants Aren't So Bad! */
select st_makepoint('-104.97300245114094','39.76471253574085'),
st_makepoint($loc_lat,$loc_lng) as mc_to_cp;

-----------------------------------------------------------------------------------------------------------

/* 📓 Let's Create a UDF for Measuring Distance from Melanie's Café */

create schema LOCATIONS;

-- UDF  --> DISTANCE_TO_MC (for Distance to Melanie's Café). 
CREATE FUNCTION distance_to_mc(loc_lat number(38,32), loc_lng number(38,32))
  RETURNS FLOAT
  AS
  $$
     st_distance(
        st_makepoint('-104.97300245114094','39.76471253574085')
        ,st_makepoint(loc_lat,loc_lng)
        )
  $$
  ;

/* 🥋 Test the New Function! */
--Tivoli Center into the variables 
set tc_lat='-105.00532059763648'; 
set tc_lng='39.74548137398218';

select distance_to_mc($tc_lat,$tc_lng);

---------------------------------------------------------------------

/* 🥋 Create a List of Competing Juice Bars in the Area */

select * 
from OPENSTREETMAP_DENVER.DENVER.V_OSM_DEN_AMENITY_SUSTENANCE
where 
    ((amenity in ('fast_food','cafe','restaurant','juice_bar'))
    and 
    (name ilike '%jamba%' or name ilike '%juice%'
     or name ilike '%superfruit%'))
 or 
    (cuisine like '%smoothie%' or cuisine like '%juice%');
  
/* 🎯 Convert the List into a View */
--  Create a view called COMPETITION 
use schema locations;

create view COMPETITION as (
    select * 
from OPENSTREETMAP_DENVER.DENVER.V_OSM_DEN_AMENITY_SUSTENANCE
where 
    ((amenity in ('fast_food','cafe','restaurant','juice_bar'))
    and 
    (name ilike '%jamba%' or name ilike '%juice%'
     or name ilike '%superfruit%'))
 or 
    (cuisine like '%smoothie%' or cuisine like '%juice%')
);

/* 🥋 Which Competitor is Closest to Melanie's? */
SELECT
 name
 ,cuisine
 , ST_DISTANCE(
    st_makepoint('-104.97300245114094','39.76471253574085')
    , coordinates
  ) AS distance_from_melanies
 ,*
FROM  competition
ORDER by distance_from_melanies;

/* 🥋 Changing the Function to Accept a GEOGRAPHY Argument  */
CREATE OR REPLACE FUNCTION distance_to_mc(lat_and_lng GEOGRAPHY)
  RETURNS FLOAT
  AS
  $$
   st_distance(
        st_makepoint('-104.97300245114094','39.76471253574085')
        ,lat_and_lng
        )
  $$
  ;
  
/* 🥋 Now We Can Use it In Our Sonra Select */

SELECT
 name
 ,cuisine
 ,distance_to_mc(coordinates) AS distance_from_melanies
 ,*
FROM  competition
ORDER by distance_from_melanies;

/* 🥋 Different Options, Same Outcome! */

-- Tattered Cover Bookstore McGregor Square
set tcb_lat='-104.9956203'; 
set tcb_lng='39.754874';

--this will run the first version of the UDF
select distance_to_mc($tcb_lat,$tcb_lng);

--this will run the second version of the UDF, bc it converts the coords 
--to a geography object before passing them into the function
select distance_to_mc(st_makepoint($tcb_lat,$tcb_lng));

--this will run the second version bc the Sonra Coordinates column
-- contains geography objects already
select name
, distance_to_mc(coordinates) as distance_to_melanies 
, ST_ASWKT(coordinates)
from OPENSTREETMAP_DENVER.DENVER.V_OSM_DEN_SHOP
where shop='books' 
and name like '%Tattered Cover%'
and addr_street like '%Wazee%';


-------------------------------------------------------------------------------------------------
/* 🎯 Create a View of Bike Shops in the Denver Data */
use role sysadmin;

select *,distance_to_mc(coordinates) as DISTANCE_TO_MELANIES 
from 
OPENSTREETMAP_DENVER.DENVER.V_OSM_DEN_SHOP_OUTDOORS_AND_SPORT_VEHICLES 
where shop = 'bicycle';

-- CREATE A VIEW for above SELECT statement
create view DENVER_BIKE_SHOPS as (
    select *,distance_to_mc(coordinates) as DISTANCE_TO_MELANIES 
from OPENSTREETMAP_DENVER.DENVER.V_OSM_DEN_SHOP_OUTDOORS_AND_SPORT_VEHICLES 
where shop = 'bicycle'
);
desc table OPENSTREETMAP_DENVER.DENVER.V_OSM_DEN_SHOP;

-- select on VIEW ==> DENVER_BIKE_SHOPS
select name,distance_to_melanies from DENVER_BIKE_SHOPS;



/* 🤖 Run This in Your Worksheet to Send a Report to DORA */
select DEMO_DB.PUBLIC.GRADER(step, (actual = expected), actual, expected, description) as graded_results from
(
  SELECT
  'DLKW08' as step
  ,(select truncate(distance_to_melanies)
      from mels_smoothie_challenge_db.locations.denver_bike_shops
      where name like '%Mojo%') as actual
  ,14084 as expected
  ,'Bike Shop View Distance Calc works' as description
 ); 
 
 -------------------------------------------------------------------------------------------------
 
 /* 🥋 Remember this View? Let's Look at it, then Rename It! */
 
 select * from mels_smoothie_challenge_db.trails.cherry_creek_trail;
 
 /* 
 We're going to create this same data structure with an External Table so let's change the name of our view to have "V_" in front of the name. That way we can create a table that starts with "T_".
 */

alter view mels_smoothie_challenge_db.trails.cherry_creek_trail
rename to mels_smoothie_challenge_db.trails.v_cherry_creek_trail;

/* 🥋 Let's Create a Super-Simple, Stripped Down External Table */
create or replace external table T_CHERRY_CREEK_TRAIL(
	my_filename varchar(50) as (metadata$filename::varchar(50))
) 
location= @trails_parquet
auto_refresh = true
file_format = (type = parquet);
 
-- list @trails_parquet;
-- show stages;

/* 🥋 Now Let's Modify Our V_CHERRY_CREEK_TRAIL Code to Create the New Table */
select get_ddl('view','mels_smoothie_challenge_db.trails.v_cherry_creek_trail');

create or replace external table mels_smoothie_challenge_db.trails.T_CHERRY_CREEK_TRAIL(
	POINT_ID number as ($1:sequence_1::number),
	TRAIL_NAME varchar(50) as  ($1:trail_name::varchar),
	LNG number(11,8) as ($1:latitude::number(11,8)),
	LAT number(11,8) as ($1:longitude::number(11,8)),
	COORD_PAIR varchar(50) as (lng::varchar||' '||lat::varchar)
) 
location= @mels_smoothie_challenge_db.trails.trails_parquet
auto_refresh = true
file_format = mels_smoothie_challenge_db.trails.ff_parquet;

select * from t_cherry_creek_trail;

/* 🎯 Create a Materialized View on Top of the External Table */
create secure materialized view SMV_CHERRY_CREEK_TRAIL
    as (select * from t_cherry_creek_trail);

select * from SMV_CHERRY_CREEK_TRAIL;

/* 🤖 Run This in Your Worksheet to Send a Report to DORA */

select row_count
     from mels_smoothie_challenge_db.information_schema.tables
     where table_schema = 'TRAILS'
    and table_name = 'SMV_CHERRY_CREEK_TRAIL';

select DEMO_DB.PUBLIC.GRADER(step, (actual = expected), actual, expected, description) as graded_results from
(
  SELECT
  'DLKW09' as step
  ,(select row_count
     from mels_smoothie_challenge_db.information_schema.tables
     where table_schema = 'TRAILS'
    and table_name = 'SMV_CHERRY_CREEK_TRAIL')   
   as actual
  ,3526 as expected
  ,'Secure Materialized View Created' as description
 ); 