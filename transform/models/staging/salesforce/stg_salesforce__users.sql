-- No IsDeleted filter needed: sf_user uses replace write disposition,
-- so deleted users are absent from the source table after each pipeline run.
with source as (
    select * from {{ source('salesforce', 'sf_user') }}
),

renamed as (
    select
        cast("Id"       as varchar) as user_id,
        cast("Name"     as varchar) as user_name,
        cast("Email"    as varchar) as email,
        cast("IsActive" as boolean) as is_active,
        cast("UserType" as varchar) as user_type
    from source
)

select * from renamed
