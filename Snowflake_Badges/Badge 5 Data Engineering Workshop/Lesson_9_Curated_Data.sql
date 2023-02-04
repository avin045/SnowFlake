/* 🎯 Create a CURATED Layer */
use database ags_game_audience;

create schema CURATED;

use schema curated;


/* 🥋 Rolling Up Login and Logout Events with ListAgg */
--the List Agg function can put both login and logout into a single column in a single row
-- if we don't have a logout, just one timestamp will appear
select GAMER_NAME
      , listagg(GAME_EVENT_LTZ,' / ') as login_and_logout -- GROUP CONCAT
from AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED 
group by gamer_name;

/*  🥋 Windowed Data for Calculating Time in Game Per Player */
select GAMER_NAME
       ,game_event_ltz as login 
       ,lead(game_event_ltz) 
                OVER (
                    partition by GAMER_NAME 
                    order by GAME_EVENT_LTZ
                ) as logout
       ,coalesce(datediff('mi', login, logout),0) as game_session_length
from AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED
order by game_session_length desc;

select * from AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED;

select game_event_ltz as login 
       ,lead(game_event_ltz) 
                OVER (
                    partition by GAMER_NAME 
                    order by GAME_EVENT_LTZ
                ) as logout from AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED;