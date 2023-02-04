-- Lesson_12_Streamlit_but_with_Snowflake_Added

USE DATABASE PC_RIVERY_DB;
-- insert into fruit_load_list values ('test');
select * from fruit_load_list;

-- delete from fruit_load_list where fruit_name like 'test' or fruit_name like 'from streamlit';

-- DORA CHECKUP
-- Set your worksheet drop lists
USE DATABASE DEMO_DB;
-- DO NOT EDIT ANYTHING BELOW THIS LINE
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
   SELECT 'DABW07' as step 
   ,(select count(*) 
     from pc_rivery_db.public.fruit_load_list 
     where fruit_name in ('jackfruit','papaya', 'kiwi', 'test', 'from streamlit', 'guava')) as actual 
   , 4 as expected 
   ,'Followed challenge lab directions' as description
); 