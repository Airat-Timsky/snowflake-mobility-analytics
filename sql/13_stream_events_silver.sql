USE ROLE ACCOUNTADMIN;
USE WAREHOUSE WH_MOBILITY_DEV;
USE DATABASE MOBILITY_DEMO;

CREATE OR REPLACE VIEW SILVER.STREAM_TRIP_EVENTS_CLEAN AS
SELECT
    events.EVENT_DATA:event_id::STRING AS event_id,
    events.EVENT_DATA:event_type::STRING AS event_type,
    events.EVENT_DATA:event_ts::TIMESTAMP_TZ AS event_ts,

    events.EVENT_DATA:vendor_id::NUMBER AS vendor_id,

    events.EVENT_DATA:pickup_location_id::NUMBER AS pickup_location_id,
    pickup_zone.BOROUGH AS pickup_borough,
    pickup_zone.ZONE AS pickup_zone,

    events.EVENT_DATA:dropoff_location_id::NUMBER AS dropoff_location_id,
    dropoff_zone.BOROUGH AS dropoff_borough,
    dropoff_zone.ZONE AS dropoff_zone,

    events.EVENT_DATA:passenger_count::NUMBER AS passenger_count,
    events.EVENT_DATA:trip_distance::FLOAT AS trip_distance,
    events.EVENT_DATA:fare_amount::FLOAT AS fare_amount,
    events.EVENT_DATA:tip_amount::FLOAT AS tip_amount,
    events.EVENT_DATA:total_amount::FLOAT AS total_amount,
    events.EVENT_DATA:payment_type::NUMBER AS payment_type

FROM RAW.STREAM_TRIP_EVENTS events

LEFT JOIN RAW.TAXI_ZONE_LOOKUP pickup_zone
    ON events.EVENT_DATA:pickup_location_id::NUMBER = pickup_zone.LOCATION_ID

LEFT JOIN RAW.TAXI_ZONE_LOOKUP dropoff_zone
    ON events.EVENT_DATA:dropoff_location_id::NUMBER = dropoff_zone.LOCATION_ID

WHERE events.EVENT_DATA:event_type::STRING = 'trip_completed'
  AND events.EVENT_DATA:event_id IS NOT NULL
  AND events.EVENT_DATA:pickup_location_id IS NOT NULL
  AND events.EVENT_DATA:dropoff_location_id IS NOT NULL
  AND events.EVENT_DATA:total_amount::FLOAT >= 0;


select count(*) from SILVER.STREAM_TRIP_EVENTS_CLEAN;