-- Calculate the average number of riders per carpool ride for a given day.
with ride_count as (
    select
        ride_id,
        ride_date,
        count(user_id) as rider_count
    from fact_ride_rider
    where ride_date = '20250325'
    group by ride_id, ride_date
)
select
    ride_date,
    avg(rider_count) as avg_riders_per_ride
from ride_count
group by ride_date;

-- Calculate the percentage of riders who completed their ride segment
SELECT
    ride_date,
    (SUM(CASE WHEN is_complete THEN 1 ELSE 0 END)::float / COUNT(*)) AS rider_completion_rate
FROM fact_ride_rider
where ride_date = '20250325'
GROUP BY ride_date;

-- Offer conversion rate
SELECT
    d.full_date,
    COUNT(*) AS total_offers,
    SUM(CASE WHEN o.status = 'accepted' THEN 1 ELSE 0 END) AS accepted_offers,
    (SUM(CASE WHEN o.status = 'accepted' THEN 1 ELSE 0 END)::float / COUNT(*)) * 100 AS conversion_rate_percentage
FROM dim_offer o
JOIN dim_date d ON DATE(o.submitted_time) = d.full_date
WHERE d.full_date = '2025-04-01'
GROUP BY d.full_date;

-- time to deision
SELECT
    offer_id,
    rider_id,
    EXTRACT(EPOCH FROM (decision_time - submitted_time)) AS time_to_decision_seconds,
    status
FROM dim_offer
WHERE status IN ('accepted', 'rejected')
  AND DATE(submitted_time) = '2025-04-01';

-- cost saving
-- In our model, we assume that when a rider submits an offer, the offer dimension (dim_offer) stores a proposed_fare (the estimated solo fare).
-- When a ride is confirmed as a carpool, each rider’s share (in fact_ride_rider) is stored as fare_share.
-- The cost saving for each rider is defined as:
-- \text{cost saving} = \text{proposed_fare} - \text{fare_share}
-- We focus on carpool rides (where ride_type = 'Carpool').
SELECT
    r.ride_date,
    AVG(o.proposed_fare - rr.fare_share) AS avg_cost_saving_per_rider,
    SUM(o.proposed_fare - rr.fare_share) AS total_cost_saving,
    COUNT(*) AS total_riders
FROM fact_ride r
JOIN fact_ride_rider rr ON r.ride_id = rr.ride_id
JOIN dim_offer o ON r.offer_id = o.offer_id
WHERE r.ride_type = 'Carpool'
  AND r.ride_date = '2025-04-01'
GROUP BY r.ride_date;

-- retention/consecutive rider
-- We want to measure next-day retention for riders using the fact_ride_rider table.
-- Each record in fact_ride_rider has a ride_date (indicating the day of the ride) and a user_id.
-- A rider is considered "retained" if they take a ride on the day immediately following their ride on a given base day.

WITH daily_riders AS (
  SELECT
      ride_date::date AS ride_date,
      user_id
  FROM fact_ride_rider
  GROUP BY ride_date, user_id
)
SELECT
  d1.ride_date AS base_date,
  COUNT(DISTINCT d1.user_id) AS total_riders,
  COUNT(DISTINCT d2.user_id) AS retained_next_day,
  (COUNT(DISTINCT d2.user_id) * 100.0 / COUNT(DISTINCT d1.user_id)) AS next_day_retention_rate
FROM daily_riders d1
LEFT JOIN daily_riders d2
  ON d1.user_id = d2.user_id
  AND d2.ride_date = d1.ride_date + INTERVAL '1 day'
GROUP BY d1.ride_date
ORDER BY d1.ride_date;
