# 📊 Module 3 Homework – Data Warehousing & BigQuery

> **Data Engineering Zoomcamp 2026** | Module 3 Solutions

This repository contains comprehensive solutions for Module 3 of the Data Engineering Zoomcamp 2026, focusing on advanced BigQuery concepts and data warehousing best practices.

---

## 📂 Dataset Information

**Source:** Yellow Taxi Trip Records  
**Period:** January 2024 – June 2024  
**Format:** Parquet

### GCS Location
```
gs://nik-de-zoomcamp-kestra/yellow_tripdata_2024-*.parquet
```

**Total Records:** 20,332,093

---

## 🏗️ BigQuery Setup

### Create External Table

```sql
CREATE OR REPLACE EXTERNAL TABLE `zoomcamp.external_yellow_tripdata`
OPTIONS(
  FORMAT = 'PARQUET',
  uris = ['gs://nik-de-zoomcamp-kestra/yellow_tripdata_2024-*.parquet']
);
```

### Create Materialized Table

```sql
CREATE OR REPLACE TABLE `zoomcamp.yellow_tripdata_materialized` AS
SELECT *
FROM `zoomcamp.external_yellow_tripdata`;
```

---

## 📝 Questions & Solutions

### **Question 1** – Counting Records

**Task:** Count total records in the materialized table

```sql
SELECT COUNT(*) 
FROM `zoomcamp.yellow_tripdata_materialized`;
```

**Answer:** `20,332,093` ✅

---

### **Question 2** – Data Read Estimation

**Task:** Compare data processing between External and Materialized tables

**External Table Query:**
```sql
SELECT COUNT(DISTINCT(PULocationID))
FROM `zoomcamp.external_yellow_tripdata`;
```

**Materialized Table Query:**
```sql
SELECT COUNT(DISTINCT(PULocationID))
FROM `zoomcamp.yellow_tripdata_materialized`;
```

**Answer:**
- External Table: `0 MB` (estimation not available)
- Materialized Table: `155.12 MB`

✅ **Correct**

---

### **Question 3** – Understanding Columnar Storage

**Task:** Explain data scanning behavior

**Query 1 (Single Column):**
```sql
SELECT PULocationID
FROM `zoomcamp.yellow_tripdata_materialized`;
```

**Query 2 (Two Columns):**
```sql
SELECT PULocationID, DOLocationID
FROM `zoomcamp.yellow_tripdata_materialized`;
```

**Answer:** ✅

BigQuery uses **columnar storage**, which means it only scans the specific columns requested in the query. Querying two columns requires reading more data than querying a single column, resulting in higher data processing costs.

---

### **Question 4** – Counting Zero Fare Trips

**Task:** Find trips with zero fare amount

```sql
SELECT COUNT(*) 
FROM `zoomcamp.yellow_tripdata_materialized`
WHERE fare_amount = 0;
```

**Answer:** `8,333` ✅

---

### **Question 5** – Partitioning and Clustering Strategy

**Task:** Create an optimized table structure

```sql
CREATE OR REPLACE TABLE `zoomcamp.yellow_tripdata_2024_partitioned_clustered`
PARTITION BY DATE(tpep_dropoff_datetime)
CLUSTER BY VendorID AS
SELECT *
FROM `zoomcamp.external_yellow_tripdata`;
```

**Answer:** ✅
- **Partition by:** `tpep_dropoff_datetime` (date-based)
- **Cluster on:** `VendorID` (frequently filtered field)

---

### **Question 6** – Partition Benefits

**Task:** Compare query performance with and without partitioning

**Non-Partitioned Query:**
```sql
SELECT DISTINCT(VendorID) 
FROM `zoomcamp.yellow_tripdata_materialized`
WHERE DATE(tpep_dropoff_datetime) BETWEEN '2024-03-01' AND '2024-03-15';
```

**Partitioned & Clustered Query:**
```sql
SELECT DISTINCT(VendorID) 
FROM `zoomcamp.yellow_tripdata_2024_partitioned_clustered`
WHERE DATE(tpep_dropoff_datetime) BETWEEN '2024-03-01' AND '2024-03-15';
```

**Answer:** ✅
- Non-Partitioned: `310.24 MB`
- Partitioned: `26.84 MB`

---

### **Question 7** – External Table Storage

**Task:** Where is external table data physically stored?

**Answer:** ✅ **GCP Bucket**

External tables reference data in Google Cloud Storage without copying it into BigQuery's internal storage.

---

### **Question 8** – Clustering Best Practices

**Task:** Should you always cluster tables?

**Answer:** ✅ **False**

Clustering should only be applied when it aligns with query patterns. Over-clustering can add unnecessary overhead without performance benefits.

---

### **Question 9** – Understanding Table Scans

**Task:** Analyze metadata optimization

```sql
SELECT COUNT(*) 
FROM `zoomcamp.yellow_tripdata_materialized`;
```

**Observation:**
- **Data Processed:** `0 B`
- **Reason:** BigQuery uses **metadata** for `COUNT(*)` queries without scanning actual data

This demonstrates BigQuery's intelligent query optimization! 🎯

<<<<<<< HEAD
- 0B
- Reason: because BigQuery uses metadata for COUNT() query.


🔗 Repository

Homework solutions and scripts available in this repository.
=======
