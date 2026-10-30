# Shared functions: source this file before calling the helpers below.
# Defining a function does not run it; a call runs it with the supplied input.

# Input: the original bike data frame with numeric category codes.
# Output: a prepared data frame. The original input object stays unchanged.
prepare_bike_data <- function(data) {
  # Convert date strings such as "2011-01-01" into Date values.
  data$dteday <- as.Date(data$dteday)

  # Match each season code to its label using the dataset's codebook.
  data$season <- factor(
    data$season,
    levels = c(1, 2, 3, 4),
    labels = c("Winter", "Spring", "Summer", "Fall")
  )

  # Preserve workingday and add a separate column with readable labels.
  data$day_type <- factor(
    data$workingday,
    levels = c(0, 1),
    labels = c("Weekend or holiday", "Working day")
  )

  # Preserve weathersit and add readable weather labels.
  # A factor can include categories that have no observations in this file.
  data$weather <- factor(
    data$weathersit,
    levels = c(1, 2, 3, 4),
    labels = c(
      "Clear",
      "Mist or cloudy",
      "Light rain or snow",
      "Heavy rain or snow"
    )
  )

  # The source is already tidy: one observation (day) per row.
  # Arrange the prepared rows in date order without dropping observations.
  data <- data |>
    dplyr::arrange(dteday)

  # 'data' is local to this function. Return it so the caller can save it.
  return(data)
}

# Input: a numeric vector of rental counts, such as bike$cnt.
# Output: its mean, or a numeric NA if no observed counts are available.
average_rentals <- function(rentals) {
  # Reject text and other nonnumeric input with a clear error message.
  if (!is.numeric(rentals)) {
    stop("Rental counts must be numeric.")
  }

  # An empty group or an entirely missing group has no calculable average.
  # Return NA rather than zero: zero would mean there really were no rentals.
  if (length(rentals) == 0 || all(is.na(rentals))) {
    return(NA_real_)
  }

  # Ignore missing counts only for this calculation; do not delete data rows.
  return(mean(rentals, na.rm = TRUE))
}

# Format counts with thousands separators and a consistent decimal point.
format_console_number <- function(value, digits = 2) {
  if (length(value) != 1 || is.na(value)) {
    return("N/A")
  }

  return(formatC(
    value,
    format = "f",
    digits = digits,
    big.mark = ",",
    decimal.mark = "."
  ))
}

# Print a colored section title and a matching divider.
console_heading <- function(title) {
  divider <- paste(rep("=", 68), collapse = "")

  cat("\n", crayon::bold(crayon::cyan(title)), "\n", sep = "")
  cat(crayon::blue(divider), "\n", sep = "")
}

# Print a left-aligned label and a colored text value on one line.
console_info <- function(label, value) {
  cat(
    sprintf("  %-32s", paste0(label, ":")),
    crayon::cyan(as.character(value)),
    "\n",
    sep = ""
  )
}

# Print a clearly formatted status for a TRUE/FALSE/NA quality check.
console_check <- function(label, passed) {
  if (isTRUE(passed)) {
    status <- crayon::green("PASS")
    explanation <- "Check passed"
  } else if (length(passed) == 1 && is.na(passed)) {
    status <- crayon::yellow("CHECK")
    explanation <- "Missing data prevents a complete check"
  } else {
    status <- crayon::red("FAIL")
    explanation <- "Check did not pass"
  }

  cat(
    "  ", sprintf("%-38s", paste0(label, ":")),
    status, "  ", explanation, "\n",
    sep = ""
  )
}

# Print one clean table row for each group, without console vector indexes.
console_group_table <- function(title, group_header, group_names, days, averages) {
  console_heading(title)

  cat(sprintf("  %-27s %10s %18s\n", group_header, "Days", "Average / day"))
  cat(crayon::blue(paste(rep("-", 59), collapse = "")), "\n", sep = "")

  for (i in seq_along(group_names)) {
    average_text <- if (is.na(averages[i])) {
      crayon::yellow(sprintf("%18s", "No data"))
    } else {
      crayon::green(sprintf("%18s", format_console_number(averages[i])))
    }

    cat(
      sprintf("  %-27s %10s ", group_names[i], formatC(days[i], format = "d", big.mark = ",")),
      average_text,
      "\n",
      sep = ""
    )
  }
}

# Input: a wide table with one row per season and one mean per day type.
# Pad plain text before applying colors, so ANSI codes do not affect alignment.
console_season_comparison <- function(data) {
  console_heading("Average rentals by season and day type")

  cat(sprintf("  %-12s %20s %18s\n", "Season", "Weekend or holiday", "Working day"))
  cat(crayon::blue(paste(rep("-", 54), collapse = "")), "\n", sep = "")

  for (i in seq_len(nrow(data))) {
    day_off_average <- data[["Weekend or holiday"]][i]
    working_average <- data[["Working day"]][i]

    day_off_text <- if (is.na(day_off_average)) {
      crayon::yellow(sprintf("%20s", "No data"))
    } else {
      crayon::green(sprintf("%20s", format_console_number(day_off_average)))
    }

    working_text <- if (is.na(working_average)) {
      crayon::yellow(sprintf("%18s", "No data"))
    } else {
      crayon::green(sprintf("%18s", format_console_number(working_average)))
    }

    cat(
      sprintf("  %-12s ", data$season[i]),
      day_off_text, " ", working_text, "\n",
      sep = ""
    )
  }
}

# Input: the ranked days table; extra columns remain available for CSV export.
# Show only three columns in the console to keep the table easy to read.
console_top_days <- function(data) {
  console_heading("Top 5 days by total rentals")

  cat(sprintf("  %-12s %-24s %15s\n", "Date", "Day type", "Total rentals"))
  cat(crayon::blue(paste(rep("-", 55), collapse = "")), "\n", sep = "")

  for (i in seq_len(nrow(data))) {
    # Counts are whole numbers; only the displayed value gains separators.
    total_text <- format_console_number(data$cnt[i], digits = 0)

    cat(
      sprintf("  %-12s %-24s ", as.character(data$dteday[i]), data$day_type[i]),
      crayon::green(sprintf("%15s", total_text)),
      "\n",
      sep = ""
    )
  }
}
