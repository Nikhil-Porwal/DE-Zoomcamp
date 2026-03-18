from dataclasses import dataclass
import dataclasses
import json
import math
from datetime import datetime, timezone

@dataclass
class Ride:
    lpep_pickup_datetime: str  
    lpep_dropoff_datetime: str
    PULocationID: int
    DOLocationID: int
    passenger_count: float
    trip_distance: float
    tip_amount: float
    total_amount: float

def ride_from_row(row):
    return Ride(
        lpep_pickup_datetime= str(row['lpep_pickup_datetime']),
        lpep_dropoff_datetime= str(row['lpep_dropoff_datetime']),
        PULocationID=int(row['PULocationID']),
        DOLocationID=int(row['DOLocationID']),
        passenger_count=float(row['passenger_count']),
        trip_distance=float(row['trip_distance']),
        tip_amount=float(row['tip_amount']),
        total_amount=float(row['total_amount']),
    )

def ride_serializer(ride):
    ride_dict = dataclasses.asdict(ride)

    # Flink's JSON parser rejects NaN tokens; encode missing numerics as null.
    for key, value in ride_dict.items():
        if isinstance(value, float) and math.isnan(value):
            ride_dict[key] = None

    json_str = json.dumps(ride_dict, allow_nan=False)
    return json_str.encode('utf-8')

def ride_deserializer(data):
    json_str = data.decode('utf-8')
    ride_dict = json.loads(json_str)
    return Ride(**ride_dict)