# Kenya County Economic Performance & Poverty Analysis

## Overview
This project examines the relationship between county-level economic output and poverty across Kenya's 47 counties, using official Gross County Product (GCP) data and World Bank poverty estimates.

## Objective
To identify which counties are converting economic growth into poverty reduction, and which are not — and to explore whether GCP growth rate or absolute GCP level is a stronger predictor of poverty outcomes.

## Data Sources
- **Gross County Product (GCP), 2013–2020** — Kenya National Bureau of Statistics (KNBS), via the Kenya Data Portal
- **Poverty rate estimates (2015)** — World Bank international poverty line data (Poverty and Inequality Platform), compiled by county

## Tools Used
- Python (pandas, matplotlib, seaborn, scikit-learn)
- Jupyter Notebook

## Method
1. Loaded and validated the merged county-level dataset (no missing values, 47 counties)
2. Ranked counties by GCP growth rate and by poverty rate
3. Identified outlier counties — high growth with persistent high poverty, and low growth with already-low poverty
4. Visualized growth and poverty distributions across counties
5. Tested the correlation between GCP growth and poverty rate, and built a simple linear regression model
6. Compared GCP growth rate vs. absolute GCP level as predictors of poverty

## Key Findings
- Fast GCP growth doesn't always translate into lower poverty — several high-growth counties still show high poverty rates.
- Counties with the lowest poverty (e.g., Nairobi, Mombasa) tend to have large, established economies rather than the fastest recent growth.
- Absolute GCP level shows a stronger relationship with poverty than growth rate alone, suggesting the *scale* of a county's economy matters more than its recent growth pace.

## Limitations
- Small sample size (47 counties)
- GCP data (2013–2020) and poverty data (2015) come from different years, so this is a structural analysis rather than a real-time comparison
- Poverty estimates use international thresholds, which may differ from Kenya's national poverty line definitions

## Files
- `Kenya_County_GCP_Poverty_Analysis.ipynb` — full analysis notebook with code, charts, and findings
- `kenya_county_gcp_poverty_merged.csv` — merged dataset used for the analysis
