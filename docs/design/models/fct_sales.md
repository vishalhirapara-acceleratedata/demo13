---
artifacts: [fct_sales]
---

# fct_sales

Fact table containing aggregated sales measures by order date, customer, and product.

## Grain

One row per unique combination of (order_date, customer_id, product) — each row represents one or more orders placed by a customer for a product on that date, aggregated into measures.

## Decisions

**D-01: Aggregation grain is (order_date, customer_id, product).** This matches the approved requirement R-01@1 for the fact table grain. Allows tracking customer purchase patterns by product and date.

**D-02: Materialization is `table`.** Marts are persisted as physical tables for query performance and downstream dependency clarity. Cites `/workspace/docs/design/sales-mart-medallion.md` (medallion modeling decision).

**D-03: Measures are SUM(total) for revenue, SUM(quantity) for total_quantity, and COUNT(DISTINCT order_id) for order_count.** Direct aggregations from stg_orders match the approved measures in R-01@1. Nulls in source are absent per bronze profiling.

## Rejected

- Grain at order level (one row per order): Rejected because requirement explicitly asks for aggregation by date, customer, and product.
- Incremental refresh: Not adopted in this intent; full refresh only. Incremental strategy is design pending.

## Rerun behaviour

Full refresh: every run produces identical output given identical source. No time-dependent logic, no deduplication needed (source keys are unique per bronze profile).

## Consumers

None named yet.

## Supporting evidence

- Bronze profiling verdict: `/workspace/docs/requirement/2026-09-21-sales-data-mart-1c1695ba.md` — source is READY with no nulls in key columns and correct types.
- Medallion modeling: `/workspace/docs/design/sales-mart-medallion.md` — placed in marts layer with table materialization.
- Requirement: `/workspace/docs/requirement/2026-09-21-sales-data-mart-1c1695ba.md#r-01` — fct_sales specification.

## Gotchas

None identified yet.

## History

- **new-intent-1c1695ba, 2026-09-21:** Initial design. D-01, D-02, D-03 defined.
