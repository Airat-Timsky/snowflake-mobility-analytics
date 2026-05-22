USE ROLE ACCOUNTADMIN;
USE WAREHOUSE WH_MOBILITY_DEV;
USE DATABASE MOBILITY_DEMO;

-- 1. Overall pipeline summary.
CREATE OR REPLACE VIEW OPS.PIPELINE_SUMMARY AS
SELECT
    'yellow_taxi_2024_01' AS dataset_name,

    raw_stats.raw_row_count,
    valid_stats.valid_row_count,

    raw_stats.raw_row_count - valid_stats.valid_row_count AS excluded_row_count,

    ROUND(
        valid_stats.valid_row_count / NULLIF(raw_stats.raw_row_count, 0) * 100,
        2
    ) AS valid_row_percentage,

    valid_stats.min_pickup_datetime,
    valid_stats.max_pickup_datetime,

    valid_stats.total_revenue,
    valid_stats.avg_total_amount,
    valid_stats.avg_trip_distance,
    valid_stats.avg_trip_duration_minutes

FROM (
    SELECT
        COUNT(*) AS raw_row_count
    FROM SILVER.YELLOW_TAXI_TRIPS_CLEAN
) raw_stats
CROSS JOIN (
    SELECT
        COUNT(*) AS valid_row_count,
        MIN(pickup_datetime) AS min_pickup_datetime,
        MAX(pickup_datetime) AS max_pickup_datetime,
        ROUND(SUM(total_amount), 2) AS total_revenue,
        ROUND(AVG(total_amount), 2) AS avg_total_amount,
        ROUND(AVG(trip_distance), 2) AS avg_trip_distance,
        ROUND(AVG(trip_duration_minutes), 2) AS avg_trip_duration_minutes
    FROM SILVER.YELLOW_TAXI_TRIPS_VALID
) valid_stats;


-- 2. Data quality issue counts.
CREATE OR REPLACE VIEW OPS.DATA_QUALITY_REPORT AS
SELECT
    'yellow_taxi_2024_01' AS dataset_name,

    COUNT(*) AS total_rows,

    COUNT_IF(pickup_datetime < '2024-01-01'::TIMESTAMP_NTZ) AS pickup_before_jan_2024,
    COUNT_IF(pickup_datetime >= '2024-02-01'::TIMESTAMP_NTZ) AS pickup_after_jan_2024,

    COUNT_IF(dropoff_datetime <= pickup_datetime) AS invalid_time_order,
    COUNT_IF(DATEDIFF('minute', pickup_datetime, dropoff_datetime) > 240) AS too_long_trips,

    COUNT_IF(trip_distance <= 0) AS non_positive_distance,
    COUNT_IF(trip_distance > 100) AS suspicious_distance,

    COUNT_IF(fare_amount < 0) AS negative_fare,
    COUNT_IF(total_amount < 0) AS negative_total,

    COUNT_IF(pickup_location_id IS NULL) AS missing_pickup_location,
    COUNT_IF(dropoff_location_id IS NULL) AS missing_dropoff_location

FROM SILVER.YELLOW_TAXI_TRIPS_CLEAN;


-- 3. Top-level business highlights.
CREATE OR REPLACE VIEW OPS.BUSINESS_HIGHLIGHTS AS
WITH top_demand_zone AS (
    SELECT
        pickup_borough,
        pickup_zone,
        trips_count,
        total_revenue
    FROM GOLD.PICKUP_ZONE_METRICS
    ORDER BY demand_rank
    LIMIT 1
),

top_revenue_zone AS (
    SELECT
        pickup_borough,
        pickup_zone,
        trips_count,
        total_revenue
    FROM GOLD.PICKUP_ZONE_METRICS
    ORDER BY revenue_rank
    LIMIT 1
),

top_revenue_route AS (
    SELECT
        pickup_borough,
        pickup_zone,
        dropoff_borough,
        dropoff_zone,
        trips_count,
        total_revenue
    FROM GOLD.ROUTE_REVENUE_METRICS
    ORDER BY revenue_rank
    LIMIT 1
)

SELECT
    'top_demand_zone' AS metric_name,
    pickup_borough || ' / ' || pickup_zone AS metric_value,
    trips_count,
    total_revenue
FROM top_demand_zone

UNION ALL

SELECT
    'top_revenue_zone' AS metric_name,
    pickup_borough || ' / ' || pickup_zone AS metric_value,
    trips_count,
    total_revenue
FROM top_revenue_zone

UNION ALL

SELECT
    'top_revenue_route' AS metric_name,
    pickup_zone || ' → ' || dropoff_zone AS metric_value,
    trips_count,
    total_revenue
FROM top_revenue_route;


SELECT 'OPS views created' AS status;

SELECT *
FROM OPS.PIPELINE_SUMMARY;

SELECT *
FROM OPS.DATA_QUALITY_REPORT;

SELECT *
FROM OPS.BUSINESS_HIGHLIGHTS;