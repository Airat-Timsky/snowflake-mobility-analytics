USE ROLE ACCOUNTADMIN;
USE WAREHOUSE WH_MOBILITY_DEV;
USE DATABASE MOBILITY_DEMO;

CREATE OR REPLACE VIEW GOLD.PICKUP_ZONE_METRICS AS 
WITH zone_metrics AS (
    SELECT
        pickup_location_id,
        pickup_borough,
        pickup_zone,
        pickup_service_zone,

        COUNT(*) AS trips_count,

        ROUND(SUM(total_amount), 2) AS total_revenue,
        ROUND(AVG(total_amount), 2) AS avg_total_amount,
        ROUND(AVG(fare_amount), 2) AS avg_fare_amount,
        ROUND(AVG(tip_amount), 2) AS avg_tip_amount,

        ROUND(AVG(trip_distance), 2) AS avg_trip_distance,
        ROUND(AVG(trip_duration_minutes), 2) AS avg_trip_duration_minutes,

        MIN(pickup_datetime) AS first_pickup_datetime,
        MAX(pickup_datetime) AS last_pickup_datetime
    FROM SILVER.YELLOW_TAXI_TRIPS_VALID
    GROUP BY
        pickup_location_id,
        pickup_borough,
        pickup_zone,
        pickup_service_zone
)
SELECT 
    *,
    RANK() OVER (ORDER BY trips_count DESC) AS demand_rank,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM zone_metrics;

CREATE OR REPLACE VIEW GOLD.HOURLY_PICKUP_DEMAND AS
SELECT 
    DATE_TRUNC('hour', pickup_datetime) AS pickup_hour,
    pickup_location_id,
    pickup_borough,
    pickup_zone,

    COUNT(*) AS trip_count,
    ROUND(SUM(total_amount), 2) AS total_revenue,
    ROUND(AVG(total_amount), 2) AS avg_total_amount,
    ROUND(AVG(trip_distance), 2) AS avg_trip_distance,
    ROUND(AVG(trip_duration_minutes), 2) AS avg_trip_duration_minutes
FROM SILVER.YELLOW_TAXI_TRIPS_VALID
GROUP BY
    pickup_hour,
    pickup_location_id,
    pickup_borough,
    pickup_zone;

CREATE OR REPLACE VIEW GOLD.ROUTE_REVENUE_METRICS AS
WITH route_metrics AS (
    SELECT
        pickup_location_id,
        pickup_borough,
        pickup_zone,

        dropoff_location_id,
        dropoff_borough,
        dropoff_zone,

        COUNT(*) AS trips_count,
        ROUND(SUM(total_amount), 2) AS total_revenue,
        ROUND(AVG(total_amount), 2) AS avg_total_amount,
        ROUND(AVG(trip_distance), 2) AS avg_trip_distance,
        ROUND(AVG(trip_duration_minutes), 2) AS avg_trip_duration_minutes
    FROM SILVER.YELLOW_TAXI_TRIPS_VALID
    GROUP BY 
        pickup_location_id,
        pickup_borough,
        pickup_zone,
        dropoff_location_id,
        dropoff_borough,
        dropoff_zone
)
SELECT
    *,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank,
    RANK() OVER (ORDER BY trips_count DESC) AS demand_rank
FROM route_metrics;

SELECT 'Gold views created' AS status;


SELECT
    demand_rank,
    pickup_borough,
    pickup_zone,
    trips_count,
    total_revenue,
    avg_total_amount,
    avg_trip_distance,
    avg_trip_duration_minutes
FROM GOLD.PICKUP_ZONE_METRICS
ORDER BY demand_rank
LIMIT 20;

SELECT
    revenue_rank,
    pickup_borough,
    pickup_zone,
    trips_count,
    total_revenue,
    avg_total_amount
FROM GOLD.PICKUP_ZONE_METRICS
ORDER BY revenue_rank
LIMIT 20;

SELECT
    revenue_rank,
    pickup_borough,
    pickup_zone,
    dropoff_borough,
    dropoff_zone,
    trips_count,
    total_revenue,
    avg_total_amount,
    avg_trip_distance
FROM GOLD.ROUTE_REVENUE_METRICS
ORDER BY revenue_rank
LIMIT 20;

SELECT
    pickup_hour,
    SUM(trip_count) AS total_trips,
    ROUND(SUM(total_revenue), 2) AS total_revenue
FROM GOLD.HOURLY_PICKUP_DEMAND
GROUP BY pickup_hour
ORDER BY pickup_hour
LIMIT 48;