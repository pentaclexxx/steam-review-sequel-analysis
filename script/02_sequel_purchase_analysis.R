# === LIBRARIES ===
library(readr)
library(dplyr)
library(tidyr)
library(stringr)
library(scales)
library(broom)
library(ggplot2)
library(car)

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
data <- data %>%
  mutate(
    gameplay = clean_binary(gameplay),
    storyline = clean_binary(storyline),
    sociability = clean_binary(sociability),
    scariness = clean_binary(scariness),
    sequel_purchased = clean_binary(sequel_purchased)
  )

data_clean <- data %>%
  filter(!is.na(sequel_purchased)) %>%
  mutate(
    Overall = gameplay + storyline + sociability + scariness,
    Overall_scaled = scale(Overall)[,1]
  )

cat("\nData cleaning and theme scoring completed.\n")

summary(data_clean$Overall)
sd(data_clean$Overall, na.rm = TRUE)

# === LOGISTIC REGRESSION MODELS ===

## H1: Overall positivity (scaled) -> Sequel purchase
model_h1 <- glm(sequel_purchased ~ Overall_scaled, data = data_clean, family = binomial)
summary(model_h1)

## H2a–d: Specific themes -> Sequel purchase
model_h2 <- glm(sequel_purchased ~ gameplay + storyline + sociability + scariness, data = data_clean, family = binomial)
summary(model_h2)

# === MODEL DIAGNOSTICS ===

## Pseudo-R² (McFadden)
cat("\nMcFadden's R² for H1:", pR2(model_h1)["McFadden"], "\n")
cat("McFadden's R² for H2:", pR2(model_h2)["McFadden"], "\n")

## Multicollinearity Check (VIF for H2)
vif(model_h2)

# === CALCULATE ODDS RATIOS AND CONFIDENCE INTERVALS ===

## H1 Odds Ratios
OR_H1 <- exp(cbind(Odds_Ratio = coef(model_h1), confint(model_h1)))
print(OR_H1)

## H2 Odds Ratios
OR_H2 <- exp(cbind(Odds_Ratio = coef(model_h2), confint(model_h2)))
print(OR_H2)

# === SAVE MODEL SUMMARIES ===
write.csv(tidy(model_h1, conf.int = TRUE, exponentiate = TRUE), "model_H1_summary.csv")
write.csv(tidy(model_h2, conf.int = TRUE, exponentiate = TRUE), "model_H2_summary.csv")

# === VISUALIZATIONS ===

## Odds Ratio Plot - H1
tidy(model_h1, conf.int = TRUE, exponentiate = TRUE) %>%
  filter(term != "(Intercept)") %>%
  ggplot(aes(x = term, y = estimate, ymin = conf.low, ymax = conf.high)) +
  geom_pointrange() +
  geom_hline(yintercept = 1, linetype = "dashed") +
  coord_flip() +
  labs(title = "H1: Odds Ratios (Overall Positivity)", y = "Odds Ratio", x = "") +
  theme_minimal()

## Odds Ratio Plot - H2
tidy(model_h2, conf.int = TRUE, exponentiate = TRUE) %>%
  filter(term != "(Intercept)") %>%
  ggplot(aes(x = term, y = estimate, ymin = conf.low, ymax = conf.high)) +
  geom_pointrange() +
  geom_hline(yintercept = 1, linetype = "dashed") +
  coord_flip() +
  labs(title = "H2: Odds Ratios (Theme Predictors)", y = "Odds Ratio", x = "") +
  theme_minimal()

# === ADD PREDICTED PROBABILITIES ===
data_clean <- data_clean %>%
  mutate(predicted = predict(model_h2, type = "response"))

# Plot predicted probabilities
ggplot(data_clean, aes(x = predicted)) +
  geom_histogram(binwidth = 0.05, fill = "skyblue", color = "black") +
  labs(title = "Predicted Probability of Sequel Purchase", x = "Predicted Probability", y = "Count") +
  theme_minimal()