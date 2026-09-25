bike <- read.csv("data/raw/day.csv")

# Convert the date from text to a date object
bike$dteday <- as.Date(bike$dteday)

# Give understandable names to the seasons
bike$season <- factor(
  bike$season,
  levels = c(1, 2, 3, 4),
  labels = c("Winter", "Spring", "Summer", "Fall")
)

# Give understandable names to the types of day
bike$day_type <- factor(
  bike$workingday,
  levels = c(0, 1),
  labels = c("Weekend or holiday", "Working day")
)

# Give understandable names to weather categories
bike$weather <- factor(
  bike$weathersit,
  levels = c(1, 2, 3, 4),
  labels = c(
    "Clear",
    "Mist or cloudy",
    "Light rain or snow",
    "Heavy rain or snow"
  )
)

summary(bike)