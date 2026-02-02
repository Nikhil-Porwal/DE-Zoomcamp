# Module 2 Homework - Workflow Orchestration

## Data Engineering Zoomcamp 2026 - Cohort 2026

This document contains solutions for the Module 2 homework on Workflow Orchestration using Kestra.

---

## Questions and Solutions

### Question 1: File Size

**Question:** Within the execution for Yellow Taxi data for the year 2020 and month 12: what is the uncompressed file size (i.e. the output file `yellow_tripdata_2020-12.csv` of the extract task)?

**Solution:**

To find the uncompressed file size, I used the following command in the Kestra flow:

```bash
du -b {{render(vars.file)}} | awk '{printf "%.1f MiB\n", $1/1048576}'
```

**Answer:** The file size can be found in the execution logs.

**Screenshot:** [img1.png](https://github.com/Nikhil-Porwal/DE-Zoomcamp/blob/main/img1.png)


---

### Question 2: Variable Rendering

**Question:** What is the rendered value of the variable `file` when the inputs `taxi` is set to `green`, `year` is set to `2020`, and `month` is set to `04` during execution?

**Template:**
```yaml
{{inputs.taxi}}_tripdata_{{inputs.year}}-{{inputs.month}}.csv
```

**Solution:**

With the given inputs:
- `taxi = green`
- `year = 2020`
- `month = 04`

The rendered value becomes:
```
green_tripdata_2020-04.csv
```

**Screenshot:** [img2.png](https://github.com/Nikhil-Porwal/DE-Zoomcamp/blob/main/img2.png)


---

### Question 3: Yellow Taxi 2020 Row Count

**Question:** How many rows are in the Yellow Taxi data for the year 2020?

**SQL Query:**
```sql
SELECT COUNT(1) 
FROM public.yellow_tripdata 
WHERE filename LIKE '%2020%';
```

**Answer:** 24,648,499

**Supporting Evidence:**
- Flow configuration: [yellow_taxi_2020_full_load.yaml](https://github.com/Nikhil-Porwal/DE-Zoomcamp/blob/main/flows/yellow_taxi_2020_full_load.yaml)

---

### Question 4: Green Taxi 2020 Row Count

**Question:** How many rows are in the Green Taxi data for the year 2020?

**SQL Query:**
```sql
SELECT COUNT(1) 
FROM public.green_tripdata 
WHERE filename LIKE '%2020%';
```

**Answer:** 1,734,051

**Supporting Evidence:**
- Flow configuration: [green_taxi_2020_full_load.yaml](https://github.com/Nikhil-Porwal/DE-Zoomcamp/blob/main/flows/green_taxi_2020_full_load.yaml)


### Question 5: Yellow Taxi March 2021 Row Count

**Question:** How many rows are in the Yellow Taxi data for March 2021?

**SQL Query:**
```sql
SELECT COUNT(1) 
FROM public.yellow_tripdata 
WHERE filename LIKE '%2021-03%';
```

**Answer:** 1,925,152


### Question 6: Scheduled Flow - Cron Expression

**Question:** What cron expression should be used for scheduling the flow?

**Reference:** [Kestra Schedule Trigger Documentation](https://kestra.io/docs/workflow-components/triggers/schedule-trigger#cron-extension)

**Solution:**
Add a timezone property set to America/New_York in the Schedule trigger configuration
