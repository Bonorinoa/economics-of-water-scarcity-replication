version 19.5

if `"$EXT_SETUP_COMPLETE"' != "1" {
	do "Reproducibility Package/Extension/code/00_setup_prereqs.do"
}

ext_display_step "Creating extension figures and appendix diagnostics"

use "$EXT_RESULTS/meta_analysis_results.dta", clear
keep if status == "success"
gen ci_low = ame_scarcity - 1.96 * ame_se
gen ci_high = ame_scarcity + 1.96 * ame_se
gsort ame_scarcity spec_id
gen spec_order = _n

quietly summarize spec_order if scarcity_measure == "available" & functional_form == "linear" & estimator == "two_way_fe", meanonly
local baseline_rank = r(mean)
scalar baseline_beta = $EXT_BASELINE_BETA

save "$EXT_RESULTS_RAW/spec_curve_data.dta", replace
export delimited using "$EXT_RESULTS_RAW/spec_curve_data.csv", replace

gen row_q75 = 1 if d_q75
gen row_q50 = 2 if d_q50
gen row_q25 = 3 if d_q25
gen row_first_diff = 4 if d_first_diff
gen row_between = 5 if d_between
gen row_re = 6 if d_re
gen row_country_fe_only = 7 if d_country_fe_only
gen row_no_year_fe = 8 if d_no_year_fe
gen row_renewable = 9 if d_renewable
gen row_internal = 10 if d_internal
gen row_threshold = 11 if d_threshold
gen row_interaction_use = 12 if d_interaction_use
gen row_interaction_income = 13 if d_interaction_income
gen row_quadratic = 14 if d_quadratic

local common_top ///
	graphregion(color(white)) ///
	plotregion(color(white)) ///
	xscale(range(1 120)) ///
	xlabel(1(10)120, labsize(small)) ///
	ytitle("Average marginal effect of scarcity") ///
	xtitle("Specification rank (sorted by AME)") ///
	yline(`=baseline_beta', lpattern(dash) lcolor(black)) ///
	xline(`baseline_rank', lpattern(shortdash) lcolor(gs8))

twoway ///
	(rcap ci_high ci_low spec_order, lcolor(gs12) lwidth(vthin)) ///
	(scatter ame_scarcity spec_order if estimator == "country_fe_only", msymbol(circle_hollow) msize(vsmall) mcolor(navy)) ///
	(scatter ame_scarcity spec_order if estimator == "two_way_fe", msymbol(circle) msize(vsmall) mcolor(maroon)) ///
	(scatter ame_scarcity spec_order if estimator == "random_effects", msymbol(diamond) msize(vsmall) mcolor(forest_green)) ///
	(scatter ame_scarcity spec_order if estimator == "between", msymbol(square) msize(vsmall) mcolor(teal)) ///
	(scatter ame_scarcity spec_order if estimator == "first_diff", msymbol(triangle) msize(vsmall) mcolor(orange)) ///
	(scatter ame_scarcity spec_order if estimator == "q25", msymbol(circle_hollow) msize(vsmall) mcolor(cranberry)) ///
	(scatter ame_scarcity spec_order if estimator == "q50", msymbol(diamond_hollow) msize(vsmall) mcolor(purple)) ///
	(scatter ame_scarcity spec_order if estimator == "q75", msymbol(square_hollow) msize(vsmall) mcolor(brown)), ///
	legend(order(2 "Country FE only" 3 "Two-way FE" 4 "Random effects" 5 "Between" 6 "First diff" 7 "Q25" 8 "Q50" 9 "Q75") rows(2) size(vsmall)) ///
	title("Specification curve for water scarcity AMEs") ///
	subtitle("120 AME estimates with 95% confidence intervals") ///
	xsize(11) ysize(3.8) ///
	`common_top' ///
	name(ext_fig_spec_curve, replace)

graph export "$EXT_FIGURES/fig_spec_curve.png", width(3300) replace
graph export "$EXT_FIGURES/fig_spec_curve.pdf", replace

twoway ///
	(scatter row_q75 spec_order if d_q75, msymbol(square) msize(tiny) mcolor(black)) ///
	(scatter row_q50 spec_order if d_q50, msymbol(square) msize(tiny) mcolor(black)) ///
	(scatter row_q25 spec_order if d_q25, msymbol(square) msize(tiny) mcolor(black)) ///
	(scatter row_first_diff spec_order if d_first_diff, msymbol(square) msize(tiny) mcolor(black)) ///
	(scatter row_between spec_order if d_between, msymbol(square) msize(tiny) mcolor(black)) ///
	(scatter row_re spec_order if d_re, msymbol(square) msize(tiny) mcolor(black)) ///
	(scatter row_country_fe_only spec_order if d_country_fe_only, msymbol(square) msize(tiny) mcolor(black)) ///
	(scatter row_no_year_fe spec_order if d_no_year_fe, msymbol(square) msize(tiny) mcolor(gs8)) ///
	(scatter row_renewable spec_order if d_renewable, msymbol(square) msize(tiny) mcolor(black)) ///
	(scatter row_internal spec_order if d_internal, msymbol(square) msize(tiny) mcolor(black)) ///
	(scatter row_threshold spec_order if d_threshold, msymbol(square) msize(tiny) mcolor(black)) ///
	(scatter row_interaction_use spec_order if d_interaction_use, msymbol(square) msize(tiny) mcolor(black)) ///
	(scatter row_interaction_income spec_order if d_interaction_income, msymbol(square) msize(tiny) mcolor(black)) ///
	(scatter row_quadratic spec_order if d_quadratic, msymbol(square) msize(tiny) mcolor(black)), ///
	graphregion(color(white)) ///
	plotregion(color(white)) ///
	xscale(range(1 120)) ///
	xlabel(1(10)120, labsize(small)) ///
	ylabel(1 "Q75" 2 "Q50" 3 "Q25" 4 "First diff" 5 "Between" 6 "RE" 7 "Country FE only" 8 "No year FE" 9 "Renewable" 10 "Internal" 11 "Threshold" 12 "Use interaction" 13 "Income interaction" 14 "Quadratic", angle(0) labsize(vsmall)) ///
	ytitle("") ///
	xtitle("Specification rank (sorted by AME)") ///
	xline(`baseline_rank', lpattern(shortdash) lcolor(gs8)) ///
	title("Decision matrix") ///
	subtitle("Filled squares mark active modeling choices") ///
	legend(off) ///
	xsize(11) ysize(3.2) ///
	name(ext_fig_decision_matrix, replace)

graph export "$EXT_FIGURES/fig_decision_matrix.png", width(3300) replace
graph export "$EXT_FIGURES/fig_decision_matrix.pdf", replace

graph combine ext_fig_spec_curve ext_fig_decision_matrix, rows(2) cols(1) imargin(0 0 0 0) xsize(11) ysize(7.2) name(ext_specification_curve, replace)
graph export "$EXT_FIGURES/specification_curve.png", width(3300) replace
graph export "$EXT_FIGURES/specification_curve.pdf", replace

quietly count if ame_scarcity < 0
local share_negative : display %4.1f 100 * r(N) / _N

histogram ame_scarcity, ///
	bin(25) percent ///
	fcolor(eltblue) lcolor(navy) ///
	graphregion(color(white)) ///
	plotregion(color(white)) ///
	xline(0, lpattern(dash) lcolor(maroon)) ///
	xtitle("Average marginal effect of scarcity") ///
	ytitle("Percent of specifications") ///
	title("Distribution of 120 AME estimates") ///
	subtitle("Negative share = `share_negative'%") ///
	xsize(7) ysize(3.5) ///
	name(ext_fig_histogram, replace)

graph export "$EXT_FIGURES/fig_histogram.png", width(2100) replace
graph export "$EXT_FIGURES/fig_histogram.pdf", replace

use "$EXT_RESULTS_RAW/meta_regression_coefficients_ame.dta", clear
drop if term == "_cons"
gen plot_order = .
replace plot_order = 1 if term == "d_quadratic"
replace plot_order = 2 if term == "d_interaction_income"
replace plot_order = 3 if term == "d_interaction_use"
replace plot_order = 4 if term == "d_threshold"
replace plot_order = 5 if term == "d_internal"
replace plot_order = 6 if term == "d_renewable"
replace plot_order = 7 if term == "d_no_year_fe"
replace plot_order = 8 if term == "d_re"
replace plot_order = 9 if term == "d_between"
replace plot_order = 10 if term == "d_first_diff"
replace plot_order = 11 if term == "d_q25"
replace plot_order = 12 if term == "d_q50"
replace plot_order = 13 if term == "d_q75"
sort plot_order

save "$EXT_RESULTS_RAW/meta_regression_coef_plot_data.dta", replace
export delimited using "$EXT_RESULTS_RAW/meta_regression_coef_plot_data.csv", replace

twoway ///
	(rcap ci_high ci_low plot_order if category == "functional_form", horizontal lcolor(navy)) ///
	(rcap ci_high ci_low plot_order if category == "scarcity_measure", horizontal lcolor(forest_green)) ///
	(rcap ci_high ci_low plot_order if category == "estimator", horizontal lcolor(maroon)) ///
	(scatter plot_order coef if category == "functional_form", msymbol(circle) msize(small) mcolor(navy)) ///
	(scatter plot_order coef if category == "scarcity_measure", msymbol(diamond) msize(small) mcolor(forest_green)) ///
	(scatter plot_order coef if category == "estimator", msymbol(square) msize(small) mcolor(maroon)), ///
	graphregion(color(white)) ///
	plotregion(color(white)) ///
	xline(0, lpattern(dash) lcolor(gs8)) ///
	ylabel(1 "Quadratic" 2 "Scarcity x log GDP pc" 3 "Scarcity x log water use" 4 "Threshold" 5 "Internal" 6 "Renewable" 7 "No year FE" 8 "Random effects" 9 "Between" 10 "First diff" 11 "Q25" 12 "Q50" 13 "Q75", angle(0) labsize(vsmall)) ///
	ytitle("") ///
	xtitle("Shift in AME relative to baseline category") ///
	title("AME meta-regression coefficients") ///
	subtitle("95% confidence intervals; omitted baseline is linear available-freshwater two-way FE") ///
	legend(order(4 "Functional form" 5 "Scarcity measure" 6 "Estimator") rows(1) size(vsmall)) ///
	xsize(7) ysize(5.5) ///
	name(ext_fig_coef_plot, replace)

graph export "$EXT_FIGURES/fig_coef_plot.png", width(2100) replace
graph export "$EXT_FIGURES/fig_coef_plot.pdf", replace

use "$EXT_DATA/analysis_panel.dta", clear
keep if analysis_window_1990_2020
gen double Total_gr = GDP_gr
gen double rhs_scarcity = WaterStress_p99
gen double rhs_use = ln_total_water_withdrawal_pc
gen double rhs_income = lnGDP
gen double rhs_aux1 = rhs_scarcity * rhs_income
keep if !missing(Total_gr, rhs_scarcity, rhs_use, rhs_income, rhs_aux1)
xtset id Year

capture noisily reghdfe Total_gr rhs_scarcity rhs_use rhs_income rhs_aux1, absorb(id Year) vce(cluster id)
if _rc {
	ext_abort "failed to estimate the income-interaction model for the marginal-effect plot"
}

tempvar income_sample
gen byte `income_sample' = e(sample)
quietly summarize rhs_income if `income_sample', detail
local income_p5 = r(p5)
local income_p10 = r(p10)
local income_p90 = r(p90)
local income_p95 = r(p95)

postutil clear
tempname me_post
tempfile me_results
postfile `me_post' double lnGDP marginal_effect se ci_low ci_high using "`me_results'", replace

local grid_points = 41
forvalues i = 0/40 {
	local x = `income_p5' + (`i' / (`grid_points' - 1)) * (`income_p95' - `income_p5')
	quietly lincom _b[rhs_scarcity] + (`x') * _b[rhs_aux1]
	local me = r(estimate)
	local me_se = r(se)
	local me_lo = `me' - 1.96 * `me_se'
	local me_hi = `me' + 1.96 * `me_se'
	post `me_post' (`x') (`me') (`me_se') (`me_lo') (`me_hi')
}
postclose `me_post'

use "`me_results'", clear
sort lnGDP
save "$EXT_RESULTS_RAW/marginal_effect_income_data.dta", replace
export delimited using "$EXT_RESULTS_RAW/marginal_effect_income_data.csv", replace

twoway ///
	(rarea ci_high ci_low lnGDP, color(eltblue%35) lcolor(none)) ///
	(line marginal_effect lnGDP, lcolor(navy) lwidth(medthick)), ///
	graphregion(color(white)) ///
	plotregion(color(white)) ///
	xline(`income_p10' `income_p90', lpattern(dot) lcolor(gs8)) ///
	yline(0, lpattern(dash) lcolor(black)) ///
	yline(`=baseline_beta', lpattern(shortdash) lcolor(maroon)) ///
	xtitle("Log GDP per capita (PPP)") ///
	ytitle("Marginal effect of scarcity on GDP growth") ///
	title("Marginal effect of scarcity across income levels") ///
	subtitle("Two-way FE, available-freshwater measure, income interaction") ///
	note("Reference points: ln GDP pc 6.91 ≈ $1,000; 9.21 ≈ $10,000; 10.82 ≈ $50,000. Dotted lines mark the 10th and 90th percentiles of the estimation sample.") ///
	xsize(8) ysize(5) ///
	name(ext_marginal_income, replace)

graph export "$EXT_FIGURES/marginal_effect_income.png", width(2400) replace
graph export "$EXT_FIGURES/marginal_effect_income.pdf", replace

use "$EXT_DATA/analysis_panel.dta", clear
keep if analysis_window_1990_2020
gen double Total_gr = GDP_gr
gen double rhs_scarcity = WaterStress_p99
gen double rhs_use = ln_total_water_withdrawal_pc
gen double rhs_income = lnGDP
keep if !missing(Total_gr, rhs_scarcity, rhs_use, rhs_income)
xtset id Year

postutil clear
tempname thr_post
tempfile thr_results
postfile `thr_post' double threshold rss n_obs beta_scarcity se_scarcity using "`thr_results'", replace

	foreach cutoff in 10 20 30 40 50 {
		preserve
			gen byte rhs_aux1 = rhs_scarcity >= `cutoff'
			gen double rhs_aux2 = rhs_scarcity * rhs_aux1
			capture noisily reghdfe Total_gr rhs_scarcity rhs_use rhs_income rhs_aux1 rhs_aux2, absorb(id Year) vce(cluster id)
		if _rc {
			post `thr_post' (`cutoff') (.) (.) (.) (.)
			restore
			continue
		}
			local rss = .
			capture scalar __ext_rss = e(rss)
			if !_rc {
				local rss = __ext_rss
			}
			else {
				local rss = e(rmse)^2 * e(df_r)
			}
			capture scalar drop __ext_rss
			post `thr_post' (`cutoff') (`rss') (e(N)) (_b[rhs_scarcity]) (_se[rhs_scarcity])
		restore
	}
