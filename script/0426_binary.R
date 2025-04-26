# === LIBRARIES ===
library(readr)
library(dplyr)
library(tidyr)
library(stringr)
library(scales)

# === LOAD CLEANED DATA ===
data <- read_csv("/Volumes/SP PHD U3/data_collection/sequel_analysis/data/usable_data_clean.csv")
cat("\n Usable data successfully loaded.\n")

colnames(data)

# === CLEANING FUNCTION FOR BINARY VARIABLES ===
clean_binary <- function(x) {
  x <- trimws(tolower(as.character(x)))
  x[x %in% c("1", "yes", "y")] <- 1
  x[x %in% c("0", "no", "n")] <- 0
  x[!(x %in% c("0", "1"))] <- NA
  return(as.numeric(x))
}


# === CLEAN DATA ===
# Apply clean_binary if your columns are not already pure 0/1 (probably not needed here, but for consistency)
data <- data %>%
  mutate(
    gameplay = clean_binary(gameplay),
    storyline = clean_binary(storyline),
    sociability = clean_binary(sociability),
    scariness = clean_binary(scariness),
    sequel_purchased = clean_binary(sequel_purchased)
  )

# Filter out missing outcome values
data_clean <- data %>%
  filter(!is.na(sequel_purchased))

# === CREATE THEME SCORES ===
data_clean <- data_clean %>%
  mutate(
    theme_positive_score = gameplay + storyline + sociability + scariness,
    Overall = ifelse(theme_positive_score >= 1, 1, 0)
  )

cat("\n Data cleaning and binary theme scoring completed.\n")

summary(data_clean$Overall)
table(data_clean$Overall)

# === Logistic Regression Models (H1 and H2) ===

# H1: Binary Overall positivity predicting sequel purchase
model_h1_better <- glm(sequel_purchased ~ Overall, 
                       data = data_clean, 
                       family = binomial)

# 1. Check model summary
summary(model_h1_better)

# 2. Get odds ratios
exp(coef(model_h1_better))
exp(confint(model_h1_better))

# 3. Predict probabilities
data_clean <- data_clean %>%
  mutate(predicted_overall = predict(model_h1_better, type = "response"))

# 4. Plot predicted probabilities
ggplot(data_clean, aes(x = factor(Overall), y = predicted_overall)) +
  geom_jitter(width = 0.1, alpha = 0.3) +
  geom_boxplot(alpha = 0.2, outlier.shape = NA) +
  stat_summary(fun = mean, geom = "point", color = "red", size = 3) +
  labs(title = "Predicted Probability of Sequel Purchase by Overall Positivity",
       x = "Overall Positivity (0 = No, 1 = Yes)",
       y = "Predicted Probability") +
  theme_minimal()

# 5. McFadden R2
library(pscl)
pR2(model_h1_better)


# H2a–H2d: Individual themes predicting sequel purchase
model_h2 <- glm(sequel_purchased ~ gameplay + storyline + sociability + scariness,
                data = data_clean,
                family = binomial)

car::vif(model_h2)

AIC(model_h1_better)
AIC(model_h2)

# === Model Diagnostics: McFadden's R2 ===
# install.packages("pscl") # (only once)
library(pscl)

# Here 'model_h2' is used for R² check, you can also fit a 'full' model if needed
pR2(model_h2)

# === Add predicted probabilities to data ===
data_clean <- data_clean %>%
  mutate(predicted = predict(model_h2, type = "response"))

# === Visualizing Model Results ===
library(broom)
library(ggplot2)

# --- Odds Ratio Plot for H1 (Overall Positivity) ---
tidy_model_h1_better <- broom::tidy(model_h1_better, conf.int = TRUE, exponentiate = TRUE)

ggplot(tidy_model_h1_better %>% filter(term != "(Intercept)"),
       aes(x = term, y = estimate, ymin = conf.low, ymax = conf.high)) +
  geom_pointrange() +
  geom_hline(yintercept = 1, linetype = "dashed", color = "gray") +
  coord_flip() +
  labs(title = "Odds Ratios with 95% CI – H1 (Overall Positivity)",
       y = "Odds Ratio", x = "")

# --- Odds Ratio Plot for H2 (Thematic Drivers) ---
tidy_model_h2 <- broom::tidy(model_h2, conf.int = TRUE, exponentiate = TRUE)

ggplot(tidy_model_h2 %>% filter(term != "(Intercept)"),
       aes(x = term, y = estimate, ymin = conf.low, ymax = conf.high)) +
  geom_pointrange() +
  geom_hline(yintercept = 1, linetype = "dashed", color = "gray") +
  coord_flip() +
  labs(title = "Odds Ratios with 95% CI – H2a–H2d (Thematic Drivers)",
       y = "Odds Ratio", x = "")
