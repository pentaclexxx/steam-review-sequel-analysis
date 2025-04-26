# 📚 Steam Review Sequel Analysis

**Repository Link:**  
[https://github.com/pentaclexxx/steam-review-sequel-analysis](https://github.com/pentaclexxx/steam-review-sequel-analysis)

---

## 📜 Project Description

This project investigates whether positive thematic sentiment expressed in Steam reviews of *The Forest* predicts the likelihood of purchasing its sequel, *Sons of the Forest*.  
We used a combination of manual review coding, logistic regression analysis, and data visualization to test hypotheses regarding player sentiment and sequel engagement.

---

## 📂 Project Structure

| Folder | Contents |
|:-------|:---------|
| `/data/` | Raw and cleaned datasets (`sample_600_coded.xlsx`, `usable_data_clean.csv`) |
| `/scripts/` | Data cleaning and analysis scripts |
| `/results/` | Model summaries and outputs |
| `/figures/` | Generated visualizations (odds ratio plots, predicted probability histograms) |

---

## ⚙️ Scripts Overview

| Script | Purpose |
|:-------|:--------|
| `01_data_cleaning_and_filtering.R` | Loads raw coded data, cleans and filters reviews with usable sequel purchase data. |
| `02_sequel_purchase_analysis.R` | Runs logistic regression models (H1, H2a–d), calculates odds ratios, plots results, and saves outputs. |

---

## 📊 Analysis Summary

**Hypotheses Tested:**

- **H1:** Overall positivity in a review predicts sequel purchase likelihood.
- **H2a–d:** Positive sentiment toward specific themes (Gameplay, Storyline, Sociability, Scariness) predicts sequel purchase likelihood.

**Key Findings:**
- Overall positivity significantly predicts sequel purchase (✅ H1 supported).
- Scariness sentiment marginally predicts sequel purchase (🔶 Weak support for H2d).
- Gameplay, Storyline, and Sociability sentiments did not significantly predict sequel purchase (❌ H2a–c not supported).

---

## 📈 Key Tools and Libraries

- **R** (version 4.2.0 or later)
- Libraries: `dplyr`, `readr`, `tidyr`, `stringr`, `janitor`, `broom`, `ggplot2`, `scales`, `car`

---

## 🧪 How to Reproduce the Analysis

1. Run `01_data_cleaning_and_filtering.R` to generate the usable cleaned dataset.
2. Run `02_sequel_purchase_analysis.R` to perform logistic regressions and visualize results.
3. Check the outputs in `/results/` and `/figures/`.

---

## 📚 References

- Abdul-Rahman et al. (2024). Enhancing churn forecasting with sentiment analysis of Steam reviews.
- Britto & Pacífico (2020). Evaluating Video Game Acceptance in Game Reviews.
- Hu & Xi (2019). The Relationship Between Game Elements and Player Emotions.
- Cole & Griffiths (2007). Social Interactions in MMORPGs.
- Yuan et al. (2025). Sentiment Analysis and Rating Video Game Dimensions.

---

## 📑 License

**Academic Use Only.**  
Data collected from publicly available Steam reviews under fair use policy.

---

# ✅ Before Upload Checklist

- [x] Scripts are clean and properly named.
- [x] Data files are correctly placed under `/data/`.
- [x] Model outputs and figures saved in `/results/` and `/figures/`.
- [x] Group members' names filled in above.

---

# 🚀

> Thank you for visiting our project! 🚀  
> We hope our analysis helps better understand player sentiment and sequel engagement in gaming.
