USE ROLE ACCOUNTADMIN;
USE WAREHOUSE WH_MOBILITY_DEV;
USE DATABASE MOBILITY_DEMO;
USE SCHEMA RAW;

CREATE OR REPLACE TABLE WEATHER_NYC_HOURLY (
    WEATHER_TIME_STRING STRING,
    TEMPERATURE_2M FLOAT,
    RELATIVE_HUMIDITY_2M FLOAT,
    PRECIPITATION FLOAT,
    RAIN FLOAT,
    SNOWFALL FLOAT,
    WEATHER_CODE NUMBER,
    WIND_SPEED_10M FLOAT
);

SELECT 'WEATHER_NYC_HOURLY table created' AS status;

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE WH_MOBILITY_DEV;
USE DATABASE MOBILITY_DEMO;

SELECT COUNT(*) AS weather_rows
FROM RAW.WEATHER_NYC_HOURLY;

SELECT *
FROM RAW.WEATHER_NYC_HOURLY
ORDER BY WEATHER_TIME_STRING
LIMIT 20;


CREATE OR REPLACE VIEW SILVER.WEATHER_NYC_HOURLY_CLEAN AS 
SELECT 
    TO_TIMESTAMP_NTZ(WEATHER_TIME_STRING) AS weather_hour,
    TEMPERATURE_2M AS temperature_2m_c,
    RELATIVE_HUMIDITY_2M AS relative_humidity_2m_pct,
    PRECIPITATION AS precipitation_mm,
    RAIN AS rain_mm,
    SNOWFALL AS snowfall_cm,
    WEATHER_CODE AS weather_code,
    WIND_SPEED_10M AS wind_speed_10m_kmh,

    CASE    
        WHEN PRECIPITATION > 0 OR RAIN > 0 OR SNOWFALL > 0 THEN TRUE
        ELSE FALSE
    END AS has_precipitation,

    CASE 
        WHEN TEMPERATURE_2M < 0 THEN 'freezing'
        WHEN TEMPERATURE_2M < 5 THEN 'cold'
        WHEN TEMPERATURE_2M < 12 THEN 'cool'
        ELSE 'mild'
    END AS temperature_bucket
FROM RAW.WEATHER_NYC_HOURLY;

SELECT *
FROM SILVER.WEATHER_NYC_HOURLY_CLEAN
ORDER BY rain_mm DESC
LIMIT 24;



CREATE OR REPLACE VIEW GOLD.WEATHER_IMPACT_HOURLY AS
SELECT
    DATE_TRUNC('hour', t.pickup_datetime) AS pickup_hour,

    w.temperature_2m_c,
    w.relative_humidity_2m_pct,
    w.precipitation_mm,
    w.rain_mm,
    w.snowfall_cm,
    w.weather_code,
    w.wind_speed_10m_kmh,
    w.has_precipitation,
    w.temperature_bucket,

    COUNT(*) AS trips_count,
    ROUND(SUM(t.total_amount), 2) AS total_revenue,
    ROUND(AVG(t.total_amount), 2) AS avg_total_amount,
    ROUND(AVG(t.trip_distance), 2) AS avg_trip_distance,
    ROUND(AVG(t.trip_duration_minutes), 2) AS avg_trip_duration_minutes
FROM SILVER.YELLOW_TAXI_TRIPS_VALID t
LEFT JOIN SILVER.WEATHER_NYC_HOURLY_CLEAN w
    ON DATE_TRUNC('hour', t.pickup_datetime) = w.weather_hour
GROUP BY
    pickup_hour,
    w.temperature_2m_c,
    w.relative_humidity_2m_pct,
    w.precipitation_mm,
    w.rain_mm,
    w.snowfall_cm,
    w.weather_code,
    w.wind_speed_10m_kmh,
    w.has_precipitation,
    w.temperature_bucket;



SELECT
    temperature_bucket,
    has_precipitation,
    COUNT(*) AS hours_count,
    SUM(trips_count) AS trips_count,
    ROUND(AVG(trips_count), 2) AS avg_trips_per_hour,
    ROUND(SUM(total_revenue), 2) AS total_revenue,
    ROUND(AVG(avg_total_amount), 2) AS avg_trip_amount
FROM GOLD.WEATHER_IMPACT_HOURLY
GROUP BY
    temperature_bucket,
    has_precipitation
ORDER BY
    temperature_bucket,
    has_precipitation;


SELECT
--    temperature_bucket,
    has_precipitation,
--    SUM(trips_count) AS trips_count,
--    ROUND(AVG(trips_count), 2) AS avg_trips_per_hour,
    ROUND(SUM(total_revenue), 2) AS total_revenue,
--    ROUND(AVG(avg_total_amount), 2) AS avg_trip_amount
FROM GOLD.WEATHER_IMPACT_HOURLY
GROUP BY
--    temperature_bucket,
    has_precipitation
ORDER BY
 --   temperature_bucket,
    has_precipitation;


SELECT
    pickup_hour,
    temperature_2m_c,
    precipitation_mm,
    snowfall_cm,
    wind_speed_10m_kmh,
    trips_count,
    total_revenue
FROM GOLD.WEATHER_IMPACT_HOURLY
ORDER BY trips_count DESC
LIMIT 20;