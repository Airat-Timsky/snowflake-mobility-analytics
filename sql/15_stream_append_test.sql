USE ROLE ACCOUNTADMIN;
USE WAREHOUSE WH_MOBILITY_DEV;
USE DATABASE MOBILITY_DEMO;

CREATE OR REPLACE VIEW OPS.LIVE_STREAM_SUMMARY AS
SELECT
    COUNT(*) AS processed_event_count,
    COUNT(DISTINCT event_id) AS distinct_event_count,
    MIN(event_ts) AS first_event_ts,
    MAX(event_ts) AS last_event_ts,
    ROUND(SUM(total_amount), 2) AS total_revenue,
    ROUND(AVG(total_amount), 2) AS avg_total_amount
FROM SILVER.STREAM_TRIP_EVENTS_CLEAN;

select count(*) from OPS.LIVE_STREAM_SUMMARY;


USE ROLE ACCOUNTADMIN;
USE WAREHOUSE WH_MOBILITY_DEV;
USE DATABASE MOBILITY_DEMO;

CREATE OR REPLACE VIEW OPS.LIVE_STREAM_SUMMARY AS
SELECT
    COUNT(*) AS processed_event_count,
    COUNT(DISTINCT event_id) AS distinct_event_count,
    MIN(event_ts) AS first_event_ts,
    MAX(event_ts) AS last_event_ts,
    ROUND(SUM(total_amount), 2) AS total_revenue,
    ROUND(AVG(total_amount), 2) AS avg_total_amount
FROM SILVER.STREAM_TRIP_EVENTS_CLEAN;

SELECT *
FROM OPS.LIVE_STREAM_SUMMARY;


SELECT
    demand_rank,
    pickup_borough,
    pickup_zone,
    trips_count,
    total_revenue,
    avg_total_amount,
    avg_trip_distance
FROM GOLD.LIVE_PICKUP_ZONE_METRICS
ORDER BY demand_rank
LIMIT 10;



SELECT
    pickup_borough,
    pickup_zone,
    dropoff_borough,
    dropoff_zone,
    trips_count,
    total_revenue,
    avg_total_amount,
    avg_trip_distance
FROM GOLD.LIVE_ROUTE_METRICS
ORDER BY total_revenue DESC
LIMIT 10;


SELECT *
FROM OPS.LIVE_STREAM_SUMMARY;