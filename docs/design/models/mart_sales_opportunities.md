---
artifacts: [mart_sales_opportunities]
---

# mart_sales_opportunities

Durable design record for the sales opportunities mart model.

## Grain

One row per Salesforce Opportunity. Primary key: `opportunity_id` (= Salesforce `Id`).

## Decisions

- `D-01` Grain is one row per Opportunity; `opportunity_id` (SF `Id`) is the unique key. Source: R-02 user answer.
- `D-02` Metric: `amount` = `Opportunity.Amount` (ARR / Revenue). NULL amounts are preserved as NULL; not coerced to zero. Source: R-02 user answer.
- `D-03` Three staging inputs: `stg_salesforce__opportunities`, `stg_salesforce__accounts`, `stg_salesforce__users`. Each staging model is 1:1 with its bronze table (rename, cast, soft-delete filter only). Source: medallion-guardrails silver layer.
- `D-04` Unmatched `account_id`: joined via LEFT JOIN to `stg_salesforce__accounts`; no-match rows kept with `account_name = 'Unknown'` and `account_id` preserved. Source: medallion-guardrails unmatched-key default; R-02 (must not drop Opportunity rows).
- `D-05` Unmatched `owner_id`: joined via LEFT JOIN to `stg_salesforce__users`; no-match rows kept with `owner_name = 'Unknown'` and `owner_id` preserved. Source: medallion-guardrails unmatched-key default.
- `D-06` `close_date` NULL: the mart retains the row; downstream dated aggregates that depend on `close_date` must exclude NULLs themselves. The mart does not coerce NULL to a placeholder date. Source: medallion-guardrails null-date-key default.
- `D-07` Materialisation: `table`. Mart is rebuilt on each dbt run; the data volume is driven by the Salesforce Opportunity object count and is manageable as a full table refresh. Source: designing (no requirement or existing model pushed toward incremental).
- `D-08` Contract enforced (`contract: {enforced: true}`) with explicit column types. Grain tested with `unique` + `not_null` on `opportunity_id`; `not_null` on `amount` is NOT added because NULL amount is a valid Salesforce state (requirement preserves it). Source: medallion-guardrails gold layer; R-02.
- `D-09` Layer: gold (`models/marts/sales/`). Reads only `ref()` to staging models; never reads `source()` directly. Source: medallion-guardrails gold layer.
- `D-10` Staging models path: `models/staging/salesforce/`. Each staging model is `stg_salesforce__<object>.sql`. Source: standard dbt project layout; no `AGENTS.md` overriding it.

## Rejected

- **Silver intermediate model**: rejected for now — the join between Opportunity, Account and User is simple enough to do directly in the mart without a dedicated intermediate. Can be introduced later if join logic grows.
- **Incremental materialisation**: rejected — the Opportunity dataset is refreshed via dlt merge; a full-table dbt rebuild is simpler and avoids stale-state risks at this scale.
- **`not_null` test on `amount`**: rejected — Salesforce allows NULL Amount on open opportunities; enforcing not_null would fail on valid source data.

## Consumers

- None currently declared (fresh domain). Downstream BI or semantic-model consumers can be added in a future intent.

## Evidence

- No existing dbt project in repository — fresh build. Change impact: none (no existing artifacts impacted).
- No `/cache/prod-target/manifest.json` — greenfield, no breaking-contract diff applicable.
- Connector confirms `Opportunity.Amount` field is returned as a numeric column (`get_records` via SOQL `SELECT * FROM Opportunity`).

## History

- 2026-10-13 — intent/new-intent-bf62da00 — initial design — D-01 through D-10
