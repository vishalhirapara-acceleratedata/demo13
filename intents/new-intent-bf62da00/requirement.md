---
kinds: [ingestion, transformation, orchestration]
---

# Requirement: Salesforce Sales Datamart Pipeline

## Ask

Build a Salesforce sales datamart pipeline: ingest Opportunity, Account, and User objects from Salesforce into bronze via dlt, transform them into a deal-level sales mart exposing ARR/Revenue, and schedule the end-to-end pipeline to run daily.

## Requirements

- [ ] `R-01` Ingest Salesforce **Opportunity**, **Account**, and **User** objects via a dlt pipeline, landing them in the bronze layer of the sandbox — accept when all three tables are present in the sandbox destination, pass Tier-1 bronze checks (non-empty, schema matches declared contract, no null primary keys), and the pipeline audit finds no critical issues — source: user answer
- [ ] `R-02` Build a mart model `mart_sales_opportunities` at **Opportunity grain** (one row per Opportunity) exposing at minimum: Opportunity ID, Account name, Owner (sales rep) name, stage, close date, created date, and **ARR / Revenue** (`Opportunity.Amount`) — accept when the model builds in the sandbox, grain uniqueness passes (unique + not-null test on Opportunity ID), and `amount` values are non-null and agree with the bronze source to within rounding — source: user answer
- [ ] `R-03` Schedule the pipeline to run **daily** (once per day) in the ephemeral orchestration layer — accept when a schedule definition is present, configured for daily cadence, and passes a one-shot trial run without error — source: user answer

## Business decisions

| Decision | Value | Source |
| --- | --- | --- |
| Salesforce objects in scope | Opportunity, Account, User | user answer |
| Mart grain | One row per Opportunity (Opportunity.Id is the primary key) | user answer |
| Key metric | ARR / Revenue = `Opportunity.Amount` | user answer |
| Metrics out of scope | Win rate, pipeline value, avg deal size, sales cycle length | user answer (not selected) |
| History / write disposition | Merge on Salesforce record ID (stable identity) — default | playbook default applied |
| Development load size | Sample (default 1,000 rows per object) | playbook default applied |
| Unmatched dimension key handling | Keep under an explicit unknown member | playbook default applied |
| Null date key in dated aggregates | Row excluded from dated aggregates | playbook default applied |
| Schedule cadence | Daily | user answer |
| Source connection (`sources.salesforce`) | Not yet configured — first task is `add-or-update-source` | repository inspection |

## Out of scope

- Salesforce objects not listed (Lead, Contact, Opportunity Line Items, etc.)
- Additional metrics beyond ARR/Revenue (win rate, pipeline value, avg deal size, sales cycle) — can be added in a future intent
- No existing published dbt models in this repository to preserve or reuse
- Semantic model layer (not requested)

## Open questions

None — all business branches resolved.

## Approvals

- 2026-10-13T11:40Z — requirement approved — "approved" — 7b03dd1
