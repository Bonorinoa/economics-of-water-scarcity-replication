version 19.5

if `"$EXT_SETUP_COMPLETE"' != "1" {
	do "Reproducibility Package/Extension/code/00_setup_prereqs.do"
}

ext_display_step "Running the 120-specification extension grid"

capture program drop ext_prepare_level_vars
program define ext_prepare_level_vars
	syntax, scarcity(string) form(string)

	tempvar scarcity_var
	gen double `scarcity_var' = .
	if "`scarcity'" == "internal" {
		replace `scarcity_var' = Freshwater_withdrawal_rIR_p99
	}
	else if "`scarcity'" == "renewable" {
		replace `scarcity_var' = FreshwaterWithdrawal_rtrwr_p99
	}
	else if "`scarcity'" == "available" {
		replace `scarcity_var' = WaterStress_p99
	}
	else {
		ext_abort "unknown scarcity measure `scarcity'"
	}

	gen double rhs_scarcity = `scarcity_var'
	gen double rhs_use = ln_total_water_withdrawal_pc
	gen double rhs_income = lnGDP

	if "`form'" == "linear" {
		gen double rhs_aux1 = .
		gen double rhs_aux2 = .
	}
	else if "`form'" == "quadratic" {
		gen double rhs_aux1 = `scarcity_var'^2
		gen double rhs_aux2 = .
	}
	else if "`form'" == "interaction_income" {
		gen double rhs_aux1 = `scarcity_var' * lnGDP
		gen double rhs_aux2 = .
	}
	else if "`form'" == "interaction_use" {
		gen double rhs_aux1 = `scarcity_var' * ln_total_water_withdrawal_pc
		gen double rhs_aux2 = .
	}
	else if "`form'" == "threshold" {
		quietly summarize `scarcity_var' if !missing(Total_gr, `scarcity_var', ln_total_water_withdrawal_pc, lnGDP), detail
		gen byte rhs_aux1 = (`scarcity_var' >= r(p50)) if !missing(`scarcity_var')
		gen double rhs_aux2 = `scarcity_var' * rhs_aux1 if !missing(`scarcity_var')
	}
	else {
		ext_abort "unknown functional form `form'"
	}
end

capture program drop ext_compute_ame
program define ext_compute_ame, rclass
	syntax, form(string) maincoef(string) [aux1coef(string) aux2coef(string)]

	tempvar regression_sample
	gen byte `regression_sample' = e(sample)

	local ame = _b[`maincoef']
	local ame_se = _se[`maincoef']
	local ame_t = .
	local ame_p = .

	capture scalar __ext_df = e(df_r)
	if !_rc & __ext_df < . {
		local ame_t = `ame' / `ame_se'
		local ame_p = 2 * ttail(__ext_df, abs(`ame_t'))
	}
	else {
		local ame_t = `ame' / `ame_se'
		local ame_p = 2 * normal(-abs(`ame_t'))
	}
	capture scalar drop __ext_df

	if "`form'" == "quadratic" {
		quietly summarize rhs_scarcity if `regression_sample', meanonly
		local scarcity_mean = r(mean)
		capture quietly lincom _b[`maincoef'] + (2 * `scarcity_mean') * _b[`aux1coef']
		if _rc {
			return scalar failed = 1
			exit
		}
		local ame = r(estimate)
		local ame_se = r(se)
		local ame_t = `ame' / `ame_se'
		local ame_p = r(p)
	}
	else if "`form'" == "interaction_income" {
		quietly summarize rhs_income if `regression_sample', meanonly
		local income_mean = r(mean)
		capture quietly lincom _b[`maincoef'] + (`income_mean') * _b[`aux1coef']
		if _rc {
			return scalar failed = 1
			exit
		}
		local ame = r(estimate)
		local ame_se = r(se)
		local ame_t = `ame' / `ame_se'
		local ame_p = r(p)
	}
	else if "`form'" == "interaction_use" {
		quietly summarize rhs_use if `regression_sample', meanonly
		local use_mean = r(mean)
		capture quietly lincom _b[`maincoef'] + (`use_mean') * _b[`aux1coef']
		if _rc {
			return scalar failed = 1
			exit
		}
		local ame = r(estimate)
		local ame_se = r(se)
		local ame_t = `ame' / `ame_se'
		local ame_p = r(p)
	}
	else if "`form'" == "threshold" {
		quietly summarize rhs_aux1 if `regression_sample', meanonly
		local share_above = r(mean)
		capture quietly lincom _b[`maincoef'] + (`share_above') * _b[`aux2coef']
		if _rc {
			return scalar failed = 1
			exit
		}
		local ame = r(estimate)
		local ame_se = r(se)
		local ame_t = `ame' / `ame_se'
		local ame_p = r(p)
	}

	return scalar failed = 0
	return scalar ame = `ame'
	return scalar ame_se = `ame_se'
	return scalar ame_t = `ame_t'
	return scalar ame_p = `ame_p'
end

capture program drop ext_post_failure
program define ext_post_failure
	args postname specid scarcity form estimator reason

	local d_internal = ("`scarcity'" == "internal")
	local d_renewable = ("`scarcity'" == "renewable")
	local d_quadratic = ("`form'" == "quadratic")
	local d_interaction_income = ("`form'" == "interaction_income")
	local d_interaction_use = ("`form'" == "interaction_use")
	local d_threshold = ("`form'" == "threshold")
	local d_country_fe_only = ("`estimator'" == "country_fe_only")
	local d_re = ("`estimator'" == "random_effects")
	local d_between = ("`estimator'" == "between")
	local d_first_diff = ("`estimator'" == "first_diff")
	local d_q25 = ("`estimator'" == "q25")
	local d_q50 = ("`estimator'" == "q50")
	local d_q75 = ("`estimator'" == "q75")
	local d_no_year_fe = inlist("`estimator'", "country_fe_only", "between", "q25", "q50", "q75")

	post `postname' ///
		(`specid') ///
		("`scarcity'") ///
		("`form'") ///
		("`estimator'") ///
		(.) ///
		(.) ///
		(.) ///
		(.) ///
		(.) ///
		(.) ///
		(.) ///
		(.) ///
		(.) ///
		(.) ///
		(.) ///
		(.) ///
		(`d_quadratic') ///
		(`d_interaction_income') ///
		(`d_interaction_use') ///
		(`d_threshold') ///
		(`d_internal') ///
		(`d_renewable') ///
		(`d_country_fe_only') ///
		(`d_re') ///
		(`d_between') ///
		(`d_first_diff') ///
		(`d_q25') ///
		(`d_q50') ///
		(`d_q75') ///
		(`d_no_year_fe') ///
		("failed") ///
		(`"`reason'"')
end

capture program drop ext_post_success
program define ext_post_success
	args postname specid scarcity form estimator beta se tstat pvalue nobs rsq hausmanp ame amese amet amep withinrsq overallrsq

	local d_internal = ("`scarcity'" == "internal")
	local d_renewable = ("`scarcity'" == "renewable")
	local d_quadratic = ("`form'" == "quadratic")
	local d_interaction_income = ("`form'" == "interaction_income")
	local d_interaction_use = ("`form'" == "interaction_use")
	local d_threshold = ("`form'" == "threshold")
	local d_country_fe_only = ("`estimator'" == "country_fe_only")
	local d_re = ("`estimator'" == "random_effects")
	local d_between = ("`estimator'" == "between")
	local d_first_diff = ("`estimator'" == "first_diff")
	local d_q25 = ("`estimator'" == "q25")
	local d_q50 = ("`estimator'" == "q50")
	local d_q75 = ("`estimator'" == "q75")
	local d_no_year_fe = inlist("`estimator'", "country_fe_only", "between", "q25", "q50", "q75")

	post `postname' ///
		(`specid') ///
		("`scarcity'") ///
		("`form'") ///
		("`estimator'") ///
		(`beta') ///
		(`se') ///
		(`tstat') ///
		(`pvalue') ///
		(`nobs') ///
		(`rsq') ///
		(`hausmanp') ///
		(`ame') ///
		(`amese') ///
		(`amet') ///
		(`amep') ///
		(`withinrsq') ///
		(`overallrsq') ///
		(`d_quadratic') ///
		(`d_interaction_income') ///
		(`d_interaction_use') ///
		(`d_threshold') ///
		(`d_internal') ///
		(`d_renewable') ///
		(`d_country_fe_only') ///
		(`d_re') ///
		(`d_between') ///
		(`d_first_diff') ///
		(`d_q25') ///
		(`d_q50') ///
		(`d_q75') ///
		(`d_no_year_fe') ///
		("success") ///
		("")
end

tempfile meta_results
postutil clear
tempname metapost
postfile `metapost' ///
	int spec_id ///
	str12 scarcity_measure ///
	str20 functional_form ///
	str18 estimator ///
	double beta_scarcity se_scarcity t_stat p_value n_obs r_squared hausman_p ///
	double ame_scarcity ame_se ame_t_stat ame_p_value within_r2 overall_r2 ///
	byte d_quadratic d_interaction_income d_interaction_use d_threshold ///
		d_internal d_renewable ///
		d_country_fe_only d_re d_between d_first_diff d_q25 d_q50 d_q75 d_no_year_fe ///
	str8 status ///
	str244 failure_reason ///
	using "`meta_results'", replace

use "$EXT_DATA/analysis_panel.dta", clear
keep if analysis_window_1990_2020
gen double Total_gr = GDP_gr
sort id Year
xtset id Year

local spec_id = 0
local scarcity_list "internal renewable available"
local form_list "linear quadratic interaction_income interaction_use threshold"
local estimator_list "country_fe_only two_way_fe random_effects between first_diff q25 q50 q75"

foreach scarcity in `scarcity_list' {
	foreach form in `form_list' {
		foreach estimator in `estimator_list' {
			local ++spec_id
			preserve
				quietly ext_prepare_level_vars, scarcity(`scarcity') form(`form')
				local rhs_vars "rhs_scarcity rhs_use rhs_income"
				local ame_aux1 = ""
				local ame_aux2 = ""
				if "`form'" == "quadratic" {
					local rhs_vars "`rhs_vars' rhs_aux1"
					local ame_aux1 "rhs_aux1"
				}
				else if inlist("`form'", "interaction_income", "interaction_use") {
					local rhs_vars "`rhs_vars' rhs_aux1"
					local ame_aux1 "rhs_aux1"
				}
				else if "`form'" == "threshold" {
					local rhs_vars "`rhs_vars' rhs_aux1 rhs_aux2"
					local ame_aux2 "rhs_aux2"
				}

				if inlist("`estimator'", "country_fe_only", "two_way_fe", "random_effects", "q25", "q50", "q75") {
					keep if !missing(Total_gr, rhs_scarcity, rhs_use, rhs_income)
					if inlist("`form'", "quadratic", "interaction_income", "interaction_use") {
						keep if !missing(rhs_aux1)
					}
					if "`form'" == "threshold" {
						keep if !missing(rhs_aux1, rhs_aux2)
					}
				}

				local beta = .
				local se = .
				local tstat = .
				local pvalue = .
				local rsq = .
				local hausman_p = .
				local ame = .
				local ame_se = .
				local ame_t = .
				local ame_p = .
				local within_r2 = .
				local overall_r2 = .

				if "`estimator'" == "country_fe_only" {
					capture noisily reghdfe Total_gr `rhs_vars', absorb(id) vce(cluster id)
					if _rc {
						ext_post_failure `metapost' `spec_id' "`scarcity'" "`form'" "`estimator'" "reghdfe country FE failed"
						restore
						continue
					}
					local beta = _b[rhs_scarcity]
					local se = _se[rhs_scarcity]
					local tstat = `beta' / `se'
					local pvalue = 2 * ttail(e(df_r), abs(`tstat'))
					local rsq = e(r2)
					local overall_r2 = e(r2)
					capture scalar __ext_within = e(r2_within)
					if !_rc local within_r2 = __ext_within
					capture scalar drop __ext_within
					local nobs = e(N)
					quietly ext_compute_ame, form(`form') maincoef(rhs_scarcity) aux1coef(`ame_aux1') aux2coef(`ame_aux2')
					if r(failed) {
						ext_post_failure `metapost' `spec_id' "`scarcity'" "`form'" "`estimator'" "AME computation failed"
						restore
						continue
					}
					local ame = r(ame)
					local ame_se = r(ame_se)
					local ame_t = r(ame_t)
					local ame_p = r(ame_p)
					ext_post_success `metapost' `spec_id' "`scarcity'" "`form'" "`estimator'" `beta' `se' `tstat' `pvalue' `nobs' `rsq' . `ame' `ame_se' `ame_t' `ame_p' `within_r2' `overall_r2'
				}
				else if "`estimator'" == "two_way_fe" {
					capture noisily reghdfe Total_gr `rhs_vars', absorb(id Year) vce(cluster id)
					if _rc {
						ext_post_failure `metapost' `spec_id' "`scarcity'" "`form'" "`estimator'" "reghdfe two-way FE failed"
						restore
						continue
					}
					local beta = _b[rhs_scarcity]
					local se = _se[rhs_scarcity]
					local tstat = `beta' / `se'
					local pvalue = 2 * ttail(e(df_r), abs(`tstat'))
					local rsq = e(r2)
					local overall_r2 = e(r2)
					capture scalar __ext_within = e(r2_within)
					if !_rc local within_r2 = __ext_within
					capture scalar drop __ext_within
					local nobs = e(N)
					quietly ext_compute_ame, form(`form') maincoef(rhs_scarcity) aux1coef(`ame_aux1') aux2coef(`ame_aux2')
					if r(failed) {
						ext_post_failure `metapost' `spec_id' "`scarcity'" "`form'" "`estimator'" "AME computation failed"
						restore
						continue
					}
					local ame = r(ame)
					local ame_se = r(ame_se)
					local ame_t = r(ame_t)
					local ame_p = r(ame_p)
					ext_post_success `metapost' `spec_id' "`scarcity'" "`form'" "`estimator'" `beta' `se' `tstat' `pvalue' `nobs' `rsq' . `ame' `ame_se' `ame_t' `ame_p' `within_r2' `overall_r2'
				}
				else if "`estimator'" == "random_effects" {
					capture noisily xtreg Total_gr `rhs_vars' i.Year, re vce(cluster id)
					if _rc {
						ext_post_failure `metapost' `spec_id' "`scarcity'" "`form'" "`estimator'" "xtreg random effects failed"
						restore
						continue
					}
					local beta = _b[rhs_scarcity]
					local se = _se[rhs_scarcity]
					local tstat = `beta' / `se'
					local pvalue = 2 * normal(-abs(`tstat'))
					local rsq = e(r2_o)
					local overall_r2 = e(r2_o)
					capture scalar __ext_within = e(r2_w)
					if !_rc local within_r2 = __ext_within
					capture scalar drop __ext_within
					local nobs = e(N)

					tempvar re_sample
					gen byte `re_sample' = e(sample)
					local hausman_p = .
					quietly xtreg Total_gr `rhs_vars' i.Year if `re_sample', fe
					estimates store ext_fe_h
					quietly xtreg Total_gr `rhs_vars' i.Year if `re_sample', re
					estimates store ext_re_h
					capture noisily hausman ext_fe_h ext_re_h, sigmamore
					if !_rc {
						local hausman_p = r(p)
					}
					estimates drop ext_fe_h
					estimates drop ext_re_h

					quietly xtreg Total_gr `rhs_vars' i.Year if `re_sample', re vce(cluster id)
					quietly ext_compute_ame, form(`form') maincoef(rhs_scarcity) aux1coef(`ame_aux1') aux2coef(`ame_aux2')
					if r(failed) {
						ext_post_failure `metapost' `spec_id' "`scarcity'" "`form'" "`estimator'" "AME computation failed"
						restore
						continue
					}
					local ame = r(ame)
					local ame_se = r(ame_se)
					local ame_t = r(ame_t)
					local ame_p = r(ame_p)
					ext_post_success `metapost' `spec_id' "`scarcity'" "`form'" "`estimator'" `beta' `se' `tstat' `pvalue' `nobs' `rsq' `hausman_p' `ame' `ame_se' `ame_t' `ame_p' `within_r2' `overall_r2'
				}
				else if "`estimator'" == "between" {
					collapse (mean) Total_gr rhs_scarcity rhs_use rhs_income rhs_aux1 rhs_aux2, by(id iso3 CountryName)
					capture noisily regress Total_gr `rhs_vars', vce(robust)
					if _rc {
						ext_post_failure `metapost' `spec_id' "`scarcity'" "`form'" "`estimator'" "between regression failed"
						restore
						continue
					}
					local beta = _b[rhs_scarcity]
					local se = _se[rhs_scarcity]
					local tstat = `beta' / `se'
					local pvalue = 2 * ttail(e(df_r), abs(`tstat'))
					local rsq = e(r2)
					local overall_r2 = e(r2)
					local nobs = e(N)
					quietly ext_compute_ame, form(`form') maincoef(rhs_scarcity) aux1coef(`ame_aux1') aux2coef(`ame_aux2')
					if r(failed) {
						ext_post_failure `metapost' `spec_id' "`scarcity'" "`form'" "`estimator'" "AME computation failed"
						restore
						continue
					}
					local ame = r(ame)
					local ame_se = r(ame_se)
					local ame_t = r(ame_t)
					local ame_p = r(ame_p)
					ext_post_success `metapost' `spec_id' "`scarcity'" "`form'" "`estimator'" `beta' `se' `tstat' `pvalue' `nobs' `rsq' . `ame' `ame_se' `ame_t' `ame_p' . `overall_r2'
				}
				else if "`estimator'" == "first_diff" {
					sort id Year
					foreach fdvar in Total_gr rhs_scarcity rhs_use rhs_income rhs_aux1 rhs_aux2 {
						capture confirm variable `fdvar'
						if !_rc {
							gen double D_`fdvar' = D.`fdvar'
						}
					}
					keep if !missing(D_Total_gr, D_rhs_scarcity, D_rhs_use, D_rhs_income)
					local fd_rhs "D_rhs_scarcity D_rhs_use D_rhs_income"
					local ame_maincoef "D_rhs_scarcity"
					local ame_aux1_fd = ""
					local ame_aux2_fd = ""
					if inlist("`form'", "quadratic", "interaction_income", "interaction_use") {
						keep if !missing(D_rhs_aux1)
						local fd_rhs "`fd_rhs' D_rhs_aux1"
						local ame_aux1_fd "D_rhs_aux1"
					}
					if "`form'" == "threshold" {
						keep if !missing(D_rhs_aux1, D_rhs_aux2)
						local fd_rhs "`fd_rhs' D_rhs_aux1 D_rhs_aux2"
						local ame_aux2_fd "D_rhs_aux2"
					}
					capture noisily regress D_Total_gr `fd_rhs' i.Year, vce(cluster id)
					if _rc {
						ext_post_failure `metapost' `spec_id' "`scarcity'" "`form'" "`estimator'" "first-difference regression failed"
						restore
						continue
					}
					local beta = _b[D_rhs_scarcity]
					local se = _se[D_rhs_scarcity]
					local tstat = `beta' / `se'
					local pvalue = 2 * ttail(e(df_r), abs(`tstat'))
					local rsq = e(r2)
					local overall_r2 = e(r2)
					local nobs = e(N)
					quietly ext_compute_ame, form(`form') maincoef(`ame_maincoef') aux1coef(`ame_aux1_fd') aux2coef(`ame_aux2_fd')
					if r(failed) {
						ext_post_failure `metapost' `spec_id' "`scarcity'" "`form'" "`estimator'" "AME computation failed"
						restore
						continue
					}
					local ame = r(ame)
					local ame_se = r(ame_se)
					local ame_t = r(ame_t)
					local ame_p = r(ame_p)
					ext_post_success `metapost' `spec_id' "`scarcity'" "`form'" "`estimator'" `beta' `se' `tstat' `pvalue' `nobs' `rsq' . `ame' `ame_se' `ame_t' `ame_p' . `overall_r2'
				}
				else if inlist("`estimator'", "q25", "q50", "q75") {
					local tau = 0.25
					if "`estimator'" == "q50" local tau = 0.50
					if "`estimator'" == "q75" local tau = 0.75
					capture noisily xtqreg Total_gr `rhs_vars', id(id) q(`tau')
					if _rc {
						ext_post_failure `metapost' `spec_id' "`scarcity'" "`form'" "`estimator'" "xtqreg failed to converge"
						restore
						continue
					}
					local beta = _b[rhs_scarcity]
					local se = _se[rhs_scarcity]
					local tstat = `beta' / `se'
					local pvalue = 2 * normal(-abs(`tstat'))
					local nobs = e(N)
					local rsq = .
					local overall_r2 = .
					capture scalar __ext_overall = e(r2)
					if !_rc {
						local rsq = __ext_overall
						local overall_r2 = __ext_overall
					}
					capture scalar drop __ext_overall
					quietly ext_compute_ame, form(`form') maincoef(rhs_scarcity) aux1coef(`ame_aux1') aux2coef(`ame_aux2')
					if r(failed) {
						ext_post_failure `metapost' `spec_id' "`scarcity'" "`form'" "`estimator'" "AME computation failed"
						restore
						continue
					}
					local ame = r(ame)
					local ame_se = r(ame_se)
					local ame_t = r(ame_t)
					local ame_p = r(ame_p)
					ext_post_success `metapost' `spec_id' "`scarcity'" "`form'" "`estimator'" `beta' `se' `tstat' `pvalue' `nobs' `rsq' . `ame' `ame_se' `ame_t' `ame_p' . `overall_r2'
				}
				else {
					ext_post_failure `metapost' `spec_id' "`scarcity'" "`form'" "`estimator'" "unsupported estimator"
				}
			restore
		}
	}
}

postclose `metapost'

use "`meta_results'", clear
sort spec_id
label var spec_id "Specification id"
label var beta_scarcity "Coefficient on scarcity variable"
label var se_scarcity "Standard error on scarcity variable"
label var hausman_p "Hausman p-value"
label var ame_scarcity "Average marginal effect of scarcity"
label var ame_se "Standard error of average marginal effect"
label var ame_t_stat "t or z statistic for AME"
label var ame_p_value "p-value for AME"
label var within_r2 "Within R-squared when available"
label var overall_r2 "Overall R-squared when available"
label var d_no_year_fe "Estimator omits year fixed effects"

duplicates tag spec_id, gen(spec_dup)
count if spec_dup > 0
if r(N) > 0 {
	ext_abort "duplicate specification identifiers were generated"
}
drop spec_dup

quietly count if functional_form == "linear" & status == "success" & abs(ame_scarcity - beta_scarcity) > 1e-10
if r(N) > 0 {
	ext_abort "linear AMEs do not match the raw scarcity coefficients"
}

quietly count if status == "success" & missing(ame_scarcity, ame_se, ame_t_stat, ame_p_value)
if r(N) > 0 {
	ext_abort "some successful specifications are missing AME outputs"
}

save "$EXT_RESULTS/meta_analysis_results.dta", replace
export delimited using "$EXT_RESULTS/meta_analysis_results.csv", replace

quietly count
if r(N) != 120 {
	ext_abort "the specification grid did not produce 120 rows"
}

quietly count if estimator == "random_effects" & status == "success" & missing(hausman_p)
if r(N) > 0 {
	display as error "Warning: some successful random-effects specifications do not have Hausman p-values"
}

ext_display_step "Specification grid results saved to $EXT_RESULTS/meta_analysis_results.dta and .csv"
