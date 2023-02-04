-- Lesson_7_Exploring_FoodData_Central_via_API

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE PC_RIVERY_WH;
USE DATABASE PC_RIVERY_DB;

-- SHOW TABLES (LOOKING for : FDC_FOOD_INGEST )
show tables;

-- VIEW RECORDS
select * from FDC_FOOD_INGEST;

-- VIEW COUNT
select count(*) from FDC_FOOD_INGEST;

-- DORA CHECKUP
-- Set your worksheet drop lists
USE WAREHOUSE COMPUTE_WH;
USE DATABASE DEMO_DB;


-- DO NOT EDIT ANYTHING BELOW THIS LINE
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
  SELECT 'DABW04' as step
 ,(select count(*) 
   from pc_rivery_db.public.fdc_food_ingest
   where lowercasedescription like '%cheddar%') as actual
 , 50 as expected
 ,'FDC_FOOD_INGEST Cheddar 50' as description
);