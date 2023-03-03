use database snowflake_sample_data;
use schema tpch_sf10;

select * from lineitem limit 50; -- 1.1s /* First 50 rows */

select * from lineitem sample(50);

---------------------------------------------------------------------------------------------------
use database demo_db;
use schema demo_schema;

show tables;

select * from test; -- (23),(67),(2),(3),(9),(19),(45),(81),(90),(11)

select * from test sample(50); -- 50% of the value  --> (67),(2),(3),(9),(19),(45) -> 10 rows -> 5 rows is 50% but return 6 rows

select * from test sample(20); -- (23),(81)

-- BERNOULLI
select * from test sample bernoulli(20); -- 9,90

select * from test sample row(20); -- 67,3,9

select * from test sample(50) seed(765);
/*
Running the ABOVE QUERY for the
1st time -- 23,9,81,90,11
2nd time -- 23,9,81,90,11
3rd time -- 23,9,81,90,11
Returns the same result due to seed()
*/

-- BLOCK
select * from test sample block(100); -- always returns all values
select * from test sample block(50); -- 67,2,3,45 -- it may return 5 rows,1 row,4 rows.

/* FIXED SIZE */
select * from test sample bernoulli (4 rows); -- Randomly generates 4 rows from the table test
select * from test sample row (2 rows); -- Randomly generates 2 rows from the table test
