
with source as (

    select * from {{ source('staging', 'yellow_tripdata') }}

),

renamed as (

    select
        -- identifiers
        SAFE_CAST(FLOOR(CAST(vendor_id AS FLOAT64)) AS INT64)           as vendor_id,
        SAFE_CAST(FLOOR(CAST(rate_code AS FLOAT64)) AS INT64)           as rate_code,
        SAFE_CAST(FLOOR(CAST(pickup_location_id AS FLOAT64)) AS INT64)  as pickup_location_id,
        SAFE_CAST(FLOOR(CAST(dropoff_location_id AS FLOAT64)) AS INT64) as dropoff_location_id,
        
        -- timestamps
        cast(pickup_datetime as timestamp)  as pickup_datetime,
        cast(dropoff_datetime as timestamp) as dropoff_datetime,
        
        -- trip info
        SAFE_CAST(FLOOR(CAST(passenger_count AS FLOAT64)) AS INT64) as passenger_count,
        cast(trip_distance as numeric) as trip_distance,
        cast(store_and_fwd_flag as string) as store_and_fwd_flag,

        -- payment info 
        cast(fare_amount as numeric)   as fare_amount,
        cast(extra as numeric)         as extra,
        cast(mta_tax as numeric)       as mta_tax,
        cast(tip_amount as numeric)    as tip_amount,
        cast(tolls_amount as numeric)  as tolls_amount,
        cast(imp_surcharge as numeric) as improvement_surcharge,
        cast(total_amount as numeric)  as total_amount,
        SAFE_CAST(FLOOR(CAST(payment_type AS FLOAT64)) AS INT64) as payment_type

    from source
    where vendor_id is not null

)

select * from renamed
