use database snowflake_sample_data;
use schema TPCH_SF10;

show tables;

-- WAREHOUSE
alter warehouse compute_wh suspend;
alter warehouse compute_wh resume;

-- 1. HLL() → HyperLogLog
select approx_count_distinct(l_orderkey) from lineitem; -- 14866288 -- 2.9 Seconds
select count(distinct l_orderkey) from lineitem; -- 15,000,000 -- 2.6 Seconds


-- Similarity Estimation

/* MINHASH */
select minhash(5,c_custkey) from customer;

-- APPROXIMATE SIMILARITY
select approximate_similarity(mh) from(
(select minhash(5,c_custkey) mh from customer)
union
(select minhash(5,o_custkey) mh from orders)
); -- 0.8

-- FREQUENCY ESTIMATION
/* APPROX_TOP_K */

select approx_top_k(p_size,3,100000) from part;

select p_size , count(p_size) as c from part
group by p_size
order by c desc
limit 3;

select p_size,count(p_size) from part group by p_size limit 10;

-- PERCENTILE ESTIMATION
use database demo_db;
use schema demo_schema;

CREATE or replace TABLE test(
test_scores int
);

insert overwrite into test values (23),(67),(2),(3),(9),(19),(45),(81),(90),(11);

select approx_percentile(test_scores,0.8) from test; -- 0.8 => 80th percentile.
