# BikePatternsR

A beginner R project about daily bicycle rentals.

## Question

How are bicycle rentals related to weather, season, and working-day status?

## Data

The project uses `day.csv` from the [UCI Bike Sharing Dataset](https://archive.ics.uci.edu/dataset/275/bike+sharing+dataset).

## Requirements

The project uses R and the following packages:

- dplyr — filtering, grouping, and summarising data.
- tidyr — organising comparison tables.
- crayon — coloured console output.

The current scripts have been checked using R 4.6.1.

Install the required packages once:

```r
install.packages(c("dplyr", "tidyr", "crayon"))
```

## Running the project

1. Open `Code-BikePatternsR.Rproj` in RStudio.
2. Run the following commands in the Console:

```r
source("R/01_load_and_inspect.R")
source("R/02_clean_data.R")
source("R/03_basic_analysis.R")
```

Each script can also run independently. All file paths are relative to the project folder.

The shared functions are loaded automatically by the scripts.

## Main scripts

| File | Purpose |
|---|---|
| `R/01_load_and_inspect.R` | Inspect the original dataset and report data quality checks. |
| `R/02_clean_data.R` | Prepare dates and category labels, then save the prepared dataset. |
| `R/03_basic_analysis.R` | Calculate comparisons, display results, and export summary tables. |
| `R/functions.R` | Provide shared functions for preparation, calculations, and console formatting. |

## Generated outputs

The preparation script saves:

```text
data/processed/bike_clean.csv
```

The prepared dataset contains 731 daily records and 18 columns.

The analysis script saves seven CSV files in `output/tables/`:

| File | Contents |
|---|---|
| `day_type_summary.csv` | Working days compared with weekends and holidays. |
| `weather_group_summary.csv` | Clear weather compared with other conditions. |
| `season_summary.csv` | Average daily rentals by season. |
| `weather_summary.csv` | Average daily rentals by weather category. |
| `user_type_summary.csv` | Average daily rentals by user category. |
| `season_day_type_comparison.csv` | Day types compared within each season. |
| `top5_days.csv` | The five days with the highest rental counts. |

Generated CSV files are updated when the corresponding script is run again.

Averages are displayed with two decimal places in the console. The CSV exports retain additional numerical precision.

## Data checks and interpretation

The inspection script checks:

- Missing values.
- Duplicate dates.
- Duplicate record identifiers.
- Whether casual and registered rentals add up to total rentals.

Weather categories without observations are retained with zero days and an unavailable average. The console displays this as `No data`, while the CSV contains `NA`.

Rental counts represent rentals, not the number of unique people.

## Current development

The current version provides console output and CSV tables.

Planned work includes four comparison charts covering season, weather, day type, and season combined with day type. Further development includes testing based on CS50R and exploring an interactive Shiny application.