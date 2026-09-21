---
artifacts: [dim_product]
---

# dim_product

Product dimension table with one row per product.

## Grain

One row per unique product name — each row uniquely identifies a product offered for sale.

## Decisions

**D-01: Grain is one row per unique product_name.** Requirement R-03@1 specifies one row per product. product_name is the natural key.

**D-02: product_id is a surrogate key generated as ROW_NUMBER() OVER (ORDER BY product_name).** Provides a stable integer key for joins. product_name itself serves as the natural key and uniqueness constraint.

**D-03: first_sold_date is MIN(order_date) grouped by product_name.** Captures when each product first appeared in orders. Cites R-03@1.

**D-04: Materialization is `table`.** Dimensions are persisted. Cites medallion modeling decision.

## Rejected

- SCD Type 2 (tracking product attributes over time): Not applicable — sample data contains no attribute changes. Full refresh only.

## Rerun behaviour

Full refresh: identical output on every run. No time logic.

## Consumers

None named yet.

## Supporting evidence

- Bronze profiling: Source has 6 distinct products (Gadget X, Gadget Y, Gadget Z, Widget A, Widget B, Widget C) with no nulls.
- Requirement: `/workspace/docs/requirement/2026-09-21-sales-data-mart-1c1695ba.md#r-03` — product dimension specification.

## Gotchas

None identified yet.

## History

- **new-intent-1c1695ba, 2026-09-21:** Initial design. D-01 through D-04 defined.
