# Evaluation Methodology
## Kenya Development Impact Analytics

## 1. Introduction

This document describes the evaluation design, data preparation procedures, statistical methods, assumptions and limitations used in the Kenya Development Impact Analytics project.

The project demonstrates an analytical workflow for evaluating a fictional Climate-Smart Agriculture Programme operating across Bungoma, Kitui, Nyeri and Siaya counties in Kenya.

**Important:** The dataset is entirely synthetic. It does not represent actual programme beneficiaries, household observations or measured programme outcomes. All results are illustrative and must not be presented as evidence of actual programme effectiveness.

## 2. Evaluation design

### 2.1 Analytical approach

The project uses a Difference-in-Differences (DiD) approach to demonstrate how changes in outcomes can be compared between a treatment group and a comparison group over time.

The analytical dataset contains:

- 600 fictional beneficiary identifiers.
- 1,200 survey records.
- Two survey waves: baseline and endline.
- Four counties: Bungoma, Kitui, Nyeri and Siaya.
- Treatment and comparison groups.

The treatment group represents fictional beneficiaries participating in the programme. The comparison group represents fictional beneficiaries not participating in the programme.

The dataset is structured to represent repeated observations of beneficiaries across the two survey waves.

### 2.2 Evaluation question

The principal analytical question is:

*Did the treatment group experience a greater change in the selected outcome indicators between baseline and endline than the comparison group?*

The analysis demonstrates this comparison for four outcome indicators:

1. Crop yield, measured in kilograms per acre.
2. Monthly household income, measured in Kenyan shillings.
3. Number of climate-smart agricultural practices adopted.
4. Food security score, measured in score units.

The precise interpretation of the food security score depends on its measurement definition and coding. Its scale and direction should be confirmed before substantive interpretation.

## 3. Data sources and structure

### 3.1 Data source

All observations are synthetically generated for this portfolio project. There are no actual survey respondents or external programme monitoring records.

The raw dataset is stored at:

`data/raw/beneficiary_survey.csv`

The cleaned analytical dataset is generated at:

`outputs/cleaned_beneficiary_survey.csv`

### 3.2 Key variables

| Variable | Description |
|---|---|
| beneficiary_id | Unique fictional beneficiary identifier |
| county | County associated with the observation |
| treatment_group | Group indicator: 0 = comparison; 1 = treatment |
| survey_wave | Survey period: baseline or endline |
| age | Beneficiary age |
| gender | Recorded gender category |
| land_size_acres | Land size in acres |
| crop_yield_kg_per_acre | Crop yield in kilograms per acre |
| monthly_household_income_kes | Monthly household income in KES |
| climate_smart_practices_adopted | Number of practices adopted |
| food_security_score | Food security indicator score |
| training_sessions_attended | Number of training sessions attended |
| survey_date | Survey date |

The analytical script derives a post-period indicator from the survey wave. The interaction between treatment status and the post-period indicator is used to estimate the DiD effect.

## 4. Data preparation and quality assurance

Python is used for data preparation, cleaning and validation before statistical analysis.

The preparation workflow includes:

1. Loading the raw survey dataset.
2. Checking the structure and completeness of the data.
3. Identifying and removing duplicate records according to the pipeline rules.
4. Standardising county values.
5. Creating the survey-period indicator used in the analysis.
6. Checking selected variables for missing or out-of-range values.
7. Producing a cleaned dataset for statistical analysis.
8. Exporting data quality and descriptive summary outputs.

The Python pipeline also generates a data quality report in JSON format.

Missing values are not automatically evidence of invalid observations. Their treatment must be considered in relation to the variable, the analysis and the reason for missingness.

For the R outcome models, observations missing the relevant outcome or required model variables are excluded from that particular model. The analysis does not use statistical imputation for missing outcome values.

The number of observations may therefore differ between outcome models.

## 5. Statistical methodology

### 5.1 Descriptive analysis

Descriptive statistics are generated to summarise the selected outcomes by programme group and survey wave.

The descriptive analysis helps examine:

- Differences between treatment and comparison groups.
- Changes in outcome averages between baseline and endline.
- The distribution of observations across groups and survey periods.
- The number of usable observations for each outcome.

Descriptive differences alone do not establish programme effects. The DiD model is used to estimate the additional change associated with treatment status.

### 5.2 Difference-in-Differences model

The primary analytical method is a linear Difference-in-Differences regression model with county fixed effects.

The model is specified as:

\[
Y_{ict} = \beta_0 + \beta_1 T_i + \beta_2 Post_t
+ \beta_3(T_i \times Post_t) + \gamma_c + \epsilon_{ict}
\]

Where:

- \(Y_{ict}\) = outcome for beneficiary \(i\), in county \(c\), during period \(t\).
- \(\beta_0\) = intercept.
- \(T_i\) = treatment-group indicator.
- \(Post_t\) = post-programme-period indicator.
- \(T_i \times Post_t\) = treatment-by-post interaction.
- \(\beta_3\) = estimated Difference-in-Differences coefficient.
- \(\gamma_c\) = county fixed effects.
- \(\epsilon_{ict}\) = error term.

The coefficient of primary interest is \(\beta_3\), reported in the R output as:

`treatment_group:post`

It estimates the additional change in the treatment group relative to the comparison group, conditional on the included county fixed effects.

A positive coefficient indicates a greater increase, or a smaller decrease, in the treatment group relative to the comparison group.

The model includes county fixed effects but does not include beneficiary fixed effects or additional individual-level control variables.

### 5.3 Interpretation of the DiD estimate

The DiD estimate can be understood as:

\[
DiD = (Y_{T,Endline} - Y_{T,Baseline})
- (Y_{C,Endline} - Y_{C,Baseline})
\]

Where:

