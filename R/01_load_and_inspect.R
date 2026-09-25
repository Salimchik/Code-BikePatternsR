# Load the daily bicycle rental data
bike <- read.csv("data/raw/day.csv")

# Show the first rows
head(bike)

# Inspect the structure
str(bike)

# Show basic statistics
summary(bike)

# Check dimensions and column names
nrow(bike)
ncol(bike)
colnames(bike)

# Check missing values
colSums(is.na(bike))

# Check whether row IDs are duplicated
anyDuplicated(bike$instant)

# Check whether the total is calculated correctly
all(bike$casual + bike$registered == bike$cnt)