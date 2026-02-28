"""@bruin
# ingestion.trips: fetch monthly parquet files from TLC and append to raw table
name: ingestion.trips
type: python
image: python:3.11
connection: duckdb-default
materialization:
  type: table
  strategy: append
columns:
  - name: vendor_id
    type: string
  - name: pickup_datetime
    type: timestamp
  - name: dropoff_datetime
    type: timestamp
  - name: passenger_count
    type: integer
  - name: trip_distance
    type: float
  - name: pickup_location_id
    type: integer
  - name: dropoff_location_id
    type: integer
  - name: payment_type
    type: string
  - name: fare_amount
    type: float
  - name: extra
    type: float
  - name: mta_tax
    type: float
  - name: tip_amount
    type: float
  - name: tolls_amount
    type: float
  - name: improvement_surcharge
    type: float
@bruin"""

# standard libraries for env vars and JSON handling
import os
import json
from datetime import datetime, timedelta

# third‑party libraries for HTTP and data processing
import pandas as pd


# TODO: Only implement `materialize()` if you are using Bruin Python materialization.
# If you choose the manual-write approach (no `materialization:` block), remove this function and implement ingestion
# as a standard Python script instead.
def materialize():
    # pipeline variables come in as JSON string
    vars_json = os.environ.get("BRUIN_VARS", "{}")
    pipeline_vars = json.loads(vars_json)
    taxi_types = pipeline_vars.get("taxi_types", [])

    # date window variables (provided by Bruin runtime)
    start_date = os.environ.get("BRUIN_START_DATE")
    end_date = os.environ.get("BRUIN_END_DATE")
    if not start_date or not end_date:
        raise ValueError("BRUIN_START_DATE and BRUIN_END_DATE must be set")

    # convert to datetime objects (date strings are YYYY-MM-DD)
    start = datetime.fromisoformat(start_date)
    end = datetime.fromisoformat(end_date)

    # build list of monthly URLs for each taxi type
    urls = []
    current = start
    while current < end:
        year = current.year
        month = current.month
        for taxi in taxi_types:
            urls.append(
                f"https://d37ci6vzurychx.cloudfront.net/trip-data/{taxi}_tripdata_{year}-{month:02d}.parquet"
            )
        # advance to first of next month
        if month == 12:
            current = datetime(year + 1, 1, 1)
        else:
            current = datetime(year, month + 1, 1)

    # fetch each parquet file, add lineage column, and collect DataFrames
    dfs = []
    for url in urls:
        try:
            df = pd.read_parquet(url)
            
            # standardize column names: yellow has tpep_ prefix, green has lpep_ prefix
            # rename to common names declared in the asset metadata
            rename_map = {
                'tpep_pickup_datetime': 'pickup_datetime',
                'tpep_dropoff_datetime': 'dropoff_datetime',
                'lpep_pickup_datetime': 'pickup_datetime',
                'lpep_dropoff_datetime': 'dropoff_datetime',
            }
            df = df.rename(columns={k: v for k, v in rename_map.items() if k in df.columns})
            
            # convert timezone-aware timestamp columns to naive UTC to avoid pyarrow issues
            for col in df.columns:
                if pd.api.types.is_datetime64_any_dtype(df[col]):
                    if df[col].dt.tz is not None:
                        df[col] = df[col].dt.tz_convert('UTC').dt.tz_localize(None)
            
            df["extracted_at"] = datetime.now(timezone.utc).replace(tzinfo=None)
            dfs.append(df)
        except Exception as e:
            print(f"warning: failed to fetch {url}: {e}")

    if dfs:
        return pd.concat(dfs, ignore_index=True)
    else:
        # return empty frame with no columns (Bruin handles schema from header)
        return pd.DataFrame()


