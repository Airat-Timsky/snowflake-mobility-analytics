# 7. COST_REPORT.md

# Cost Report

## Summary

The first Snowflake batch analytics milestone was completed using an XSMALL warehouse.
```text
| Metric                            | Value     |
|-----------------------------------|----------:|
| Credits used                      | 0.9907    |
| Estimated cost                    | $2.97     |
| Estimated trial budget used       | 0.74%     |
| Estimated trial budget remaining  | $397.03   |
```
## Assumptions

Estimated cost is calculated as:

```text
estimated_cost_usd = credits_used * credit_price_usd

The current report assumes:
credit_price_usd = 3.00
trial_budget_usd = 400.00

Actual Snowflake credit price may vary by cloud provider, region, edition, and contract.
```

### Cost controls used:
* XSMALL warehouse
* AUTO_SUSPEND = 60
* Manual warehouse suspension
* Resource monitor
* Separate OPS reporting views

### Current warehouse:
* WH_MOBILITY_DEV
* Size: XSMALL
* Auto suspend: 60 seconds

## Notes

This report focuses on warehouse compute usage from SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY.

It does not attempt to fully estimate all possible Snowflake charges such as long-term storage, serverless services, Snowpipe, or data transfer.