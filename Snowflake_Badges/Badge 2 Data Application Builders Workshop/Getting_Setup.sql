USE ROLE ACCOUNTADMIN;

-- SEE WHICH CLOUD SERVICE WE'RE USING
select current_region(); -- AWS_CA_CENTRAL_1

-- GET THE ACCOUNT LOCATOR
select current_account(); -- MY35759

-- DORA CHECK UP
USE ROLE ACCOUNTADMIN;
USE DATABASE DEMO_DB;
USE SCHEMA PUBLIC;

-- Set your worksheet drop lists
-- DO NOT EDIT ANYTHING BELOW THIS LINE
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
  SELECT 'DORA_IS_WORKING' as step
 ,(select 223) as actual
 , 223 as expected
 ,'Dora is working!' as description
); 

