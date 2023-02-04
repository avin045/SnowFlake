-- Lesson_4_Google+Rivery+Snowflake=Fast

-- Set your worksheet drop lists

-- DO NOT EDIT ANYTHING BELOW THIS LINE
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
  SELECT 'DABW01' as step
 ,(select count(*) 
   from PC_RIVERY_DB.INFORMATION_SCHEMA.SCHEMATA 
   where schema_name ='PUBLIC') as actual
 , 1 as expected
 ,'Rivery is set up' as description
);

-- --------------------------------------------------------
USE WAREHOUSE PC_RIVERY_WH;
USE DATABASE PC_RIVERY_DB;
USE SCHEMA PUBLIC;
-- truncate HEALTHY_FOOD_INTEREST_FORM_RESULTS_INGEST;

-- Mistakenly i've cleared a ROW (Google Form that empty row inserted in Table) So i deleted it.
-- delete from HEALTHY_FOOD_INTEREST_FORM_RESULTS_INGEST where LIKE_HEALTHY IS NULL;

-- VIEW
select * from HEALTHY_FOOD_INTEREST_FORM_RESULTS_INGEST;


-- DORA CHECK UP

-- Set your worksheet drop lists
USE DATABASE DEMO_DB;

-- DO NOT EDIT ANYTHING BELOW THIS LINE
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
 SELECT 'DABW02' as step
 ,(select count(*) 
   from PC_RIVERY_DB.INFORMATION_SCHEMA.TABLES 
   where ((table_name ilike '%FORM%') 
   and (table_name ilike '%RESULT%'))) as actual
 , 1 as expected
 ,'Rivery form results table is set up' as description
);
