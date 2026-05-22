USE ROLE ACCOUNTADMIN;

-- 1. Small development warehouse.
-- This is the compute engine that runs SQL queries.
CREATE OR REPLACE WAREHOUSE WH_MOBILITY_DEV
  WAREHOUSE_SIZE = XSMALL
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE
  COMMENT = 'Development warehouse for Snowflake mobility analytics project';

-- 2. Basic resource monitor to protect trial credits.
-- We start with a conservative 80-credit limit.
CREATE OR REPLACE RESOURCE MONITOR RM_MOBILITY_TRIAL_GUARD
  WITH CREDIT_QUOTA = 80
  FREQUENCY = MONTHLY
  START_TIMESTAMP = IMMEDIATELY
  TRIGGERS
    ON 50 PERCENT DO NOTIFY
    ON 80 PERCENT DO SUSPEND
    ON 100 PERCENT DO SUSPEND_IMMEDIATE;

ALTER WAREHOUSE WH_MOBILITY_DEV SET RESOURCE_MONITOR = RM_MOBILITY_TRIAL_GUARD;

-- 3. Use the warehouse we just created.
USE WAREHOUSE WH_MOBILITY_DEV;

-- 4. Create project database.
CREATE OR REPLACE DATABASE MOBILITY_DEMO
  COMMENT = 'End-to-end Snowflake mobility analytics demo project';

-- 5. Create medallion-style schemas.
CREATE OR REPLACE SCHEMA MOBILITY_DEMO.RAW
  COMMENT = 'Raw source-aligned data';

CREATE OR REPLACE SCHEMA MOBILITY_DEMO.SILVER
  COMMENT = 'Cleaned and normalized data';

CREATE OR REPLACE SCHEMA MOBILITY_DEMO.GOLD
  COMMENT = 'Analytics-ready data marts';

CREATE OR REPLACE SCHEMA MOBILITY_DEMO.OPS
  COMMENT = 'Operational metadata, data quality checks, and cost monitoring';

-- 6. Quick checks.
SHOW WAREHOUSES LIKE 'WH_MOBILITY_DEV';
SHOW DATABASES LIKE 'MOBILITY_DEMO';
SHOW SCHEMAS IN DATABASE MOBILITY_DEMO;
SHOW RESOURCE MONITORS LIKE 'RM_MOBILITY_TRIAL_GUARD';