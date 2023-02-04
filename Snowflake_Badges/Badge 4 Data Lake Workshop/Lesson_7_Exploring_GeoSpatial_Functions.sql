-- Lesson_7_Exploring_GeoSpatial_Functions

/* 🥋 Re-Using Earlier Code (with a Small Addition) */

--Remember this code? 
select 
'LINESTRING('||
listagg(coord_pair, ',') 
within group (order by point_id)
||')' as my_linestring
,st_length(my_linestring) as length_of_trail --this line is new! but it won't work!
from cherry_creek_trail
group by trail_name;

/* 🎯 TO_GEOGRAPHY Challenge Lab!! */
select 
'LINESTRING('||
listagg(coord_pair, ',') 
within group (order by point_id)
||')' as my_linestring
,st_length(TO_GEOGRAPHY(my_linestring)) as length_of_trail --this line is new! but it will work Now!
from cherry_creek_trail
group by trail_name;

/* 🎯 Calculate the Lengths for the Other Trails 
Use Snowflake's GeoSpatial functions to derive the length of the trails that are available in the DENVER_AREA_TRAILS view. 
*/

-- select * from DENVER_AREA_TRAILS;
select feature_name,st_length(to_geography(geometry)) from DENVER_AREA_TRAILS;



/* 🎯 Change your DENVER_AREA_TRAILS view to include a Length Column! */
-- create a VIEW using DDL
select get_ddl('view','DENVER_AREA_TRAILS');


create or replace view DENVER_AREA_TRAILS(
	FEATURE_NAME,
	FEATURE_COORDINATES,
	GEOMETRY,
	TRIAL_LENGTH, -- EDITED(Newly Added)
	FEATURE_PROPERTIES,
	SPECS,
	WHOLE_OBJECT
) as (
    select
$1:features[0]:properties:Name::string as feature_name
,$1:features[0]:geometry:coordinates::string as feature_coordinates
,$1:features[0]:geometry::string as geometry
,st_length(to_geography(geometry)) as trial_length -- EDITED(Newly Added)
,$1:features[0]:properties::string as feature_properties
,$1:crs:properties:name::string as specs
,$1 as whole_object
from @trails_geojson (file_format => ff_json)
);

select * from denver_area_trails;
select * from cherry_creek_trail;

/* 🥋 Create a View on Cherry Creek Data to Mimic the Other Trail Data */
--Create a view that will have similar columns to DENVER_AREA_TRAILS 
--Even though this data started out as Parquet, and we're joining it with geoJSON data
--So let's make it look like geoJSON instead.
create view DENVER_AREA_TRAILS_2 as
select 
trail_name as feature_name
,'{"coordinates":['||listagg('['||lng||','||lat||']',',')||'],"type":"LineString"}' as geometry
,st_length(to_geography(geometry)) as trail_length
from cherry_creek_trail
group by trail_name;

select * from denver_area_trails_2;

/* 🥋 Use A Union All to Bring the Rows Into a Single Result Set */
-- Create a view that will have similar columns to DENVER_AREA_TRAILS 


select feature_name,geometry,trial_length from denver_area_trails 
union all
select feature_name,geometry,trail_length from denver_area_trails_2;

/* 📓  Now We've Got GeoSpatial LineStrings for All 5 Trails in the Same View */
select feature_name,to_geography(geometry),trial_length from denver_area_trails 
union all
select feature_name,to_geography(geometry),trail_length from denver_area_trails_2;

/* 🥋 But Wait! There's More! */
--Add more GeoSpatial Calculations to get more GeoSpecial Information! 
select feature_name
, to_geography(geometry) as my_linestring
, st_xmin(my_linestring) as min_eastwest
, st_xmax(my_linestring) as max_eastwest
, st_ymin(my_linestring) as min_northsouth
, st_ymax(my_linestring) as max_northsouth,trial_length
from DENVER_AREA_TRAILS
union all 
select feature_name
,to_geography(geometry) as my_linestring
, st_xmin(my_linestring) as min_eastwest
, st_xmax(my_linestring) as max_eastwest
, st_ymin(my_linestring) as min_northsouth
, st_ymax(my_linestring) as max_northsouth,trail_length
from DENVER_AREA_TRAILS_2;

-- CREATE A view for ABOVE select STATEMENT
create view TRIALS_AND_BOUNDARIES as (
    select feature_name
, to_geography(geometry) as my_linestring
, st_xmin(my_linestring) as min_eastwest
, st_xmax(my_linestring) as max_eastwest
, st_ymin(my_linestring) as min_northsouth
, st_ymax(my_linestring) as max_northsouth,trial_length
from DENVER_AREA_TRAILS
union all 
select feature_name
,to_geography(geometry) as my_linestring
, st_xmin(my_linestring) as min_eastwest
, st_xmax(my_linestring) as max_eastwest
, st_ymin(my_linestring) as min_northsouth
, st_ymax(my_linestring) as max_northsouth,trail_length
from DENVER_AREA_TRAILS_2
);

-- RENAME THE ABOVE view
ALTER VIEW IF EXISTS TRIALS_AND_BOUNDARIES RENAME TO TRAILS_AND_BOUNDARIES;

select * from TRAILS_AND_BOUNDARIES;

/* 📓  A Polygon Can be Used to Create a Bounding Box */

select min(min_eastwest) as western_edge,
min(min_northsouth) as southern_edge,
max(max_eastwest) as eastern_edge,
max(max_northsouth) as northen_edge
from trials_and_boundaries;

select 'POLYGON((' ||
min(min_eastwest)||' '||max(max_northsouth)||','||
max(max_eastwest)||' '||max(max_northsouth)||','||
max(max_eastwest)||' '||min(min_northsouth)||','||
min(min_eastwest)||' '||max(max_northsouth)||'))' as my_polygon
from trials_and_boundaries;

-- SCHEMA wrongly named so i need to correct it
ALTER SCHEMA IF EXISTS TRIALS RENAME TO TRAILS;
 
/* 🤖 Run This in Your Worksheet to Send a Report to DORA */
select DEMO_DB.PUBLIC.GRADER(step, (actual = expected), actual, expected, description) as graded_results from
(
 SELECT
  'DLKW07' as step
   ,(select round(max(max_northsouth))
      from MELS_SMOOTHIE_CHALLENGE_DB.TRAILS.TRAILS_AND_BOUNDARIES)
      as actual
 ,40 as expected
 ,'Trails Northern Extent' as description
 ); 

-------------------------------------------------------------------------------------------------------------------------------
 -- select round(max(max_northsouth))
 --      from MELS_SMOOTHIE_CHALLENGE_DB.TRIALS.TRIALS_AND_BOUNDARIES;