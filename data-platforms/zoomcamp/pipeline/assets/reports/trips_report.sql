/* @bruin
# reports.trips_report: daily trip counts by vendor for analytics
name: reports.trips_report
type: duckdb.sql

depends:
  - staging.trips

materialization:
  type: table
  strategy: create+replace
  # incremental_key: pickup_datetime
  # time_granularity: timestamp

columns:
  - name: vendor_id
    type: string
    description: ID of the taxi vendor (identifies which taxi company)
    primary_key: true
  - name: pickup_date
    type: DATE
    description: Date of the trip pickup
    primary_key: true
  - name: trip_count
    type: BIGINT
    description: Number of trips for the vendor and date combination
    checks:
      - name: non_negative

@bruin */

-- Daily trip aggregation by vendor
-- Groups staging data at the day/vendor level for dashboards and analytics
-- Counts total trips per vendor per day
-- Filtered to the run's time window (required for time_interval strategy)

SELECT
  vendor_id,
  DATE(pickup_datetime) AS pickup_date,
  COUNT(*) AS trip_count
FROM staging.trips
WHERE pickup_datetime >= '{{ start_datetime }}'
  AND pickup_datetime < '{{ end_datetime }}'
GROUP BY
  vendor_id,
  DATE(pickup_datetime)
ORDER BY
  vendor_id,
  pickup_date
