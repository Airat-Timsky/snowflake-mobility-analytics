# 8. DATA_DICTIONARY.md

```md
# Data Dictionary

## RAW.TAXI_ZONE_LOOKUP
```text
| Column            | Description           |
|-------------------|-----------------------|
| `LOCATION_ID`     | Taxi zone location ID |
| `BOROUGH`         | NYC borough           |
| `ZONE`            | Taxi zone name        |
| `SERVICE_ZONE`    | Taxi service zone     |
```

## SILVER.YELLOW_TAXI_TRIPS_VALID
```text
| Column                    | Description               |
|---------------------------|---------------------------|
| `pickup_datetime`         | Trip pickup timestamp     |
| `dropoff_datetime`        | Trip dropoff timestamp    |
| `trip_duration_minutes`   | Trip duration in minutes  |
| `passenger_count`         | Number of passengers      |
| `trip_distance`           | Trip distance             |
| `pickup_location_id`      | Pickup taxi zone ID       |
| `pickup_borough`          | Pickup borough            |
| `pickup_zone`             | Pickup zone               |
| `dropoff_location_id`     | Dropoff taxi zone ID      |
| `dropoff_borough`         | Dropoff borough           |
| `dropoff_zone`            | Dropoff zone              |
| `fare_amount`             | Fare amount               |
| `tip_amount`              | Tip amount                |
| `total_amount`            | Total trip amount         |
```

## SILVER.WEATHER_NYC_HOURLY_CLEAN
```text
| Column                        | Description                       |
|-------------------------------|-----------------------------------|
| `weather_hour`                | Weather timestamp rounded to hour |
| `temperature_2m_c`            | Temperature at 2 meters, Celsius  |
| `relative_humidity_2m_pct`    | Relative humidity percentage      |
| `precipitation_mm`            | Precipitation in millimeters      |
| `rain_mm`                     | Rain in millimeters               |
| `snowfall_cm`                 | Snowfall in centimeters           |
| `weather_code`                | Weather code                      |
| `wind_speed_10m_kmh`          | Wind speed at 10 meters           |
| `has_precipitation`           | Boolean precipitation flag        |
| `temperature_bucket`          | Derived temperature bucket        |
```

## GOLD.PICKUP_ZONE_METRICS

Zone-level taxi demand and revenue metrics.

## GOLD.ROUTE_REVENUE_METRICS

Pickup-to-dropoff route-level revenue metrics.

## GOLD.WEATHER_IMPACT_BY_BUCKET

Weather bucket level demand and revenue metrics.