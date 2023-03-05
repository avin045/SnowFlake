-- EXTERNAL TABLE (using Snowflake Learning Platform)
 create or replace stage demo_db.demo_schema.s3_bucket_files
 url = 's3://uni-lab-files/dabw/';
 
 -- MODEL DATA AS STAGE
 create or replace stage demo_db.demo_schema.s3_bucket_Modelfile
 url = 's3://uni-lab-files/dabw/Color_Names.csv';
 
 -- create file format
 create or replace file format csv_fmt
 TYPE = 'CSV';
 
list @s3_bucket_files;

select $1,$2 from @s3_bucket_Modelfile;

-- ---------------------------------------------------------------
-- WORKING

/* CREATE or REPLACE EXTERNAL TABLE my_external_table (
  column1 int,
  column2 varchar
)
location = @s3_bucket_files
FILE_FORMAT = (TYPE = 'CSV' FIELD_DELIMITER = ',' PATTERN = 'Color_Names.csv');*/
create or replace external table my_external_table 
with location = @s3_bucket_files file_format = mys3csv pattern = '.*.csv';

select 
value:c1::varchar as ID, 
value:c2::varchar as name from my_external_table;

select * from my_external_table;

-- ---------------------------------------------------------------

-- https://stackoverflow.com/questions/59197596/snowflake-external-table-from-csv-file-under-s3

select $1,$2,$3,$4 from @s3_bucket_Modelfile;
select * from EXT_TABLE;

list @s3_bucket_files;

alter external table EXT_TABLE refresh;
-- ------------------------------------------
-- FROM SNOWFLAKE LEARNING PLATFORM
create file format ff_parquet
TYPE = 'PARQUET';

create stage trails_parquet
url = 's3://uni-lab-files-more/dlkw/trails/trails_parquet/';

list @trails_parquet;

select $1
from @trails_parquet
(file_format => ff_parquet);

create or replace external table T_CHERRY_CREEK_TRAIL(
	POINT_ID number as ($1:sequence_1::number),
	TRAIL_NAME varchar(50) as  ($1:trail_name::varchar),
	LNG number(11,8) as ($1:latitude::number(11,8)),
	LAT number(11,8) as ($1:longitude::number(11,8)),
	COORD_PAIR varchar(50) as (lng::varchar||' '||lat::varchar)
) 
location= @trails_parquet
auto_refresh = true
file_format = ff_parquet;

select * from T_CHERRY_CREEK_TRAIL;

-- -----------------------------------------------------

-- UNDERSTOOD -> https://dwgeek.com/working-with-snowflake-external-tables-and-s3-examples.html/
create or replace file format mys3csv 
type = 'CSV' 
field_delimiter = ',' 
skip_header = 1;

create or replace stage MYS3STAGE url='s3://uni-lab-files/dabw/'
file_format = mys3csv;

create or replace external table sample_ext 
with location = @mys3stage file_format = mys3csv;

select 
value:c1::varchar as ID, 
value:c2::varchar as name from sample_ext;
-- ----------------------------------------------------------------------

CREATE or replace EXTERNAL TABLE mytable1 with
FILE_FORMAT = (TYPE = 'CSV' FIELD_DELIMITER = ',')
LOCATION = @s3_bucket_Modelfile;

select * from mytable1;
-- ----------------------------------------------------------------------