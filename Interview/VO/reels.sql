-- Reels Metrics
-- First reel CTR (Click Through Rate)
SELECT
    activity_date,
    COUNT(*) AS total_sessions,
    SUM(CASE WHEN first_post_engaged THEN 1 ELSE 0 END) AS engaged_sessions,
    (SUM(CASE WHEN first_post_engaged THEN 1 ELSE 0 END)::float / COUNT(*)) * 100 AS first_reel_ctr
FROM fact_reels_session
GROUP BY activity_date;

-- Playlist Engagement Analysis:
select
    activity_date,
    AVG(dwell_time_seconds) AS avg_dwell_time,
    AVG(swipe_count) AS avg_swipe_count
FROM fact_reels_session
GROUP BY activity_date;

-- Viral Post Share Count:
SELECT
    activity_date,
    COUNT(*) AS total_sessions,
    SUM(CASE WHEN first_reel_engaged THEN 1 ELSE 0 END) AS engaged_sessions,
    ROUND((SUM(CASE WHEN first_reel_engaged THEN 1 ELSE 0 END)::float / COUNT(*)) * 100, 2) AS first_reel_ctr_percentage,
    AVG(dwell_time_seconds) AS avg_dwell_time_seconds,
    AVG(swipe_count) AS avg_swipe_count
FROM fact_reels_session
WHERE activity_date = '2025-04-01'
GROUP BY activity_date;

--Identify Reels with Zero Likes/React on the Day They Were Posted
SELECT
    r.reel_id,
    r.created_time::date AS post_date,
    r.content_details,
    COUNT(e.engagement_id) AS total_engagements
FROM dim_reel r
LEFT JOIN fact_reel_engagement e
    ON r.reel_id = e.reel_id
    AND e.engagement_type IN ('like', 'react')
    AND e.activity_date = r.created_time::date
WHERE r.created_time::date = '2025-04-01'
GROUP BY r.reel_id, r.created_time, r.content_details
HAVING COUNT(e.engagement_id) = 0;

-- Compute Reels Session KPIs (First Reel CTR & Playlist Engagement)
SELECT
    activity_date,
    COUNT(*) AS total_sessions,
    SUM(CASE WHEN first_reel_engaged THEN 1 ELSE 0 END) AS engaged_sessions,
    ROUND((SUM(CASE WHEN first_reel_engaged THEN 1 ELSE 0 END)::float / COUNT(*)) * 100, 2) AS first_reel_ctr_percentage,
    AVG(dwell_time_seconds) AS avg_dwell_time_seconds,
    AVG(swipe_count) AS avg_swipe_count
FROM fact_reels_session
WHERE activity_date = '2025-04-01'
GROUP BY activity_date;

-- cumulative share counts across days
SELECT
    original_post_id,
    SUM(share_count) AS cumulative_shares
FROM fact_reel_share
WHERE original_post_id = 100  -- For a specific Reel
  AND activity_date BETWEEN '2025-04-01' AND '2025-04-03'
GROUP BY original_post_id;

-- Engagement Rate
select
    r.reel_id,
    count(fre.engagement_id) as total_engagements,
    count(distinct frs.session_id) as total_impressions,
    (count(fre.engagement_id)::float / NULLIF(count(distinct frs.session_id), 0)) AS engagement_rate
from dim_reel r
left join fact_reel_engagement fre on r.reel_id = fre.reel_id
left join fact_reel_sessions frs on r.reel_id = frs.first_reel_id
where r.create_time::date = '2025-04-01'
group by r.reel_id;

-- Share Rate
select
    r.reel_id,
    sum(frs.share_count) as total_shares,
    count(distinct fs.session_id) as total_impressions,
    (sum(frs.share_count)::float / NULLIF(count(distinct fs.session_id), 0)) AS share_rate
from dim_reel r
left join fact_reel_share frs on r.reel_id = frs.original_post_id
left join fat_reel_session fs on r.reel_id = fs.first_reel_id
WHERE frs.activity_date ::date = '2025-04-01'
GROUP BY r.reel_id;


-- Viral
WITH viral AS (
  SELECT
    original_post_id AS reel_id,
    MAX(share_depth) AS max_share_depth,
    SUM(share_count) AS total_shares
  FROM fact_reel_share
  GROUP BY original_post_id
)
SELECT
    r.reel_id,
    v.max_share_depth,
    v.total_shares,
    COUNT(e.engagement_id) AS total_engagements,
    (COUNT(e.engagement_id)::float / NULLIF(v.total_shares, 0)) AS engagement_per_share
FROM dim_reel r
LEFT JOIN viral v
    ON r.reel_id = v.reel_id
LEFT JOIN fact_reel_engagement e
    ON r.reel_id = e.reel_id
WHERE r.created_time::date = '2025-04-01'
GROUP BY r.reel_id, v.max_share_depth, v.total_shares;

SELECT
    original_post_id AS reel_id,
    MAX(share_depth) AS max_share_depth,
    SUM(share_count) AS total_shares
FROM fact_reel_share
WHERE activity_date = '2025-04-01'
GROUP BY original_post_id;



-- Retention
WITH daily_users AS (
  SELECT
      activity_date,
      user_id
  FROM fact_reels_session
  GROUP BY activity_date, user_id
)
SELECT
  d1.activity_date AS base_date,
  COUNT(DISTINCT d1.user_id) AS total_users,
  COUNT(DISTINCT d2.user_id) AS retained_users,
  (COUNT(DISTINCT d2.user_id)::float / NULLIF(COUNT(DISTINCT d1.user_id), 0)) * 100 AS next_day_retention_rate
FROM daily_users d1
LEFT JOIN daily_users d2
  ON d1.user_id = d2.user_id
  AND d2.activity_date = d1.activity_date + INTERVAL '1 day'
GROUP BY d1.activity_date
ORDER BY d1.activity_date;
