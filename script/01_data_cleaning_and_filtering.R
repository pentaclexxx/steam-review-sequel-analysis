library(readxl)    # for reading Excel files
library(dplyr)     # for data manipulation
library(janitor)   # for cleaning column names
# -------------------------------------------------------------------
# LOAD AND CLEAN DATA -----------------------------------------------
# -------------------------------------------------------------------
raw <- read_excel("/Volumes/SP PHD U3/data_collection/sequel_analysis/data/sample_600_coded.xlsx", skip = 1)

# Clean column names to be lowercase and snake_case
data <- clean_names(raw)

# Check structure after cleaning
cat("\n=== Structure of Cleaned Data ===\n")
str(data)

# Rename default x1–x6 columns with meaningful names
data <- data %>%
  rename(
    user_id = x1,
    reviewer_id = x2,
    username = x3,
    review_text = x4,
    timestamp = x5,
    review_vote = x6,
    sequel_purchased = sequel_purchased
  )

# Convert theme and target variables to numeric
data <- data %>%
  mutate(across(c(gameplay, storyline, sociability, scariness, sequel_purchased), as.numeric))

# Confirm column names
cat("\n=== Column Names After Cleaning ===\n")
print(names(data))

# Count total entries
total_users <- nrow(data)
cat("\n=== DATA SUMMARY ===\n")
cat("Total number of user reviews in dataset:", total_users, "\n\n")

# -------------------------------------------------------------------
# IDENTIFY REVIEW TYPES BASED ON DATA AVAILABILITY ---------------
# -------------------------------------------------------------------

# Group A: Reviews with no mention of any theme (all 4 coded columns are NA)
group_blank_themes <- data %>%
  filter(
    is.na(gameplay) &
      is.na(storyline) &
      is.na(sociability) &
      is.na(scariness)
  )

cat("Group A — Reviews with NO coded theme content:\n")
cat("Count:", nrow(group_blank_themes), "\n")
str(group_blank_themes)
cat("\n\n")

# -------------------------------------------------------------------
# Group B: Reviews with at least one coded theme, but sequel purchase info is missing
group_missing_sequel_but_coded_themes <- data %>%
  filter(is.na(sequel_purchased)) %>%
  filter(!(is.na(gameplay) & is.na(storyline) & is.na(sociability) & is.na(scariness)))

cat("Group B — Theme-coded reviews missing sequel purchase info:\n")
cat("Count:", nrow(group_missing_sequel_but_coded_themes), "\n")
str(group_missing_sequel_but_coded_themes)
cat("\n\n")

# -------------------------------------------------------------------
# FILTER: SELECT FULLY USABLE REVIEWS FOR ANALYSIS ---------------
# -------------------------------------------------------------------

# Retain only reviews that have at least one coded theme AND valid sequel outcome
usable_data <- data %>%
  filter(!is.na(sequel_purchased)) %>%
  filter(!(is.na(gameplay) & is.na(storyline) & is.na(sociability) & is.na(scariness)))

cat("Usable entries for analysis:", nrow(usable_data), "\n")
str(usable_data)

# -------------------------------------------------------------------
# EXPORT: SAVE CLEANED USABLE DATA -------------------------------
# -------------------------------------------------------------------
output_path <- "/Volumes/SP PHD U3/data_collection/sequel_analysis/data/usable_data_clean.csv"
write.csv(usable_data, file = output_path, row.names = FALSE)
cat("leaned dataset saved to:\n", output_path, "\n")
