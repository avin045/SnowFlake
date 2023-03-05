/*----------------D3_2 Hands-on----------------
1) Stage types
2) Listing staged data files
3) PUT command
4) Querying staged data files
5) Removing staged data files
----------------------------------------------*/

--Set context
USE ROLE SYSADMIN;

CREATE DATABASE FILMS_DB;
CREATE SCHEMA FILMS_SCHEMA;

CREATE TABLE FILM
(
ID STRING, 
TITLE STRING, 
RELEASE_DATE DATE
);

-- INTERNAL STAGES
-- list contents of user stage (contains worksheet data)
ls @~;
list @~;

-- list contents of table stage 
ls @%FILM;

-- Create internal named stage
CREATE STAGE FILM_STAGE;

-- list contents of internal named stage 
ls @FILM_STAGE;

-- EXTERNAL STAGES
-- Create external stage 
/*
CREATE STAGE EXTERNAL_STAGE
  URL='s3://<bucket_name>/path1/'
  storage_integration = s3_int;

-- Create storage integration object
CREATE STORAGE INTEGRATION s3_int
  type = external_stage
  storage_provider = s3
  storage_aws_role_arn = 'arn:aws:iam::001234567890:role/<aws_role_name>'
  enabled = true
  storage_allowed_locations = ('s3://<bucket_name>/path1/', 's3://<bucket_name>/path2/');
*/

/* ----------------------------- OWN EXPLORATION FOR EXTERNAL STAGE start----------------------------- */

/* CREATING STAGE */
create stage external_stage
URL = 's3://uni-lab-files';

/* creating file format */
create or replace file format L8_CHALLENGE_FF
    TYPE = 'CSV' --csv is used for any flat file (tsv, pipe-separated, etc)
    FIELD_DELIMITER = '\t'
    SKIP_HEADER = 1;


select $1,$2,$3 
from @films_db.films_schema.external_stage/LU_SOIL_TYPE.tsv
(file_format => films_db.films_schema.L8_CHALLENGE_FF);

show file formats;

-- SOIL TABLE
create or replace table LU_SOIL_TYPE(
SOIL_TYPE_ID number,	
SOIL_TYPE varchar(15),
SOIL_DESCRIPTION varchar(75)
 );
 
 show tables;
 desc table LU_SOIL_TYPE;
 
--  Create a COPY INTO Statement to Load the File into the Table
COPY into LU_SOIL_TYPE
from @external_stage
files = ('LU_SOIL_TYPE.tsv')
file_format = (format_name=L8_CHALLENGE_FF);

select "file","status","rows_parsed","rows_loaded" from table(result_scan(last_query_id()));

select * from LU_SOIL_TYPE;


/* ----------------------------- OWN EXPLORATION FOR EXTERNAL STAGE end----------------------------- */
  
  
-- PUT command (execute from within SnowSQL)
USE ROLE SYSADMIN;
USE DATABASE FILMS_DB;
USE SCHEMA FILMS_SCHEMA;

-- PUT file://C:\Users\Admin\Downloads\films.csv @~ auto_compress=false; -- @~ -> User Stage.

-- PUT file://C:\Users\Admin\Downloads\films.csv @%FILM auto_compress=false; -- @%FILM -> Table Stage.

-- PUT file://C:\Users\Admin\Downloads\films.csv @FILM_STAGE auto_compress=false; -- @FILM_STAGE -> Named Stage.

ls @~/films.csv;
-- ls @~;

ls @%FILM;

ls @FILM_STAGE;


-- Contents of a stage can be queried
select $1,$2,$3 from @~/films.csv;

/* select * from @~/films.csv; -- ERROR : SELECT with no columns */

/* FROM TABLE STAGE (@%) */
select * from @%film;

-- Create csv file format to parse files in stage
CREATE FILE FORMAT CSV_FILE_FORMAT
  TYPE = CSV
  SKIP_HEADER = 1;

-- Metadata columns and file format
SELECT metadata$filename, metadata$file_row_number, $1, $2, $3 FROM @%FILM (file_format => 'CSV_FILE_FORMAT');
-- Pattern
SELECT metadata$filename, metadata$file_row_number, $1, $2, $3 FROM @FILM_STAGE (file_format => 'CSV_FILE_FORMAT', pattern=>'.*[.]csv') as t; -- get only csv file using REGEX

-- Path
SELECT metadata$filename, metadata$file_row_number, $1, $2, $3 FROM @FILM_STAGE/films.csv (file_format => 'CSV_FILE_FORMAT') t;

-- Remove file from stage
rm @~/films.csv;
rm @%FILM; 
rm @FILM_STAGE;
-- remove @~/films.csv;