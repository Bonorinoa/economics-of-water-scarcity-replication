# Python Replication Scaffold

This package is the Python translation scaffold for the Frost et al. water scarcity replication.

## Scope
- The Stata package remains the ground-truth implementation.
- The Python package is stage-mapped to the Stata workflow so each translation can be validated against Stata outputs before moving on.
- Graph 6 is intentionally excluded from automated parity because the public Stata package does not generate it.

## Quickstart
```bash
cd /Users/bonorinoa/Desktop/ECN726/TermProject_2/python_replication
python3 -m water_scarcity.run --stage all --manifest stage_manifest.json
python3 -m water_scarcity.run --stage format_unido --check-existing-outputs
python3 -m water_scarcity.verify --standard documented-parity --md-out parity_report.md --json-out parity_report.json
```

## Stage model
- Each Python stage module maps one-to-one to a Stata stage executed by the Mac driver.
- The CLI resolves the expected Stata script, declared dependencies, and expected output artifacts for each stage.
- `--check-existing-outputs` is designed for oracle validation after the Stata run has succeeded.
- `python3 -m water_scarcity.verify` validates the generated Stata outputs against the README/report artifact inventory and flags known documentation anomalies explicitly.

## Install
```bash
cd /Users/bonorinoa/Desktop/ECN726/TermProject_2/python_replication
python3 -m pip install -e .
```
