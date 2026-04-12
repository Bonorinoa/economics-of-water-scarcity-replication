# The Economics of Water Scarcity

This repo contains the Stata replication of [Frost, Martinez Jaramillo, and Madeira, *The Economics of Water Scarcity*](https://www.bis.org/publ/work1314.pdf) based off of their available [replication package](https://reproducibility.worldbank.org/catalog/393).

## How to run

Clone this repository and keep the directory structure unchanged.

From the cloned repository root, the code expects the official raw data package under:

```text
./Reproducibility Package/Data/
```

The easiest setup is:

1. Download the official World Bank reproducibility package zip: [RR_WLD_2025_440.zip](https://reproducibility.worldbank.org/catalog/393/download/1115/RR_WLD_2025_440.zip)
2. Extract it.
3. Copy the extracted `Data/` folder into:

```text
./Reproducibility Package/Data/
```

After that, these folders should contain the raw inputs:

- `Reproducibility Package/Data/CSV`
- `Reproducibility Package/Data/Excel`
- `Reproducibility Package/Data/Stata`

From the repository root, open Stata (I have StataSE 19) and run:

```stata
do "run_paper_replication_mac.do"
```

It sets the repository root dynamically and then runs the canonical Stata workflow in `Reproducibility Package/Codes/Main_WaterScarcity_FMM_2025_mac.do`.

## Where The Replicated Results Are

Tracked reviewer-facing outputs live here:

- figures: `Reproducibility Package/Outputs/graphs/*.png`
- tables: `Reproducibility Package/Outputs/tables/Table*.tex`
- comparison PDF: `Reproducibility Package/paper_order_replication.pdf`

The tracked figure set is:

- `Fig1_water_pc.png`
- `Fig2_daily_water_use_per_capita.png`
- `Fig3_WaterStress_SectorsSDG.png`
- `Fig4_WaterStress_WB.png`
- `Fig5_WaterStress_2000_2020_WB.png`
- `Fig6_OECD_WaterPrices.png`
- `FigA1_USDm3.png`
- `FigA2_USDm3_Sectors.png`

The tracked table set is:

- `Table1.tex` through `Table8.tex`
- `TableA1.tex` through `TableA7.tex`

## What Is Ignored And Why

Ignored on purpose:

- `Reproducibility Package/Data/**`: raw downloaded data should be restored locally, not versioned in git
- `Reproducibility Package/Outputs/StataData_other/**`: large Stata intermediate datasets are scratch outputs, not reviewer-facing deliverables
- `Reproducibility Package/Outputs/tables/raw/**`: machine-oriented intermediate `.txt`, `.xls`, `.xlsx`, and `.csv` files used to assemble the final LaTeX tables
- logs, caches, and editor noise: local runtime artifacts only

## Authoritative Raw Sources

If someone wants to rebuild the `Data/` folder manually instead of restoring it from the official package zip, these are the source portals referenced by the public replication package:

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

These files are best restored from the official package zip instead of rebuilt manually:

- `Reproducibility Package/Data/Stata/CountryDataMatching_vs0.dta`
- `Reproducibility Package/Data/Excel/ISO 3166 Codes.xlsx`
- `Reproducibility Package/Data/Excel/INDSTAT2 national_currency.xlsx`
- `Reproducibility Package/Data/Excel/INDSTAT2 national_currency metadata.xlsx`
