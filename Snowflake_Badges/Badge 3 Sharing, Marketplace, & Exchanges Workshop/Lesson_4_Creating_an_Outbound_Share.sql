-- Lesson_4_Creating_an_Outbound_Share

-- 🥋 Create an Outbound Share of the INTL_DB Tables
use role accountadmin;

-- OVERRIDE THE SHARE RESTRICTIONS
USE DATABASE INTL_DB;
grant override share restrictions on account to role accountadmin;

-- LOOKING FOR ACCOUNT LOCATOR
SELECT CURRENT_ACCOUNT();

-- 🥋 Convert "Regular" Views to Secure Views
ALTER VIEW INTL_DB.PUBLIC.NATIONS_SAMPLE_PLUS_ISO
SET SECURE; 

ALTER VIEW INTL_DB.PUBLIC.SIMPLE_CURRENCY
SET SECURE;