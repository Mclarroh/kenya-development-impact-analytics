# Data Dictionary
## Kenya Development Impact Analytics

**Project:** Kenya Development Impact Analytics  
**Dataset:** Synthetic Climate-Smart Agriculture Beneficiary Survey  
**Geographical coverage:** Bungoma, Kitui, Nyeri and Siaya counties, Kenya  
**Survey period:** February 2025–February 2026  
**Records:** 1,200  
**Unique beneficiaries:** 600  
**Survey waves:** Baseline and Endline  

---

## 1. Dataset Overview

This dataset contains synthetic beneficiary-level survey observations developed for a fictional Climate-Smart Agriculture Programme.

It represents 600 beneficiaries observed at two survey waves:

- Baseline: February 2025
- Endline: February 2026

The dataset contains 1,200 records, with two observations per beneficiary.

The data supports demonstration of:

- Beneficiary monitoring and tracking.
- Data cleaning and validation.
- Programme participation analysis.
- Household welfare analysis.
- County-level comparisons.
- Difference-in-Differences (DiD) analysis.
- Power BI monitoring and reporting.

**Important:** All records are synthetic. They do not represent actual beneficiaries, households, programme activities or verified programme outcomes in Kenya.

---

## 2. Dataset Structure

| Attribute | Description |
|---|---|
| Number of observations | 1,200 |
| Unique beneficiaries | 600 |
| Observations per beneficiary | 2 |
| Geographic coverage | 4 counties |
| Survey waves | Baseline and Endline |
| Treatment groups | Treatment and Comparison |
| File format | CSV |
| Character encoding | UTF-8 (expected) |

---

## 3. Variable Definitions

| Variable | Data type | Description | Unit / permitted values |
|---|---|---|---|
| beneficiary_id | String | Unique identifier assigned to each beneficiary | BEN0001–BEN0600 |
| county | Categorical | County where the beneficiary is represented | Bungoma, Kitui, Nyeri, Siaya |
| treatment_group | Integer | Programme assignment indicator | 0 = Comparison; 1 = Treatment |
| survey_wave | Categorical | Survey measurement period | Baseline, Endline |
| age | Integer | Beneficiary age | Years |
| gender | Categorical | Beneficiary gender category in the synthetic dataset | Male, Female |
| land_size_acres | Numeric | Land size associated with the beneficiary | Acres |
| crop_yield_kg_per_acre | Numeric | Crop production yield | Kilograms per acre |
| monthly_household_income_kes | Numeric | Monthly household income | Kenyan shillings (KES) |
| climate_smart_practices_adopted | Integer | Number of climate-smart agricultural practices adopted | Count |
| food_security_score | Numeric | Synthetic household food-security indicator | Score; see measurement notes |
| training_sessions_attended | Integer | Number of programme training sessions attended | Count |
| survey_date | Date | Date of survey observation | YYYY-MM-DD |

---

## 4. Categorical Variable Coding

### 4.1 Treatment group

| Code | Label |
|---|---|
| 0 | Comparison |
| 1 | Treatment |

The treatment-group variable identifies whether an observation belongs to the programme treatment group or comparison group.

### 4.2 Survey wave

| Value | Description |
|---|---|
| Baseline | Initial survey measurement |
| Endline | Follow-up survey measurement |

### 4.3 County

| County |
|---|
| Bungoma |
| Kitui |
| Nyeri |
| Siaya |

### 4.4 Gender

| Value |
|---|
| Female |
| Male |

---

## 5. Missing Data Profile

The raw dataset contains the following missing observations:

| Variable | Missing records | Missing (%) |
|---|---:|---:|
| monthly_household_income_kes | 14 | 1.17% |
| food_security_score | 9 | 0.75% |
| training_sessions_attended | 7 | 0.58% |
| All other variables | 0 | 0.00% |

The percentages use 1,200 total records as the denominator.

Missing values should be assessed according to the analytical objective. They should not automatically be replaced with zero.

The analysis should also consider whether missing observations differ between treatment groups, survey waves or counties.

---

## 6. Derived Variables

The analytical pipeline creates additional variables for reporting and statistical analysis.

| Derived variable | Description |
|---|---|
| post | Binary indicator: 0 = Baseline; 1 = Endline |
| programme_group | Text label derived from treatment_group: Comparison or Treatment |
| yield_per_acre | Analytical alias for crop_yield_kg_per_acre |

These derived variables are generated during data processing and are not additional original survey questions.

---

## 7. Data Quality Considerations

The project includes automated data validation and cleaning procedures.

Key checks include:

1. Required-column validation.
2. Numeric type conversion.
3. Date parsing and validation.
4. Duplicate-record detection.
5. County standardisation.
6. Treatment-group validation.
7. Missing-value assessment.
8. Plausible range checks for analytical variables.

The Python pipeline produces cleaned data and a machine-readable data quality report.

The existence of validation procedures does not imply that all potential measurement, sampling or reporting errors have been eliminated.

---

## 8. Analytical Use

The dataset supports descriptive and inferential analysis, including:

- Beneficiary characteristics.
- Programme participation.
- Crop yield comparisons.
- Household income comparisons.
- Climate-smart agricultural practice adoption.
- Food-security comparisons.
- Difference-in-Differences estimation.

The DiD model estimates the additional change in the treatment group relative to the comparison group, controlling for county fixed effects.

The interpretation of estimated programme effects depends on the research design and assumptions, particularly the parallel-trends assumption.

---

## 9. Important Limitations

This is a fictional, synthetic dataset designed for technical demonstration.

It should not be used to:

- Claim actual programme impact.
- Make decisions about real beneficiaries.
- Represent official Kenyan agricultural statistics.
- Infer causal effects without appropriate research-design assumptions.
- Substitute for verified field data.

The treatment-assignment mechanism, sampling process and measurement instruments are simulated for portfolio demonstration.

---

## 10. Reproducibility

The dataset is processed through the project's Python and R analytical workflows.

Relevant project files:

- `data/raw/beneficiary_survey.csv`
- `data/reference/county_targets.csv`
- `python/src/pipeline.py`
- `python/scripts/run_pipeline.py`
- `R/scripts/impact_analysis.R`
- `outputs/data_quality_report.json`

Refer to the main README for installation instructions and execution commands.