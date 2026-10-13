with source as (
    select * from {{ source('salesforce', 'account') }}
    where "IsDeleted" = false
),

renamed as (
    select
        cast("Id"               as varchar)   as account_id,
        cast("Name"             as varchar)   as account_name,
        cast("Industry"         as varchar)   as industry,
        cast("BillingCountry"   as varchar)   as billing_country,
        cast("LastModifiedDate" as timestamp) as last_modified_at
    from source
)

select * from renamed
