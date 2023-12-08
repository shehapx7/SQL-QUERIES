--  monthly trends for sessions from google search capaign "nonbrand" sessions and orders ?

SELECT 
    count(distinct w.website_session_id) as sessions, -- number of sessions
    count(distinct o.order_id) c_orders, -- number of orders
    round((count(distinct o.order_id) / count(distinct w.website_session_id ) ) * 100 ,2) as conv_rt -- conversion rate
FROM website_sessions as w
Left join orders as o
on o.website_session_id = w.website_session_id
where w.created_at < '2012-04-14' and w.utm_source ="gsearch" and w.utm_campaign = "nonbrand";