-- Lesson_10_Prepping_Data_for_an_Exchange

/* Set Up the ACME Database and Schemas */
use role sysadmin;

--Caden set up a new database (and you will, too)
create database ACME;

--did Snowflake set your worksheet database to the new database? 
--if not, you can do it yourself.
use database ACME;

--get rid of the public schema - too generic
drop schema public;

--When creating shares it is best to have multiple schemas
create schema sales;

create schema ACME.STOCK;

create schema ACME.ADU; --this is the schema they'll use to share to ADU, Max's company

/* 🥋 Lotstock Table and View */
use role sysadmin;

--Lottie's team will enter new stock into this table when inventory is received
-- the Date_Sold and Customer_Id will be null until the car is sold
create or replace table ACME.STOCK.LOTSTOCK(
    VIN varchar(17),
    EXTERIOR varchar(50),
    INTERIOR varchar(50),
    DATE_SOLD date,
    CUSTOMER_ID number(20)
);

--This secure view breaks the VIN into digestible components
--this view only shares unsold cars because the unsold cars
--are the ones that need to be enhanced
create or replace secure view ACME.ADU.LOTSTOCK 
AS (
SELECT VIN
  , LEFT(VIN,3) as WMI
  , SUBSTR(VIN,4,5) as VDS
  , SUBSTR(VIN,10,1) as MODYEARCODE
  , SUBSTR(VIN,11,1) as PLANTCODE
  , EXTERIOR
  , INTERIOR
FROM ACME.STOCK.LOTSTOCK
WHERE DATE_SOLD is NULL
);

/* 🥋 A File Format to Help Caden Load the Data */
--You need a file format if you want to load the table
create file format ACME.STOCK.COMMA_SEP_HEADERROW 
TYPE = 'CSV' 
COMPRESSION = 'AUTO' 
FIELD_DELIMITER = ',' 
RECORD_DELIMITER = '\n' 
SKIP_HEADER = 1 
FIELD_OPTIONALLY_ENCLOSED_BY = '\042'  
TRIM_SPACE = TRUE 
ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE 
ESCAPE = 'NONE' 
ESCAPE_UNENCLOSED_FIELD = '\134' 
DATE_FORMAT = 'AUTO' 
TIMESTAMP_FORMAT = 'AUTO' 
NULL_IF = ('\\N');

show databases LIKE 'A%';

/* 🥋 Load the Table and Check Out the Data */
use role accountadmin;

--Use a COPY INTO to load the data
--the file is named Lotties_LotStock_Data.csv

COPY INTO acme.stock.lotstock
from @demo_db.public.like_a_window_into_an_s3_bucket
files = ('smew/Lotties_LotStock_Data.csv')
file_format =(format_name=ACME.STOCK.COMMA_SEP_HEADERROW);


-- After loading your base table is no longer empty
-- it should now have 300 rows
select * from acme.stock.lotstock;

--the View will show just 298 rows because the view only shows
--rows where the date_sold is null
select * from acme.adu.lotstock;


-- DORA CHECK-UP
USE DATABASE DEMO_DB;

-- set your worksheet drop lists to the location of your GRADER function
--DO NOT EDIT ANYTHING BELOW THIS LINE
select grader(step, (actual = expected), actual, expected, description) as graded_results from (
 SELECT 'SMEW12' as step
 ,(select count(*) 
   from SNOWFLAKE.ACCOUNT_USAGE.DATABASES 
   where database_name in ('INTL_DB','DEMO_DB','ACME', 'ACME_DETROIT','ADU_VINHANCED') 
   and deleted is null) as actual
 , 5 as expected
 ,'Databases from all over!' as description
); 

-- RENAME THE 'ACME' (caden data)
alter DATABASE ACME rename to back_when_i_pretended_i_was_caden;

/*
📓 The One ADU Database! 
You have ADU_VINHANCED -- which is coming in to you via an Exchange Share. This is the way Max will sends the data back to Lottie and Cade
*/

/* 🥋 Set Up the ADU Decode Database and Schemas */
USE ROLE SYSADMIN;

--Max created a database to store Vehicle Identification Numbers
CREATE DATABASE max_vin;

DROP SCHEMA max_vin.public;
CREATE SCHEMA max_vin.decode;

/* 🥋 Max's Decode Tables */

--We need a table that will allow WMIs to be decoded into Manufacturer Name, Country and Vehicle Type
CREATE TABLE MAX_VIN.DECODE.WMITOMANUF 
(
     WMI          VARCHAR(6)
    ,MANUF_ID      NUMBER(6)
    ,MANUF_NAME         VARCHAR(50)
    ,COUNTRY       VARCHAR(50)
    ,VEHICLETYPE    VARCHAR(50)
 );
 
