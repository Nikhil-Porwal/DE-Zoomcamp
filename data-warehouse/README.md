Module 3 Homework – Data Warehousing & BigQuery

This repository contains my solutions for Module 3 – Data Warehousing & BigQuery of the Data Engineering Zoomcamp 2026.

The goal of this homework is to practice working with:

Google Cloud Storage (GCS)

BigQuery External Tables

Materialized (regular) Tables

Partitioning & Clustering

Query optimization and cost awareness

📂 Dataset

Yellow Taxi Trip Records (January 2024 – June 2024)

Files uploaded to GCS:

gs://nik-de-zoomcamp-kestra/yellow_tripdata_2024-*.parquet

🧱 BigQuery Setup
Create External Table
CREATE OR REPLACE EXTERNAL TABLE `zoomcamp.external_yellow_tripdata`
OPTIONS(
  FORMAT = 'PARQUET',
  uris = ['gs://nik-de-zoomcamp-kestra/yellow_tripdata_2024-*.parquet']
);

Create Materialized (Regular) Table
CREATE OR REPLACE TABLE `zoomcamp.yellow_tripdata_materialized` AS
SELECT *
FROM `zoomcamp.external_yellow_tripdata`;

✅ Question 1 – Counting Records

Query

SELECT COUNT(*) 
FROM `zoomcamp.yellow_tripdata_materialized`;


Answer

✅ 20,332,093

✅ Question 2 – Data Read Estimation

Query (External Table)

SELECT COUNT(DISTINCT(PULocationID))
FROM `zoomcamp.external_yellow_tripdata`;


Query (Materialized Table)

SELECT COUNT(DISTINCT(PULocationID))
FROM `zoomcamp.yellow_tripdata_materialized`;


Answer

✅ 0 MB for the External Table and 155.12 MB for the Materialized Table

✅ Question 3 – Understanding Columnar Storage

Query 1

SELECT PULocationID
FROM `zoomcamp.yellow_tripdata_materialized`;


Query 2

SELECT PULocationID, DOLocationID
FROM `zoomcamp.yellow_tripdata_materialized`;


Answer

✅ BigQuery is a columnar database, and it only scans the specific columns requested in the query. Querying two columns requires reading more data than querying one column.

✅ Question 4 – Counting Zero Fare Trips
SELECT COUNT(*) 
FROM `zoomcamp.yellow_tripdata_materialized`
WHERE fare_amount = 0;


Answer

✅ 8333

✅ Question 5 – Partitioning and Clustering Strategy

Create Optimized Table

CREATE OR REPLACE TABLE `zoomcamp.yellow_tripdata_2024_partitioned_clustered`
PARTITION BY DATE(tpep_dropoff_datetime)
CLUSTER BY VendorID AS
SELECT *
FROM `zoomcamp.external_yellow_tripdata`;


Answer

✅ Partition by tpep_dropoff_datetime and Cluster on VendorID

✅ Question 6 – Partition Benefits

Query on Materialized Table

SELECT DISTINCT(VendorID) 
FROM `zoomcamp.yellow_tripdata_materialized`
WHERE DATE(tpep_dropoff_datetime) 
BETWEEN '2024-03-01' AND '2024-03-15';


Query on Partitioned & Clustered Table

SELECT DISTINCT(VendorID) 
FROM `zoomcamp.yellow_tripdata_2024_partitioned_clustered`
WHERE DATE(tpep_dropoff_datetime) 
BETWEEN '2024-03-01' AND '2024-03-15';


Answer

✅ 310.24 MB for non-partitioned table and 26.84 MB for the partitioned table

✅ Question 7 – External Table Storage

Answer

✅ GCP Bucket

✅ Question 8 – Clustering Best Practices

Answer

✅ False

Clustering should be applied only when it aligns with query patterns.

✅ Question 9 – Understanding Table Scans
SELECT COUNT(*) 
FROM `zoomcamp.yellow_tripdata_materialized`;


Observation

- 0B
- Reason: because BigQuery uses metadata for COUNT() query.


🔗 Repository

Homework solutions and scripts available in this repository.