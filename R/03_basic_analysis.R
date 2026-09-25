bike <- read.csv("data/raw/day.csv")

working_days <- bike[bike$workingday == 1, ]
days_off <- bike[bike$workingday == 0, ]

average_working <- mean(working_days$cnt)
average_day_off <- mean(days_off$cnt)

print(paste(
  "Average rentals on working days:",
  average_working
))

print(paste(
  "Average rentals on weekends and holidays:",
  average_day_off
))

clear_days <- bike[bike$weathersit == 1, ]
other_weather <- bike[bike$weathersit != 1, ]

average_clear <- mean(clear_days$cnt)
average_other <- mean(other_weather$cnt)

print(paste(
  "Average rentals during clear weather:",
  average_clear
))

print(paste(
  "Average rentals during other weather:",
  average_other
))

average_casual <- mean(bike$casual)
average_registered <- mean(bike$registered)

print(paste("Average casual rentals:", average_casual))
print(paste("Average registered rentals:", average_registered))