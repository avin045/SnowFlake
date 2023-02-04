-- Lesson_2_Reviewing_Data_Structuring_&_Stage_Types

/* 🥋 Create a Database for Zena's Athleisure Idea */
USE ROLE SYSADMIN;

CREATE DATABASE ZENAS_ATHLEISURE_DB;
DROP SCHEMA PUBLIC;
CREATE SCHEMA PRODUCTS;

-- CODE FOR STAGING ("clothing" folder in Klaus' bucket)
create stage UNI_KLAUS_CLOTHING
url = 's3://uni-klaus/clothing';

-- LIST stages;
SHOW STAGES;
list @UNI_KLAUS_CLOTHING;

-- Staging for another of Klaus' folders
create stage UNI_KLAUS_ZMD
  url = 's3://uni-klaus/zenas_metadata';
  
-- List stage 
list @UNI_KLAUS_ZMD;

/* 🎯 Create A 3rd Stage! */
create stage UNI_KLAUS_SNEAKERS
  url = 's3://uni-klaus/sneakers';

-- List stage 
list @UNI_KLAUS_SNEAKERS;


-- DORA CHECK-UP
USE DATABASE DEMO_DB;
select DEMO_DB.PUBLIC.GRADER(step, (actual = expected), actual, expected, description) as graded_results from
(
 SELECT
 'DLKW01' as step
  ,(
      select count(*)  
      from ZENAS_ATHLEISURE_DB.INFORMATION_SCHEMA.STAGES 
      where stage_url ilike ('%/clothing%')
      or stage_url ilike ('%/zenas_metadata%')
      or stage_url like ('%/sneakers%')
   ) as actual
, 3 as expected
, 'Stages for Klaus bucket look good' as description
); 
SHOW EXTERNAL FUNCTIONS;