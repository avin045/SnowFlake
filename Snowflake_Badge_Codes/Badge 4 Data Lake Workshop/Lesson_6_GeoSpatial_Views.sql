-- Lesson_6_GeoSpatial_Views

/* 🥋 Look at the Parquet Data */

select $1
from @trails_parquet
(file_format => ff_parquet);

/* Write a more sophisticated query to parse the data into columns */
select $1:sequence_1 as sequence_1,
$1:trail_name::varchar as trial_name,
$1:latitude as latitude,
$1:longitude as longitude,
$1:sequence_2 as sequence_2,
$1:elevation as elevation
from @trails_parquet
(file_format => ff_parquet)
order by sequence_1;

/*  🥋 Use a Select Statement to Fix Some Issues */
--Nicely formatted trail data
select 
 $1:sequence_1 as point_id,
 $1:trail_name::varchar as trail_name,
 $1:latitude::number(11,8) as lng, --remember we did a gut check on this data
 $1:longitude::number(11,8) as lat
from @trails_parquet
(file_format => ff_parquet)
order by point_id;

/* 🎯 Create a View Called CHERRY_CREEK_TRAIL */
create view CHERRY_CREEK_TRAIL as (
    select 
 $1:sequence_1 as point_id,
 $1:trail_name::varchar as trail_name,
 $1:latitude::number(11,8) as lng, --remember we did a gut check on this data
 $1:longitude::number(11,8) as lat
from @trails_parquet
(file_format => ff_parquet)
order by point_id
);

/*  🥋 Use || to Chain Lat and Lng Together into Coordinate Sets! */
select top 100
lng||' '||lat as coord_pair,
'POINT('||coord_pair||')' as trial_point
from cherry_creek_trail;

/* To add a column, we have to replace the entire view */
--changes to the original are shown in red

create or replace view cherry_creek_trail as
select 
 $1:sequence_1 as point_id,
 $1:trail_name::varchar as trail_name,
 $1:latitude::number(11,8) as lng,
 $1:longitude::number(11,8) as lat,
 lng||' '||lat as coord_pair
from @trails_parquet
(file_format => ff_parquet)
order by point_id;

/* 🥋 Run this SELECT and Paste the Results into WKT Playground! */
select 
'LINESTRING('||
listagg(coord_pair, ',') 
within group (order by point_id)
||')' as my_linestring
from cherry_creek_trail
where point_id <= 10
group by trail_name;


/* 🎯 Can You Make The Whole Trail into a Single LINESTRING?  */
select 
'LINESTRING('||
listagg(coord_pair, ',') 
within group (order by point_id)
||')' as my_linestring
from cherry_creek_trail
where point_id <= 1000
group by trail_name;

/* 🥋 Look at the geoJSON Data */
show stages;
select $1
from @trails_geojson
(file_format => ff_json);

/* 🥋 Normalize the Data Without Loading It! */
select
$1:features[0]:properties:Name::string as feature_name
,$1:features[0]:geometry:coordinates::string as feature_coordinates
,$1:features[0]:geometry::string as geometry
,$1:features[0]:properties::string as feature_properties
,$1:crs:properties:name::string as specs
,$1 as whole_object
from @trails_geojson (file_format => ff_json);

/* 🎯 Create a View Called DENVER_AREA_TRAILS */
create view DENVER_AREA_TRAILS as (
    select
$1:features[0]:properties:Name::string as feature_name
,$1:features[0]:geometry:coordinates::string as feature_coordinates
,$1:features[0]:geometry::string as geometry
,$1:features[0]:properties::string as feature_properties
,$1:crs:properties:name::string as specs
,$1 as whole_object
from @trails_geojson (file_format => ff_json)
);

/* 🤖 Run This in Your Worksheet to Send a Report to DORA */
select DEMO_DB.PUBLIC.GRADER(step, (actual = expected), actual, expected, description) as graded_results from
(
SELECT
'DLKW06' as step
 ,(select count(*) as tally
      from mels_smoothie_challenge_db.information_schema.views 
      where table_name in ('CHERRY_CREEK_TRAIL','DENVER_AREA_TRAILS')) as actual
 ,2 as expected
 ,'Mel\'s views on the geospatial data from Camila' as description
 ); 