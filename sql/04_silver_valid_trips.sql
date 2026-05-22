USE ROLE ACCOUNTADMIN;
USE WAREHOUSE WH_MOBILITY_DEV;
USE DATABASE MOBILITY_DEMO;

CREATE OR REPLACE VIEW SILVER.YELLOW_TAXI_TRIPS_VALID AS 
SELECT 
    t.vendor_id,
    t.pickup_datetime,
    t.dropoff_datetime,

    DATEDIFF('minute', t.pickup_datetime, t.dropoff_datetime) AS trip_duration_minutes,

    t.passenger_count,
    t.trip_distance,
    t.rate_code_id,
    t.store_and_fwd_flag,

    t.pickup_location_id,
    pickup_zone.BOROUGH AS pickup_borough,
    pickup_zone.ZONE AS pickup_zone,
    pickup_zone.SERVICE_ZONE AS pickup_service_zone,

    t.dropoff_location_id,
    dropoff_zone.BOROUGH AS dropoff_borough,
    dropoff_zone.ZONE AS dropoff_zone,
    dropoff_zone.SERVICE_ZONE AS dropoff_service_zone,

    t.payment_type,
    t.fare_amount,
    t.extra,
    t.mta_tax,
    t.tip_amount,
    t.tolls_amount,
    t.improvement_surcharge,
    t.total_amount,
    t.congestion_surcharge,
    t.airport_fee
FROM SILVER.YELLOW_TAXI_TRIPS_CLEAN t
LEFT JOIN RAW.TAXI_ZONE_LOOKUP pickup_zone
    ON t.pickup_location_id = pickup_zone.LOCATION_ID
LEFT JOIN RAW.TAXI_ZONE_LOOKUP dropoff_zone
    ON t.dropoff_location_id = dropoff_zone.LOCATION_ID
WHERE 1 = 1
    AND t.pickup_datetime >= '2024-01-01'::TIMESTAMP_NTZ 
    AND t.pickup_datetime <  '2024-02-01'::TIMESTAMP_NTZ

    AND t.dropoff_datetime > t.pickup_datetime
    AND DATEDIFF('minute', t.pickup_datetime, t.dropoff_datetime) BETWEEN 1 AND 240
    AND t.trip_distance > 0
    AND t.trip_distance <= 100
    AND t.fare_amount >= 0
    AND t.total_amount >= 0
    AND t.pickup_location_id IS NOT NULL
    AND t.dropoff_location_id IS NOT NULL;

SELECT
    COUNT(*) AS valid_row_count
FROM SILVER.YELLOW_TAXI_TRIPS_VALID;

SELECT
    MIN(pickup_datetime) AS min_pickup_datetime,
    MAX(pickup_datetime) AS max_pickup_datetime,
    MIN(dropoff_datetime) AS min_dropoff_datetime,
    MAX(dropoff_datetime) AS max_dropoff_datetime
FROM SILVER.YELLOW_TAXI_TRIPS_VALID;


SELECT * FROM SILVER.YELLOW_TAXI_TRIPS_VALID
LIMIT 10;

SELECT
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