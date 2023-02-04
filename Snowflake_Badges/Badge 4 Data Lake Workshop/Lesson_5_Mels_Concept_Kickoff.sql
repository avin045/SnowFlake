-- Lesson_5_Mels_Concept_Kickoff

-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
/* 🎯 Put Your Snowflake Skills to Work! */

create database MELS_SMOOTHIE_CHALLENGE_DB;
drop schema public;
create schema trials;

/* -- create Stage demo
create stage un_named_trail
    url = 's3://uni-lab-files-more/dlkw/trails/';
list @un_named_trail; */

-- drop stage un_named_trail;

/* CREATE STAGE for trails_geojson */

create stage trails_geojson
url = 's3://uni-lab-files-more/dlkw/trails/trails_geojson/';

/* CREATE STAGE for trails_parquet */

create stage trails_parquet
url = 's3://uni-lab-files-more/dlkw/trails/trails_parquet/';

/* ALTER STAGING 
alter stage trails_geojson 
set directory = (enable = true);
*/

-- LISTING STAGES
list @trails_geojson;
list @trails_parquet;

/* 🎯 File Formats! */
create file format ff_json
TYPE = 'JSON';

create file format ff_parquet
TYPE = 'PARQUET';

/* SELECT using STAGES ==> trails_geojson,trails_parquet */
select $1
from @trails_geojson
(file_format => ff_json);

select $1
from @trails_parquet
(file_format => ff_parquet);

/* 🤖 Run This in Your Worksheet to Send a Report to DORA */
select DEMO_DB.PUBLIC.GRADER(step, (actual = expected), actual, expected, description) as graded_results from
(
SELECT
'DLKW05' as step
 ,(select sum(tally)
   from
     (select count(*) as tally
      from mels_smoothie_challenge_db.information_schema.stages 
      union all
      select count(*) as tally
      from mels_smoothie_challenge_db.information_schema.file_formats)) as actual
 ,4 as expected
 ,'Camila\'s Trail Data is Ready to Query' as description
 ); 