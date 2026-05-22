# Snowflake Mobility Analytics

End-to-end data engineering project built on Snowflake using NYC taxi trips, taxi zones, and hourly weather data.

The project demonstrates batch ingestion, RAW/SILVER/GOLD data modeling, data quality checks, business analytics marts, weather enrichment, and cost monitoring.

## Project overview

This project analyzes NYC Yellow Taxi trips for January 2024 and enriches trip data with:
- NYC taxi zone lookup data
- Hourly NYC weather data
- Data quality checks
- Business KPI marts
- Snowflake cost monitoring

## Architecture

```text
External data sources
        |
        v
Snowflake RAW schema
        |
        v
Snowflake SILVER schema
        |
        v
Snowflake GOLD schema
        |
        v
Snowflake OPS schema
```

### Data sources:
* NYC Yellow Taxi Trip Records, January 2024
* NYC Taxi Zone Lookup
* NYC hourly weather data, January 2024

## Snowflake objects

### Compute:
* WH_MOBILITY_DEV

### Database:
* MOBILITY_DEMO

### Schemas:
* RAW
* SILVER
* GOLD
* OPS

### Results:
```text
Metric                      Value
Raw taxi rows               2,964,624
Valid taxi rows             2,863,081
Valid row percentage        96.57%
Weather rows                744
Total taxi revenue          $78,164,735.77
Estimated Snowflake cost    $2.97
Trial budget used           0.74%
```

### Business highlights:
```text
Metric                                       Result
Top pickup zone by demand                    Manhattan / Upper East Side South
Top pickup zone by revenue                   Queens / JFK Airport
Top revenue route                            JFK Airport → Outside of NYC
Top demand hour                              2024-01-17 18:00
Trips during top demand hour                 8,697
Highest average trips/hour weather bucket    freezing
```

### Data quality findings:
```text
Check                           Count
Pickup before January 2024      15
Pickup after January 2024       3
Invalid time order              870
Non-positive distance           60,371
Negative fare                   37,448
Negative total                  35,504
```

### Cost monitoring:
The first batch analytics milestone was completed using an XSMALL Snowflake warehouse.
```text
Metric                              Value
Credits used                        0.9907
Estimated cost                      $2.97
Estimated trial budget used         0.74%
Estimated trial budget remaining    $397.03
```

Cost estimate assumes $3.00 per Snowflake credit. Actual credit price may vary by cloud provider, region, edition, and contract.

## Project status

### Current milestone:
* Batch ingestion completed
* Taxi data modeled through RAW/SILVER/GOLD layers
* Weather enrichment completed
* OPS quality and cost reporting completed

### Next milestone:
* Package project for reproducible GitHub demo
* Add Streamlit dashboard
* Add simulated streaming ingestion