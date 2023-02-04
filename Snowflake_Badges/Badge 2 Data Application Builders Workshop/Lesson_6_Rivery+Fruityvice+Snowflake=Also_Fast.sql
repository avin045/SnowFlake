-- Lesson_6_Rivery+Fruityvice+Snowflake=Also_Fast

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE PC_RIVERY_WH;
USE DATABASE PC_RIVERY_DB;

-- SHOW TABLES
show tables;

-- VIEW FRUITYVICE RECORDS
select * from PC_RIVERY_DB.PUBLIC.FRUITYVICE;

-- DORA CHECKUP
USE WAREHOUSE COMPUTE_WH;
USE DATABASE DEMO_DB;

-- DO NOT EDIT ANYTHING BELOW THIS LINE
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
  SELECT 'DABW03' as step
 ,(select sum(round(nutritions_sugar)) 
   from PC_RIVERY_DB.PUBLIC.FRUITYVICE) as actual
 , 35 as expected
 ,'Fruityvice table is perfectly loaded' as description
);