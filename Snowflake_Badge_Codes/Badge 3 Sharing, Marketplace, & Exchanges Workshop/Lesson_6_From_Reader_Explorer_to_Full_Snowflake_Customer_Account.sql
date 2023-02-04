-- Lesson_6_From_Reader_Explorer_to_Full_Snowflake_Customer_Account

USE WAREHOUSE COMPUTE_WH;
USE DATABASE DEMO_DB;

-- DORA CHECK-UP
-- set your worksheet drop lists to the location of your GRADER function
-- DO NOT EDIT ANYTHING BELOW THIS LINE
select grader(step, (actual = expected), actual, expected, description) as graded_results from
(
SELECT 
 'SMEW08' as step
 ,(select count(*)/NULLIF(count(*),0) from snowflake.reader_account_usage.query_history
where USER_NAME = 'MANAGED_READER_ADMIN' and query_text ilike ('%366%')) as actual
 , 1 as expected
 ,'03-00-01-08' as description
UNION ALL
SELECT 
  'SMEW09' as step
 ,(select count(*)/NULLIF(count(*),0) from snowflake.reader_account_usage.query_history
where USER_NAME = 'MANAGED_READER_ADMIN' and query_text ilike ('%NCIES%')) as actual
 , 1 as expected
 ,'03-00-01-09' as description
UNION ALL
SELECT 
  'SMEW10' as step
 ,(select count(*)/NULLIF(count(*),0) from snowflake.reader_account_usage.query_history
where USER_NAME = 'MANAGED_READER_ADMIN' and query_text ilike ('%IMPLE%')) as actual
 , 1 as expected
 ,'03-00-01-10' as description
UNION ALL 
SELECT 
    'SMEW11' as step 
,(select count(*)/NULLIF(count(*),0) from snowflake.reader_account_usage.query_history
where USER_NAME = 'MANAGED_READER_ADMIN' and query_text ilike ('%DE_TO%')) as actual
, 1 as expected
,'03-00-01-11' as description
);