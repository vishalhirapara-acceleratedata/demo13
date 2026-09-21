---
artifacts: [dim_customer]
---

# dim_customer

Customer dimension table with one row per customer.

## Grain

One row per unique customer_id — the surrogate key uniquely identifying a customer in the orders data.

## Decisions

**D-01: Grain is one row per customer_id.** Requirement R-02@1 specifies one row per customer with customer_id as the key. Cites R-02@1.

**D-02: customer_name is derived as a static label from customer_id.** Since sample data has no separate customer table, name is generated as "Customer_{customer_id}". This is a placeholder suitable for sample/demo data; production data would import actual names from a source dimension or CRM.

**D-03: created_date captures the first order date for each customer.** Derived from MIN(order_date) grouped by customer_id in stg_orders. Cites R-02@1.

**D-04: Materialization is `table`.** Dimensions are persisted as physical tables. Cites medallion modeling decision.

## Rejected

- Incremental SCD Type 2 (tracking customer name changes): Not applicable — sample data has no historical changes. Full refresh only.

## Rerun behaviour

Full refresh: identical output on every run. No time-dependent logic.

## Consumers

None named yet.

## Supporting evidence

- Bronze profiling verdict: Source has 6 distinct customers with no nulls in customer_id.
- Requirement: `/workspace/docs/requirement/2026-09-21-sales-data-mart-1c1695ba.md#r-02` — customer dimension specification.

## Gotchas

- customer_name is a placeholder. Production implementation should source actual customer names from a CRM or customer master table.

## History

- **new-intent-1c1695ba, 2026-09-21:** Initial design. D-01 through D-04 defined.
