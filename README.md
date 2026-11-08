
# Kenya Development Impact Analytics

**An integrated Python, R and Power BI portfolio project demonstrating data engineering, Monitoring, Evaluation and Learning (MEL), statistical analysis and impact evaluation.**

---

## 1. Project overview

Kenya Development Impact Analytics is an intermediate-level portfolio project simulating the evaluation of a fictional Climate-Smart Agriculture Programme across four Kenyan counties:

- Bungoma
- Kitui
- Nyeri
- Siaya

The project demonstrates an integrated analytical workflow using Python for data preparation and quality assurance, R for statistical analysis and Difference-in-Differences (DiD) estimation, and Power BI for interactive data visualisation.

The synthetic dataset contains 600 fictional beneficiaries observed at baseline and endline, producing 1,200 survey records.

**Important:** This is a fictional demonstration project. The dataset and findings do not represent actual Kenyan households, a real development programme or verified programme impact.

## 2. Project objectives

The analysis explores five questions:

1. How did crop productivity change between baseline and endline?
2. How did monthly household income change?
3. Did adoption of climate-smart agricultural practices change?
4. How did household food-security scores change?
5. Was the change in the treatment group greater than the change in the comparison group?

## 3. Technology stack

| Technology | Application |
|---|---|
| Python | Data preparation, cleaning and validation |
| pandas | Data manipulation and transformation |
| NumPy | Numerical operations |
| pytest | Automated testing |
| R | Statistical analysis and impact estimation |
| dplyr | Data manipulation |
| readr | CSV import and export |
| sandwich | Robust and clustered covariance estimation |
| lmtest | Statistical hypothesis testing |
| Power BI Desktop | Interactive dashboard and data visualisation |
| CSV / JSON / TXT | Data and analytical outputs |
| Git / GitHub | Version control and portfolio publication |

## 4. Analytical workflow

The project follows a reproducible, multi-stage workflow.

### Stage 1: Data preparation and quality assurance

Python performs:

- Data loading and validation.
- Required-field checks.
- Category standardisation.
- Duplicate beneficiary-wave record checks and removal.
- Implausible-value detection and flagging.
- Missing-value assessment.
- Creation of the post-period indicator.
- Descriptive summaries.
- Automated data-quality reporting.

### Stage 2: Statistical analysis

R performs:

- Descriptive analysis by programme group and survey wave.
- Difference-in-Differences estimation.
- County fixed-effects modelling.
- HC1 heteroskedasticity-robust standard errors.
- Beneficiary-clustered standard errors.
- Confidence interval estimation.
- Statistical significance assessment.
- Model diagnostics.

### Stage 3: Dashboard reporting

Power BI provides an interactive presentation of the synthetic programme data and analytical indicators.

Dashboard file:

`dashboard/Kenya_Development_Impact_Dashboard.pbix`

### Stage 4: Automated testing

pytest tests important Python pipeline functions, including:

- Duplicate record removal.
- Survey-wave indicator creation.
- County standardisation.
- Summary group generation.

## 5. Repository structure

```text
kenya_development_impact_analytics/
│
├── dashboard/
│   └── Kenya_Development_Impact_Dashboard.pbix
│
├── data/
│   ├── raw/
│   │   └── beneficiary_survey.csv
│   └── reference/
│       └── county_targets.csv
│
├── outputs/
│   ├── cleaned_beneficiary_survey.csv
│   ├── descriptive_summary.csv
│   ├── participation_summary.csv
│   ├── data_quality_report.json
│   ├── R_descriptive_results.csv
│   ├── R_difference_in_differences_results.csv
│   ├── R_clustered_DiD_results.csv
│   └── R_yield_model_diagnostics.txt
│
├── python/
│   ├── src/
│   │   └── pipeline.py
│   ├── scripts/
│   │   └── run_pipeline.py
│   └── tests/
│       └── test_pipeline.py
│
├── R/
│   └── scripts/
│       └── impact_analysis.R
│
├── reports/
│   └── interpretation_guide.md
│
├── .gitignore
├── PROJECT_METADATA.json
├── README.md
└── requirements.txt
```

## 6. Installation and setup

### Requirements

- Windows 10 or later.
- Python 3.12 or later, subject to package compatibility.
- R.
- Power BI Desktop for viewing the dashboard.
- Visual Studio Code or another suitable code editor.

The Python pipeline has been tested with Python 3.14.7.

### Python setup

Open the project directory in VS Code.

In the integrated PowerShell terminal:

```powershell
cd D:\Data\kenya_development_impact_analytics

py -3.14 -m venv .venv

.\.venv\Scripts\Activate.ps1

python -m pip install --upgrade pip

pip install -r requirements.txt
```

If Python 3.14 is not installed, use another installed version supported by the project dependencies.

