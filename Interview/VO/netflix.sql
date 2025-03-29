/*NETFLIX*/

-- Platform engagement
SELECT
    d.full_date,
    COUNT(DISTINCT fuva.session_id) AS active_sessions,
    COUNT(DISTINCT fuva.user_id) AS active_users,
    SUM(fuva.calculated_watch_duration) AS total_streaming_time_minutes, -- calculated_watch_duration = (end_time - start_time) - total_pause_duration.
    AVG(fuva.calculated_watch_duration) AS avg_streaming_time_per_session
FROM fact_user_video_activity fuva
JOIN dim_date d ON fuva.activity_date = d.date_id
WHERE d.date_id = 20250322
GROUP BY d.full_date;

-- User
-- Daily Active User (DAU)
-- Why: Indicates how many individual users are active on the platform each day.
select
    d.full_date,
    count(distinct fuva.user_id) as daily_active_users
from fact_user_activity fuva
join dim_date d on fuva.activity_date = d.date_id
where d.date_id = '2025-03-22'
group by d.full_date;

-- Session Frequency
-- Why: Helps determine how often users return or engage in multiple sessions within the same day.
with daily_sessions as (
    select
        d.full_date,
        fuva.user_id,
        count(distinct fuva.session_id) as session_count
    from fact_user_video_activity fuva
    join dim_date d on fuva.activity_date = d.date_id
    where d.date_id = '20250322'
    group by d.full_date, fuva.user_id
)
select
    full_date,
    avg(session_count) as avg_sessions_per_user
from daily_sessions
group by full_date;

-- Session Duration per User
-- Why: Provides insight into how much time users are dedicating to watching content per session.
with user_sessions as (
    select
        d.full_date,
        fuva.user_id,
        (extract(epoch from (fuva.end_time - fuva.start_time))
            - extract(epoch from fuva.total_pause_duration)
        ) as session_duration_seconds
    from fact_user_video_activity fuva
    join dim_date d on fuva.activity_date = d.date_id
    where d.date_id ='20250322'
)
select
    full_date,
    user_id,
    avg(session_duration_seconds) as avg_session_duration_seconds
from user_sessions
group by full_date, user_id;

-- Is completed
select
    fuva.user_id,
    fuva.video_id,
    dv.duration,
    sum(fuva.calculate_watch_duration) as cumulative_watch_time,
    case when sum(fuva.calculate_watch_duration) >= (0.9 * dv.duration) then True else False end as is_completed
from fact_user_video_activity fuva
join dim_video dv on fuva.video_id = dv.video_id
group by fua.user_id, fua.video_id, dv.duration;

/* Extra - retention and consecutive

This query computes, for each day, the number of users active that day and the percentage who return the very next day.

WITH daily_users AS (
  SELECT
    activity_date::date AS activity_date,
    user_id
  FROM fact_user_activity
  GROUP BY activity_date, user_id
)
SELECT
  d1.activity_date AS base_date,
  COUNT(DISTINCT d1.user_id) AS users_base_day,
  COUNT(DISTINCT d2.user_id) AS retained_next_day,
  (COUNT(DISTINCT d2.user_id) * 100.0 / COUNT(DISTINCT d1.user_id)) AS retention_rate_percentage
FROM daily_users d1
LEFT JOIN daily_users d2
  ON d1.user_id = d2.user_id
  AND d2.activity_date = d1.activity_date + INTERVAL '1 day'
GROUP BY d1.activity_date
ORDER BY d1.activity_date;

This query extends the logic to calculate retention for the next two consecutive days. You can adjust by adding more self-joins for additional days.

WITH daily_users AS (
  SELECT
    activity_date::date AS activity_date,
    user_id
  FROM fact_user_activity
  GROUP BY activity_date, user_id
)
SELECT
  d1.activity_date AS base_date,
  COUNT(DISTINCT d1.user_id) AS users_base_day,
  COUNT(DISTINCT d2.user_id) AS retained_day2,
  COUNT(DISTINCT d3.user_id) AS retained_day3,
  (COUNT(DISTINCT d2.user_id) * 100.0 / COUNT(DISTINCT d1.user_id)) AS retention_rate_day2,
  (COUNT(DISTINCT d3.user_id) * 100.0 / COUNT(DISTINCT d1.user_id)) AS retention_rate_day3
FROM daily_users d1
LEFT JOIN daily_users d2
  ON d1.user_id = d2.user_id
  AND d2.activity_date = d1.activity_date + INTERVAL '1 day'
LEFT JOIN daily_users d3
  ON d1.user_id = d3.user_id
  AND d3.activity_date = d1.activity_date + INTERVAL '2 day'
GROUP BY d1.activity_date
ORDER BY d1.activity_date;
*/

