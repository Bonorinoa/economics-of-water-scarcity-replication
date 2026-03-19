# The Economics of Water Scarcity: Replication Repository

This repository contains our working replication of Frost, Martinez Jaramillo, and Madeira, *The Economics of Water Scarcity*.

## Status

- The Stata replication is working on macOS and produces the expected code-generated outputs.
- The Python package is **not** yet a full reimplementation of the paper. It currently provides a stage registry and a documented-parity verifier for the Stata outputs.
- Graph 6 is not code-generated in the public package and must still be reconstructed manually from the OECD figures referenced by the authors.

## What Is Included

- The patched Stata replication package under [Reproducibility Package](/Users/bonorinoa/Desktop/ECN726/TermProject_2/Reproducibility%20Package)
- macOS run helpers and setup docs under [docs](/Users/bonorinoa/Desktop/ECN726/TermProject_2/docs)
- the Python verification scaffold under [python_replication](/Users/bonorinoa/Desktop/ECN726/TermProject_2/python_replication)

## What Is Not Included In Git

To keep this repository GitHub-safe and lightweight, the following are not versioned:

- raw input datasets in `Reproducibility Package/Data/`
- generated outputs in `Reproducibility Package/Outputs/`
- local logs, caches, and temporary files

This is intentional. Some files in the original package exceed GitHub's normal file-size limits for regular git pushes. See [About large files on GitHub](https://docs.github.com/en/enterprise-cloud@latest/repositories/working-with-files/managing-large-files/about-large-files-on-github).

## Repository Layout

- [Reproducibility Package](/Users/bonorinoa/Desktop/ECN726/TermProject_2/Reproducibility%20Package): Stata code, vendored ado dependencies, and the expected `Data/` and `Outputs/` directories
- [docs/mac_stata_setup.md](/Users/bonorinoa/Desktop/ECN726/TermProject_2/docs/mac_stata_setup.md): step-by-step macOS Stata setup and execution notes
- [python_replication](/Users/bonorinoa/Desktop/ECN726/TermProject_2/python_replication): Python oracle/verifier scaffold
- [README.pdf](/Users/bonorinoa/Desktop/ECN726/TermProject_2/README.pdf): authors' original package README
- [reproducibility_report_RR_WLD_2025_440.pdf](/Users/bonorinoa/Desktop/ECN726/TermProject_2/reproducibility_report_RR_WLD_2025_440.pdf): World Bank reproducibility report

## Data Setup

### Recommended path

The easiest way to restore the ignored data is to download the official World Bank reproducibility package zip and copy its `Data/` directory into this repository.

