from pyflink.datastream import StreamExecutionEnvironment
from pyflink.table import EnvironmentSettings, StreamTableEnvironment


# Create this table in Postgres before running the job:
# CREATE TABLE IF NOT EXISTS green_trip_window_counts (
#     window_start TIMESTAMP,
#     PULocationID INTEGER,
#     num_trips BIGINT,
#     PRIMARY KEY (window_start, PULocationID)
# );


def create_source_kafka(t_env):
	table_name = "green_trips"
	source_ddl = f"""
		CREATE TABLE IF NOT EXISTS {table_name} (
			lpep_pickup_datetime VARCHAR,
			lpep_dropoff_datetime VARCHAR,
			PULocationID INTEGER,
			DOLocationID INTEGER,
			passenger_count DOUBLE,
			trip_distance DOUBLE,
			tip_amount DOUBLE,
			total_amount DOUBLE,
			event_timestamp AS TO_TIMESTAMP(lpep_pickup_datetime, 'yyyy-MM-dd HH:mm:ss'),
			WATERMARK FOR event_timestamp AS event_timestamp - INTERVAL '5' SECOND
		) WITH (
			'connector' = 'kafka',
			'topic' = 'green-trips',
			'properties.bootstrap.servers' = 'redpanda:29092',
			'properties.group.id' = 'flink-green-trips-tumbling-window',
			'scan.startup.mode' = 'earliest-offset',
			'format' = 'json',
			'json.ignore-parse-errors' = 'true'
		)
	"""
	t_env.execute_sql(source_ddl)
	return table_name


def create_sink_postgres(t_env):
	table_name = "green_trip_window_counts"
	sink_ddl = f"""
		CREATE TABLE IF NOT EXISTS {table_name} (
			window_start TIMESTAMP(3),
			PULocationID INTEGER,
				num_trips BIGINT,
			PRIMARY KEY (window_start, PULocationID) NOT ENFORCED
		) WITH (
			'connector' = 'jdbc',
			'url' = 'jdbc:postgresql://postgres:5432/postgres',
			'table-name' = '{table_name}',
			'username' = 'postgres',
			'password' = 'postgres',
			'driver' = 'org.postgresql.Driver'
		)
	"""
	t_env.execute_sql(sink_ddl)
	return table_name


def run():
	env = StreamExecutionEnvironment.get_execution_environment()
	env.set_parallelism(1)
	env.enable_checkpointing(10 * 1000)

	settings = EnvironmentSettings.new_instance().in_streaming_mode().build()
	t_env = StreamTableEnvironment.create(env, environment_settings=settings)

	source_table = create_source_kafka(t_env)
	sink_table = create_sink_postgres(t_env)

	t_env.execute_sql(
		f"""
		INSERT INTO {sink_table}
		SELECT
			window_start,
			PULocationID,
			COUNT(*) AS num_trips
		FROM TABLE(
			TUMBLE(TABLE {source_table}, DESCRIPTOR(event_timestamp), INTERVAL '5' MINUTES)
		)
		GROUP BY window_start, PULocationID
		"""
	).wait()


if __name__ == "__main__":
	run()
