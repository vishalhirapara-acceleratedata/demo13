---
kinds: [transformation]
scope: dbt models for mart_sales_opportunities
---

# Plan: Salesforce Sales Datamart — dbt Models

**Goal:** Author, build and test the dbt staging models and `mart_sales_opportunities` gold mart in the sandbox, producing one verified row per Salesforce Opportunity with ARR/Revenue enriched with Account and Owner names.

**Constraints:**
- Platform: `duckdb_local`; all writes go to `VD_EPHM_DUCKDB_LOCAL_PATH`
- dbt target: `dev` only; never edit profiles or invent a target
- Sources read from `src_salesforce` schema (landed by the dlt pipeline — must exist before Task 3+)
- No `source()` calls inside the gold mart; gold reads only `ref()`
- Contract enforced on `mart_sales_opportunities`; explicit column types required
- `columns: freeze` / `data_type: freeze` schema contract on bronze; staging must cast to declared types
- `IsDeleted = false` filter required on `opportunity` and `account` staging; not needed on `sf_user` (replace)
- NULL `amount` is valid — no `not_null` test on `amount`
- No `dbt_project_evaluator` installed — omit `--exclude package:dbt_project_evaluator`
- Baseline build_sha: not applicable (`/cache/prod-selection/manifest-source.json` absent)

## Scope and impact

| Artifact | Kind | Action | Requirements | Design record | Gate |
| --- | --- | --- | --- | --- | --- |
| `dbt_project.yml` + `packages.yml` | project-config | create | R-02 | code is contract | `dbt parse` — exit 0, 0 errors |
| `sources_salesforce.yml` | project-config | create | R-01, R-02 | `docs/design/pipelines/salesforce_pipeline.md` | `dbt parse` — exit 0 |
| `stg_salesforce__opportunities` | model | create | R-02 | `docs/design/models/mart_sales_opportunities.md` D-03 | `dbt build -s stg_salesforce__opportunities` — exit 0 |
| `stg_salesforce__accounts` | model | create | R-02 | `docs/design/models/mart_sales_opportunities.md` D-03 | `dbt build -s stg_salesforce__accounts` — exit 0 |
| `stg_salesforce__users` | model | create | R-02 | `docs/design/models/mart_sales_opportunities.md` D-03 | `dbt build -s stg_salesforce__users` — exit 0 |
| `mart_sales_opportunities` | model | create | R-02 | `docs/design/models/mart_sales_opportunities.md` | `dbt build -s mart_sales_opportunities` — exit 0, unique+not_null on `opportunity_id` pass |

**Change impact:** Fresh build — no existing dbt project. No downstream consumers. No compiled graph to query.

## Tasks

---

### Task 1: Scaffold dbt project and declare Salesforce sources

**Requirements:** R-02 · **Design:** code is contract · **Skill:** `generating-dbt-model`
**Dependencies:** none

Create the dbt project skeleton and declare the `src_salesforce` source so staging models can reference it via `source()`.

**Files to author:**
- `transform/dbt_project.yml`
- `transform/packages.yml`
- `transform/models/staging/salesforce/sources_salesforce.yml`
- `transform/profiles.yml` — **do not author**; resolved by the runtime

**`dbt_project.yml` must configure:**
```yaml
name: salesforce_datamart
version: "1.0.0"
profile: salesforce_datamart
model-paths: ["models"]
models:
  salesforce_datamart:
    staging:
      +materialized: view
    marts:
      +materialized: table
      +contract:
        enforced: true
```

**`sources_salesforce.yml` must declare:**
- source name `salesforce`, database omitted (DuckDB-local: no catalog), schema `src_salesforce`
- tables: `opportunity`, `account`, `sf_user`
- freshness not set (no orchestration on this platform)

**Gate:**
```bash
cd transform && dbt parse
```
Expected: exit 0, `Done.`, 0 errors, 0 warnings.

**Commit:** `feat(dbt): scaffold project and declare src_salesforce sources`

---

### Task 2: `stg_salesforce__opportunities`

**Requirements:** R-02 · **Design:** `docs/design/models/mart_sales_opportunities.md` D-03 · **Skill:** `generating-dbt-model`
**Dependencies:** Task 1 (project + source declaration must exist)

1:1 staging model over `src_salesforce.opportunity`. Renames columns to snake_case, casts types, filters soft-deletes.

**Files to author:**
- `transform/models/staging/salesforce/stg_salesforce__opportunities.sql`
- `transform/models/staging/salesforce/stg_salesforce__opportunities.yml`

**SQL shape:**
```sql
with source as (
    select * from {{ source('salesforce', 'opportunity') }}
    where "IsDeleted" = false
),
renamed as (
    select
        "Id"               as opportunity_id,
        "Name"             as opportunity_name,
        "AccountId"        as account_id,
        "OwnerId"          as owner_id,
        "StageName"        as stage_name,
        cast("CloseDate" as date)        as close_date,
        cast("CreatedDate" as timestamp) as created_at,
        cast("Amount" as double)         as amount,
        "SystemModstamp"   as system_modstamp
    from source
)
select * from renamed
```

**YAML must include:**
- `description`: "One row per active Salesforce Opportunity (IsDeleted = false). Grain: opportunity_id."
- `not_null` + `unique` test on `opportunity_id`
- column descriptions for all columns

**Gate:**
```bash
cd transform && dbt build -s stg_salesforce__opportunities
```
Expected: exit 0, model created, `not_null` and `unique` tests on `opportunity_id` pass.

**Commit:** `feat(dbt): add stg_salesforce__opportunities`

---

