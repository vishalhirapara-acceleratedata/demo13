# Sales Mart Medallion Data Modelling

Shared layering and architectural decisions for the sales data mart.

## Model Inventory

| Model | Layer | Grain | Materialization | Purpose | Dependencies |
|-------|-------|-------|---|---------|---------|
| stg_orders | staging | one row per order | view | Pass-through of bronze.stg_orders with no transformation | bronze.stg_orders |
| int_sales_by_date_customer_product | intermediate | (order_date, customer_id, product) | ephemeral | Aggregated fact before final mart table | stg_orders |
| fct_sales | marts | (order_date, customer_id, product) | table | Final fact table with revenue, quantity, order count measures | int_sales_by_date_customer_product |
| dim_customer | marts | one row per customer_id | table | Customer dimension with name and first order date | stg_orders |
| dim_product | marts | one row per product_name | table | Product dimension with first sale date | stg_orders |
| dim_date | marts | one row per calendar date | table | Date dimension with time hierarchy (year, month, quarter, week) | stg_orders |

## Decisions

**D-01: Three-layer medallion structure (staging → intermediate → marts).**

- **Staging**: Minimal transformation, one model `stg_orders` as a view over bronze.
- **Intermediate**: Aggregation logic isolated in `int_sales_by_date_customer_product` as ephemeral, keeping intermediate work out of production.
- **Marts**: Final fact and dimension tables exposed to consumers as persistent tables.

Cites architectural pattern from `/data/default-plugins/vibedata-data-engineering/_shared/references/guides/medallion-guardrails.md`.

**D-02: Fact table aggregation at (order_date, customer_id, product) grain.**

Enables customer purchase analysis by product and day. Cites requirement R-01@1.

**D-03: Full refresh materialization; no incremental refresh in this intent.**

Simplifies initial build. Incremental CDC and merge logic are design pending for future work.

**D-04: Staging is a view; intermediate is ephemeral; marts are tables.**

Reduces storage for transient work; persists final outputs. Aligns with dbt defaults in `dbt_project.yml` config.

## Rejected

- Single-layer flat design: Rejected in favor of medallion to support future evolution and intermediate data quality checks.
- All ephemeral: Rejected because marts must be persisted for consumer queries and reproducibility.

## Supporting evidence

- Bronze profiling verdict: `/workspace/docs/requirement/2026-09-21-sales-data-mart-1c1695ba.md` — READY.
- Requirement grains and measures: R-01 through R-04 in the same Requirement artifact.

## History

- **new-intent-1c1695ba, 2026-09-21:** Initial design. D-01 through D-04 defined. Inventory complete.
