with source as (
    select *
    from {{ source('staging', 'fhv_tripdata') }}
    where dispatching_base_num is not null
),

renamed as (
    select
        cast(dispatching_base_num as string) as dispatching_base_num,
        cast(pickup_datetime as timestamp) as pickup_datetime,
        cast(dropoff_datetime as timestamp) as dropoff_datetime,
        cast(pulocationid as integer) as pickup_location_id,
        cast(dolocationid as integer) as dropoff_location_id
    from source
)

select * from renamed
