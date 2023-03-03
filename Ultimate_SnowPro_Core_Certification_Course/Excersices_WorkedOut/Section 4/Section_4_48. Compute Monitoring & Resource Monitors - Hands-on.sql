/*----------------D2_2 Hands-on----------------
1) Virtual Warehouse usage and credit monitoring through UI and SQL 
2) Resource Monitors
----------------------------------------------*/

-- Set context
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE SNOWFLAKE;
USE SCHEMA ACCOUNT_USAGE;

select * from warehouse_metering_history;

select * from warehouse_metering_history 
where warehouse_name='DATA_ANALYSIS_WAREHOUSE';

-- Total credits used grouped by warehouse
SELECT WAREHOUSE_NAME,
       SUM(CREDITS_USED) AS TOTAL_CREDITS_USED
FROM WAREHOUSE_METERING_HISTORY
WHERE START_TIME >= DATE_TRUNC(MONTH, CURRENT_DATE)
GROUP BY 1
ORDER BY 2 DESC;

select DATE_TRUNC(MONTH, CURRENT_DATE);

-- Warehouse metering history using the Information Schema
SELECT *
FROM TABLE(INFORMATION_SCHEMA.WAREHOUSE_METERING_HISTORY(dateadd('days',-7,current_date())));


-- Copy into Classic Console

-- Set context
USE DATABASE SNOWFLAKE_SAMPLE_DATA;
USE SCHEMA TPCH_SF1000;

-- Create resource monitor
CREATE RESOURCE MONITOR DATA_ANALYSIS_WAREHOUSE_RESOURCE_MONITOR WITH CREDIT_QUOTA = 1 
 TRIGGERS 
 ON 50 PERCENT DO NOTIFY
 ON 90 PERCENT DO SUSPEND 
 ON 100 PERCENT DO SUSPEND_IMMEDIATE;
 
-- Resource Monitor object can be applied at account level 
-- ALTER ACCOUNT SET RESOURCE_MONITOR = "ACCOUNT_RESOURCE_MONITOR";

-- Apply resource monitor at virtual warehouse level 
ALTER WAREHOUSE "COMPUTE_WH" SET RESOURCE_MONITOR = "DATA_ANALYSIS_WAREHOUSE_RESOURCE_MONITOR";

ALTER WAREHOUSE COMPUTE_WH SET WAREHOUSE_SIZE=XXXLARGE;

SELECT * FROM LINEITEM;

-- Resize warehouse to xsmall
ALTER WAREHOUSE COMPUTE_WH SET WAREHOUSE_SIZE=XSMALL;
DROP RESOURCE MONITOR DATA_ANALYSIS_WAREHOUSE_RESOURCE_MONITOR;