### Task 3: `stg_salesforce__accounts`

**Requirements:** R-02 · **Design:** `docs/design/models/mart_sales_opportunities.md` D-03 · **Skill:** `generating-dbt-model`
**Dependencies:** Task 1

1:1 staging model over `src_salesforce.account`. Renames columns, casts types, filters soft-deletes.

**Files to author:**
- `transform/models/staging/salesforce/stg_salesforce__accounts.sql`
- `transform/models/staging/salesforce/stg_salesforce__accounts.yml`

**SQL shape:**
```sql
with source as (
    select * from {{ source('salesforce', 'account') }}
    where "IsDeleted" = false
),
renamed as (
    select
        "Id"             as account_id,
        "Name"           as account_name,
        "Industry"       as industry,
        "BillingCountry" as billing_country,
        "LastModifiedDate" as last_modified_at
    from source
)
select * from renamed
```

**YAML must include:**
- `description`: "One row per active Salesforce Account (IsDeleted = false). Grain: account_id."
- `not_null` + `unique` test on `account_id`
- column descriptions for all columns

**Gate:**
```bash
cd transform && dbt build -s stg_salesforce__accounts
```
Expected: exit 0, model created, grain tests pass.

**Commit:** `feat(dbt): add stg_salesforce__accounts`

---

### Task 4: `stg_salesforce__users`

**Requirements:** R-02 · **Design:** `docs/design/models/mart_sales_opportunities.md` D-03 · **Skill:** `generating-dbt-model`
**Dependencies:** Task 1

1:1 staging model over `src_salesforce.sf_user`. No `IsDeleted` filter needed — `sf_user` uses `replace` write disposition so deleted users are absent from the source table after each load.

**Files to author:**
- `transform/models/staging/salesforce/stg_salesforce__users.sql`
- `transform/models/staging/salesforce/stg_salesforce__users.yml`

**SQL shape:**
```sql
with source as (
    select * from {{ source('salesforce', 'sf_user') }}
),
renamed as (
    select
        "Id"         as user_id,
        "Name"       as user_name,
        "Email"      as email,
        "IsActive"   as is_active,
        "UserType"   as user_type
    from source
)
select * from renamed
```

**YAML must include:**
- `description`: "One row per Salesforce User. Grain: user_id. Full-replace on every pipeline run — no soft-delete filter needed."
- `not_null` + `unique` test on `user_id`
- column descriptions for all columns

**Gate:**
```bash
cd transform && dbt build -s stg_salesforce__users
```
Expected: exit 0, model created, grain tests pass.

**Commit:** `feat(dbt): add stg_salesforce__users`

---

### Task 5: `mart_sales_opportunities`

**Requirements:** R-02 · **Design:** `docs/design/models/mart_sales_opportunities.md` · **Skill:** `generating-dbt-model`
**Dependencies:** Tasks 2, 3, 4 (all three staging models must be built first)

Gold mart at Opportunity grain. LEFT JOINs to accounts and users; unmatched foreign keys fall back to `'Unknown'`. Enforced contract. Materialised as `table`.

**Files to author:**
- `transform/models/marts/sales/mart_sales_opportunities.sql`
- `transform/models/marts/sales/mart_sales_opportunities.yml`

**SQL shape:**
```sql
-- Grain: one row per Opportunity (opportunity_id = Salesforce Id)
with opportunities as (
    select * from {{ ref('stg_salesforce__opportunities') }}
),
accounts as (
    select * from {{ ref('stg_salesforce__accounts') }}
),
users as (
    select * from {{ ref('stg_salesforce__users') }}
),
final as (
    select
        cast(o.opportunity_id   as varchar) as opportunity_id,
        cast(o.opportunity_name as varchar) as opportunity_name,
        cast(o.account_id       as varchar) as account_id,
        cast(coalesce(a.account_name, 'Unknown') as varchar) as account_name,
        cast(o.owner_id         as varchar) as owner_id,
        cast(coalesce(u.user_name, 'Unknown')    as varchar) as owner_name,
        cast(o.stage_name       as varchar) as stage_name,
        cast(o.close_date       as date)    as close_date,
        cast(o.created_at       as timestamp) as created_at,
        cast(o.amount           as double)  as amount
    from opportunities o
    left join accounts a using (account_id)
    left join users    u on o.owner_id = u.user_id
)
select * from final
```

**YAML must include:**
- `description`: "One row per Salesforce Opportunity. Grain: opportunity_id. ARR/Revenue = amount (Opportunity.Amount). Unmatched account or owner resolves to 'Unknown'."
- Enforced contract block:
  ```yaml
  config:
    contract:
      enforced: true
  ```
- Explicit `data_type` on every column matching the SQL casts above
- `not_null` + `unique` test on `opportunity_id`
- `not_null` tests on `opportunity_name`, `account_id`, `owner_id`, `stage_name`, `account_name`, `owner_name`, `created_at`
- **No** `not_null` on `amount` (NULL is valid for open deals — D-02, R-02)
- Column descriptions for all columns

**Gate (run both commands; both must exit 0):**
```bash
cd transform && dbt build -s mart_sales_opportunities --exclude test_type:unit
cd transform && dbt test -s mart_sales_opportunities --select test_type:unit
```
Expected: model materialised as `table`; `unique` + `not_null` on `opportunity_id` pass; contract enforced with no column-type mismatches.

**Commit:** `feat(dbt): add mart_sales_opportunities gold mart`

---

## Execution evidence

<!-- Append one line per completed task gate:
- Task N: <command> — exit <code> — <artifact> — sha256:<hash>
-->
