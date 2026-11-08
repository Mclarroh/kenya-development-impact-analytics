
# ============================================================
# KENYA DEVELOPMENT IMPACT ANALYTICS
# Statistical impact analysis: Difference-in-Differences
# Dataset: Fictional synthetic programme data
#
# Run after the Python pipeline has generated:
# outputs/cleaned_beneficiary_survey.csv
# ============================================================


# 1. INSTALL AND LOAD REQUIRED PACKAGES -----------------------

required_packages <- c(
  "dplyr",
  "readr",
  "broom",
  "sandwich",
  "lmtest"
)

missing_packages <- required_packages[
  !vapply(
    required_packages,
    requireNamespace,
    logical(1),
    quietly = TRUE
  )
]

if (length(missing_packages) > 0) {
  install.packages(
    missing_packages,
    repos = "https://cloud.r-project.org"
  )
}

invisible(
  lapply(
    required_packages,
    library,
    character.only = TRUE
  )
)


# 2. DEFINE PROJECT PATHS -------------------------------------

project_root <- normalizePath(
  getwd(),
  winslash = "/",
  mustWork = TRUE
)

input_file <- file.path(
  project_root,
  "outputs",
  "cleaned_beneficiary_survey.csv"
)

output_dir <- file.path(
  project_root,
  "outputs"
)

if (!file.exists(input_file)) {
  stop(
    "Cleaned data not found. Run the Python pipeline first ",
    "from the project root."
  )
}


# 3. LOAD AND PREPARE DATA ------------------------------------

data <- read_csv(
  input_file,
  show_col_types = FALSE
) |>
  mutate(
    treatment_group = as.numeric(treatment_group),
    post = as.numeric(post),
    treatment_post = treatment_group * post,
    county = as.factor(county),
    gender = as.factor(gender),
    beneficiary_id = as.character(beneficiary_id)
  )

if (!"beneficiary_id" %in% names(data)) {
  stop("The beneficiary_id column is missing.")
}

if (any(is.na(data$beneficiary_id))) {
  stop("Missing beneficiary_id values detected.")
}


# 4. DEFINE OUTCOME VARIABLES ---------------------------------

outcomes <- c(
  "crop_yield_kg_per_acre",
  "monthly_household_income_kes",
  "climate_smart_practices_adopted",
  "food_security_score"
)

missing_outcomes <- setdiff(outcomes, names(data))

if (length(missing_outcomes) > 0) {
  stop(
    "The following outcome variables are missing: ",
    paste(missing_outcomes, collapse = ", ")
  )
}


# 5. DESCRIPTIVE ANALYSIS -------------------------------------

descriptive <- data |>
  group_by(programme_group, survey_wave) |>
  summarise(
    n_records = n(),
    across(
      all_of(outcomes),
      ~ mean(.x, na.rm = TRUE)
    ),
    .groups = "drop"
  )

write_csv(
  descriptive,
  file.path(output_dir, "R_descriptive_results.csv")
)


# 6. DIFFERENCE-IN-DIFFERENCES: HC1 ROBUST STANDARD ERRORS ----

# Model:
# Outcome = Treatment + Post + Treatment x Post
#           + County fixed effects + Error
#
# The interaction coefficient estimates the additional
# change in the treatment group relative to the comparison
# group.

did_results <- lapply(outcomes, function(y) {

  model_data <- data |>
    filter(
      !is.na(.data[[y]]),
      !is.na(treatment_group),
      !is.na(post),
      !is.na(county)
    )

  formula <- as.formula(
    paste0(y, " ~ treatment_group * post + county")
  )

  fit <- lm(
    formula,
    data = model_data
  )

  robust <- coeftest(
    fit,
    vcov. = vcovHC(fit, type = "HC1")
  )

  term <- "treatment_group:post"

  if (!term %in% rownames(robust)) {
    stop(paste("DiD interaction term missing for", y))
  }

  estimate <- unname(robust[term, 1])
  robust_se <- unname(robust[term, 2])

  data.frame(
    outcome = y,
    estimate = estimate,
    robust_se = robust_se,
    statistic = unname(robust[term, 3]),
    p_value = unname(robust[term, 4]),
    n = nobs(fit),
    interpretation = paste(
      "Treatment group's additional change",
      "relative to comparison group"
    )
  )

}) |>
  bind_rows()


# Calculate 95% confidence intervals using the normal
# approximation for HC1 robust standard errors.

