-- Lesson_8_Staging_Data

use role accountadmin;
use database GARDEN_PLANTS;
use SCHEMA VEGGIES;


-- Create a Snowflake Stage Object
 create stage garden_plants.veggies.like_a_window_into_an_s3_bucket 
 url = 's3://uni-lab-files';
 
--  LIST the FILES in Staged Object (Access the Stage PREFIXED with `@`)
list @like_a_window_into_an_s3_bucket;

-- File starts with `this_`
list @like_a_window_into_an_s3_bucket/this_;

-- File starts with `veg`
list @like_a_window_into_an_s3_bucket/veg;

-- File which is in another directory `dabw` starts with Color
list @like_a_window_into_an_s3_bucket/dabw/Color;

-- CASE SENSITIVE -> TABLE NAME = ROOT_DEPTH OR root_depth 
select * from ROOT_DEPTH; -- WORKING
select * from ROoT_DEpTH; -- WORKING
select * from root_depth; -- WORKING

-- CASE SENSITIVE `TABLE NAME` as String.
select * from "ROOT_DEPTH"; -- WORKING
select * from "ROoT_DEpTH"; -- NOT WORKING Becasue it created as `ROOT_DEPTH` in CAPS.
select * from "root_depth"; -- NOT WORKING Becasue it created as `ROOT_DEPTH` in CAPS.

show tables;

-- 🤖 Run This in Your Worksheet to Send a Report to DORA
USE ROLE ACCOUNTADMIN;
USE DATABASE DEMO_DB;
USE SCHEMA public;

-- DO NOT EDIT ANYTHING BELOW THIS LINE. THE CODE MUST BE RUN EXACTLY AS IT IS WRITTEN
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
 SELECT 'DWW10' as step
  ,(select count(*) 
    from GARDEN_PLANTS.INFORMATION_SCHEMA.stages
    where stage_url='s3://uni-lab-files' 
    and stage_type='External Named') as actual
  , 1 as expected
  , 'External stage created' as description
 ); 
 
--  ----------------------------------------------------------------------------------------------------------------------------------------


-- Create a Table for Soil Types (create it in the GARDEN_PLANTS database, in the VEGGIES schema).
create or replace table vegetable_details_soil_type
( plant_name varchar(25)
 ,soil_type number(1,0)
);

-- COPY file from Staged Object [@like_a_window_into_an_s3_bucket] --> TABLE [vegetable_details_soil_type].

copy into vegetable_details_soil_type
from @like_a_window_into_an_s3_bucket
files = ( 'VEG_NAME_TO_SOIL_TYPE_PIPE.txt')
file_format = ( format_name=PIPECOLSEP_ONEHEADROW ); -- ONE HEAD ROW 
-- '''
-- copy into vegetable_details_soil_type
-- from @like_a_window_into_an_s3_bucket
-- files = ( 'VEG_NAME_TO_SOIL_TYPE_PIPE.txt','dabw/fruit_macros.txt')
-- file_format = ( format_name=PIPECOLSEP_ONEHEADROW ); -- ONE HEAD ROW --> ERROR
--   File 'dabw/fruit_macros.txt', line 3, character 1
--   Row 1 starts at line 2, column "VEGETABLE_DETAILS_SOIL_TYPE"["PLANT_NAME":1]
--   If you would like to continue loading when an error is encountered, use other values such as 'SKIP_FILE' or 'CONTINUE' for the ON_ERROR option. For more information on loading options, please run 'info loading_data' in a SQL client
-- '''

select * from vegetable_details_soil_type;
truncate vegetable_details_soil_type;

--  Run This in Your Worksheet to Send a Report to DORA
--Set your worksheet drop list role to ACCOUNTADMIN
--Set your worksheet drop list database and schema to the location of your GRADER function

-- DO NOT EDIT ANYTHING BELOW THIS LINE. THE CODE MUST BE RUN EXACTLY AS IT IS WRITTEN
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
  SELECT 'DWW11' as step
  ,(select row_count 
    from GARDEN_PLANTS.INFORMATION_SCHEMA.TABLES 
    where table_name = 'VEGETABLE_DETAILS_SOIL_TYPE') as actual
  , 42 as expected
  , 'Veg Det Soil Type Count' as description
 );
 
--  🥋 Explore the Effect of File Formats On Data Interpretation

select $1,$2 -- $1,$2 refers like c_1,c_2 in databricks for Column Notation
from @garden_plants.veggies.like_a_window_into_an_s3_bucket/LU_SOIL_TYPE.tsv;

--Same file but with one of the file formats we created earlier  

