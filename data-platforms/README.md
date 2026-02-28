# Module 5 Homework: Data Platforms with Bruin — Solutions

## Setup

```bash
# Install Bruin CLI
curl -LsSf https://getbruin.com/install/cli | sh

# Initialize the zoomcamp template
bruin init zoomcamp my-pipeline

# Configure .bruin.yml with a DuckDB connection, then run
bruin run
```

---

## Solutions

### Question 1. Bruin Pipeline Structure

**Answer: `.bruin.yml` and `pipeline.yml` (assets can be anywhere)**

A Bruin project requires a `.bruin.yml` file at the root (for environment/connection config) and a `pipeline.yml` file to define the pipeline. Asset files can live in any directory within the project.

---

### Question 2. Materialization Strategies

**Answer: `time_interval` — incremental based on a time column**

The `time_interval` strategy is designed for processing data over a specific time window. It deletes existing rows for the given interval and re-inserts the freshly processed data, making it ideal for NYC taxi data partitioned by `pickup_datetime`.

---

### Question 3. Pipeline Variables

**Answer: `bruin run --var 'taxi_types=["yellow"]'`**

Array variables must be passed as JSON-formatted strings. The correct syntax uses `--var` with a JSON array value:

```bash
bruin run --var 'taxi_types=["yellow"]'
```

---

### Question 4. Running with Dependencies

**Answer: `bruin run --select ingestion.trips+`**

The `+` suffix after an asset name tells Bruin to run that asset and all downstream assets that depend on it. The `--select` flag accepts dot-notation asset names.

```bash
bruin run --select ingestion.trips+
```

---

### Question 5. Quality Checks

**Answer: `name: not_null`**

To ensure a column never contains NULL values, add a `not_null` quality check to the asset definition:

```yaml
columns:
  - name: pickup_datetime
    checks:
      - name: not_null
```

---

### Question 6. Lineage and Dependencies

**Answer: `bruin lineage`**

The `bruin lineage` command visualizes the dependency graph between assets, showing how data flows through the pipeline from ingestion to reporting.

```bash
bruin lineage
```

---

### Question 7. First-Time Run

**Answer: `--full-refresh`**

When running a pipeline for the first time against a new DuckDB database, use `--full-refresh` to ensure all tables are created from scratch, bypassing any incremental logic.

```bash
bruin run --full-refresh
```

---
