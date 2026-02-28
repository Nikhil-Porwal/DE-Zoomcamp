# Module 5 Homework: Data Platforms with Bruin — Solutions (Corrected)

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

**Answer: `.bruin.yml` and `pipeline/` with `pipeline.yml` and `assets/`**

A valid Bruin project requires:

- `.bruin.yml` at the project root (environment and connection configuration)
- A `pipeline/` directory
  - `pipeline.yml` (pipeline definition)
  - `assets/` directory containing SQL, Python, or YAML assets

Typical structure:

```
my-project/
├── .bruin.yml
└── pipeline/
    ├── pipeline.yml
    └── assets/
```

---

### Question 2. Materialization Strategies

**Answer: `time_interval` — incremental based on a time column**

The `time_interval` strategy processes data over a defined time window.  
It replaces data for the specified interval, making it ideal for taxi data partitioned by `pickup_datetime`.

---

### Question 3. Pipeline Variables

**Answer: `bruin run --var 'taxi_types=["yellow"]'`**

Array variables must be passed as JSON-formatted strings:

```bash
bruin run --var 'taxi_types=["yellow"]'
```

---

### Question 4. Running with Dependencies

**Answer: `bruin run --select ingestion.trips+`**

The `+` suffix runs the selected asset and all downstream dependencies:

```bash
bruin run --select ingestion.trips+
```

---

### Question 5. Quality Checks

**Answer: `name: not_null`**

To prevent NULL values:

```yaml
columns:
  - name: pickup_datetime
    checks:
      - name: not_null
```

---

### Question 6. Lineage and Dependencies

**Answer: `bruin lineage`**

Visualize the dependency graph:

```bash
bruin lineage
```

---

### Question 7. First-Time Run

**Answer: `--full-refresh`**

When running a pipeline for the first time with incremental materialization:

```bash
bruin run --full-refresh
```

---

