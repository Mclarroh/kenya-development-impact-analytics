from pathlib import Path
import json
import pandas as pd

ROOT = Path(__file__).resolve().parents[2]
RAW = ROOT / "data" / "raw" / "beneficiary_survey.csv"
OUT = ROOT / "outputs"

REQUIRED = [
    "beneficiary_id", "county", "treatment_group", "survey_wave", "age",
    "gender", "land_size_acres", "crop_yield_kg_per_acre",
    "monthly_household_income_kes", "climate_smart_practices_adopted",
    "food_security_score", "training_sessions_attended", "survey_date"
]

def load_data(path=RAW):
    return pd.read_csv(path)

def validate_and_clean(df):
    missing_columns = sorted(set(REQUIRED) - set(df.columns))
    if missing_columns:
        raise ValueError(f"Missing required columns: {missing_columns}")

    clean = df.copy()
    clean["survey_date"] = pd.to_datetime(clean["survey_date"], errors="coerce")
    clean["treatment_group"] = pd.to_numeric(clean["treatment_group"], errors="coerce")
    clean["age"] = pd.to_numeric(clean["age"], errors="coerce")
    clean["land_size_acres"] = pd.to_numeric(clean["land_size_acres"], errors="coerce")

    # Keep the first record for each beneficiary-wave combination.
    duplicate_count = int(clean.duplicated(["beneficiary_id", "survey_wave"]).sum())
    clean = clean.drop_duplicates(["beneficiary_id", "survey_wave"], keep="first")

    # Standardise categories.
    clean["county"] = clean["county"].astype("string").str.strip().str.title()
    clean["survey_wave"] = clean["survey_wave"].astype("string").str.strip().str.title()
    clean["gender"] = clean["gender"].astype("string").str.strip().str.title()

    # Flag implausible values; set them to missing rather than silently retaining them.
    ranges = {
        "age": (18, 100),
        "land_size_acres": (0, 50),
        "crop_yield_kg_per_acre": (0, 20000),
        "monthly_household_income_kes": (0, 1000000),
        "climate_smart_practices_adopted": (0, 8),
        "food_security_score": (1, 5),
        "training_sessions_attended": (0, 8),
    }
    range_issues = {}
    for col, (low, high) in ranges.items():
        bad = ~clean[col].between(low, high) & clean[col].notna()
        range_issues[col] = int(bad.sum())
        clean.loc[bad, col] = pd.NA

    clean["post"] = (clean["survey_wave"] == "Endline").astype(int)
    clean["treatment_group"] = clean["treatment_group"].where(
        clean["treatment_group"].isin([0, 1]), pd.NA
    )
    clean["programme_group"] = clean["treatment_group"].map({0: "Comparison", 1: "Treatment"})
    clean["yield_per_acre"] = clean["crop_yield_kg_per_acre"]

    metadata = {
        "input_rows": int(len(df)),
        "output_rows": int(len(clean)),
        "duplicate_beneficiary_wave_records_removed": duplicate_count,
        "range_issues_by_variable": range_issues,
        "missing_values_by_variable": {k: int(v) for k, v in clean.isna().sum().items()},
    }
    return clean, metadata

def build_summaries(clean):
    outcome_cols = [
        "crop_yield_kg_per_acre", "monthly_household_income_kes",
        "climate_smart_practices_adopted", "food_security_score"
    ]
    summary = (clean.groupby(["county", "programme_group", "survey_wave"], dropna=False)[outcome_cols]
               .mean().reset_index())
    participation = (clean.groupby(["county", "programme_group", "survey_wave"])
                     .agg(beneficiary_records=("beneficiary_id", "count"),
                          mean_training_sessions=("training_sessions_attended", "mean"))
                     .reset_index())
    return summary, participation

def run_pipeline():
    OUT.mkdir(exist_ok=True)
    raw = load_data()
    clean, metadata = validate_and_clean(raw)
    summary, participation = build_summaries(clean)
    clean.to_csv(OUT / "cleaned_beneficiary_survey.csv", index=False)
    summary.to_csv(OUT / "descriptive_summary.csv", index=False)
    participation.to_csv(OUT / "participation_summary.csv", index=False)
    (OUT / "data_quality_report.json").write_text(json.dumps(metadata, indent=2))
    print(f"Pipeline complete: {len(clean):,} clean records written to {OUT}")
    return clean, metadata

if __name__ == "__main__":
    run_pipeline()
