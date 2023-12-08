
--  monthly trends for all sessions from google search and orders 
select
	month(ws.created_at) as months, -- month
    count(ws.website_session_id) gsearch_sessions, -- count sessions
    count(order_id) as orders -- count orders
from 
	website_sessions as ws
left join orders 
using(website_session_id)
where 
	ws.created_at < '2012-11-27' -- sepcific condition for the data base
	and utm_source= "gsearch" -- traffic source
group by 1
order by months;