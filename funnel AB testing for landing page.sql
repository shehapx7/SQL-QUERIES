
-- A/B Testing full conversion funnel from each of the two pages to orders. 
-- for new landing page vs the current home page from google search ads campaign "nonbrand"

select -- getting the first time the new landing page used (marking the test start)
	min(website_pageview_id)
from website_pageviews
where pageview_url = "/lander-1";
-- min(website_pageview_id)= 23504

drop table if exists sessions; 
create temporary table sessions -- temp table of the session and landing page
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

drop table if exists funnel_raw; 
create temporary table funnel_raw -- checking if the page visited "1" or not "0"
select 
	sessions.pageview_url, -- landing page 
	sessions.website_session_id, -- sessions
    -- checking if the page visited "1" or not "0" for every page
    case when wp.pageview_url = "/products" then 1 else 0 end as to_product, 
    case when wp.pageview_url = "/the-original-mr-fuzzy" then 1 else 0 end as to_mrfuzzy,
    case when wp.pageview_url = "/cart" then 1 else 0 end as to_cart,
    case when wp.pageview_url = "/shipping" then 1 else 0 end as to_shipping,
    case when wp.pageview_url = "/billing" then 1 else 0 end as to_billing,
    case when wp.pageview_url = "/thank-you-for-your-order" then 1 else 0 end as to_thankyou
from sessions
	left join website_pageviews as wp
		on sessions.website_session_id = wp.website_session_id
where  -- the pages in the funnel
	wp.pageview_url in ("/home","/lander-1","/products","/the-original-mr-fuzzy", 
    "/cart","/shipping","/billing","/thank-you-for-your-order");


drop table if exists funnel_ready_for_calculations; 
-- grouping the raw data from the funnel for each session and sessions grouped by the landing page
-- session_id is repeated for every page in the session and every page have unique page id
-- ex if the customer droped in the cart page
-- pageview_url = "/home" > website_session_id = 5242 > madeit_product = 1 
-- > madeit_mrfuzzy = 1 > madeit_cart = 1 the rest would be 0 for this session etc..
create temporary table funnel_ready_for_calculations 
select 
	pageview_url, -- flag to use in the next aggregation
    website_session_id, -- the current session
    max(to_product) madeit_product,
    max(to_mrfuzzy) madeit_mrfuzzy,
    max(to_cart) madeit_cart,
    max(to_shipping) madeit_shipping,
    max(to_billing) madeit_billing,
    max(to_thankyou) madeit_thankyou
from funnel_raw
group by 1,2;

-- aggregating the sessions data for the 2 landing pages
select
	pageview_url as landing_page,
    count(website_session_id) as sessions,
    sum(madeit_product) product_click_throu,
    sum(madeit_mrfuzzy) mrfuzzy_click_throu,
    sum(madeit_cart) cart_click_throu,
    sum(madeit_shipping) shipping_click_throu,
    sum(madeit_billing) billing_click_throu,
    sum(madeit_thankyou) thankyou_click_throu
from funnel_ready_for_calculations
group by 1; -- the landing page