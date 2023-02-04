-- Lesson_8_Intro_to_Variables_and_VariableDriven_Loading

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE PC_RIVERY_WH;
USE DATABASE PC_RIVERY_DB;

show tables;


-- MAKE A COPY OF `FDC_FOOD_INGEST` as `FDC_FOOD_INGEST_CHEDDAR`
CREATE TABLE FDC_FOOD_INGEST_CHEDDAR as select * from FDC_FOOD_INGEST;

-- TRNCATE THE ORIGINAL
-- truncate FDC_FOOD_INGEST;

-- VIEW
select * from FDC_FOOD_INGEST;

-- COUNT
select count(*) from FDC_FOOD_INGEST;

-- CLONING
create table orders_303_clone clone FDC_FOOD_INGEST;


-- create table FRUIT_LOAD_LIST

USE ROLE PC_RIVERY_ROLE;

create table FRUIT_LOAD_LIST(
    FRUIT_NAME VARCHAR(25)
);
DESC TABLE FRUIT_LOAD_LIST;

insert into pc_rivery_db.public.fruit_load_list
values 
('banana')
,('cherry')
,('strawberry')
,('pineapple')
,('apple')
,('mango')
,('coconut')
,('plum')
,('avocado')
,('starfruit');

SELECT * FROM fruit_load_list;

select * from 
pc_rivery_db.public.fruit_load_list;

-- show tables;

-- DORA CHECK UP

-- Set your worksheet drop lists
USE ROLE ACCOUNTADMIN;
USE DATABASE DEMO_DB;

-- show external functions;

-- DO NOT EDIT ANYTHING BELOW THIS LINE
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
  SELECT 'DABW05' as step
 ,(select count(*) 
   from pc_rivery_db.public.fdc_food_ingest) as actual
 , 927 as expected
 ,'All the fruits!' as description
);