1. Download the official package zip: [RR_WLD_2025_440.zip](https://reproducibility.worldbank.org/catalog/393/download/1115/RR_WLD_2025_440.zip)
2. Extract it.
3. Copy the extracted `Data/` folder into:

```text
/Users/bonorinoa/Desktop/ECN726/TermProject_2/Reproducibility Package/Data/
```

After that, these subdirectories should exist:

- `Reproducibility Package/Data/CSV`
- `Reproducibility Package/Data/Excel`
- `Reproducibility Package/Data/Stata`

### Direct source links

If someone wants to rebuild the `Data/` directory manually from source portals, these are the authoritative sources referenced by the public reproducibility package:

- Official package page: [World Bank reproducibility catalog entry](https://reproducibility.worldbank.org/index.php/catalog/393)
- AQUASTAT: [FAO AQUASTAT](https://data.apps.fao.org/aquastat/?lang=en)
- FRED CPIAUCSL: [FRED CPIAUCSL series](https://fred.stlouisfed.org/series/CPIAUCSL)
- SDG 6 portal: [UN-Water SDG 6 Data Portal](https://sdg6data.org/)
- UN population projections: [World Population Prospects 2024 downloads](https://population.un.org/wpp/downloads?folder=Standard%20Projections&group=Most%20used)
- Penn World Table 10.01: [PWT 10.01](https://www.rug.nl/ggdc/productivity/pwt/pwt-releases/pwt1001)
- Penn World Table 9.1: [PWT 9.1](https://www.rug.nl/ggdc/productivity/pwt/pwt-releases/pwt9.1)
- UNIDO source portal: [UNIDO Statistics Portal](https://stat.unido.org/)
- World Development Indicators: [World Development Indicators DataBank](https://databank.worldbank.org/id/6a38c2ce)
- Worldwide Governance Indicators: [Worldwide Governance Indicators](https://www.worldbank.org/en/publication/worldwide-governance-indicators)

Two files in the package are author-compiled or tied to the original bundled release and are best restored from the official zip, not rebuilt manually:

- `Reproducibility Package/Data/Stata/CountryDataMatching_vs0.dta`
- `Reproducibility Package/Data/Excel/ISO 3166 Codes.xlsx`

The legacy UNIDO files used by the package are also best restored from the official zip, because the exact download used by the authors has since been discontinued from the public portal:

- `Reproducibility Package/Data/Excel/INDSTAT2 national_currency.xlsx`
- `Reproducibility Package/Data/Excel/INDSTAT2 national_currency metadata.xlsx`

## Stata Replication

### First-time setup

1. Install Stata 19 for macOS.
2. Open the Stata GUI once.
3. In Stata, run:

```stata
ssc install moremata
do "/Users/bonorinoa/Desktop/ECN726/TermProject_2/Reproducibility Package/Codes/verify_stata_environment_mac.do"
```

4. Then run the full driver from the Stata GUI:

```stata
do "/Users/bonorinoa/Desktop/ECN726/TermProject_2/Reproducibility Package/Codes/Main_WaterScarcity_FMM_2025_mac.do"
```

Detailed setup notes are in [mac_stata_setup.md](/Users/bonorinoa/Desktop/ECN726/TermProject_2/docs/mac_stata_setup.md).

### Expected output location

The Stata run writes generated files under:

- `Reproducibility Package/Outputs/`
- `Reproducibility Package/Outputs/tables/`
- `Reproducibility Package/Outputs/graphs/`
- `Reproducibility Package/Outputs/StataData_other/`

Figure 5 is exported to the `Outputs/` root. Graph 6 is not generated by code in the public package.

## Python Verification Workflow

The Python package is currently a verifier and staging scaffold, not a full replication of the paper.

### Install

```bash
cd /Users/bonorinoa/Desktop/ECN726/TermProject_2/python_replication
python3 -m pip install -e .
```

### Run the documented-parity verifier

```bash
cd /Users/bonorinoa/Desktop/ECN726/TermProject_2
PYTHONPATH=/Users/bonorinoa/Desktop/ECN726/TermProject_2/python_replication \
python3 -m water_scarcity.verify \
  --standard documented-parity \
  --json-out parity_report.json \
  --md-out parity_report.md
```

This checks that the generated Stata outputs exist, are structurally readable, and match the documented artifact inventory from the package README and the World Bank reproducibility report.

## What Has Been Verified

- The patched Stata package runs successfully on macOS.
- The generated Stata output inventory passes the Python documented-parity verifier.
- The verifier explicitly handles known documentation anomalies such as filename mismatches in the World Bank report and the intentional absence of Graph 6.

## What Has Not Been Verified

- A full Python reproduction of the Stata econometric pipeline
- Numerical equivalence between a Python reimplementation and the Stata estimates
- Automatic reconstruction of Graph 6

## Replicated Methodology

At a high level, the package does the following:

1. Harmonizes public data from AQUASTAT, SDG 6, Penn World Table, World Development Indicators, Worldwide Governance Indicators, UN population projections, UNIDO industrial statistics, and author-compiled country mappings.
2. Constructs water scarcity, freshwater withdrawal, productivity, inflation, growth, sectoral composition, and electricity variables.
3. Produces descriptive figures and summary tables.
4. Estimates panel regressions with country and year fixed effects, mainly using `reghdfe`.
5. Estimates quantile panel regressions for appendix robustness tables using `xtqreg`.
6. Produces a 2050 water-demand projection exercise based on population and income-related inputs.

## Complexity

This is a moderate-to-high complexity replication:

- multi-source international data harmonization
- a nontrivial Stata workflow with multiple formatting and regression stages
- vendored Stata dependencies in `ado/`
- platform portability issues between Windows and macOS
- partial manual post-processing in the public paper workflow

The Stata pipeline is runnable. The Python package is useful today for verification, but a full Python translation remains a separate project.
