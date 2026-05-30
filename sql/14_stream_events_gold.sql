CREATE OR REPLACE VIEW GOLD.LIVE_PICKUP_ZONE_METRICS AS
WITH metrics AS (
    SELECT
        pickup_location_id,
        pickup_borough,
        pickup_zone,

        COUNT(*) AS trips_count,
        ROUND(SUM(total_amount), 2) AS total_revenue,
        ROUND(AVG(total_amount), 2) AS avg_total_amount,
        ROUND(AVG(trip_distance), 2) AS avg_trip_distance,

        MIN(event_ts) AS first_event_ts,
        MAX(event_ts) AS last_event_ts

    FROM SILVER.STREAM_TRIP_EVENTS_CLEAN
    GROUP BY
        pickup_location_id,
        pickup_borough,
        pickup_zone
)

SELECT
    *,
    RANK() OVER (ORDER BY trips_count DESC) AS demand_rank,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM metrics;


CREATE OR REPLACE VIEW GOLD.LIVE_ROUTE_METRICS AS
SELECT
    pickup_borough,
    pickup_zone,
    dropoff_borough,
    dropoff_zone,

    COUNT(*) AS trips_count,
    ROUND(SUM(total_amount), 2) AS total_revenue,
    ROUND(AVG(total_amount), 2) AS avg_total_amount,
    ROUND(AVG(trip_distance), 2) AS avg_trip_distance,

    MIN(event_ts) AS first_event_ts,
    MAX(event_ts) AS last_event_ts

FROM SILVER.STREAM_TRIP_EVENTS_CLEAN
GROUP BY
    pickup_borough,
    pickup_zone,
    dropoff_borough,
    dropoff_zone;

select count(*) from GOLD.LIVE_ROUTE_METRICS;