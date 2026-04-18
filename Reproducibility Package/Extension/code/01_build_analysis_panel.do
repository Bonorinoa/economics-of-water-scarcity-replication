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

quietly summarize GDP_gr if sample_available, detail
local gdp_min : display %9.0f r(min)
local gdp_p50 : display %9.0f r(p50)
local gdp_mean : display %9.0f r(mean)
local gdp_max : display %9.0f r(max)
local gdp_sd : display %9.0f r(sd)

quietly summarize Freshwater_withdrawal_rIR_p99 if sample_internal, detail
local internal_min : display %9.0f r(min)
local internal_p50 : display %9.0f r(p50)
local internal_mean : display %9.0f r(mean)
local internal_max : display %9.0f r(max)
local internal_sd : display %9.0f r(sd)

quietly summarize FreshwaterWithdrawal_rtrwr_p99 if sample_renewable, detail
local renewable_min : display %9.0f r(min)
local renewable_p50 : display %9.0f r(p50)
local renewable_mean : display %9.0f r(mean)
local renewable_max : display %9.0f r(max)
local renewable_sd : display %9.0f r(sd)

quietly summarize WaterStress_p99 if sample_available, detail
local available_min : display %9.0f r(min)
local available_p50 : display %9.0f r(p50)
local available_mean : display %9.0f r(mean)
local available_max : display %9.0f r(max)
local available_sd : display %9.0f r(sd)

quietly summarize ln_total_water_withdrawal_pc if sample_available, detail
local water_pc_min : display %9.1f r(min)
local water_pc_p50 : display %9.1f r(p50)
local water_pc_mean : display %9.1f r(mean)
local water_pc_max : display %9.1f r(max)
local water_pc_sd : display %9.1f r(sd)

quietly summarize lnGDP if sample_available, detail
local lngdp_min : display %9.1f r(min)
local lngdp_p50 : display %9.1f r(p50)
local lngdp_mean : display %9.1f r(mean)
local lngdp_max : display %9.1f r(max)
local lngdp_sd : display %9.1f r(sd)

foreach scalar_label in ///
	gdp_min gdp_p50 gdp_mean gdp_max gdp_sd ///
	internal_min internal_p50 internal_mean internal_max internal_sd ///
	renewable_min renewable_p50 renewable_mean renewable_max renewable_sd ///
	available_min available_p50 available_mean available_max available_sd ///
	water_pc_min water_pc_p50 water_pc_mean water_pc_max water_pc_sd ///
	lngdp_min lngdp_p50 lngdp_mean lngdp_max lngdp_sd {
	local `scalar_label' = trim("``scalar_label''")
}

capture file close sumstats_tex
file open sumstats_tex using "$EXT_TABLES/summary_statistics.tex", write replace text
file write sumstats_tex "\begin{table}[htbp]" _n
file write sumstats_tex "\centering" _n
file write sumstats_tex "\caption{Summary statistics of key variables}" _n
file write sumstats_tex "\label{tab:sumstats}" _n
file write sumstats_tex "\small" _n
file write sumstats_tex "\begin{tabular}{lccccc}" _n
file write sumstats_tex "\toprule" _n
file write sumstats_tex "Variable & Min & Median & Mean & Max & SD \\\\" _n
file write sumstats_tex "\midrule" _n
file write sumstats_tex `"Annual GDP growth (\%) & `gdp_min' & `gdp_p50' & `gdp_mean' & `gdp_max' & `gdp_sd' \\\\"' _n
file write sumstats_tex "\addlinespace" _n
file write sumstats_tex "\multicolumn{6}{l}{\textit{Water scarcity (freshwater withdrawal as \% of):}} \\\\" _n
file write sumstats_tex `"\quad Internal resources & `internal_min' & `internal_p50' & `internal_mean' & `internal_max' & `internal_sd' \\\\"' _n
file write sumstats_tex `"\quad Total renewable resources & `renewable_min' & `renewable_p50' & `renewable_mean' & `renewable_max' & `renewable_sd' \\\\"' _n
file write sumstats_tex `"\quad Available freshwater & `available_min' & `available_p50' & `available_mean' & `available_max' & `available_sd' \\\\"' _n
file write sumstats_tex "\addlinespace" _n
file write sumstats_tex "\multicolumn{6}{l}{\textit{Controls (in logarithms):}} \\\\" _n
file write sumstats_tex `"\quad Total water withdrawal per capita & `water_pc_min' & `water_pc_p50' & `water_pc_mean' & `water_pc_max' & `water_pc_sd' \\\\"' _n
file write sumstats_tex `"\quad GDP per capita (PPP, 2017 USD) & `lngdp_min' & `lngdp_p50' & `lngdp_mean' & `lngdp_max' & `lngdp_sd' \\\\"' _n
file write sumstats_tex "\bottomrule" _n
file write sumstats_tex "\end{tabular}" _n
file write sumstats_tex "\end{table}" _n
file close sumstats_tex

ext_display_step "Analysis panel saved to $EXT_DATA/analysis_panel.dta and .csv"
