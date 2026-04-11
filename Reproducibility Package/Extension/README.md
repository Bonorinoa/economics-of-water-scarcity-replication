# Water Scarcity Extension Module

This folder contains a Stata-only extension to the replication package for Frost, Madeira, and Martinez Jaramillo, "The Economics of Water Scarcity." The extension asks a narrow but important robustness question: how stable is the paper's headline GDP-growth coefficient on water scarcity when the analyst varies economically motivated functional forms and alternative panel estimators?

The extension is designed as a single-entry replication module. From the repository root, the intended command in Stata is:

```stata
do "Reproducibility Package/Extension/code/run_extension.do"
```

That command runs the full extension workflow in sequence:

1. Checks paths, vendored ado dependencies, and prerequisite formatted datasets.
2. Rebuilds the minimum formatted inputs only if they are missing and the raw data exist locally.
3. Constructs the extension analysis panel.
4. Verifies the published baseline GDP-growth regression.
5. Runs the full specification grid.
6. Estimates the internal meta-regression.
7. Exports tables and figures.
8. Writes the extension paper draft.

## Data Requirements

This extension reuses the same raw replication inputs as the main project. The raw `Data/` folder is intentionally not versioned in git.

For setup instructions, use the repository-level [README.md](../../README.md). In particular, the official World Bank reproducibility package should be restored under:

```text
./Reproducibility Package/Data/
```

The extension then works from the formatted datasets created by the original replication code:

- `Data_WB.dta`
- `Aquastat_Selected.dta`
- `WGI.dta`
- `PWT_new.dta`

## Theoretical Motivation

The original paper motivates the GDP-growth regression from a production framework in which water enters as a productive input and scarcity lowers effective productivity. The baseline empirical regression is a linear panel approximation to that structural idea. This extension does not claim to identify a new causal effect. Instead, it evaluates whether the estimated scarcity-growth relationship is robust to plausible modeling choices that are still consistent with the paper's economic logic.

Two broad concerns motivate the extension:

- Functional-form uncertainty: if scarcity becomes more damaging at high stress levels, or if richer economies buffer scarcity differently, a linear specification may hide important heterogeneity.
- Estimator uncertainty: if the effect is driven by within-country variation rather than between-country cross sections, alternative panel estimators may move the coefficient materially.

This is therefore an internal meta-analysis of model space, not a new structural or quasi-experimental identification strategy.

## Econometric Design

The extension centers the Table 3, column 3 GDP-growth coefficient on freshwater withdrawal as a share of available freshwater. It first reconstructs the paper's panel logic and then estimates a full grid of:

- 3 scarcity measures:
  - withdrawal as a share of internal renewable resources
  - withdrawal as a share of total renewable resources
  - withdrawal as a share of available freshwater
- 5 functional forms:
  - linear
  - quadratic
  - interaction with log GDP per capita
  - interaction with log water withdrawal per capita
  - threshold above the within-sample median scarcity level
- 8 estimators:
  - country fixed effects only
  - two-way fixed effects
  - random effects
  - between estimator
  - first differences
  - panel quantile regression at the 25th percentile
  - panel quantile regression at the 50th percentile
  - panel quantile regression at the 75th percentile

That yields `3 x 5 x 8 = 120` planned specifications.

Across all specifications, the extension preserves the paper's core empirical ingredients:

- the dependent variable is annual GDP growth
- the main controls are log total water withdrawal per capita and log GDP per capita
- scarcity measures are capped at 100
- the same regressors are winsorized at the 99th percentile before logs where applicable

The extension then runs a meta-regression on the estimated scarcity coefficients. The omitted categories are:

- linear functional form
- available-freshwater scarcity measure
- two-way fixed effects

This makes the meta-regression coefficients easy to interpret as average shifts away from the authors' baseline design.

## What The Module Produces

The single-entry Stata command is currently expected to produce the following main artifacts.

Code:

- `code/run_extension.do`
- modular `.do` files for setup, panel construction, baseline verification, specification grid estimation, meta-regression, figures, and paper writing

Constructed analysis data:

- `data/analysis_panel.dta`
- `data/analysis_panel.csv`

Model-space results:

- `results/meta_analysis_results.dta`
- `results/meta_analysis_results.csv`
- supporting raw outputs under `results/raw/`

Reviewer-facing tables:

- `tables/baseline_verification.tex`
- `tables/estimate_distribution.tex`
- `tables/meta_regression.tex`

Reviewer-facing figures:

- `figures/specification_curve.png`
- `figures/specification_curve.pdf`
- `figures/shadow_price_proxy.png`
- `figures/shadow_price_proxy.pdf`

Paper outputs:

- `paper/draft.tex`
- `paper/draft.pdf` if a local LaTeX engine is available
- `paper/OVERLEAF_UPLOAD.md` with the minimal upload instructions

Logs:

- `logs/run_extension.log`
- optional batch smoke-test logs if batch mode is used locally

## Current Empirical Status

At the time this module was prepared, the extension reproduced the published baseline on the 1990--2020 extension sample and completed the full 120-specification grid without failed estimates. The generated draft, tables, and figures are therefore not placeholders; they reflect a full run of the current Stata workflow.

The main interpretive takeaway is that the sign of the scarcity-growth relationship is generally robust, while the magnitude is sensitive to modeling choices. Nonlinear forms and lower-tail quantile specifications tend to make the scarcity coefficient more negative, whereas estimators that place more weight on between-country variation tend to attenuate it.

## Limitations And Transparency Notes

- The extension is transparent about remaining endogeneity concerns. Reverse causality and omitted variables are discussed explicitly in the draft.
- The shadow-price figure is a diagnostic, not a structural estimate. It uses a normalization for the water-share term because the source paper does not pin that parameter down in a way that can be directly carried into the extension.
- The extension depends on the original replication package's local Stata environment and vendored ado files, so it should be run from the repository root with the existing directory structure unchanged.

## Recommended Commit Surface

For version control, the intended tracked extension artifacts are:

- `code/`
- `figures/`
- `tables/`
- `paper/draft.tex`
- `paper/OVERLEAF_UPLOAD.md`
- `Reference/`
- this `README.md`

Large constructed datasets, logs, and local temporary files should remain untracked.