select $1, $2, $3
from @garden_plants.veggies.like_a_window_into_an_s3_bucket/LU_SOIL_TYPE.tsv
(file_format => garden_plants.veggies.COMMASEP_DBLQUOT_ONEHEADROW);

--Same file but with the other file format we created earlier

select $1, $2, $3
from @garden_plants.veggies.like_a_window_into_an_s3_bucket/LU_SOIL_TYPE.tsv
(file_format => garden_plants.veggies.PIPECOLSEP_ONEHEADROW );

-- TASK : Create a file format that will help you load files with these properties. Name the file format: L8_CHALLENGE_FF

create or replace file format garden_plants.veggies.L8_CHALLENGE_FF
    TYPE = 'CSV'--csv is used for any flat file (tsv, pipe-separated, etc)
    FIELD_DELIMITER = '\t'
    SKIP_HEADER = 1;


select $1,$2,$3 
from @garden_plants.veggies.like_a_window_into_an_s3_bucket/LU_SOIL_TYPE.tsv
(file_format => garden_plants.veggies.L8_CHALLENGE_FF);

show file formats;

-- SOIL TABLE
create or replace table LU_SOIL_TYPE(
SOIL_TYPE_ID number,	
SOIL_TYPE varchar(15),
SOIL_DESCRIPTION varchar(75)
 );
 
 show tables;
 desc table LU_SOIL_TYPE;
 
--  Create a COPY INTO Statement to Load the File into the Table
COPY into LU_SOIL_TYPE
from @like_a_window_into_an_s3_bucket
files = ('LU_SOIL_TYPE.tsv')
file_format = (format_name=L8_CHALLENGE_FF);

select * from LU_SOIL_TYPE;

-- ------------------------------------------------------------------------------------------------------------

-- VEGETABLE_DETAILS_PLANT_HEIGHT Table
-- Create a table called VEGETABLE_DETAILS_PLANT_HEIGHT in the VEGGIES schema.

CREATE OR REPLACE TABLE VEGETABLE_DETAILS_PLANT_HEIGHT(
    plant_name varchar(50),
    UOM varchar(1),
    Low_End_of_Range number,
    High_End_of_Range number
);

--  Use the header row of the file to get your column names. Choose good data types for each column. 
-- Choose an existing file format (one we already created) that you think can be used to load the data.

create file format garden_plants.veggies.COMMASEP_DBLQUOT_ONEHEADROW 
    TYPE = 'CSV'--csv for comma separated files
    SKIP_HEADER = 1 --one header row  
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'; --this means that some values will be wrapped in 
-- double-quotes bc they have commas in them

COPY INTO VEGETABLE_DETAILS_PLANT_HEIGHT
from @like_a_window_into_an_s3_bucket -- STAGE
files = ('veg_plant_height.csv')
file_format = (format_name = COMMASEP_DBLQUOT_ONEHEADROW);

select * from VEGETABLE_DETAILS_PLANT_HEIGHT;

-- ------------------------------------------------------------------------------------------------------------------
-- DORA CHECKER
--Set your worksheet drop list role to ACCOUNTADMIN
--Set your worksheet drop list database and schema to the location of your GRADER function
USE ROLE ACCOUNTADMIN;
USE DATABASE DEMO_DB;
USE SCHEMA PUBLIC;

-- DO NOT EDIT ANYTHING BELOW THIS LINE. THE CODE MUST BE RUN EXACTLY AS IT IS WRITTEN
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (  
      SELECT 'DWW12' as step 
      ,(select row_count 
        from GARDEN_PLANTS.INFORMATION_SCHEMA.TABLES 
        where table_name = 'VEGETABLE_DETAILS_PLANT_HEIGHT') as actual 
      , 41 as expected 
      , 'Veg Detail Plant Height Count' as description   
); 

-- DO NOT EDIT ANYTHING BELOW THIS LINE. THE CODE MUST BE RUN EXACTLY AS IT IS WRITTEN
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (  
     SELECT 'DWW13' as step 
     ,(select row_count 
       from GARDEN_PLANTS.INFORMATION_SCHEMA.TABLES 
       where table_name = 'LU_SOIL_TYPE') as actual 
     , 8 as expected 
     ,'Soil Type Look Up Table' as description   
);

select GRADER(step, (actual = expected), actual, expected, description) as graded_results from ( 
     SELECT 'DWW14' as step 
     ,(select count(*) 
       from GARDEN_PLANTS.INFORMATION_SCHEMA.FILE_FORMATS 
       where FILE_FORMAT_NAME='L8_CHALLENGE_FF' 
       and FIELD_DELIMITER = '\t') as actual 
     , 1 as expected 
     ,'Challenge File Format Created' as description  
); 