/*----------------D3_3 Hands-on----------------
1) File formats
2) File format options
3) COPY INTO <table> statement
4) COPY INTO <table> copy options
5) COPY INTO <table> load transformation
6) COPY INTO <table> load validation
----------------------------------------------*/

--Set context
USE ROLE SYSADMIN;
USE DATABASE FILMS_DB;
USE SCHEMA FILMS_SCHEMA;

-- WAREHOUSE
use warehouse compute_wh;

SELECT $1, $2, $3 FROM @FILM_STAGE/films.csv (file_format=>'CSV_FILE_FORMAT'); -- (file_format=> CSV_FILE_FORMAT)

-- Table Description
desc table film;

-- Reading file ERROR
COPY INTO FILM FROM @FILM_STAGE/films.csv;

-- Set file format options directly on COPY INTO statement
COPY INTO FILM FROM @FILM_STAGE/films.csv
FILE_FORMAT = (TYPE='CSV' SKIP_HEADER=1);

-- Set file format object on COPY INTO statement
COPY INTO FILM FROM @FILM_STAGE/films.csv
FILE_FORMAT = CSV_FILE_FORMAT;

-- Set file format object on stage
ALTER STAGE FILM_STAGE SET FILE_FORMAT=CSV_FILE_FORMAT;

COPY INTO FILM FROM @FILM_STAGE/films.csv force=true;

-------------------------------------------------------------------

select count(*) from film; -- 10

-------------------------------------------------------------------

-- COPY from table stage
COPY INTO FILM FROM @%FILM/films.csv force=true;

-- Set file format on "table stage"
ALTER TABLE FILM SET STAGE_FILE_FORMAT=(FORMAT_NAME = 'CSV_FILE_FORMAT');

COPY INTO FILM FROM @%FILM/films.csv force=true;

-- FILES copy option
COPY INTO FILM FROM @FILM_STAGE
FILE_FORMAT = CSV_FILE_FORMAT
FILES = ('films.csv')
FORCE=true;

-- PATTERN copy option
COPY INTO FILM FROM @FILM_STAGE
FILE_FORMAT = CSV_FILE_FORMAT
PATTERN = '.*[.]csv'
FORCE=true;

-- Omit columns
COPY INTO FILM(ID, TITLE) FROM
( SELECT 
 $1,
 $2
 FROM @%FILM/films.csv)
FILE_FORMAT = CSV_FILE_FORMAT
FORCE = TRUE;

-- Cast columns
COPY INTO FILM FROM
( SELECT 
 $1,
 $2,
 to_date($3)
 FROM @%FILM/films.csv)
FILE_FORMAT = CSV_FILE_FORMAT
FORCE = TRUE;

-- Reorder columns
COPY INTO FILM FROM
( SELECT 
 $2,
 $1,
 date($3)
 FROM @%FILM/films.csv)
FILE_FORMAT = CSV_FILE_FORMAT
FORCE = TRUE;

--------------------------------------------------------------------

--------------------------------------------------------------------

-- VALIDATION MODE copy option. Possible values: RETURN_<number>_ROWS, RETURN_ERRORS, RETURN_ALL_ERRORS
COPY INTO FILM FROM @FILM_STAGE/films.csv
VALIDATION_MODE = 'RETURN_ROWS'; -- 'RETURN_ROWS','RETURN_ERRORS','RETURN_ALL_ERRORS'

-- Validate function to validate historical copy into execution via query id
COPY INTO FILM FROM @FILM_STAGE
FILE_FORMAT = (TYPE='CSV', SKIP_HEADER=0) -- if SKIP_HEADER=1 WORKS fine, but here the String has been considered as a "DATE" (Date 'release_date' is not recognized)
ON_ERROR=CONTINUE -- "CONTINUE","ABORT_STATEMENT","ABORT_TRANSACTION"
FILES = ('films.csv')
FORCE=true;

COPY INTO FILM FROM @FILM_STAGE
FILE_FORMAT = (TYPE='CSV', SKIP_HEADER=0) -- if SKIP_HEADER=1 WORKS fine, but here the String has been considered as a "DATE" (Date 'release_date' is not recognized)
ON_ERROR=ABORT_STATEMENT -- "CONTINUE","ABORT_STATEMENT","ABORT_TRANSACTION"
FILES = ('films.csv')
FORCE=true;

COPY INTO FILM FROM @FILM_STAGE
FILE_FORMAT = (TYPE='CSV', SKIP_HEADER=0) -- if SKIP_HEADER=1 WORKS fine, but here the String has been considered as a "DATE" (Date 'release_date' is not recognized)
ON_ERROR=SKIP_FILE -- "CONTINUE","ABORT_STATEMENT","ABORT_TRANSACTION"
FILES = ('films.csv')
FORCE=true;

/*
COPY INTO FILM FROM @FILM_STAGE
FILE_FORMAT = (TYPE='CSV', SKIP_HEADER=0) -- if SKIP_HEADER=1 WORKS fine, but here the String has been considered as a "DATE" (Date 'release_date' is not recognized)
ON_ERROR=ABORT_TRANSACTION -- "CONTINUE","ABORT_STATEMENT","ABORT_TRANSACTION"
FILES = ('films.csv')
FORCE=true; -- Wrong option in ON_ERROR*/

-- SELECT * FROM TABLE(VALIDATE(FILMS, job_id=>'<failed_job_id>'));
SELECT * FROM TABLE(VALIDATE(FILM, job_id=>'01aa853e-3200-a9cc-0003-41ba0006007a')); -- VALIDATE(FILM, job_id=>'01aa853e-3200-a9cc-0003-41ba0006007a') (table_name,job id)
