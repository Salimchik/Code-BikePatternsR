# Purpose: prepare dates and category labels using the shared function.
# Run this script from the project root, with the .Rproj file open.

# 1. Load function definitions. This does not run the analysis.
source("R/functions.R")

# 2. Keep the original data and store the prepared result separately.
# The preparation rules live in functions.R so both scripts use the same rules.
bike_raw <- read.csv("data/raw/day.csv")
bike <- prepare_bike_data(bike_raw)

# 3. Display a compact summary of the prepared data.
console_heading("BikePatternsR: Prepared data")
console_info("Prepared rows", format_console_number(nrow(bike), digits = 0))
console_info(
  "Date range",
  paste(format(min(bike$dteday)), "to", format(max(bike$dteday)))
)
console_info("Season labels", paste(levels(bike$season), collapse = ", "))
console_info("Day type labels", paste(levels(bike$day_type), collapse = ", "))
console_info("Weather labels", paste(levels(bike$weather), collapse = ", "))
console_check("No missing values after preparation", !anyNA(bike))

# 4. Save the prepared daily table for later use in reports or other tools.
# Re-running this script updates this generated file, not the original CSV.
# row.names = FALSE avoids exporting an extra row-number column.
dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)
write.csv(
  bike,
  "data/processed/bike_clean.csv",
  row.names = FALSE,
  na = "NA"
)
console_info("Saved CSV", "data/processed/bike_clean.csv")
