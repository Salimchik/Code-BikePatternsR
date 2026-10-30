# Purpose: compare daily rentals and export the results as numeric CSV tables.
# Run this script from the project root, with the .Rproj file open.
# This script loads and prepares its own data, so it can run independently.

# 1. Load shared functions and prepare the original data.
source("R/functions.R")

bike_raw <- read.csv("data/raw/day.csv")
bike <- prepare_bike_data(bike_raw)

# 2. Compare working days with weekends and holidays.
# |> passes the table to the next function; filter() selects matching rows.
working_days <- bike |>
  dplyr::filter(workingday == 1)
days_off <- bike |>
  dplyr::filter(workingday == 0)

average_working <- average_rentals(working_days$cnt)
average_day_off <- average_rentals(days_off$cnt)

day_type_summary <- data.frame(
  day_type = c("Working day", "Weekend or holiday"),
  days = c(nrow(working_days), nrow(days_off)),
  average = c(average_working, average_day_off)
)

console_group_table(
  title = "BikePatternsR: Rentals by day type",
  group_header = "Day type",
  group_names = day_type_summary$day_type,
  days = day_type_summary$days,
  averages = day_type_summary$average
)

# 3. Compare clear weather (code 1) with all other weather categories together.
clear_days <- bike |>
  dplyr::filter(weathersit == 1)
other_weather <- bike |>
  dplyr::filter(weathersit != 1)

average_clear <- average_rentals(clear_days$cnt)
average_other <- average_rentals(other_weather$cnt)

weather_group_summary <- data.frame(
  weather_group = c("Clear", "Other conditions"),
  days = c(nrow(clear_days), nrow(other_weather)),
  average = c(average_clear, average_other)
)

console_group_table(
  title = "BikePatternsR: Clear versus other weather",
  group_header = "Weather group",
  group_names = weather_group_summary$weather_group,
  days = weather_group_summary$days,
  averages = weather_group_summary$average
)

# 4. Replace the season calculation loop with a grouped summary.
# n() counts the days in each group; average_rentals() computes its mean.
# .groups = "keep" makes grouping explicit; ungroup() then removes it.
season_summary <- bike |>
  dplyr::group_by(season, .drop = FALSE) |>
  dplyr::summarize(
    days = dplyr::n(),
    average = average_rentals(cnt),
    .groups = "keep"
  ) |>
  dplyr::ungroup() |>
  dplyr::arrange(season)

console_group_table(
  title = "BikePatternsR: Rentals by season",
  group_header = "Season",
  group_names = as.character(season_summary$season),
  days = season_summary$days,
  averages = season_summary$average
)

# 5. Inspect every weather category separately, including its number of days.
# .drop = FALSE keeps unused factor levels, including heavy rain or snow.
# Its empty group has days = 0 and average = NA, displayed as "No data".
weather_summary <- bike |>
  dplyr::group_by(weather, .drop = FALSE) |>
  dplyr::summarize(
    days = dplyr::n(),
    average = average_rentals(cnt),
    .groups = "keep"
  ) |>
  dplyr::ungroup() |>
  dplyr::arrange(weather)

console_group_table(
  title = "BikePatternsR: Rentals by weather category",
  group_header = "Weather",
  group_names = as.character(weather_summary$weather),
  days = weather_summary$days,
  averages = weather_summary$average
)

# 6. Apply the same function to the three numeric rental-count columns.
# Exclude dates and factors: apply() converts this table to a matrix.
rental_columns <- bike |>
  dplyr::select(casual, registered, cnt)

# MARGIN = 2 applies the function to columns (MARGIN = 1 would use rows).
# FUN receives the function itself, so there are no parentheses after its name.
average_by_user_type <- apply(
  rental_columns,
  MARGIN = 2,
  FUN = average_rentals
)

# These are average daily rental counts, not counts of unique people.
user_type_summary <- data.frame(
  user_type = c("Casual users", "Registered users", "Total rentals"),
  days = rep(nrow(bike), 3),
  average = as.numeric(average_by_user_type)
)

console_group_table(
  title = "BikePatternsR: Rentals by user type",
  group_header = "User type",
  group_names = user_type_summary$user_type,
  days = user_type_summary$days,
  averages = user_type_summary$average
)

# 7. Compare working days with weekends/holidays within each season.
# Each observation in this summary is one season/day-type combination.
season_day_type_summary <- bike |>
  dplyr::group_by(season, day_type, .drop = FALSE) |>
  dplyr::summarize(
    days = dplyr::n(),
    average = average_rentals(cnt),
    .groups = "keep"
  ) |>
  dplyr::ungroup()

# pivot_wider() turns day-type values into side-by-side columns.
# Only season identifies a row; days must not become another identifier.
season_day_type_comparison <- season_day_type_summary |>
  dplyr::select(season, day_type, average) |>
  tidyr::pivot_wider(
    id_cols = season,
    names_from = day_type,
    values_from = average
  ) |>
  dplyr::select(season, `Weekend or holiday`, `Working day`) |>
  dplyr::arrange(season)

console_season_comparison(season_day_type_comparison)

# 8. Find the five busiest days. Earlier dates come first when totals tie.
# The console shows three columns; the CSV also includes the other details.
top5_days <- bike |>
  dplyr::arrange(dplyr::desc(cnt), dteday) |>
  dplyr::slice_head(n = 5) |>
  dplyr::select(dteday, season, weather, day_type, casual, registered, cnt)

console_top_days(top5_days)

# 9. Export all seven result tables with their original numeric precision.
# The display helpers add colors and rounding only when printing to the console.
summary_tables <- list(
  day_type_summary = day_type_summary,
  weather_group_summary = weather_group_summary,
  season_summary = season_summary,
  weather_summary = weather_summary,
  user_type_summary = user_type_summary,
  season_day_type_comparison = season_day_type_comparison,
  top5_days = top5_days
)

dir.create("output/tables", recursive = TRUE, showWarnings = FALSE)

for (table_name in names(summary_tables)) {
  output_path <- file.path("output/tables", paste0(table_name, ".csv"))
  write.csv(
    summary_tables[[table_name]],
    output_path,
    row.names = FALSE,
    na = "NA"
  )
}

console_info("Saved result tables", length(summary_tables))
console_info("Output folder", "output/tables/")
