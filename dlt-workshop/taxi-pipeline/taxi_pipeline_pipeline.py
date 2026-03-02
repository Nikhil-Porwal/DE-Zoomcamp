"""Template for building a `dlt` pipeline to ingest data from a REST API."""

import dlt
from dlt.sources.rest_api import rest_api_resources
from dlt.sources.rest_api.typing import RESTAPIConfig


# if no argument is provided, `access_token` is read from `.dlt/secrets.toml`
@dlt.source
def taxi_pipeline_rest_api_source():
    """Define dlt resources from REST API endpoints."""
    config: RESTAPIConfig = {
        "client": {
            # base URL provided by the user
            "base_url": "https://us-central1-dlthub-analytics.cloudfunctions.net/data_engineering_zoomcamp_api",
            # no authentication required for this public endpoint
        },
        "resource_defaults": {
            # we'll simply append data since there is no clear primary key
            "write_disposition": "append",
        },
        "resources": [
            {
                "name": "taxi",
                "endpoint": {
                    # the API root returns a list of taxi rides
                    "path": "",
                    "method": "GET",
                    "params": {
                        # request the maximum page size if supported
                    },
                    # the response is a bare array of records
                    "paginator": {
                        "type": "page_number",
                        "base_page": 1,
                        "page_param": "page",
                        # API returns just an array without any total count, so
                        # disable the default total lookup which expects a
                        # `total` field. the paginator will instead stop when
                        # an empty page is encountered.
                        "total_path": None,
                    },
                },
            },
        ],
        # no further defaults needed
    }

    yield from rest_api_resources(config)


pipeline = dlt.pipeline(
    pipeline_name='taxi_pipeline',
    destination='duckdb',
    # `refresh="drop_sources"` ensures the data and the state is cleaned
    # on each `pipeline.run()`; remove the argument once you have a
    # working pipeline.
    refresh="drop_sources",
    # show basic progress of resources extracted, normalized files and load-jobs on stdout
    progress="log",
)


if __name__ == "__main__":
    load_info = pipeline.run(taxi_pipeline_rest_api_source())
    print(load_info)  # noqa: T201
