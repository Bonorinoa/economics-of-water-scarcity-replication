Proposed Extension: Internal Meta-Analysis of the Water Scarcity–GDP Growth Estimate

Focal Metric
The coefficient on freshwater withdrawal (% of available freshwater) in the GDP growth equation: β = −0.102* (Table 3, column 3, p. 15). This is the authors' most statistically significant estimate of how water scarcity associates with economic growth, estimated via two-way fixed effects on a panel of 169 countries (1990–2020).

Analysis Design
Following Banzhaf and Smith (2007), the extension conducts an internal meta-analysis of this focal estimate across two dimensions of modeling decisions, generating approximately 120 specifications.

Dimension 1 — Functional form (5 specifications × 3 scarcity measures = 15 configurations):

The authors impose a linear relationship between scarcity and growth, but their own quantile results (Table A.4) show the effect is strongest at the 25th percentile—suggesting the linear assumption may be misspecified. We test:

Linear (baseline)
Quadratic (adding scarcity²)
Scarcity × log GDP per capita interaction (does development buffer the effect?)
Scarcity × log water use per capita interaction (does heavy use amplify the drag?)
Piecewise threshold at median scarcity (does the effect switch on above a critical level?)

Each is estimated with all three of the authors' scarcity measures: freshwater withdrawal as a share of (a) internal resources, (b) total renewable resources, and (c) available freshwater.
Dimension 2 — Estimator choice (8 estimators):
The authors use two-way FE as their main estimator and panel quantile as a robustness check, but never systematically compare across the estimator space. We estimate each functional-form configuration with:

Country FE only (no year FE)
Two-way FE — country + year (the baseline)
Random effects (+ Hausman test against FE)
Between estimator (cross-country variation only)
First-differenced OLS
Machado–Santos Silva panel quantile at Q25, Q50, Q75

Meta-Regression
We collect all ~120 β̂ estimates and their standard errors, then estimate:
β̂_s = γ₀ + γ₁·1(quadratic) + γ₂·1(interaction_income) + γ₃·1(interaction_use) + γ₄·1(threshold) + γ₅·1(internal_resources) + γ₆·1(renewable_resources) + γ₇·1(country_FE_only) + γ₈·1(RE) + γ₉·1(between) + γ₁₀·1(first_diff) + γ₁₁·1(Q25) + γ₁₂·1(Q50) + γ₁₃·1(Q75) + ε_s
This identifies which modeling decisions systematically shift the estimated scarcity–growth relationship.
Supplementary Exercise: Shadow Price of Water
From the authors' Cobb-Douglas (Equation 1, p. 13), the marginal product of water is ∂Y/∂W = (1−α−θ) · (Y/W) · 1/(1+WS). We compute this at observed data points for the 20 OECD countries where actual water prices are available (Graph 6 / Table A.3, from OECD 2010) and compare implied shadow prices to market prices. This connects the production-function estimates to the paper's pricing discussion (Section 5) and provides a revealed-preference perspective on water underpricing.
Deliverables

Specification curve (forest plot) of all ~120 β̂ estimates
Summary table of the estimate distribution (mean, median, IQR, share significant)
Meta-regression table (analogous to Banzhaf & Smith 2007, Table VI)
Shadow price figure: implied marginal product of water vs. observed OECD prices