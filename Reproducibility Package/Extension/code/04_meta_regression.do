version 19.5

if `"$EXT_SETUP_COMPLETE"' != "1" {
	do "Reproducibility Package/Extension/code/00_setup_prereqs.do"
}

ext_display_step "Estimating the AME-based internal meta-regression"

use "$EXT_RESULTS/meta_analysis_results.dta", clear
keep if status == "success"

reg ame_scarcity ///
	d_quadratic ///
	d_interaction_income ///
	d_interaction_use ///
	d_threshold ///
	d_internal ///
	d_renewable ///
	d_no_year_fe ///
	d_re ///
	d_between ///
	d_first_diff ///
	d_q25 ///
	d_q50 ///
	d_q75, vce(robust)

estimates store ext_meta_reg_ame

postutil clear
tempname meta_post
postfile `meta_post' str32 term str16 category double coef se t_stat p_value ci_low ci_high using "$EXT_RESULTS_RAW/meta_regression_coefficients_ame.dta", replace

local terms "_cons d_quadratic d_interaction_income d_interaction_use d_threshold d_internal d_renewable d_no_year_fe d_re d_between d_first_diff d_q25 d_q50 d_q75"
foreach term of local terms {
	local coef = _b[`term']
	local se = _se[`term']
	local tstat = `coef' / `se'
	local pvalue = 2 * ttail(e(df_r), abs(`tstat'))
	local ci_low = `coef' - invttail(e(df_r), 0.025) * `se'
	local ci_high = `coef' + invttail(e(df_r), 0.025) * `se'
	local category = "baseline"
	if inlist("`term'", "d_quadratic", "d_interaction_income", "d_interaction_use", "d_threshold") local category = "functional_form"
	if inlist("`term'", "d_internal", "d_renewable") local category = "scarcity_measure"
	if inlist("`term'", "d_no_year_fe", "d_re", "d_between", "d_first_diff", "d_q25", "d_q50", "d_q75") local category = "estimator"
	post `meta_post' ("`term'") ("`category'") (`coef') (`se') (`tstat') (`pvalue') (`ci_low') (`ci_high')
}
postclose `meta_post'

use "$EXT_RESULTS_RAW/meta_regression_coefficients_ame.dta", clear
export delimited using "$EXT_RESULTS_RAW/meta_regression_coefficients_ame.csv", replace

file open meta_tex using "$EXT_TABLES/meta_regression_ame.tex", write replace text
file write meta_tex "\begin{table}[htbp]" _n
file write meta_tex "\centering" _n
file write meta_tex "\caption{AME-based meta-regression of water scarcity estimates}" _n
file write meta_tex "\label{tab:meta_ame}" _n
file write meta_tex "\small" _n
file write meta_tex "\begin{tabular}{lcc}" _n
file write meta_tex "\hline" _n
file write meta_tex "Variable & Coefficient & Robust SE \\\\" _n
file write meta_tex "\hline" _n
forvalues i = 1/`=_N' {
	local label = term[`i']
	if "`label'" == "_cons" local label "Constant"
	if "`label'" == "d_quadratic" local label "Quadratic form"
	if "`label'" == "d_interaction_income" local label "Scarcity x log GDP per capita"
	if "`label'" == "d_interaction_use" local label "Scarcity x log water use"
	if "`label'" == "d_threshold" local label "Threshold form"
	if "`label'" == "d_internal" local label "Internal scarcity measure"
	if "`label'" == "d_renewable" local label "Renewable scarcity measure"
	if "`label'" == "d_no_year_fe" local label "No year fixed effects"
	if "`label'" == "d_re" local label "Random effects"
	if "`label'" == "d_between" local label "Between estimator"
	if "`label'" == "d_first_diff" local label "First differences"
	if "`label'" == "d_q25" local label "Quantile 0.25"
	if "`label'" == "d_q50" local label "Quantile 0.50"
	if "`label'" == "d_q75" local label "Quantile 0.75"
	file write meta_tex `"`label' & `=string(coef[`i'],"%9.4f")' & `=string(se[`i'],"%9.4f")' \\\\"' _n
}
file write meta_tex "\hline" _n
file write meta_tex "\multicolumn{3}{p{0.9\textwidth}}{\footnotesize Notes: OLS meta-regression with heteroskedasticity-robust standard errors. The dependent variable is the specification-level average marginal effect (AME) of water scarcity on GDP growth. The omitted categories are the linear functional form, the available-freshwater scarcity measure, and the two-way fixed-effects estimator. The no-year-fixed-effects dummy captures the country-FE-only shift relative to the two-way FE baseline, while the between and quantile coefficients are incremental deviations on top of that no-year-FE penalty.}" _n
file write meta_tex "\end{tabular}" _n
file write meta_tex "\end{table}" _n
file close meta_tex

scalar ext_meta_n = e(N)
scalar ext_meta_r2 = e(r2)

clear
set obs 2
gen str20 metric = ""
gen double value = .
replace metric = "observations" in 1
replace value = ext_meta_n in 1
replace metric = "r_squared" in 2
replace value = ext_meta_r2 in 2
save "$EXT_RESULTS_RAW/meta_regression_fit_ame.dta", replace
export delimited using "$EXT_RESULTS_RAW/meta_regression_fit_ame.csv", replace

ext_display_step "AME meta-regression outputs written to $EXT_TABLES/meta_regression_ame.tex"
