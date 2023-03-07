use database snowflake_sample_data;
use schema TPCH_SF10;

show tables;

-- WAREHOUSE
alter warehouse compute_wh suspend;
alter warehouse compute_wh resume;

-- 1. HLL() → HyperLogLog
select approx_count_distinct(l_orderkey) from lineitem; -- 14866288 -- 2.9 Seconds -- second time -> 81ms
select count(distinct l_orderkey) from snowflake_sample_data.tpch_sf10.lineitem; -- 15,000,000 -- 2.6 Seconds


-- Similarity Estimation

/* MINHASH */
select minhash(5,c_custkey) from customer;
/*
{
  'state': [
    10518758962670,
    67530801241,
    16262854400581,
    1124333112176,
    2574359757806
  ],
  'type': 'minhash',
  'version': 1
}
*/

select minhash(2,c_custkey) from customer;
/*
{
  'state': [
    10518758962670,
    67530801241
  ],
  'type': 'minhash',
  'version': 1
}
*/

-- APPROXIMATE SIMILARITY
select approximate_similarity(mh) from(
(select minhash(5,c_custkey) mh from customer)
union
(select minhash(5,o_custkey) mh from orders)
); -- 0.8

/* APPROXIMATE_SIMILARITY -> UNDERSTANDING */
SELECT APPROXIMATE_SIMILARITY(mh) FROM
  (
    (SELECT minhash(3,'jeeva') as mh)
    UNION ALL
    (SELECT minhash(3,'jeeva j') as mh)
  ); -- 0

-- UNDERSTANDING 'HASHES'
SELECT minhash(3,'jeeva') as mh;
/*
{
  'state': [
    3403012551055548032,
    3077073923438926604,
    2751135295822305176
  ],
  'type': 'minhash',
  'version': 1
}
*/

SELECT minhash(3,'jeeva j') as mh;
/*
{
  'state': [
    7163663911284873682,
    4857838307299404143,
    2552012703313934604
  ],
  'type': 'minhash',
  'version': 1
}

HASHES for 'jeeva' and 'jeeva j' are not matching so it returned '0' ..if it's matched it returns '1'.
*/
SELECT APPROXIMATE_SIMILARITY(mh) FROM
  (
    (SELECT minhash(5,'apple') as mh)
    UNION ALL
    (SELECT minhash(5,'apple') as mh)
  ); -- OUTPUT : 1

SELECT minhash(5,'apple') as mh;
/*
{
  'state': [
    5259395363846272094,
    694937935743455451,
    5353852544495414616,
    789395116392597973,
    5448309725144557138
  ],
  'type': 'minhash',
  'version': 1
}
*/

/* ------------------------------------------ */


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


---------------------------------------------------------------------------------------------
/* -- APPROXIMATE SIMILARITY -- */
create or replace table avin_wishlist(
id int default wishlist_seq.nextval,
rating decimal(10,2),
movie_name varchar
);

create or replace table sal_wishlist(
id int default wishlist_seq.nextval,
rating decimal(10,2),
movie_name varchar
);

-- SEQUENCE
create or replace sequence wishlist_seq
start = 1
increment = 1;


-- SAL WISHLIST --  3 matches
insert into sal_wishlist(rating,movie_name) values (9.3,'The Shawshank Redemption'),
(8.0,'The Pursuit of Happyness'),(7.1,'I, Robot'),(8.1,'Thuppaki'),(7.7,'Nanban');

--  AVIN WISHLIST --  3 matches
insert into avin_wishlist(rating,movie_name) values (7.6,'Gifted'),
(8.0,'Alai Payuthey'),(7.1,'I, Robot'),(8.1,'Thuppaki'),(7.7,'Nanban');

-- APPROXIMATE SIMILARITY
select approximate_similarity(movie_name) from(
(select minhash(5,movie_name) as movie_name from sal_wishlist)
union
(select minhash(5,movie_name) as movie_name from avin_wishlist)
); -- with three matches => 0.2

select approximate_similarity(movie_name) from(
(select minhash(10,movie_name) as movie_name from sal_wishlist)
union
(select minhash(10,movie_name) as movie_name from avin_wishlist)
); -- with three matches => 0.4

select approximate_similarity(movie_name) from(
(select minhash(1024,movie_name) as movie_name from sal_wishlist)
union
(select minhash(1024,movie_name) as movie_name from avin_wishlist)
); -- with three matches => 0.4052734375

select approximate_similarity(movie_name) from(
(select minhash(1025,movie_name) as movie_name from sal_wishlist)
union
(select minhash(1025,movie_name) as movie_name from avin_wishlist)
);

---------------------------------------------------------------------------------------------