-- Video Engagement
-- Count the number of engagement events (grouped by type such as 'like', 'comment', etc.) per video per day.
select
    d.full_date,
    fve.video_id,
    fve.enent_type,
    count(*) as event_count
from fact_video_engagement fve
join dim_date d on fve.activity_date = d.date_id
where d.date_id = '20250322'
group by d.full_date, fve.video_id, fve.enent_type;

-- Engagement Rate per video
WITH video_views AS (
    SELECT
        video_id,
        activity_date,
        COUNT(DISTINCT session_id) AS total_views
    FROM fact_user_activity
    WHERE activity_date = '2025-03-22'
    GROUP BY video_id, activity_date
),
video_engagement AS (
    SELECT
        video_id,
        activity_date,
        COUNT(*) AS total_engagements
    FROM fact_video_engagement
    WHERE activity_date = '2025-03-22'
    GROUP BY video_id, activity_date
)
SELECT
    vv.activity_date,
    vv.video_id,
    vv.total_views,
    ve.total_engagements,
    (ve.total_engagements::float / vv.total_views) AS engagement_rate
FROM video_engagement ve
JOIN video_views vv
    ON ve.video_id = vv.video_id
    AND ve.activity_date = vv.activity_date;

-- update cumulative table
WITH daily_snapshot AS (
    -- Aggregate today's data from the log table
    SELECT
        customer_id,
        SUM(time_spend) AS todays_time_spend,
        SUM(time_spend_total) AS todays_time_spend_total
    FROM log_table
    WHERE date = CURRENT_DATE  -- Use the appropriate date function as needed
    GROUP BY customer_id
)
MERGE INTO aggregate_customer_table AS agg
USING (
    -- Full outer join the daily snapshot with the existing aggregate data
    SELECT
        COALESCE(ds.customer_id, agg_existing.customer_id) AS customer_id,
        COALESCE(agg_existing.time_spend_total, 0) + COALESCE(ds.todays_time_spend, 0) AS new_time_spend_total,
        COALESCE(ds.todays_time_spend, 0) AS new_time_spend
    FROM daily_snapshot ds
    FULL OUTER JOIN aggregate_customer_table agg_existing
        ON ds.customer_id = agg_existing.customer_id
) AS src
ON agg.customer_id = src.customer_id
WHEN MATCHED THEN
    UPDATE SET
        time_spend = src.new_time_spend,
        time_spend_total = src.new_time_spend_total,
        date = CURRENT_DATE
WHEN NOT MATCHED THEN
    INSERT (customer_id, time_spend, time_spend_total, date)
    VALUES (src.customer_id, src.new_time_spend, src.new_time_spend_total, CURRENT_DATE);


-- Aggregating Engagements Over a Period
SELECT
    DATE_TRUNC('week', d.full_date) AS week_start,
    fve.video_id,
    fve.event_type,
    COUNT(*) AS event_count
FROM fact_video_engagement fve
JOIN dim_date d ON fve.activity_date = d.date_id
where fve.activity_date >= '20250322'
GROUP BY DATE_TRUNC('week', d.full_date), fve.video_id, fve.event_type
ORDER BY week_start, fve.video_id;

-- rewatch and video completion rate
WITH complete_sessions AS (
  SELECT
    user_id,
    video_id,
    COUNT(*) AS complete_watch_count
  FROM fact_user_activity
  WHERE is_complete = TRUE
  GROUP BY user_id, video_id
)
SELECT
  video_id,
  SUM(complete_watch_count - 1) AS total_rewatch_events
FROM complete_sessions
WHERE complete_watch_count > 0
GROUP BY video_id;


WITH video_stats AS (
  SELECT
    video_id,
    COUNT(*) AS total_views,
    SUM(CASE WHEN is_complete = TRUE THEN 1 ELSE 0 END) AS complete_views
  FROM fact_user_activity
  GROUP BY video_id
)
SELECT
  video_id,
  complete_views,
  total_views,
  (complete_views::float / total_views) AS completion_rate
FROM video_stats;

CREATE TABLE agg_video_engagement (
    video_id INT,
    agg_date DATE,
    cumulative_views BIGINT,
    cumulative_complete_views BIGINT,
    cumulative_rewatch_events BIGINT,
    completion_rate FLOAT,
    PRIMARY KEY (video_id, agg_date)
);
