
--  monthly trends for sessions from google search campaign "nonbrand" by month and device type 
select
	month(ws.created_at) as months, 
    device_type,
    count(ws.website_session_id) gsearch_sessions,
    count(order_id) as orders
from 
	website_sessions as ws
left join orders 
	using(website_session_id)
where 
	ws.created_at < '2012-11-27' -- condition specific for the database
	and utm_source= "gsearch" -- choosing the data source
    and utm_campaign = "nonbrand" -- choosing the campaign
group by 1,2; -- group by month and device
