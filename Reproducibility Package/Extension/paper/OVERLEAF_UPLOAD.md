Upload these items to Overleaf while preserving the `figures/` and `tables/` folder names:

- `paper/draft.tex`
- `figures/specification_curve.png`
- `figures/shadow_price_proxy.png`
- `tables/estimate_distribution.tex`
- `tables/meta_regression.tex`

If you flatten the project instead, update these paths in `draft.tex`:

- `../figures/specification_curve.png`
- `../figures/shadow_price_proxy.png`
- `../tables/estimate_distribution.tex`
- `../tables/meta_regression.tex`

The Stata pipeline intentionally writes `draft.tex` even when no local LaTeX engine is installed.
