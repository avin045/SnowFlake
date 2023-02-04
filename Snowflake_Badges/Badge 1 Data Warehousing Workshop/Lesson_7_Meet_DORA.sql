use role accountadmin;
use database demo_db; --change this to a different database if you prefer
use schema public; --change this to a different schema if you prefer


-- API INTEGRATION (Use Only Once Per Snowflake Trial Account).
-- use role accountadmin;
-- create or replace api integration dora_api_integration
-- api_provider = aws_api_gateway
-- api_aws_role_arn = 'arn:aws:iam::321463406630:role/snowflakeLearnerAssumedRole'
-- enabled = trueDEMO_DB.PUBLIC.GRADER
-- api_allowed_prefixes = ('https://awy6hshxy4.execute-api.us-west-2.amazonaws.com/dev/edu_dora');

-- -- GRADER FUNCTION (Run this code once per Database.).
-- use role accountadmin;  
-- create or replace external function demo_db.public.grader(
--       step varchar
--     , passed boolean
--     , actual integer
--     , expected integer
--     , description varchar)
-- returns variant
-- api_integration = dora_api_integration 
-- context_headers = (current_timestamp,current_account, current_statement) 
-- as 'https://awy6hshxy4.execute-api.us-west-2.amazonaws.com/dev/edu_dora/grader';



select grader(step, (actual = expected), actual, expected, description) as graded_results from
(SELECT 
 'DORA_IS_WORKING' as step
 ,(select 123) as actual
 ,123 as expected
 ,'Dora is working!' as description
);

-- You were asked to set up 3 schemas in a GARDEN_PLANTS database. You were also asked to delete a schema. 
SELECT * 
FROM GARDEN_PLANTS.INFORMATION_SCHEMA.SCHEMATA;

--  Checking for Schemas by Name
SELECT * 
FROM GARDEN_PLANTS.INFORMATION_SCHEMA.SCHEMATA
where schema_name in ('FLOWERS','FRUITS','VEGGIES');

-- Counting the Number of Correctly Named Schemas
select count(*)  as SCHEMAS_FOUND, '3' as SCHEMAS_EXPECTED 
from GARDEN_PLANTS.INFORMATION_SCHEMA.SCHEMATA
where schema_name in ('FLOWERS','FRUITS','VEGGIES');


-- DORA DWW01
--You may set these manually or you may edit the code on the next 3 lines
use database DEMO_DB;
use schema PUBLIC;
use role ACCOUNTADMIN;

--Do NOT EDIT ANYTHING BELOW THIS LINE
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
 SELECT
 'DWW01' as step
 ,(select count(*)  
   from GARDEN_PLANTS.INFORMATION_SCHEMA.SCHEMATA 
   where schema_name in ('FLOWERS','VEGGIES','FRUITS')) as actual
  ,3 as expected
  ,'Created 3 Garden Plant schemas' as description
); 

-- DORA DWW02
--You may set these manually or you may edit the code on the next 3 lines
use database DEMO_DB;
use schema PUBLIC;
use role ACCOUNTADMIN;

--Do NOT EDIT ANYTHING BELOW THIS LINE
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
 SELECT 'DWW02' as step 
 ,(select count(*) 
   from GARDEN_PLANTS.INFORMATION_SCHEMA.SCHEMATA 
   where schema_name = 'PUBLIC') as actual 
 , 0 as expected 
 ,'Deleted PUBLIC schema.' as description
);


-- DORA DWW03
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
 SELECT 'DWW03' as step 
 ,(select count(*) 
   from GARDEN_PLANTS.INFORMATION_SCHEMA.TABLES 
   where table_name = 'ROOT_DEPTH') as actual 
 , 1 as expected 
 ,'ROOT_DEPTH Table Exists' as description
);

-- DORA DWW04
-- DO NOT EDIT ANYTHING BELOW THIS LINE. THE CODE MUST BE RUN EXACTLY AS IT IS WRITTEN
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
 SELECT 'DWW04' as step
 ,(select count(*) as SCHEMAS_FOUND 
   from UTIL_DB.INFORMATION_SCHEMA.SCHEMATA) as actual
 , 2 as expected
 , 'UTIL_DB Schemas' as description
); 

-- DORA DWW05
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
 SELECT 'DWW05' as step
 ,(select count(*) 
   from GARDEN_PLANTS.INFORMATION_SCHEMA.TABLES 
   where table_name = 'VEGETABLE_DETAILS') as actual
 , 1 as expected
 ,'VEGETABLE_DETAILS Table' as description
); 

-- DORA DWW06
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from ( 
 SELECT 'DWW06' as step 
,(select row_count 
  from GARDEN_PLANTS.INFORMATION_SCHEMA.TABLES 
  where table_name = 'ROOT_DEPTH') as actual 
, 3 as expected 
,'ROOT_DEPTH row count' as description
);

-- DORA DWW07
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
 SELECT 'DWW07' as step
 ,(select row_count 
   from GARDEN_PLANTS.INFORMATION_SCHEMA.TABLES 
   where table_name = 'VEGETABLE_DETAILS') as actual
 , 41 as expected
 , 'VEG_DETAILS row count' as description
);

-- DORA DWW08
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from ( 
   SELECT 'DWW08' as step 
   ,(select count(*) 
     from GARDEN_PLANTS.INFORMATION_SCHEMA.FILE_FORMATS 
     where FIELD_DELIMITER =',' 
     and FIELD_OPTIONALLY_ENCLOSED_BY ='"') as actual 
   , 1 as expected 
   , 'File Format 1 Exists' as description 
);

-- DORA DWW09
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
 SELECT 'DWW09' as step
 ,(select count(*) 
   from GARDEN_PLANTS.INFORMATION_SCHEMA.FILE_FORMATS 
   where FIELD_DELIMITER ='|' 
   ) as actual
 , 1 as expected
 ,'File Format 2 Exists' as description
); 
