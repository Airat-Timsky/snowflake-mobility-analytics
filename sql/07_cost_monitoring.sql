USE ROLE ACCOUNTADMIN;
USE WAREHOUSE WH_MOBILITY_DEV;
USE DATABASE MOBILITY_DEMO;

SHOW WAREHOUSES LIKE 'WH_MOBILITY_DEV';

SELECT 
    warehouse_name,
    DATE_TRUNC('day', start_time) AS usage_day,
    ROUND(SUM(credits_used), 4) AS credits_used
FROM snowflake.account_usage.warehouse_metering_history
WHERE warehouse_name = 'WH_MOBILITY_DEV'
GROUP BY 
    warehouse_name,
    usage_day
ORDER BY usage_day DESC;

SELECT 
    query_id,
    start_time,
    warehouse_name,
    database_name,
    schema_name,
    query_type,
    execution_status,
    total_elapsed_time / 1000 AS elapsed_seconds,
    rows_produced,
    LEFT(query_text, 120) AS query_preview
FROM snowflake.account_usage.query_history
WHERE warehouse_name = 'WH_MOBILITY_DEV'
  AND start_time >= DATEADD(day, -7, CURRENT_TIMESTAMP())
ORDER BY start_time DESC
LIMIT 50;

-- ======================================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE WH_MOBILITY_DEV;
USE DATABASE MOBILITY_DEMO;

-- Adjust these two values for your account.
-- CREDIT_PRICE_USD:
--   Use your Snowflake pricing page / account billing info.
-- TRIAL_BUDGET_USD:
--   Your trial budget, for example 400.
SET CREDIT_PRICE_USD = 3.00;
SET TRIAL_BUDGET_USD = 400.00;

CREATE OR REPLACE VIEW OPS.COST_MONITORING_SUMMARY AS
WITH warehouse_usage AS (
    SELECT
        warehouse_name,
        SUM(credits_used) AS credits_used,
        SUM(credits_used_compute) AS credits_used_compute,
        SUM(credits_used_cloud_services) AS credits_used_cloud_services,
        MIN(start_time) AS first_usage_time,
        MAX(start_time) AS last_usage_time
    FROM snowflake.account_usage.warehouse_metering_history
    WHERE warehouse_name = 'WH_MOBILITY_DEV'
    GROUP BY warehouse_name
)
SELECT
    warehouse_name,

    ROUND(credits_used, 4) AS credits_used_total,
    ROUND(credits_used_compute, 4) AS credits_used_compute,
    ROUND(credits_used_cloud_services, 4) AS credits_used_cloud_services,

    ROUND(credits_used * $CREDIT_PRICE_USD, 2) AS estimated_cost_usd,
    ROUND((credits_used * $CREDIT_PRICE_USD) / $TRIAL_BUDGET_USD * 100, 2) AS estimated_trial_budget_used_pct,
    ROUND($TRIAL_BUDGET_USD - (credits_used * $CREDIT_PRICE_USD), 2) AS estimated_trial_budget_remaining_usd,

    first_usage_time,
    last_usage_time
FROM warehouse_usage;


SELECT *
FROM OPS.COST_MONITORING_SUMMARY;




CREATE OR REPLACE VIEW OPS.COST_MONITORING_DAILY AS
SELECT
    warehouse_name,
    DATE_TRUNC('day', start_time) AS usage_day,

    ROUND(SUM(credits_used), 4) AS credits_used_total,
    ROUND(SUM(credits_used_compute), 4) AS credits_used_compute,
    ROUND(SUM(credits_used_cloud_services), 4) AS credits_used_cloud_services,

    ROUND(SUM(credits_used) * $CREDIT_PRICE_USD, 2) AS estimated_cost_usd,
    ROUND(SUM(credits_used) * $CREDIT_PRICE_USD / $TRIAL_BUDGET_USD * 100, 2) AS estimated_trial_budget_used_pct
FROM snowflake.account_usage.warehouse_metering_history
WHERE warehouse_name = 'WH_MOBILITY_DEV'
GROUP BY
    warehouse_name,
    usage_day
ORDER BY usage_day DESC;


SELECT *
FROM OPS.COST_MONITORING_DAILY
ORDER BY usage_day DESC;

ALTER WAREHOUSE WH_MOBILITY_DEV SUSPEND;

show warehouses;