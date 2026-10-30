# Purpose: inspect the original data before preparing it for analysis.
# Run this script from the project root, with the .Rproj file open.
# Use cat()-based helpers so results remain readable when run with source().

# 1. Load the original CSV without changing its values.
bike <- read.csv("data/raw/day.csv")

# 2. Load the shared formatting functions for aligned, colored output.
source("R/functions.R")

# 3. Show a compact overview instead of unformatted vectors and summaries.
console_heading("BikePatternsR: Raw data inspection")
console_info("Dataset", "UCI daily bike-sharing records")
console_info("Number of days", format_console_number(nrow(bike), digits = 0))
console_info("Number of columns", format_console_number(ncol(bike), digits = 0))

# 4. Show a small, narrow preview so rows do not wrap across the console.
# select() chooses columns; slice_head() chooses the first five rows.
preview <- bike |>
  dplyr::select(dteday, season, weathersit, cnt) |>
  dplyr::slice_head(n = 5)

console_heading("Sample of the raw data: first five days")
cat(sprintf("  %-12s %12s %13s %15s\n", "Date", "Season code", "Weather code", "Total rentals"))
cat(crayon::blue(paste(rep("-", 56), collapse = "")), "\n", sep = "")

for (row_index in seq_len(nrow(preview))) {
  cat(sprintf(
    "  %-12s %12s %13s %15s\n",
    preview$dteday[row_index],
    formatC(preview$season[row_index], format = "d"),
    formatC(preview$weathersit[row_index], format = "d"),
    formatC(preview$cnt[row_index], format = "d", big.mark = ",")
  ))
}

# 5. List each column, its R type, and its number of missing values.
console_heading("Column overview")
cat(sprintf("  %-20s %-12s %12s\n", "Column", "R type", "Missing"))
cat(crayon::blue(paste(rep("-", 46), collapse = "")), "\n", sep = "")

for (column_name in colnames(bike)) {
  column_type <- paste(class(bike[[column_name]]), collapse = "/")
  missing_count <- sum(is.na(bike[[column_name]]))

  cat(sprintf(
    "  %-20s %-12s %12s\n",
    column_name,
    column_type,
    formatC(missing_count, format = "d", big.mark = ",")
  ))
}

# 6. Report basic quality checks as readable PASS/CHECK/FAIL lines.
# The data already has one observation (a day) per row.
# distinct() builds diagnostic tables; it does not remove rows from bike.
unique_dates <- bike |>
  dplyr::distinct(dteday)
unique_ids <- bike |>
  dplyr::distinct(instant)

console_heading("Data quality checks")
console_info("Unique dates", format_console_number(nrow(unique_dates), digits = 0))
console_info("Unique record IDs", format_console_number(nrow(unique_ids), digits = 0))
console_check("No missing values", !anyNA(bike))
console_check("No duplicate dates", nrow(unique_dates) == nrow(bike))
console_check("No duplicate record IDs", nrow(unique_ids) == nrow(bike))
console_check(
  "Rental counts add up to the total",
  all(bike$casual + bike$registered == bike$cnt)
)
