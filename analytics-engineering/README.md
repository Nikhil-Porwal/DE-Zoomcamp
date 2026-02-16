# 📦 Module 4 Homework — Analytics Engineering (dbt)

This module focuses on transforming raw NYC Taxi data in BigQuery into analytics-ready models using dbt Cloud.

We build:
* Staging models
* Intermediate unioned trips model
* Fact and dimension tables
* Aggregated revenue mart

---

## 🔧 Tech Stack

* **Google BigQuery** (Data Warehouse)
* **dbt Cloud** (Developer plan – free)
* **NYC Taxi Public Dataset** + DataTalksClub releases (FHV)

---

## 📂 Project Structure
```
models/
├── staging/
│   ├── stg_green_tripdata.sql
│   ├── stg_yellow_tripdata.sql
│   └── stg_fhv_tripdata.sql
│
├── intermediate/
│   └── int_trips_unioned.sql
│
└── marts/
    ├── dim_zones.sql
    ├── dim_vendors.sql
    ├── fct_trips.sql
    └── fct_monthly_zone_revenue.sql
```

---

## ✅ Question 1 — dbt Lineage & Execution

**Question:** If you run:
```bash
dbt run --select int_trips_unioned
```

**Answer:** ✔ `stg_green_tripdata`, `stg_yellow_tripdata`, and `int_trips_unioned`

**Reason:** dbt always builds upstream dependencies automatically.

---

## ✅ Question 2 — dbt Tests

**Question:** A new value appears in `payment_type` not included in accepted_values.

**Answer:** ✔ dbt will fail the test with non-zero exit code.

---

## ✅ Question 3 — Count Records in fct_monthly_zone_revenue
```sql
SELECT COUNT(*)
FROM `de-zoomcamp-nikhilporwal.dbt_nikhilporwal.fct_monthly_zone_revenue`;
```

**option:** ➡ 12,998

---

## ✅ Question 4 — Best Performing Green Taxi Zone (2020)
```sql
SELECT
  pickup_zone,
  SUM(revenue_monthly_total_amount) AS total_revenue
FROM `de-zoomcamp-nikhilporwal.dbt_nikhilporwal.fct_monthly_zone_revenue`
WHERE service_type = 'Green'
  AND EXTRACT(YEAR FROM revenue_month) = 2020
GROUP BY pickup_zone
ORDER BY total_revenue DESC
LIMIT 1;
```

**Answer:** ✔ East Harlem South

---

## ✅ Question 5 — Green Taxi Trips (October 2019)
```sql
SELECT
  SUM(total_monthly_trips) AS total_trips
FROM `de-zoomcamp-nikhilporwal.dbt_nikhilporwal.fct_monthly_zone_revenue`
WHERE service_type = 'Green'
  AND EXTRACT(YEAR FROM revenue_month) = 2019
  AND EXTRACT(MONTH FROM revenue_month) = 10;
```

**option:** ➡ 421,509

---

## ✅ Question 6 — FHV Staging Model

### Load FHV 2019 Data

Data downloaded from:
```
https://github.com/DataTalksClub/nyc-tlc-data/releases/tag/fhv
```

Uploaded into BigQuery table:
```
trips_data_all.fhv_tripdata
```

### stg_fhv_tripdata.sql

```sql
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

select * from renamed;
```

### Count Records
```sql
SELECT COUNT(*) 
FROM `de-zoomcamp-nikhilporwal.dbt_nikhilporwal.stg_fhv_tripdata`;
```

**Answer:** ✔ 43,244,693

---

## 🧠 Key Notes (Important)

### Schema Differences

Zoomcamp originally used raw tables produced from CSV ingestion with column names like:
```
VendorID
lpep_pickup_datetime
RatecodeID
PULocationID
```

Public BigQuery NYC dataset uses:
```
vendor_id
pickup_datetime
rate_code
pickup_location_id
```

### How We Handled This

Instead of renaming raw tables, we adjusted staging models to align with our raw schema:
* No physical ALTER TABLE operations
* Only casting and aliasing in staging SQL
* Downstream models remain unchanged

This approach:
* ✔ Avoids extra BigQuery storage costs
* ✔ Preserves Zoomcamp model logic
* ✔ Keeps transformations reproducible in dbt

---

## 💰 Cost Control Strategy

* Used `dbt compile` for validation
* Ran `dbt build --select <model>` during development
* Set BigQuery max bytes billed to 1 GB
* No full refresh unless required

**Total BigQuery cost remained within free tier.**

---

## 🚀 Commands Used
```bash
dbt debug
dbt compile --select stg_green_tripdata
dbt build
```