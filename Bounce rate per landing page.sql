
/* getting the first created date for lander-1 */

SELECT 
	MIN(created_at),
	MIN(website_pageview_id) AS lander1_pv
FROM website_pageviews
WHERE pageview_url = '/lander-1';


-- get the first page id for every session in the time frame we are intersted in
-- for session source google search campaign "nonbrand"
drop table if exists session_w_id;
create temporary table session_w_id
select 
	website_pageviews.website_session_id,
    min(website_pageview_id) as first_id
from 
	website_pageviews
	left join website_sessions as ws
		using(website_session_id)
where 
	ws.created_at between '2012-06-19' and '2012-07-28' 
	and utm_source = "gsearch" 
	and utm_campaign = "nonbrand"
group by 1;


-- getting the landing page for every session
drop table if exists session_w_landing;
create temporary table session_w_landing
select
	sw.website_session_id,
    first_id,
    pageview_url
from 
	session_w_id as sw
	left join website_pageviews as wp
		on sw.first_id = wp.website_pageview_id;


-- getting the bounced sessions session-id
drop table if exists bounced_sessions;
create temporary table bounced_sessions
select 
	sw.website_session_id,
    count(wp.website_pageview_id) pages_in_session
from 
	session_w_id as sw
	left join website_pageviews as wp
		on sw.website_session_id = wp.website_session_id
group by 1
having 
	pages_in_session = 1;

-- final calculations
select 
	ts.pageview_url,
    count(DISTINCT ts.website_session_id) as total_sessions,
    count(DISTINCT bs.website_session_id) as bounced_sessions,
    (count(DISTINCT bs.website_session_id) 
		/ count(DISTINCT ts.website_session_id)) as bounce_rate
from 
	session_w_landing as ts
	left join bounced_sessions as bs
		using(website_session_id)
group by 1