postclose `thr_post'

use "`thr_results'", clear
gsort rss threshold
gen rank = _n
save "$EXT_RESULTS_RAW/threshold_grid_search.dta", replace
export delimited using "$EXT_RESULTS_RAW/threshold_grid_search.csv", replace

file open threshold_tex using "$EXT_TABLES/threshold_grid_search.tex", write replace text
file write threshold_tex "\begin{table}[htbp]" _n
file write threshold_tex "\centering" _n
file write threshold_tex "\caption{Appendix threshold grid search for the piecewise specification}" _n
file write threshold_tex "\label{tab:threshold_grid}" _n
file write threshold_tex "\small" _n
file write threshold_tex "\begin{tabular}{rccc}" _n
file write threshold_tex "\hline" _n
file write threshold_tex "Threshold (\%) & RSS & N & Beta on scarcity \\\\" _n
file write threshold_tex "\hline" _n
forvalues i = 1/`=_N' {
	file write threshold_tex `"`=string(threshold[`i'],"%9.0f")' & `=string(rss[`i'],"%15.3f")' & `=string(n_obs[`i'],"%9.0f")' & `=string(beta_scarcity[`i'],"%9.4f")' \\\\"' _n
}
file write threshold_tex "\hline" _n
file write threshold_tex "\multicolumn{4}{p{0.9\textwidth}}{\footnotesize Notes: Threshold search for the available-freshwater scarcity measure under the two-way fixed-effects piecewise specification. The 120-specification grid itself is unchanged; this table is an appendix diagnostic used to assess whether the median split is close to the RSS-minimizing cutoff.}" _n
file write threshold_tex "\end{tabular}" _n
file write threshold_tex "\end{table}" _n
file close threshold_tex

