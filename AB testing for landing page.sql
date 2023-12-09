
-- A/B Testing for new landing page vs the current home page from google search ads campaign "nonbrand"
-- orders_to_sessions 0.88% increase per session for lander-1

select -- getting the first time the new landing page used (marking the test start)
	min(website_pageview_id)
from website_pageviews
where pageview_url = "/lander-1";
-- min(website_pageview_id)= 23504


drop table if exists sessions_w_landing; 
create temporary table sessions_w_landing -- temp table of the session and landing page
select
	wp.website_session_id, 
    pageview_url, -- landing page
    min(website_pageview_id) as landing -- the landing page id
    
from website_pageviews as wp
	left join website_sessions as ws
		using(website_session_id)
where 
	ws.created_at < '2012-07-28' -- specific condition for the database
    and website_pageview_id >= 23504 -- the test beginning
    and utm_source = "gsearch" -- traffic sourse
    and utm_campaign = "nonbrand" -- choosing the campaign
    and pageview_url in ("/home","/lander-1")  -- sessions where the landing page is one of the 2 pages for the test
Group by
	1,2; -- grouping by session and landing page

-- aggregation of the sessions from the temp table per landing page
select 
	pageview_url, -- landing page
	count(website_session_id) as sessions, -- number of sessions
    count(order_id) as orders, -- number of orders
    round(100* (count(order_id) / count(website_session_id)) ,2) as orders_to_sessions_conv_rate -- conversion rate
from sessions_w_landing
	left join orders
		using(website_session_id)
group by 1; -- group by landing page

