# NYC Taxi dlt Pipeline — Homework Solutions

## Overview

This project builds a **dlt pipeline** that loads NYC Yellow Taxi trip data from a custom paginated REST API into **DuckDB**, then queries the data to answer analytical questions.

| Property | Value |
|----------|-------|
| API Base URL | `https://us-central1-dlthub-analytics.cloudfunctions.net/data_engineering_zoomcamp_api` |
| Destination | DuckDB |
| Pipeline Name | `taxi_pipeline` |

---

## Question 1: Dataset Date Range

**Query:**
```sql
SELECT
    MIN(trip_pickup_date_time) AS start_date,
    MAX(trip_dropoff_date_time) AS end_date
FROM taxi;
```

**Result:**

| start_date | end_date |
|---|---|
| 2009-06-01 11:33:00+00:00 | 2009-07-01 00:03:00+00:00 |

✅ **Answer: 2009-06-01 to 2009-07-01**

---

## Question 2: Proportion of Trips Paid with Credit Card

**Query:**
```sql
SELECT
    (COUNT(CASE WHEN payment_type = 'Credit' THEN 1 END) * 100.0 / COUNT(*)) AS credit_card_proportion
FROM taxi;
```

**Result:** `26.66`

✅ **Answer: 26.66%**

---

## Question 3: Total Amount Generated in Tips

**Query:**
```sql
SELECT
    SUM(tip_amt) AS total_tip
FROM taxi;
```

**Result:** `6,063.41`

✅ **Answer: $6,063.41**

---

## How to Run

```bash
# Install dlt
pip install "dlt[workspace]"

# Initialize the project
dlt init dlthub:taxi_pipeline duckdb

# Run the pipeline
python taxi_pipeline.py

# Explore the data
dlt pipeline taxi_pipeline show
```