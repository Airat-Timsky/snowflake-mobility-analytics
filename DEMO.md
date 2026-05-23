# Demo Guide

This guide describes how to review the Snowflake Mobility Analytics project.

## 1. Review project overview

Start with:

- `README.md`
- `ARCHITECTURE.md`
- `COST_REPORT.md`
- `DATA_DICTIONARY.md`

## 2. Review SQL scripts

SQL scripts are stored in the `sql/` directory and are ordered by execution sequence:

1. `00_setup.sql`
2. `01_load_taxi_zones.sql`
3. `02_create_yellow_taxi_table.sql`
4. `03_silver_yellow_taxi_trips.sql`
5. `04_silver_valid_trips.sql`
6. `05_gold_first_marts.sql`
7. `06_ops_quality_report.sql`
8. `07_cost_monitoring.sql`
9. `08_project_inventory.sql`
10. `09_load_weather.sql`
11. `10_weather_ops_summary.sql`
12. `11_week1_final_summary.sql`

## 3. Review screenshots

Screenshots are stored in:

```text
diagrams/screenshots/
```
They show:

* pipeline summary
* data quality findings
* business highlights
* taxi demand and revenue marts
* weather impact analysis
* Snowflake cost monitoring

## 4. Key results
```text
Metric                     | Value           |
---------------------------|-----------------|
Raw taxi rows              | 2,964,624       |
Valid taxi rows            | 2,863,081       |
Valid row percentage       | 96.57%          |
Weather rows               | 744             |
Total taxi revenue         | $78,164,735.77. |
Estimated Snowflake cost   | $2.97           |
Trial budget used          | 0.74%           |
```

## 5. Current limitations

- Current pipeline is batch-oriented.
- Streaming ingestion is planned as a next milestone.
- Streamlit dashboard is planned as a next milestone.
- Cost estimate focuses on warehouse compute usage.

