use database oag_market_place;
use schema public;

show databases;

// Show me all flights to Paris from the USA 
select *
from public.OAG_schedule
where DEPCTRY='US'
and ARRCITY='PAR';



// Show all American Airlines Flights 
select *
from public.OAG_schedule
where CARRIER='AA';

// What is the capacity of flights arriving into Melbourne? 
SELECT SUM(TOTAL_SEATS) FROM public.OAG_schedule
WHERE ARRAPT='MEL'
AND OPERATING!='N'
AND STOPS =0;