### R setup

Install R from:

https://cran.r-project.org/

Install RStudio Desktop from:

https://posit.co/download/rstudio-desktop/

The R analysis script automatically installs missing required R packages.

## 7. Running the Python pipeline

From the project root, run:

```powershell
python python/scripts/run_pipeline.py
```

The pipeline generates:

- `outputs/cleaned_beneficiary_survey.csv`
- `outputs/descriptive_summary.csv`
- `outputs/participation_summary.csv`
- `outputs/data_quality_report.json`

Run the pipeline before executing the R analysis.

## 8. Running the R statistical analysis

The R script is:

`R/scripts/impact_analysis.R`

Set the working directory to the project root before running the script.

On the documented Windows installation, run:

```powershell
& "C:\Program Files\R\R-4.6.2\bin\Rscript.exe" R/scripts/impact_analysis.R
```

The script generates:

- `outputs/R_descriptive_results.csv`
- `outputs/R_difference_in_differences_results.csv`
- `outputs/R_clustered_DiD_results.csv`
- `outputs/R_yield_model_diagnostics.txt`

The script uses both HC1 robust and beneficiary-clustered standard errors.

## 9. Running automated tests

From the project root:

```powershell
python -m pytest python/tests -v
```

The project has four automated Python tests covering core data-processing functions.

## 10. Statistical methodology

The project estimates a separate linear Difference-in-Differences model for each outcome:

```text
Outcome ~ Treatment + Post + Treatment × Post + County Fixed Effects
```

The coefficient on the interaction between treatment and post-period indicators estimates the additional change in the treatment group relative to the comparison group.

Two variance estimators are reported:

**HC1 heteroskedasticity-robust standard errors**

These adjust for heteroskedasticity and are reported in:

`R_difference_in_differences_results.csv`

**Beneficiary-clustered standard errors**

These account for repeated observations of the same beneficiary and are reported in:

`R_clustered_DiD_results.csv`

The clustered analysis uses 600 beneficiary clusters and 599 degrees of freedom for its t-tests and confidence intervals.

Beneficiary-level clustering is appropriate for this repeated-observation demonstration only insofar as it reflects the dependence structure of the data. In a real evaluation, the clustering level should be informed by the treatment-assignment design.

For further methodological explanations, see:

`reports/interpretation_guide.md`

## 11. Illustrative analytical findings

The beneficiary-clustered DiD analysis produced the following estimates:

| Outcome | Estimated additional change | 95% confidence interval |
|---|---:|---:|
| Crop yield | +200.77 kg/acre | 179.41 to 222.13 |
| Monthly household income | +KES 1,816.11 | 1,552.77 to 2,079.45 |
| Climate-smart practices adopted | +1.97 practices | 1.81 to 2.13 |
| Food security score | +0.54 points | 0.46 to 0.63 |

All four estimated coefficients are positive and statistically significant at the 5% level in the synthetic dataset.

These findings demonstrate the statistical workflow, not actual programme effectiveness.

## 12. Data quality and responsible interpretation

The project incorporates data-quality checks and documents analytical limitations.

Important considerations include:

- The dataset is synthetic and fictional.
- Missing values are retained and handled transparently in summaries and models.
- Implausible values are flagged and handled by the cleaning pipeline.
- Duplicate beneficiary-wave records are checked and removed.
- Statistical significance does not establish practical importance or causality.
- A credible causal interpretation requires the parallel-trends assumption.
- With only two survey waves, parallel trends cannot be directly assessed using multiple pre-programme periods.
- Real evaluations should investigate baseline balance, attrition, concurrent shocks, spillovers and treatment-assignment clustering.

This project is a learning and portfolio demonstration, not a substitute for a properly designed programme evaluation.

## 13. Potential future enhancements

Possible extensions include:

1. Baseline balance and attrition analysis.
2. Additional subgroup analysis by gender, age and county.
3. More advanced cluster-robust inference where the assignment design requires it.
4. Multiple-period DiD and event-study analysis.
5. A reproducible Quarto analytical report.
6. Expanded automated tests and continuous integration.

## 14. GitHub repository description

Integrated Python, R and Power BI MEL analytics project demonstrating survey data cleaning, automated quality assurance, descriptive statistics, Difference-in-Differences impact evaluation and interactive dashboard reporting using a synthetic Kenyan climate-smart agriculture dataset.

Suggested GitHub topics:

`python` `r` `power-bi` `monitoring-and-evaluation` `impact-evaluation` `difference-in-differences` `data-quality` `statistics` `kenya`

---

**Project classification:** Intermediate-level analytical portfolio project.

**Data classification:** Entirely synthetic.

**Geographical context:** Bungoma, Kitui, Nyeri and Siaya, Kenya.