use "$EXT_DATA/analysis_panel.dta", clear
keep if analysis_window_1990_2020 & Year == 2008

preserve
	import delimited "$pathRef/oecd_water_pricing_2008.csv", clear
	keep if regression_weight < . & regression_total_price_usd_m3 < .
	gen weighted_price = regression_total_price_usd_m3 * regression_weight
	collapse (sum) weighted_price regression_weight, by(iso3)
	gen WSS_price = weighted_price / regression_weight
	keep iso3 WSS_price
	tempfile pricing_reference
	save "`pricing_reference'", replace
restore

joinby iso3 using "`pricing_reference'", unmatched(master) update
drop _merge
keep if WSS_price < .

gen shadow_price_proxy = WaterProductivity / (1 + WaterStress_p99 / 100)
keep iso3 CountryName WaterStress_p99 WaterProductivity WSS_price shadow_price_proxy
sort WSS_price

save "$EXT_RESULTS_RAW/shadow_price_sample.dta", replace
export delimited using "$EXT_RESULTS_RAW/shadow_price_sample.csv", replace

twoway ///
	(scatter shadow_price_proxy WSS_price, msymbol(circle) msize(medium) mcolor(navy) mlabel(iso3) mlabsize(vsmall) mlabcolor(black)) ///
	(lfit shadow_price_proxy WSS_price, lcolor(maroon) lwidth(medthin)), ///
	graphregion(color(white)) ///
	plotregion(color(white)) ///
	xtitle("Observed total WSS price (USD/m3, 2008)") ///
	ytitle("Normalized implied shadow-price proxy") ///
	title("Observed OECD prices and implied shadow-price proxy") ///
	subtitle("Proxy = Water productivity / (1 + water stress ratio)") ///
	note("The water-share term (1-alpha-theta) is normalized to 1 because the source paper does not calibrate it.") ///
	legend(order(1 "Country observations" 2 "Linear fit") rows(1) size(vsmall)) ///
	name(ext_shadow_price, replace)

graph export "$EXT_FIGURES/shadow_price_proxy.png", width(1800) replace
graph export "$EXT_FIGURES/shadow_price_proxy.pdf", replace

ext_display_step "Figures and appendix diagnostics exported to $EXT_FIGURES and $EXT_TABLES"
