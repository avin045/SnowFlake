use database snowflake_sample_data;
use schema tpch_sf10;

/* SHOW PARTITIONS */
SHOW tables;

select count(*) from lineitem; -- 61 ms

SELECT * FROM SYSTEM$CLUSTERING_INFORMATION WHERE TABLE_NAME = 'DEMO_TABLE';




-- select count(distinct L_PARTKEY) from lineitem;
-- select approx_count_distinct(L_PARTKEY) from lineitem;

-- select * from lineitem limit 5;