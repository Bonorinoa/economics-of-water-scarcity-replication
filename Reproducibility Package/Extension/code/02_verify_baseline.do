version 19.5

if `"$EXT_SETUP_COMPLETE"' != "1" {
	do "Reproducibility Package/Extension/code/00_setup_prereqs.do"
}

ext_display_step "Verifying the replicated baseline specification"

capture program drop ext_run_baseline_check
program define ext_run_baseline_check, rclass
	syntax, usewindow(integer)

	use "$EXT_DATA/analysis_panel.dta", clear
	if `usewindow' == 1 {
		keep if analysis_window_1990_2020
	}

	gen Total_gr = GDP_gr
	reghdfe Total_gr WaterStress_p99 ln_total_water_withdrawal_pc lnGDP, absorb(id Year) vce(cluster id)

	return scalar beta = _b[WaterStress_p99]
	return scalar se = _se[WaterStress_p99]
	return scalar n = e(N)
	return scalar r2 = e(r2)
	return scalar p = 2 * ttail(e(df_r), abs(_b[WaterStress_p99] / _se[WaterStress_p99]))
end

quietly ext_run_baseline_check, usewindow(0)
scalar base_beta_full = r(beta)
scalar base_se_full = r(se)
scalar base_n_full = r(n)
scalar base_r2_full = r(r2)
scalar base_p_full = r(p)

quietly ext_run_baseline_check, usewindow(1)
scalar base_beta_window = r(beta)
scalar base_se_window = r(se)
scalar base_n_window = r(n)
scalar base_r2_window = r(r2)
scalar base_p_window = r(p)

scalar target_beta = -0.102
scalar target_se = 0.0388
scalar target_n = 4583
scalar rel_gap_window = abs(base_beta_window - target_beta) / abs(target_beta)

postutil clear
tempname baselinepost
postfile `baselinepost' str24 sample double beta_scarcity se_scarcity n_obs r_squared p_value rel_gap_vs_target using "$EXT_RESULTS_RAW/baseline_verification.dta", replace
post `baselinepost' ("all_years") (base_beta_full) (base_se_full) (base_n_full) (base_r2_full) (base_p_full) (abs(base_beta_full - target_beta) / abs(target_beta))
post `baselinepost' ("1990_2020") (base_beta_window) (base_se_window) (base_n_window) (base_r2_window) (base_p_window) (rel_gap_window)
postclose `baselinepost'

use "$EXT_RESULTS_RAW/baseline_verification.dta", clear
export delimited using "$EXT_RESULTS_RAW/baseline_verification.csv", replace

file open baseline_tex using "$EXT_TABLES/baseline_verification.tex", write replace text
file write baseline_tex "\begin{table}[htbp]" _n
file write baseline_tex "\centering" _n
file write baseline_tex "\caption{Baseline verification for the water scarcity extension}" _n
file write baseline_tex "\label{tab:baseline}" _n
file write baseline_tex "\small" _n
file write baseline_tex "\begin{tabular}{lcccc}" _n
file write baseline_tex "\toprule" _n
file write baseline_tex "Sample & Beta & SE & Observations & R-squared \\\\" _n
file write baseline_tex "\midrule" _n
forvalues i = 1/`=_N' {
	local sample_label = sample[`i']
	if "`sample_label'" == "all_years" local sample_label "All years"
	if "`sample_label'" == "1990_2020" local sample_label "1990--2020 window"
	file write baseline_tex `"`sample_label' & `=string(beta_scarcity[`i'],"%9.4f")' & `=string(se_scarcity[`i'],"%9.4f")' & `=string(n_obs[`i'],"%9.0fc")' & `=string(r_squared[`i'],"%9.3f")' \\\\"' _n
}
file write baseline_tex "\bottomrule" _n
file write baseline_tex "\multicolumn{5}{p{0.92\textwidth}}{\footnotesize Notes: The target replication benchmark is Table 3, column (3) of Frost, Mart\'inez Jaramillo and Madeira (2025): beta = -0.102, SE = 0.0388 and N = 4,583.}" _n
file write baseline_tex "\end{tabular}" _n
file write baseline_tex "\end{table}" _n
file close baseline_tex

if rel_gap_window > 0.10 | base_n_window != target_n {
	display as error "1990-2020 baseline beta = " %9.4f base_beta_window ", target = -0.102"
	display as error "1990-2020 baseline N = " %9.0f base_n_window ", target = 4,583"
	ext_abort "the 1990-2020 analysis window does not preserve the published baseline within tolerance"
}

global EXT_BASELINE_BETA = base_beta_window
global EXT_BASELINE_SE = base_se_window
global EXT_BASELINE_N = base_n_window
global EXT_BASELINE_R2 = base_r2_window

ext_display_step "Baseline verification passed for the 1990-2020 extension sample"
