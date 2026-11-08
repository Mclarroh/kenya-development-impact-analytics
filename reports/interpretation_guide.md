
# Statistical Interpretation Guide
## Kenya Development Impact Analytics

## 1. Purpose of the analysis

This guide explains the statistical methods, estimated effects, uncertainty measures and limitations of the Difference-in-Differences (DiD) analysis.

The project uses a fictional Climate-Smart Agriculture Programme implemented across Bungoma, Kitui, Nyeri and Siaya counties.

The dataset is entirely synthetic. The findings demonstrate an analytical workflow and must not be interpreted as actual programme results or evidence about Kenyan households.

## 2. Difference-in-Differences methodology

The analysis compares changes between baseline and endline for two groups:

- Treatment group: fictional beneficiaries participating in the programme.
- Comparison group: fictional beneficiaries not participating in the programme.

The model is:

Outcome = b0 + b1(Treatment) + b2(Post) + b3(Treatment * Post) + County Fixed Effects + Error

The coefficient of primary interest is b3, represented in the results as:

`treatment_group:post`

It estimates the additional change in the treatment group relative to the comparison group, conditional on the included county fixed effects.

A positive coefficient indicates a greater increase (or smaller decrease) in the treatment group relative to the comparison group.

## 3. Statistical methods

Two variance estimators are provided.

### 3.1 HC1 heteroskedasticity-robust standard errors

Results are saved in:

`outputs/R_difference_in_differences_results.csv`

HC1 standard errors adjust for heteroskedasticity.

Key fields:

- `estimate`: estimated DiD interaction coefficient.
- `robust_se`: HC1 robust standard error.
- `statistic`: test statistic.
- `p_value`: test of the null hypothesis that the DiD coefficient is zero.
- `ci_lower_95`: lower approximate 95% confidence limit.
- `ci_upper_95`: upper approximate 95% confidence limit.
- `n`: number of observations used in the model.

### 3.2 Beneficiary-clustered standard errors

Results are saved in:

`outputs/R_clustered_DiD_results.csv`

The dataset contains repeated observations for individual beneficiaries. The clustered analysis uses `beneficiary_id` as the clustering variable to account for within-beneficiary dependence across observations.

Key fields:

- `estimate`: estimated DiD interaction coefficient.
- `clustered_se`: beneficiary-clustered standard error.
- `statistic`: estimate divided by clustered standard error.
- `p_value`: two-sided test using a t-distribution with clusters minus one degrees of freedom.
- `clusters`: number of unique beneficiary clusters.
- `degrees_of_freedom`: number of clusters minus one.
- `ci_lower_95`: lower 95% confidence limit.
- `ci_upper_95`: upper 95% confidence limit.
- `n`: number of observations used in the model.

The clustered results are the preferred inferential results for this repeated-beneficiary dataset, subject to the qualification that the appropriate clustering level depends on the actual programme's treatment-assignment design.

## 4. Summary of synthetic findings

The beneficiary-clustered analysis produced the following estimates:

| Outcome | Estimated additional change | 95% confidence interval |
|---|---:|---:|
| Crop yield | +200.77 kg per acre | 179.41 to 222.13 |
| Monthly household income | +KES 1,816.11 | 1,552.77 to 2,079.45 |
| Climate-smart practices adopted | +1.97 practices | 1.81 to 2.13 |
| Food security score | +0.54 points | 0.46 to 0.63 |

All four estimated coefficients are positive and statistically significant at the 5% level in this synthetic demonstration.

These estimates illustrate how programme outcomes can be analysed. They do not establish actual programme effectiveness.

## 5. Understanding statistical significance

A p-value below 0.05 is conventionally treated as statistically significant at the 5% level.

A 95% confidence interval that excludes zero is consistent with statistical significance at approximately the same level for the corresponding two-sided test.

Statistical significance does not establish:

- That the estimated effect is practically important.
- That the programme caused the observed difference.
- That the result will generalise to other counties or populations.
- That the model is free from bias or misspecification.

Effect size, measurement quality, programme context and study design must also be considered.

## 6. Important methodological limitations

### Synthetic data

All records are simulated. The results are not observations from a real programme or actual Kenyan households.

### Parallel trends

A causal DiD interpretation requires that, in the absence of the programme, the treatment and comparison groups would have followed parallel outcome trends.

The dataset has only two survey waves, so this assumption cannot be assessed using multiple pre-programme periods.

### Treatment assignment and clustering

The current clustered model groups repeated observations by beneficiary.

In a real evaluation, standard errors should generally be clustered at the level at which treatment was assigned, where appropriate. If treatment is assigned by village, community or another group, beneficiary-level clustering alone may not adequately account for the design.

### Other potential sources of bias

A real evaluation should also investigate:

- Baseline differences between treatment and comparison groups.
- Attrition and missing observations.
- Changes in beneficiary composition.
- Concurrent events that affect the groups differently.
- Spillover effects between groups.
- Model specification and sensitivity to alternative assumptions.

## 7. Additional model diagnostics

The file:

`outputs/R_yield_model_diagnostics.txt`

contains conventional OLS diagnostic output for the crop-yield model.

It is provided for model inspection and should not be confused with the beneficiary-clustered inference results.

## 8. Reproducibility

The analysis is generated using:

- Python for data preparation, cleaning and validation.
- R for descriptive statistics and Difference-in-Differences estimation.
- CSV files for structured analytical outputs.
- Power BI for dashboard presentation.

Run the Python pipeline before running the R analysis.

The R script is:

`R/scripts/impact_analysis.R`

Run it from the project root after preparing the cleaned dataset.

## 9. Overall interpretation

Kenya Development Impact Analytics demonstrates an integrated development-impact analysis workflow, combining data quality assurance, descriptive statistics, Difference-in-Differences estimation, robust inference and dashboard reporting.

Its purpose is to demonstrate analytical methods and reproducible technical skills using fictional data, not to report actual development programme impacts.
