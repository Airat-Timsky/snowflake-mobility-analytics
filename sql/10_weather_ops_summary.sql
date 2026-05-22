USE ROLE ACCOUNTADMIN;
USE WAREHOUSE WH_MOBILITY_DEV;
USE DATABASE MOBILITY_DEMO;

-- 1. Weather data quality report.
CREATE OR REPLACE VIEW OPS.WEATHER_QUALITY_REPORT AS
SELECT
    'weather_nyc_hourly_2024_01' AS dataset_name,

    COUNT(*) AS total_rows,
    MIN(weather_hour) AS min_weather_hour,
    MAX(weather_hour) AS max_weather_hour,

    COUNT_IF(weather_hour IS NULL) AS missing_weather_hour,
    COUNT_IF(temperature_2m_c IS NULL) AS missing_temperature,
    COUNT_IF(relative_humidity_2m_pct IS NULL) AS missing_humidity,
    COUNT_IF(precipitation_mm IS NULL) AS missing_precipitation,
    COUNT_IF(wind_speed_10m_kmh IS NULL) AS missing_wind_speed,

    COUNT_IF(temperature_2m_c < -40 OR temperature_2m_c > 50) AS suspicious_temperature,
    COUNT_IF(relative_humidity_2m_pct < 0 OR relative_humidity_2m_pct > 100) AS suspicious_humidity,
    COUNT_IF(precipitation_mm < 0) AS negative_precipitation,
    COUNT_IF(wind_speed_10m_kmh < 0) AS negative_wind_speed
FROM SILVER.WEATHER_NYC_HOURLY_CLEAN;


-- 2. Weather impact by temperature bucket and precipitation flag.
CREATE OR REPLACE VIEW GOLD.WEATHER_IMPACT_BY_BUCKET AS
SELECT
    temperature_bucket,
    has_precipitation,

    COUNT(*) AS hours_count,
    SUM(trips_count) AS trips_count,

    ROUND(AVG(trips_count), 2) AS avg_trips_per_hour,
    ROUND(SUM(total_revenue), 2) AS total_revenue,
    ROUND(AVG(avg_total_amount), 2) AS avg_trip_amount,

    ROUND(AVG(temperature_2m_c), 2) AS avg_temperature_2m_c,
    ROUND(AVG(precipitation_mm), 2) AS avg_precipitation_mm,
    ROUND(AVG(wind_speed_10m_kmh), 2) AS avg_wind_speed_10m_kmh
FROM GOLD.WEATHER_IMPACT_HOURLY
GROUP BY
    temperature_bucket,
    has_precipitation;


-- 3. Top weather hours by taxi demand.
CREATE OR REPLACE VIEW GOLD.TOP_WEATHER_DEMAND_HOURS AS
SELECT
    pickup_hour,
    temperature_bucket,
    has_precipitation,
    temperature_2m_c,
    precipitation_mm,
    rain_mm,
    snowfall_cm,
    wind_speed_10m_kmh,
    trips_count,
    total_revenue,
    avg_total_amount
FROM GOLD.WEATHER_IMPACT_HOURLY
ORDER BY trips_count DESC
LIMIT 50;


-- 4. Compact weather business summary.
CREATE OR REPLACE VIEW OPS.WEATHER_BUSINESS_SUMMARY AS
WITH precip AS (
    SELECT
        has_precipitation,
        ROUND(AVG(trips_count), 2) AS avg_trips_per_hour,
        ROUND(AVG(total_revenue), 2) AS avg_revenue_per_hour
    FROM GOLD.WEATHER_IMPACT_HOURLY
    GROUP BY has_precipitation
),

most_common_temp_bucket AS (
    SELECT
        temperature_bucket,
        COUNT(*) AS hours_count
    FROM GOLD.WEATHER_IMPACT_HOURLY
    GROUP BY temperature_bucket
    ORDER BY hours_count DESC
    LIMIT 1
),

top_hour AS (
    SELECT
        pickup_hour,
        trips_count,
        total_revenue,
        temperature_bucket,
        has_precipitation
    FROM GOLD.WEATHER_IMPACT_HOURLY
    ORDER BY trips_count DESC
    LIMIT 1
)

SELECT
    'avg_trips_per_hour_with_precipitation' AS metric_name,
    avg_trips_per_hour::STRING AS metric_value
FROM precip
WHERE has_precipitation = TRUE

UNION ALL

SELECT
    'avg_trips_per_hour_without_precipitation' AS metric_name,
    avg_trips_per_hour::STRING AS metric_value
FROM precip
WHERE has_precipitation = FALSE

UNION ALL

SELECT
    'most_common_temperature_bucket' AS metric_name,
    temperature_bucket AS metric_value
FROM most_common_temp_bucket

UNION ALL

SELECT
    'top_demand_hour' AS metric_name,
    pickup_hour::STRING AS metric_value
FROM top_hour

UNION ALL

SELECT
    'top_demand_hour_trips' AS metric_name,
    trips_count::STRING AS metric_value
FROM top_hour;


SELECT 'Weather OPS and GOLD summary views created' AS status;

SELECT *
FROM OPS.WEATHER_QUALITY_REPORT;

SELECT *
FROM GOLD.WEATHER_IMPACT_BY_BUCKET
ORDER BY temperature_bucket, has_precipitation;

SELECT *
FROM GOLD.WEATHER_IMPACT_BY_BUCKET
ORDER BY temperature_bucket, has_precipitation;

SELECT *
FROM OPS.WEATHER_BUSINESS_SUMMARY;

SELECT *
FROM GOLD.TOP_WEATHER_DEMAND_HOURS
ORDER BY trips_count DESC
LIMIT 20;