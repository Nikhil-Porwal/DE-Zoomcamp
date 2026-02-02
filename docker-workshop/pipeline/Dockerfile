FROM python:3.13.11-slim
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/

WORKDIR /code
ENV PATH="/code/.venv/bin:$PATH"

COPY pyproject.toml .python-version uv.lock ./
RUN uv sync --locked

COPY ingest_data.py .
#uncomment to use parquet ingestion script
#COPY ingest_data_parquet.py .
#COPY ingest-data/ ./ingest-data/
ENTRYPOINT ["python", "ingest_data.py" ]