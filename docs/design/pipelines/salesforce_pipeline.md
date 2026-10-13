---
artifacts: [salesforce_pipeline]
---

# salesforce_pipeline

Durable design record for the Salesforce dlt ingestion pipeline.

## Grain

One landing table per Salesforce object: `opportunity`, `account`, `sf_user`. Each row is one Salesforce record version (the latest state for merge resources, the full snapshot for replace resources).

## Decisions

- `D-01` Connection name is `salesforce`; connector is `dlt-verified/salesforce`; dataset schema is `src_salesforce`. Source: R-01, medallion-guardrails (land into connection-own schema, never dbt target schema).
- `D-02` Three resources selected: `opportunity` (merge, incremental on `SystemModstamp`), `account` (merge, incremental on `LastModifiedDate`), `sf_user` (replace, no cursor — connector defines it as a full-replace snapshot). Source: R-01 user answer; connector source code `/data/connector-sources/dlt-verified/sources/salesforce/__init__.py`.
- `D-03` Schema contract per resource: `{"columns": "freeze", "tables": "evolve", "data_type": "freeze"}`. Freeze columns and data types to protect downstream staging contracts; evolve tables so new Salesforce custom fields added to the API response do not break the load. Source: medallion-guardrails.
- `D-04` Sample load default (1,000 rows via `DLT_INGEST_LIMIT=1000`) for development runs; production runs are full (no limit). Source: requirement business decision / playbook default.
- `D-05` Auth method: `SecurityTokenAuth` (`user_name` as config field, `password` and `security_token` as secrets). Secret names in local_toml: `sources.salesforce.credentials.password`, `sources.salesforce.credentials.security_token`. Source: connector introspection (`client.py` `SecurityTokenAuth`).
- `D-06` Orchestration (`R-03` daily schedule) is `omit`: DuckDB-local has no native orchestration support (`platforms/duckdb_local/orchestration.md` is absent). Source: orchestration playbook; platform file listing.

## Rejected

- **Append write disposition for Opportunity**: rejected — merge on `Id` (stable Salesforce record identity) is the correct default and avoids row duplication across runs.
- **`user` resource name**: the connector exports the resource as `sf_user` (not `user`) to avoid collisions with SQL reserved words; the landing table is `sf_user`.

## Consumers

- dbt staging models `stg_salesforce__opportunities`, `stg_salesforce__accounts`, `stg_salesforce__users` read from `src_salesforce` via `source()` references.

## Evidence

- Connector entry point: `/data/connector-sources/dlt-verified/sources/salesforce/__init__.py` — resources, write dispositions and cursors read directly.
- Auth spec: `/data/connector-sources/dlt-verified/sources/salesforce/helpers/client.py` — `SecurityTokenAuth` fields.
- `simple-salesforce==1.12.10` already installed in the runtime environment.
- No existing ingestion docs (`ingestion/docs/*.yml`) — fresh build, no impacted resources.

## History

- 2026-10-13 — intent/new-intent-bf62da00 — initial design — D-01 through D-06
