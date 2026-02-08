#CREATING AN EXTERNAL TABLE FROM THE UPLOADED DATA IN THE BUCKET
CREATE OR REPLACE EXTERNAL TABLE `zoomcamp.external_yellow_tripdata`
OPTIONS(
  FORMAT= 'PARQUET',
  uris= ['gs://nik-de-zoomcamp-kestra/yellow_tripdata_2024-*.parquet']
);


#CREATING A MATERUALIZED TABLE FROM THE EXTERNAL TABLE
CREATE OR REPLACE TABLE `zoomcamp.yellow_tripdata_materialized` AS
SELECT *
FROM `zoomcamp.external_yellow_tripdata`;

#sloution1
SELECT COUNT(*) FROM `zoomcamp.yellow_tripdata_materialized`;

#solution2
SELECT COUNT(DISTINCT(PULocationID))
FROM `zoomcamp.external_yellow_tripdata`;

SELECT COUNT(DISTINCT(PULocationID))
FROM `zoomcamp.yellow_tripdata_materialized`;

#solution3
SELECT PULocationID
FROM `zoomcamp.yellow_tripdata_materialized`;

SELECT PULocationID, DOLocationID
FROM `zoomcamp.yellow_tripdata_materialized`;

#solution4
SELECT COUNT(*) FROM `zoomcamp.yellow_tripdata_materialized`
WHERE fare_amount = 0;

#solution5
CREATE OR REPLACE TABLE `zoomcamp.yellow_tripdata_2024_partitioned_clustered`
PARTITION BY DATE(tpep_dropoff_datetime)
CLUSTER BY VendorID AS
SELECT * FROM `zoomcamp.external_yellow_tripdata`;

#solution6
SELECT DISTINCT(VendorID) 
FROM `zoomcamp.yellow_tripdata_materialized`
WHERE DATE(tpep_dropoff_datetime) BETWEEN '2024-03-01' AND '2024-03-15';

SELECT DISTINCT(VendorID) 
FROM `zoomcamp.yellow_tripdata_2024_partitioned_clustered`
WHERE DATE(tpep_dropoff_datetime) BETWEEN '2024-03-01' AND '2024-03-15';

#solution9
SELECT COUNT(*) FROM `zoomcamp.yellow_tripdata_materialized`;