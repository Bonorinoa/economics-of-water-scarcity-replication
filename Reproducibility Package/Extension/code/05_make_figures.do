version 19.5

if `"$EXT_SETUP_COMPLETE"' != "1" {
	do "Reproducibility Package/Extension/code/00_setup_prereqs.do"
}

ext_display_step "Creating extension figures"

use "$EXT_RESULTS/meta_analysis_results.dta", clear
keep if status == "success"
gen ci_low = beta_scarcity - 1.96 * se_scarcity
gen ci_high = beta_scarcity + 1.96 * se_scarcity
gsort beta_scarcity spec_id
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
gen row_renewable = 8 if d_renewable
gen row_internal = 9 if d_internal
gen row_threshold = 10 if d_threshold
gen row_interaction_use = 11 if d_interaction_use
gen row_interaction_income = 12 if d_interaction_income
gen row_quadratic = 13 if d_quadratic

local top_opts ///
	graphregion(color(white)) ///
	plotregion(color(white)) ///
	xscale(range(1 120)) ///
	xlabel(1(10)120, labsize(small)) ///
	ytitle("Beta on scarcity") ///
	xtitle("Specification rank (sorted by beta)") ///
	title("Specification curve for water scarcity estimates") ///
	subtitle("GDP growth regressions with 95% confidence intervals") ///
	yline(`=baseline_beta', lpattern(dash) lcolor(black)) ///
	xline(`baseline_rank', lpattern(shortdash) lcolor(gs8))

twoway ///
	(rcap ci_high ci_low spec_order, lcolor(gs12) lwidth(vthin)) ///
	(scatter beta_scarcity spec_order if estimator == "country_fe_only", msymbol(circle_hollow) msize(vsmall) mcolor(navy)) ///
	(scatter beta_scarcity spec_order if estimator == "two_way_fe", msymbol(circle) msize(vsmall) mcolor(maroon)) ///
	(scatter beta_scarcity spec_order if estimator == "random_effects", msymbol(diamond) msize(vsmall) mcolor(forest_green)) ///
	(scatter beta_scarcity spec_order if estimator == "between", msymbol(square) msize(vsmall) mcolor(teal)) ///
	(scatter beta_scarcity spec_order if estimator == "first_diff", msymbol(triangle) msize(vsmall) mcolor(orange)) ///
	(scatter beta_scarcity spec_order if estimator == "q25", msymbol(circle_hollow) msize(vsmall) mcolor(cranberry)) ///
	(scatter beta_scarcity spec_order if estimator == "q50", msymbol(diamond_hollow) msize(vsmall) mcolor(purple)) ///
	(scatter beta_scarcity spec_order if estimator == "q75", msymbol(square_hollow) msize(vsmall) mcolor(brown)), ///
	legend(order(2 "Country FE only" 3 "Two-way FE" 4 "Random effects" 5 "Between" 6 "First diff" 7 "Q25" 8 "Q50" 9 "Q75") rows(2) size(vsmall)) ///
	`top_opts' ///
	name(ext_spec_curve_top, replace)

twoway ///
	(scatter row_q75 spec_order if d_q75, msymbol(square) msize(tiny) mcolor(black)) ///
	(scatter row_q50 spec_order if d_q50, msymbol(square) msize(tiny) mcolor(black)) ///
	(scatter row_q25 spec_order if d_q25, msymbol(square) msize(tiny) mcolor(black)) ///
	(scatter row_first_diff spec_order if d_first_diff, msymbol(square) msize(tiny) mcolor(black)) ///
	(scatter row_between spec_order if d_between, msymbol(square) msize(tiny) mcolor(black)) ///
	(scatter row_re spec_order if d_re, msymbol(square) msize(tiny) mcolor(black)) ///
	(scatter row_country_fe_only spec_order if d_country_fe_only, msymbol(square) msize(tiny) mcolor(black)) ///
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
	ylabel(1 "Q75" 2 "Q50" 3 "Q25" 4 "First diff" 5 "Between" 6 "RE" 7 "Country FE only" 8 "Renewable" 9 "Internal" 10 "Threshold" 11 "Use interaction" 12 "Income interaction" 13 "Quadratic", angle(0) labsize(vsmall)) ///
	ytitle("") ///
	xtitle("Specification rank (sorted by beta)") ///
	xline(`baseline_rank', lpattern(shortdash) lcolor(gs8)) ///
	title("Decision matrix") ///
	subtitle("Filled squares mark active modeling choices") ///
	legend(off) ///
	name(ext_spec_curve_bottom, replace)

graph combine ext_spec_curve_top ext_spec_curve_bottom, rows(2) cols(1) imargin(0 0 0 0) xsize(10.5) ysize(8.5) name(ext_spec_curve, replace)

graph export "$EXT_FIGURES/specification_curve.png", width(2200) replace
graph export "$EXT_FIGURES/specification_curve.pdf", replace

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

ext_display_step "Figures exported to $EXT_FIGURES"
