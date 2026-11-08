import sys
from pathlib import Path
import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "src"))
from pipeline import validate_and_clean, build_summaries

def sample():
    return pd.DataFrame([
        {"beneficiary_id":"B1","county":"bungoma","treatment_group":1,"survey_wave":"Baseline","age":30,"gender":"Female","land_size_acres":1.2,"crop_yield_kg_per_acre":800,"monthly_household_income_kes":9000,"climate_smart_practices_adopted":2,"food_security_score":3.0,"training_sessions_attended":2,"survey_date":"2025-02-15"},
        {"beneficiary_id":"B1","county":"bungoma","treatment_group":1,"survey_wave":"Baseline","age":30,"gender":"Female","land_size_acres":1.2,"crop_yield_kg_per_acre":800,"monthly_household_income_kes":9000,"climate_smart_practices_adopted":2,"food_security_score":3.0,"training_sessions_attended":2,"survey_date":"2025-02-15"},
        {"beneficiary_id":"B1","county":"bungoma","treatment_group":1,"survey_wave":"Endline","age":30,"gender":"Female","land_size_acres":1.2,"crop_yield_kg_per_acre":1100,"monthly_household_income_kes":11000,"climate_smart_practices_adopted":4,"food_security_score":4.0,"training_sessions_attended":4,"survey_date":"2026-02-15"},
    ])

def test_duplicate_records_removed():
    clean, meta = validate_and_clean(sample())
    assert len(clean) == 2
    assert meta["duplicate_beneficiary_wave_records_removed"] == 1

def test_wave_indicator_created():
    clean, _ = validate_and_clean(sample())
    assert clean.loc[clean.survey_wave == "Baseline", "post"].iloc[0] == 0
    assert clean.loc[clean.survey_wave == "Endline", "post"].iloc[0] == 1

def test_county_standardised():
    clean, _ = validate_and_clean(sample())
    assert set(clean.county) == {"Bungoma"}

def test_summary_groups_are_created():
    clean, _ = validate_and_clean(sample())
    summary, participation = build_summaries(clean)
    assert len(summary) == 2
    assert "beneficiary_records" in participation.columns