- \(Y_T\) represents the treatment-group outcome average.
- \(Y_C\) represents the comparison-group outcome average.

The estimate measures the difference between the two groups' changes over time.

A DiD coefficient is not automatically proof of causation. Its causal interpretation depends on the credibility of the evaluation design and the assumptions discussed below.

## 6. Estimation and statistical inference

Two approaches to estimating uncertainty are included.

### 6.1 HC1 heteroskedasticity-robust standard errors

The first model uses HC1 heteroskedasticity-robust standard errors.

These adjust the estimated variance for heteroskedasticity, where the variance of the regression errors is not constant.

The corresponding results are saved in:

`outputs/R_difference_in_differences_results.csv`

The confidence intervals use a normal approximation based on 1.96 standard errors.

### 6.2 Beneficiary-clustered standard errors

The second model calculates standard errors clustered by `beneficiary_id`.

This accounts for potential dependence between repeated observations belonging to the same beneficiary.

The corresponding results are saved in:

`outputs/R_clustered_DiD_results.csv`

The script calculates p-values and confidence intervals using a t-distribution with degrees of freedom equal to the number of beneficiary clusters minus one.

Beneficiary-level clustering is appropriate to consider because the dataset contains repeated observations for individual beneficiaries. However, the correct clustering level in an actual evaluation depends on the treatment-assignment design.

If programme participation is assigned at village, community or another group level, inference should generally account for clustering at that assignment level where appropriate. Beneficiary-level clustering alone may not adequately capture that design.

The clustered estimates are therefore presented as an additional inferential approach for this synthetic dataset, not as a universally correct specification for real-world evaluations.

## 7. Key assumptions of Difference-in-Differences

A credible causal interpretation of DiD depends on several assumptions.

### 7.1 Parallel trends

In the absence of the programme, the treatment and comparison groups would have followed parallel outcome trends over time.

This is the central identifying assumption of the DiD approach.

The current dataset contains only two survey waves: baseline and endline. Consequently, multiple pre-programme observations are unavailable to assess whether the groups had parallel trends before treatment.

The assumption cannot be empirically established using this dataset.

### 7.2 No differential concurrent shocks

Other events occurring during the evaluation period should not affect the treatment and comparison groups differently in ways that influence the outcomes.

For a real agricultural programme, relevant events might include differences in rainfall, pest outbreaks, market access or other interventions.

Such factors should be investigated during evaluation design and analysis.

### 7.3 No substantial spillover effects

The programme should not materially affect comparison-group outcomes through spillovers.

For example, agricultural knowledge or resources received by treatment-group beneficiaries could be shared with comparison-group beneficiaries.

Spillovers can influence the estimated difference between groups.

### 7.4 Stable group composition and measurement

Changes in the composition of the treatment and comparison groups, or changes in how outcomes are measured, can distort comparisons over time.

A real evaluation should investigate attrition, sample replacement, missing observations and consistency of measurement instruments.

### 7.5 Appropriate treatment assignment and inference

The treatment-assignment mechanism and level should be clearly documented.

The analysis should reflect that design when estimating uncertainty, selecting clustering levels and interpreting results.

The synthetic dataset does not provide a documented village- or community-level treatment-assignment variable.

## 8. Model diagnostics and sensitivity considerations

The project generates conventional OLS diagnostic output for the crop-yield model:

`outputs/R_yield_model_diagnostics.txt`

These diagnostics support inspection of the fitted model but do not replace appropriate robust or clustered inference.

A more extensive real-world evaluation could include:

- Baseline comparability assessment.
- Attrition analysis.
- Alternative model specifications.
- Sensitivity to the choice of standard errors and clustering level.
- Investigation of influential observations.
- Assessment of missing-data patterns.
- Additional pre-programme periods where available.
- Alternative outcome definitions where justified.

The current portfolio analysis is a demonstration and does not claim that every possible diagnostic or sensitivity test has been performed.

## 9. Software and reproducibility

The project combines Python, R and Power BI.

| Tool | Role |
|---|---|
| Python | Data preparation, cleaning and validation |
| pandas and NumPy | Data manipulation and numerical operations |
| pytest | Automated Python pipeline tests |
| R | Descriptive and Difference-in-Differences analysis |
| dplyr and readr | Data manipulation and input/output |
| broom | Statistical model output handling |
| sandwich | Robust and clustered variance estimation |
| lmtest | Statistical inference |
| Power BI | Interactive dashboard presentation |

The main Python pipeline is:

`python/scripts/run_pipeline.py`

The R analysis script is:

`R/scripts/impact_analysis.R`

The recommended execution order is:

1. Run the Python data preparation pipeline.
2. Review the data quality report.
3. Run the R analysis script.
4. Review the exported statistical results.
5. Open the Power BI dashboard and inspect the visualisations.

The project stores intermediate and final analytical outputs in the `outputs/` directory.

## 10. Ethical and interpretation considerations

The dataset is synthetic and contains no actual beneficiary records.

The project is intended to demonstrate technical competence in data management, statistical analysis, evaluation methodology and dashboard development.

The results must not be represented as actual programme achievements, evidence of improved household welfare or verified agricultural outcomes in Kenya.

Any real evaluation using this methodology would require appropriate research permissions, informed consent where applicable, data protection safeguards, transparent documentation and a defensible evaluation design.

## 11. Methodological conclusion

Kenya Development Impact Analytics demonstrates a reproducible workflow for preparing survey data, conducting descriptive analysis, estimating Difference-in-Differences models, calculating robust and beneficiary-clustered standard errors, and presenting analytical outputs.

The project illustrates how statistical methods can support development programme evaluation while recognising the assumptions and limitations that govern causal interpretation.

Its contribution is methodological and technical: it demonstrates an integrated analytical process using synthetic data, rather than reporting actual programme impact.