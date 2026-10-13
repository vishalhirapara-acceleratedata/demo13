with source as (
    select * from {{ source('salesforce', 'opportunity') }}
    where "IsDeleted" = false
),

renamed as (
    select
        cast("Id"          as varchar)   as opportunity_id,
        cast("Name"        as varchar)   as opportunity_name,
        cast("AccountId"   as varchar)   as account_id,
        cast("OwnerId"     as varchar)   as owner_id,
        cast("StageName"   as varchar)   as stage_name,
        cast("CloseDate"   as date)      as close_date,
        cast("CreatedDate" as timestamp) as created_at,
        cast("Amount"      as double)    as amount,
        cast("SystemModstamp" as timestamp) as system_modstamp
    from source
)

select * from renamed
