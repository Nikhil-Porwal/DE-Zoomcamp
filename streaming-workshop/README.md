# Homework Solutions: Kafka (Redpanda) + PyFlink

This README contains the full working solution and final answers for the streaming homework using:

- Redpanda (Kafka-compatible)
- PyFlink
- PostgreSQL
- Green Taxi October 2025 dataset

Dataset:
https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2025-10.parquet


## Environment

From this folder:

```bash
docker compose build
docker compose up -d
```

If you need a clean reset:

```bash
docker compose down -v
docker compose build
docker compose up -d
```


## Q1. Redpanda Version

Command:

```bash
docker exec -it streaming-workshop-redpanda-1 rpk version
```

Answer:

- Redpanda version: v25.3.9


## Q2. Sending Data to Redpanda

Topic:

```bash
docker exec -it streaming-workshop-redpanda-1 rpk topic create green-trips --brokers localhost:9092
```

Producer implementation:

- Notebook: notebooks/hw_producer.ipynb
- Model/serializer: notebooks/hw_models.py

Columns sent:

- lpep_pickup_datetime
- lpep_dropoff_datetime
- PULocationID
- DOLocationID
- passenger_count
- trip_distance
- tip_amount
- total_amount

Datetime handling:

- Datetimes are converted to strings before JSON serialization.

Measured send+flush runtime:

- ~5.84 seconds

Closest option:

- 10 seconds


## Q3. Consumer: trip_distance > 5

Consumer implementation:

- Notebook: notebooks/hw_consumer_db.ipynb

Count query logic:

- Count rows where trip_distance > 5

Answer:

- 8506


## Part 2: PyFlink

Important notes used in all jobs:

- Topic: green-trips
- Event time from lpep_pickup_datetime string
- Watermark: event_timestamp - 5 seconds
- Parallelism: 1
- Job files under src/job and submitted from jobmanager container

## Q4. Tumbling Window (5 min) per PULocationID

Job file:

- src/job/hw_tumbling_window.py

Result sink table:

```sql
CREATE TABLE IF NOT EXISTS green_trip_window_counts (
	window_start TIMESTAMP,
	PULocationID INTEGER,
	num_trips BIGINT,
	PRIMARY KEY (window_start, PULocationID)
);
```

Query:

```sql
SELECT PULocationID, num_trips
FROM green_trip_window_counts
ORDER BY num_trips DESC
LIMIT 3;
```

Answer:

- PULocationID 74


## Q5. Session Window (5 min gap) on PULocationID

Job file:

- src/job/hw_session_window.py

Session logic:

- SESSION window
- PARTITION BY PULocationID
- 5 minute gap
- 5 second watermark tolerance

Result sink table:

```sql
CREATE TABLE IF NOT EXISTS green_trip_session_counts (
	session_start TIMESTAMP,
	session_end TIMESTAMP,
	PULocationID INTEGER,
	num_trips BIGINT,
	PRIMARY KEY (session_start, session_end, PULocationID)
);
```

Query:

```sql
SELECT PULocationID, num_trips
FROM green_trip_session_counts
ORDER BY num_trips DESC
LIMIT 3;
```

Answer:

- 81 trips (longest session)


## Q6. Tumbling Window (1 hour) total tips

Job file:

- src/job/hw_tumbling_window_1hr.py

Result sink table:

```sql
CREATE TABLE IF NOT EXISTS green_trip_tip_hourly (
	window_start TIMESTAMP,
	total_tip_amount DOUBLE PRECISION,
	PRIMARY KEY (window_start)
);
```

Query:

```sql
SELECT window_start, total_tip_amount
FROM green_trip_tip_hourly
ORDER BY total_tip_amount DESC
LIMIT 1;
```

Answer:

- 2025-10-16 18:00:00


## Files Created/Updated for Solutions

- notebooks/hw_models.py
- src/job/hw_consumer.py
- src/job/hw_tumbling_window.py
- src/job/hw_session_window.py
- src/job/hw_tumbling_window_1hr.py


## Useful Operations

Delete and recreate topic to avoid duplicates:

```bash
docker exec -it streaming-workshop-redpanda-1 rpk topic delete green-trips --brokers localhost:9092
docker exec -it streaming-workshop-redpanda-1 rpk topic create green-trips --brokers localhost:9092
```