/* @bruin
# staging.trips: cleaned, deduplicated trips ready for downstream use
name: staging.trips
type: duckdb.sql

depends:
  - ingestion.trips
  - ingestion.payment_lookup

materialization:
  type: table
  strategy: create+replace
  # incremental_key: pickup_datetime  # enable for incremental runs
  # time_granularity: timestamp

columns:
  - name: vendor_id
    type: string
    description: ID of the taxi vendor
    nullable: false
    checks:
      - name: not_null
  - name: pickup_datetime
    type: timestamp
    description: when the trip pickup started (incremental key)
    nullable: false
    checks:
      - name: not_null
  - name: dropoff_datetime
    type: timestamp
    description: when the trip dropoff ended
    nullable: false
    checks:
      - name: not_null
  - name: passenger_count
    type: integer
    description: number of passengers in the trip
    checks:
      - name: non_negative
  - name: trip_distance
    type: float
    description: distance of the trip in miles
    checks:
      - name: non_negative
  - name: pickup_location_id
    type: integer
    description: location ID where trip started
  - name: dropoff_location_id
    type: integer
    description: location ID where trip ended
  - name: payment_type_id
    type: integer
    description: payment method identifier (FK to payment_lookup)
  - name: payment_type_name
    type: string
    description: human-readable payment method name (enriched from lookup)
  - name: fare_amount
    type: float
    description: base fare amount in dollars
    checks:
      - name: non_negative
  - name: extra
    type: float
    description: miscellaneous extra charges
  - name: mta_tax
    type: float
    description: MTA tax in dollars
  - name: tip_amount
    type: float
    description: tip amount in dollars
  - name: tolls_amount
    type: float
    description: tolls paid in dollars
  - name: improvement_surcharge
    type: float
    description: improvement surcharge in dollars

custom_checks:
  - name: no_negative_distance_or_fare
    description: ensure trip metrics (distance, fare, extras) are never negative
    query: |
      SELECT COUNT(*) FROM staging.trips
      WHERE trip_distance < 0 OR fare_amount < 0 OR extra < 0
    value: 0
  - name: dropoff_after_pickup
    description: ensure dropoff time is always after pickup time
    query: |
      SELECT COUNT(*) FROM staging.trips
      WHERE dropoff_datetime <= pickup_datetime
    value: 0

@bruin */

-- Staging transformation: clean, deduplicate, enrich
-- 1. Normalise: resolve tpep_/lpep_ datetime prefix variants and dlt-normalised
--    location column names (PULocationID → pu_location_id, etc.)
-- 2. Window: filter to the Bruin time interval for incremental processing
-- 3. Deduplicate: keep the most recently extracted record per (vendor, pickup)
-- 4. Enrich: join payment_lookup to surface a human-readable payment name
-- 5. Clean: drop nulls and non-positive invariants that signal bad source rows

WITH raw AS (
    SELECT
        t.vendor_id,
        -- yellow taxi uses tpep_ prefix, green taxi uses lpep_ prefix
        COALESCE(t.tpep_pickup_datetime,  t.lpep_pickup_datetime)  AS pickup_datetime,
        COALESCE(t.tpep_dropoff_datetime, t.lpep_dropoff_datetime) AS dropoff_datetime,
        t.passenger_count,
        t.trip_distance,
        -- dlt normalises PULocationID → pu_location_id, DOLocationID → do_location_id
        t.pu_location_id AS pickup_location_id,
        t.do_location_id AS dropoff_location_id,
        -- source has payment_type as a numeric string column
        t.payment_type,
        t.fare_amount,
        t.extra,
        t.mta_tax,
        t.tip_amount,
        t.tolls_amount,
        t.improvement_surcharge,
        t.extracted_at
    FROM ingestion.trips t
    WHERE COALESCE(t.tpep_pickup_datetime, t.lpep_pickup_datetime) IS NOT NULL
      AND COALESCE(t.tpep_pickup_datetime, t.lpep_pickup_datetime) >= '{{ start_datetime }}'
      AND COALESCE(t.tpep_pickup_datetime, t.lpep_pickup_datetime) <  '{{ end_datetime }}'
),

deduplicated AS (
    SELECT
        vendor_id,
        pickup_datetime,
        dropoff_datetime,
        passenger_count,
        trip_distance,
        pickup_location_id,
        dropoff_location_id,
        payment_type,
        fare_amount,
        extra,
        mta_tax,
        tip_amount,
        tolls_amount,
        improvement_surcharge,
        ROW_NUMBER() OVER (
            PARTITION BY vendor_id, pickup_datetime
            ORDER BY extracted_at DESC
        ) AS rn
    FROM raw
)

SELECT
    d.vendor_id,
    d.pickup_datetime,
    d.dropoff_datetime,
    d.passenger_count,
    d.trip_distance,
    d.pickup_location_id,
    d.dropoff_location_id,
    TRY_CAST(d.payment_type AS INTEGER)          AS payment_type_id,
    COALESCE(p.payment_type_name, 'Unknown')     AS payment_type_name,
    d.fare_amount,
    d.extra,
    d.mta_tax,
    d.tip_amount,
    d.tolls_amount,
    d.improvement_surcharge
FROM deduplicated d
LEFT JOIN ingestion.payment_lookup p
       ON TRY_CAST(d.payment_type AS INTEGER) = p.payment_type_id
WHERE d.rn = 1
  AND d.vendor_id        IS NOT NULL
  AND d.dropoff_datetime IS NOT NULL
  AND d.trip_distance    >= 0
  AND d.fare_amount      >= 0