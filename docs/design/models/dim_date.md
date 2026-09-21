---
artifacts: [dim_date]
---

# dim_date

Date dimension table with one row per calendar date spanning the order history.

## Grain

One row per calendar date from MIN(order_date) to MAX(order_date) in the orders source, with no gaps.

## Decisions

**D-01: Date range spans MIN to MAX order_date with no gaps.** Requirement R-04@1 specifies complete coverage. Ensures every date in the orders period has a dimension row for time-series joins and aggregations. Cites R-04@1.

**D-02: date_key is an integer in YYYYMMDD format.** Enables efficient integer joins and filtering. Standard format for date keys in dimensional modeling.

**D-03: Time components include year, month, day, quarter (1-4), and week_of_year (ISO week numbering).** Requirement R-04@1 specifies these attributes. Supports common time-based analysis and grouping.

**D-04: Materialization is `table`.** Static dimension persisted for performance. Cites medallion modeling.

## Rejected

- Day-of-week, fiscal year, or other time attributes: Not in requirement R-04@1, deferred to future extension.
- Dynamic generation at query time: Rejected in favor of persisted dimension for consistency and query simplicity.

## Rerun behaviour

Full refresh: identical output on every run, determined solely by the min/max date range in stg_orders.

## Consumers

None named yet.

## Supporting evidence

- Bronze profiling: Date range is 2026-01-15 to 2026-01-24 (10-day span).
- Requirement: `/workspace/docs/requirement/2026-09-21-sales-data-mart-1c1695ba.md#r-04` — date dimension specification.

## Gotchas

- ISO week numbering (WEEK_OF_YEAR): Ensure consistent interpretation across timezones and calendar systems if data spans multiple regions later.

## History

- **new-intent-1c1695ba, 2026-09-21:** Initial design. D-01 through D-04 defined.
