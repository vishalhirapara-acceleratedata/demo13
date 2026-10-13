-- Grain: one row per Opportunity (opportunity_id = Salesforce Id)
-- ARR/Revenue = amount (Opportunity.Amount). NULL preserved for open deals.
-- Unmatched account_id or owner_id resolves to 'Unknown'.
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
        cast(o.opportunity_id                          as varchar)   as opportunity_id,
        cast(o.opportunity_name                        as varchar)   as opportunity_name,
        cast(o.account_id                              as varchar)   as account_id,
        cast(coalesce(a.account_name, 'Unknown')       as varchar)   as account_name,
        cast(o.owner_id                                as varchar)   as owner_id,
        cast(coalesce(u.user_name, 'Unknown')          as varchar)   as owner_name,
        cast(o.stage_name                              as varchar)   as stage_name,
        cast(o.close_date                              as date)      as close_date,
        cast(o.created_at                              as timestamp) as created_at,
        cast(o.amount                                  as double)    as amount
    from opportunities o
    left join accounts a using (account_id)
    left join users    u on o.owner_id = u.user_id
)

select * from final
