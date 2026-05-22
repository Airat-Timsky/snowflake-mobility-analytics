USE ROLE ACCOUNTADMIN;
USE WAREHOUSE WH_MOBILITY_DEV;
USE DATABASE MOBILITY_DEMO;

CREATE OR REPLACE VIEW SILVER.YELLOW_TAXI_TRIPS_CLEAN AS
SELECT
    Vendor_ID::NUMBER AS vendor_id,

    TO_TIMESTAMP_NTZ(pickup_datetime::NUMBER, 6) AS pickup_datetime,
    TO_TIMESTAMP_NTZ(dropoff_datetime::NUMBER, 6) AS dropoff_datetime,

    passenger_count::NUMBER AS passenger_count,
    trip_distance::FLOAT AS trip_distance,
    Rate_code_id::NUMBER AS rate_code_id,
    store_and_fwd_flag::STRING AS store_and_fwd_flag,

    PU_Location_ID::NUMBER AS pickup_location_id,
    DO_Location_ID::NUMBER AS dropoff_location_id,

    payment_type::NUMBER AS payment_type,
    fare_amount::FLOAT AS fare_amount,
    extra::FLOAT AS extra,
    mta_tax::FLOAT AS mta_tax,
    tip_amount::FLOAT AS tip_amount,
    tolls_amount::FLOAT AS tolls_amount,
    improvement_surcharge::FLOAT AS improvement_surcharge,
    total_amount::FLOAT AS total_amount,
    congestion_surcharge::FLOAT AS congestion_surcharge,
    Airport_fee::FLOAT AS airport_fee
FROM RAW.YELLOW_TAXI_TRIPS;


select * from MOBILITY_DEMO.SILVER.YELLOW_TAXI_TRIPS_CLEAN
LIMIT 10;

SELECT
    pickup_datetime,
    dropoff_datetime,
    DATEDIFF('minute', pickup_datetime, dropoff_datetime) AS trip_duration_minutes,
    passenger_count,
    trip_distance,
    fare_amount,
    total_amount
FROM SILVER.YELLOW_TAXI_TRIPS_CLEAN
LIMIT 20;

SELECT COUNT(*) AS row_count
FROM SILVER.YELLOW_TAXI_TRIPS_CLEAN;

SELECT
    MIN(pickup_datetime) AS min_pickup_datetime,
    MAX(pickup_datetime) AS max_pickup_datetime,
    MIN(dropoff_datetime) AS min_dropoff_datetime,
    MAX(dropoff_datetime) AS max_dropoff_datetime
FROM SILVER.YELLOW_TAXI_TRIPS_CLEAN;


SHOW WAREHOUSES LIKE 'WH_MOBILITY_DEV';