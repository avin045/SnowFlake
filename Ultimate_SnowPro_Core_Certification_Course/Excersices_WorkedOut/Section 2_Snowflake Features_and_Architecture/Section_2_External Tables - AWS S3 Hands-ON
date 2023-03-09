-- link -> s3://snowflake-training-udemy-1/external_tables/
USE ROLE ACCOUNTADMIN;
use warehouse compute_wh;
use database demo_db;
use schema demo_schema;

/* STAGE for "IMDB_DATASET" */
create or replace stage imdb_dataset
url = 's3://snowflake-training-udemy-1/'
CREDENTIALS = (AWS_KEY_ID = 'AKIAU26WV6SJPMDFH5UZ'
               AWS_SECRET_KEY = 'sYDMxgfRvsCmltq/CypLXmiWIYaigh9p2M2jUBXC');

/* FILE FORMAT */
create or replace file format imdb_file_format
type = 'CSV'
skip_header = 1
field_delimiter = ','
FIELD_OPTIONALLY_ENCLOSED_BY = '"';

list @imdb_dataset;

select $1,$2,$3,$5 from @imdb_dataset/external_tables/imdb_movie_dataset.csv;
-- Rank	        Title	         Genre	Director
-- 1	Guardians of the Galaxy	"Action	Sci-Fi"

select $1,$2,$3,$5 from @imdb_dataset/external_tables/imdb_movie_dataset.csv
(file_format=>imdb_file_format); -- total 12 columns
-- RANK    NAME                     GENRE                DIRECTOR
-- 1	Guardians of the Galaxy	Action,Adventure,Sci-Fi	James Gunn


/* EXTERNAL TABLE -> https://thinketl.com/how-to-create-snowflake-external-tables/ */
CREATE OR REPLACE EXTERNAL TABLE imdb_ext_tbl WITH
LOCATION = @imdb_dataset/external_tables/
FILE_FORMAT = imdb_file_format
PATTERN='.*imdb_movie_dataset.*[.]csv';

select * from imdb_ext_tbl;
select value from imdb_ext_tbl;
/* Above 2 queries produce same results
{
  "c1": "1",
  "c10": "757074",
  "c11": "333.13",
  "c12": "76",
  "c2": "Guardians of the Galaxy",
  "c3": "Action,Adventure,Sci-Fi",
  "c4": "A group of intergalactic criminals are forced to work together to stop a fanatical warrior from taking control of the universe.",
  "c5": "James Gunn",
  "c6": "Chris Pratt, Vin Diesel, Bradley Cooper, Zoe Saldana",
  "c7": "2014",
  "c8": "121",
  "c9": "8.1"
}
*/

create or replace external table imdb_ext_tbl_clnames(
"rank" int as (value:c1::int),
name varchar as (value:c2::varchar)
) with 
location = @imdb_dataset/external_tables/
file_format=imdb_file_format 
pattern='.*imdb_movie_dataset.*[.]csv'
auto_refresh = true;

alter external table imdb_ext_tbl refresh;
desc table imdb_ext_tbl;

select value from imdb_ext_tbl_clnames;
select * from imdb_ext_tbl_clnames;

