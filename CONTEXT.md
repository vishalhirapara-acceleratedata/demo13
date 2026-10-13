# demo123 — Context

The ubiquitous language of this domain: business terms, entities, abbreviations, source-system quirks, and naming conventions. Platform and agent-family terms are defined elsewhere and never repeated here.

**This file is the language layer, nothing else.**

| Belongs here | Belongs in the catalog (Unity Catalog, Purview, dbt metadata) |
| --- | --- |
| What the business means by a word | Column names, data types, table schemas |
| An abbreviation only this org uses | Row counts, freshness, lineage |
| A source-system quirk worth knowing | Anything a catalog query already answers |

No design decisions (those are ADRs), no implementation detail (that is the artifact's design record), no example values.

## Language

**ARR / Revenue**:
Annual Recurring Revenue or deal value, measured as `Opportunity.Amount` in Salesforce. Used interchangeably in this domain to mean the monetary value of a sales opportunity. NULL when the opportunity has no quoted amount (valid state for open deals).
_Not_: MRR (monthly recurring revenue), Bookings — those are distinct calculations not currently modelled.

**Opportunity**:
A Salesforce Opportunity record representing a potential or closed sales deal. The atomic grain of the sales datamart. Identified by Salesforce `Id`; progresses through stages (e.g. Prospecting → Closed Won / Closed Lost).

**Sales Datamart**:
The gold-layer dbt model (`mart_sales_opportunities`) that presents one row per Opportunity with enriched account and owner attributes, serving downstream sales reporting.