--We need a table that will allow you to go from Manufacturer to Make
--For example, Mercedes AG of Germany and Mercedes USA both roll up into Mercedes
--But they use different WMI Codes
CREATE TABLE MAX_VIN.DECODE.MANUFTOMAKE
(
     MANUF_ID  NUMBER(6)
    ,MAKE_NAME VARCHAR(50)
    ,MAKE_ID   NUMBER(5)
);

--We need a table that can decode the model year
-- The year 2001 is represented by the digit 1
-- The year 2020 is represented by the letter L
CREATE TABLE MAX_VIN.DECODE.MODELYEAR
(
     MODYEARCODE    VARCHAR(1)
    ,MODYEARNAME    NUMBER(4)
);

--We need a table that can decode which plant at which 
--the vehicle was assembled
--You might have code "A" for Honda and code "A" for Ford
--so you need both the Make and the Plant Code to properly decode 
--the plant code
CREATE TABLE MAX_VIN.DECODE.MANUFPLANTS
(
     MAKE_ID   NUMBER(5)
    ,PLANTCODE VARCHAR(1)
    ,PLANTNAME VARCHAR(75)
 );
 
--We need to use a combination of both the Make and VDS 
--to decode many attributes including the engine, transmission, etc
CREATE TABLE MAX_VIN.DECODE.MMVDS
(
     MAKE_ID   NUMBER(3)
    ,MODEL_ID  NUMBER(6)
    ,MODEL_NAME     VARCHAR(50)
    ,VDS  VARCHAR(5)
    ,DESC1     VARCHAR(25)
    ,DESC2     VARCHAR(25)
    ,DESC3     VARCHAR(50)
    ,DESC4     VARCHAR(25)
    ,DESC5     VARCHAR(25)
    ,BODYSTYLE VARCHAR(25)
    ,ENGINE    VARCHAR(100)
    ,DRIVETYPE VARCHAR(50)
    ,TRANS     VARCHAR(50)
    ,MPG  VARCHAR(25)
);

/* 🥋 A File Format to Help Max Load the Data */
--Create a file format and then load each of the 5 Lookup Tables
--You need a file format if you want to load the table
CREATE FILE FORMAT MAX_VIN.DECODE.COMMA_SEP_HEADERROW 
TYPE = 'CSV' 
COMPRESSION = 'AUTO' 
FIELD_DELIMITER = ',' 
RECORD_DELIMITER = '\n' 
SKIP_HEADER = 1 
FIELD_OPTIONALLY_ENCLOSED_BY = '\042'  
TRIM_SPACE = TRUE 
ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE 
ESCAPE = 'NONE' 
ESCAPE_UNENCLOSED_FIELD = '\134' 
DATE_FORMAT = 'AUTO' 
TIMESTAMP_FORMAT = 'AUTO' 
NULL_IF = ('\\N');

/* 🥋 Load the Tables and Check Out the Data */
USE ROLE ACCOUNTADMIN;

list @demo_db.public.like_a_window_into_an_s3_bucket/smew;
/*
smew/Maxs_MMVDS_Data.csv
smew/Maxs_ManufPlants_Data.csv
smew/Maxs_ManufToMake_Data.csv
smew/Maxs_ModelYear_Data.csv
smew/Maxs_WMIToManuf_data.csv
*/

COPY INTO MAX_VIN.DECODE.WMITOMANUF
from @demo_db.public.like_a_window_into_an_s3_bucket
files = ('smew/Maxs_WMIToManuf_data.csv')
file_format =(format_name=MAX_VIN.DECODE.COMMA_SEP_HEADERROW);

COPY INTO MAX_VIN.DECODE.MANUFTOMAKE
from @demo_db.public.like_a_window_into_an_s3_bucket
files = ('smew/Maxs_ManufToMake_Data.csv')
file_format =(format_name=MAX_VIN.DECODE.COMMA_SEP_HEADERROW);

COPY INTO MAX_VIN.DECODE.MODELYEAR
from @demo_db.public.like_a_window_into_an_s3_bucket
files = ('smew/Maxs_ModelYear_Data.csv')
file_format =(format_name=MAX_VIN.DECODE.COMMA_SEP_HEADERROW);

COPY INTO MAX_VIN.DECODE.MANUFPLANTS
from @demo_db.public.like_a_window_into_an_s3_bucket
files = ('smew/Maxs_ManufPlants_Data.csv')
file_format =(format_name=MAX_VIN.DECODE.COMMA_SEP_HEADERROW);

COPY INTO MAX_VIN.DECODE.MMVDS
from @demo_db.public.like_a_window_into_an_s3_bucket
files = ('smew/Maxs_MMVDS_Data.csv')
file_format =(format_name=MAX_VIN.DECODE.COMMA_SEP_HEADERROW);