USE ROLE ACCOUNTADMIN;
USE DATABASE LIBRARY_CARD_CATALOG;
USE SCHEMA VEGGIES;

// Create an Ingestion Table for XML Data

CREATE TABLE LIBRARY_CARD_CATALOG.PUBLIC.AUTHOR_INGEST_XML 
(
  "RAW_AUTHOR" VARIANT
);

-- ------------------------------------------------------------------------
-- XML Lab - With Header Row

-- Create an File Format for the XML Data 
CREATE OR REPLACE FILE FORMAT XML_FILE_FORMAT
TYPE = 'XML'
STRIP_OUTER_ELEMENT = FALSE;

-- 🎯 Modify Your XML File Format (the Non-Klugey Solution)
//MODIFY File Format for XML Data by Changing Config

CREATE OR REPLACE FILE FORMAT LIBRARY_CARD_CATALOG.PUBLIC.XML_FILE_FORMAT 
TYPE = 'XML' 
COMPRESSION = 'AUTO' 
PRESERVE_SPACE = FALSE 
STRIP_OUTER_ELEMENT = TRUE -- FALSE 
DISABLE_SNOWFLAKE_DATA = FALSE 
DISABLE_AUTO_CONVERT = FALSE 
IGNORE_UTF8_ERRORS = FALSE;

--  Load the XML Data into the XML Table

-- create stage object
create stage library_card_catalog.public.like_a_window_s3_bucket
url = "s3://uni-lab-files";

list @like_a_window_s3_bucket;

-- COPY FROM s3 stage to TABLE
COPY INTO AUTHOR_INGEST_XML
from @like_a_window_s3_bucket
files = ('author_with_header.xml')
file_format = (format_name = XML_FILE_FORMAT);

-- VIEW TABLE
select * from AUTHOR_INGEST_XML;

-- truncate AUTHOR_INGEST_XML;

-- ---------------------------------------------------------------

-- XML Lab - No Header Row INTO a SAME TABLE (XML_FILE_FORMAT)

-- COPY FROM s3 stage to TABLE
COPY INTO AUTHOR_INGEST_XML
from @like_a_window_s3_bucket
files = ('author_no_header.xml')
file_format = (format_name = XML_FILE_FORMAT);

-- VIEW TABLE
select * from AUTHOR_INGEST_XML;

-- ---------------------------------------------------------------