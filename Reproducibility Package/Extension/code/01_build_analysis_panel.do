version 19.5

if `"$EXT_SETUP_COMPLETE"' != "1" {
	do "Reproducibility Package/Extension/code/00_setup_prereqs.do"
}

ext_display_step "Building extension analysis panel"

use "$pathDs/Data_WB.dta", clear
joinby CountryName Year using "$pathDs/Aquastat_Selected.dta", unmatched(both) update
keep if _merge == 3
drop _merge

joinby iso3 Year using "$pathDs/WGI.dta", unmatched(master) update
drop _merge

joinby iso3 Year using "$pathDs/PWT_new.dta", unmatched(master) update
drop _merge

foreach scarcity_var in Freshwater_withdrawal_rIR FreshwaterWithdrawal_rtrwr WaterStress {
	replace `scarcity_var' = min(100, `scarcity_var') if `scarcity_var' < .
}

encode iso3, gen(id)
order id iso3 CountryName Year
sort id Year
xtset id Year

local winsor_vars ///
	Freshwater_withdrawal_rIR ///
	FreshwaterWithdrawal_rtrwr ///
	WaterStress ///
	Total_water_withdrawal_pc

foreach winsor_var of local winsor_vars {
	quietly summarize `winsor_var', detail
	gen `winsor_var'_p99 = min(r(p99), `winsor_var') if `winsor_var' < .
	label var `winsor_var'_p99 "`winsor_var' winsorized at p99"
}

gen ln_total_water_withdrawal_pc = ln(Total_water_withdrawal_pc_p99) if Total_water_withdrawal_pc_p99 > 0
gen lnGDP = ln(GDPpcPPP2017usd) if GDPpcPPP2017usd > 0

gen analysis_window_1990_2020 = inrange(Year, 1990, 2020)
gen sample_internal = !missing(GDP_gr, Freshwater_withdrawal_rIR_p99, ln_total_water_withdrawal_pc, lnGDP, id, Year) & analysis_window_1990_2020
gen sample_renewable = !missing(GDP_gr, FreshwaterWithdrawal_rtrwr_p99, ln_total_water_withdrawal_pc, lnGDP, id, Year) & analysis_window_1990_2020
gen sample_available = !missing(GDP_gr, WaterStress_p99, ln_total_water_withdrawal_pc, lnGDP, id, Year) & analysis_window_1990_2020

preserve
keep id iso3 CountryName Year GDP_gr GFCF_gr CPI_inf ///
	Freshwater_withdrawal_rIR FreshwaterWithdrawal_rtrwr WaterStress ///
	Freshwater_withdrawal_rIR_p99 FreshwaterWithdrawal_rtrwr_p99 WaterStress_p99 ///
	Total_water_withdrawal_pc Total_water_withdrawal_pc_p99 ln_total_water_withdrawal_pc ///
	GDPpcPPP2017usd lnGDP ///
	WaterProductivity WaterUseEfficiency ///
	GovernmentEffectiveness analysis_window_1990_2020 ///
	sample_internal sample_renewable sample_available
	save "$EXT_DATA/analysis_panel.dta", replace
	export delimited using "$EXT_DATA/analysis_panel.csv", replace
restore

preserve
	keep if analysis_window_1990_2020
	collapse ///
		(count) rows = Year ///
		(min) min_year = Year ///
		(max) max_year = Year ///
		(sum) sample_internal sample_renewable sample_available, by(id iso3 CountryName)
	tempfile country_coverage
	save "`country_coverage'", replace
restore

postutil clear
tempname paneldiag
postfile `paneldiag' str40 metric double value using "$EXT_RESULTS_RAW/panel_diagnostics.dta", replace

quietly count
post `paneldiag' ("matched_rows_all_years") (r(N))
quietly count if analysis_window_1990_2020
post `paneldiag' ("matched_rows_1990_2020") (r(N))
quietly count if sample_internal
post `paneldiag' ("sample_internal_1990_2020") (r(N))
quietly count if sample_renewable
post `paneldiag' ("sample_renewable_1990_2020") (r(N))
quietly count if sample_available
post `paneldiag' ("sample_available_1990_2020") (r(N))
quietly summarize Year
post `paneldiag' ("min_year_all") (r(min))
post `paneldiag' ("max_year_all") (r(max))
quietly summarize Year if analysis_window_1990_2020
post `paneldiag' ("min_year_window") (r(min))
post `paneldiag' ("max_year_window") (r(max))
quietly levelsof id if analysis_window_1990_2020, local(country_ids)
local country_count : word count `country_ids'
post `paneldiag' ("countries_window") (`country_count')

postclose `paneldiag'

use "$EXT_RESULTS_RAW/panel_diagnostics.dta", clear
export delimited using "$EXT_RESULTS_RAW/panel_diagnostics.csv", replace

use "$EXT_DATA/analysis_panel.dta", clear

ext_display_step "Analysis panel saved to $EXT_DATA/analysis_panel.dta and .csv"