did_results <- did_results |>
  mutate(
    ci_lower_95 = estimate - 1.96 * robust_se,
    ci_upper_95 = estimate + 1.96 * robust_se,
    statistically_significant_5pct = p_value < 0.05
  )

write_csv(
  did_results,
  file.path(
    output_dir,
    "R_difference_in_differences_results.csv"
  )
)


# 7. DIFFERENCE-IN-DIFFERENCES: CLUSTERED STANDARD ERRORS -----

# Standard errors are clustered by beneficiary_id to account
# for repeated observations of the same beneficiary.
#
# Cluster-based degrees of freedom:
# Number of clusters minus one.
#
# The p-values and confidence intervals below use the same
# cluster-based degrees of freedom.

clustered_did_results <- lapply(outcomes, function(y) {

  model_data <- data |>
    filter(
      !is.na(.data[[y]]),
      !is.na(treatment_group),
      !is.na(post),
      !is.na(county),
      !is.na(beneficiary_id)
    )

  formula <- as.formula(
    paste0(y, " ~ treatment_group * post + county")
  )

  fit <- lm(
    formula,
    data = model_data
  )

  term <- "treatment_group:post"

  if (!term %in% names(coef(fit))) {
    stop(paste("DiD interaction term missing for", y))
  }

  # Calculate beneficiary-clustered covariance matrix.
  clustered_vcov <- vcovCL(
    fit,
    cluster = model_data$beneficiary_id,
    type = "HC1"
  )

  # Extract the DiD coefficient and clustered standard error.
  estimate <- unname(coef(fit)[term])

  clustered_se <- sqrt(
    unname(clustered_vcov[term, term])
  )

  if (!is.finite(clustered_se) || clustered_se <= 0) {
    stop(paste("Invalid clustered standard error for", y))
  }

  # Calculate number of unique beneficiary clusters.
  clusters <- length(
    unique(model_data$beneficiary_id)
  )

  if (clusters < 2) {
    stop(paste("Insufficient clusters for", y))
  }

  # Calculate t-statistic.
  statistic <- estimate / clustered_se

  # Use cluster-based degrees of freedom consistently.
  cluster_df <- clusters - 1

  # Two-sided p-value.
  p_value <- 2 * pt(
    abs(statistic),
    df = cluster_df,
    lower.tail = FALSE
  )

  # 95% confidence interval.
  critical_value <- qt(
    0.975,
    df = cluster_df
  )

  ci_lower <- estimate - critical_value * clustered_se
  ci_upper <- estimate + critical_value * clustered_se

  data.frame(
    outcome = y,
    estimate = estimate,
    clustered_se = clustered_se,
    statistic = statistic,
    p_value = p_value,
    n = nobs(fit),
    clusters = clusters,
    degrees_of_freedom = cluster_df,
    ci_lower_95 = ci_lower,
    ci_upper_95 = ci_upper,
    statistically_significant_5pct = p_value < 0.05,
    interpretation = paste(
      "Treatment group's additional change",
      "relative to comparison group"
    )
  )

}) |>
  bind_rows()


# Export clustered DiD results.
write_csv(
  clustered_did_results,
  file.path(
    output_dir,
    "R_clustered_DiD_results.csv"
  )
)


# 8. MODEL DIAGNOSTICS ----------------------------------------

# Conventional OLS model diagnostics for crop yield.
# These diagnostics are descriptive model outputs and are
# not a substitute for the clustered inference above.

yield_model_data <- data |>
  filter(
    !is.na(crop_yield_kg_per_acre),
    !is.na(treatment_group),
    !is.na(post),
    !is.na(county)
  )

yield_model <- lm(
  crop_yield_kg_per_acre ~ treatment_group * post + county,
  data = yield_model_data
)

capture.output(
  summary(yield_model),
  file = file.path(
    output_dir,
    "R_yield_model_diagnostics.txt"
  )
)


# 9. DISPLAY RESULTS ------------------------------------------

cat("\n============================================\n")
cat("HC1 ROBUST DIFFERENCE-IN-DIFFERENCES RESULTS\n")
cat("============================================\n")

print(did_results)

cat("\n============================================\n")
cat("BENEFICIARY-CLUSTERED DiD RESULTS\n")
cat("============================================\n")

print(clustered_did_results)

cat("\n============================================\n")
cat("R ANALYSIS COMPLETED SUCCESSFULLY\n")
cat("============================================\n")

cat("\nResults saved in:", output_dir, "\n")
