clear
import excel "$path/Data/Excel/UN_PPP2024_Output_PopTot.xlsx", sheet("Median") firstrow
keep ISO3Alphacode AK
rename ISO3Alphacode iso3
rename AK pop2050
destring pop2050, force replace
drop if iso3==""
replace pop2050= pop2050/1000 // turn into millions of people
save "$pathDs/Pop2050.dta", replace 

use "$pathDs/Data_WB.dta", clear  // Aquastat_Bulk.dta 
joinby CountryName Year using "$pathDs/Aquastat_Selected.dta", unmatched(both) update
tab _merge  
keep if _merge==3
drop _merge
joinby iso3 Year using "$pathDs/WGI.dta", unmatched(master) update
drop _merge
joinby iso3 Year using "$pathDs/PWT_new.dta", unmatched(master) update
drop _merge
joinby iso3 using "$pathDs/Pop2050.dta", unmatched(master) update
tab _merge
drop _merge
foreach var of varlist Freshwater_withdrawal_rIR FreshwaterWithdrawal_rtrwr WaterStress {   // Total_freshwater_withdrawal
replace `var' = min(100, `var') if `var'<.
}
encode iso3, gen(id)
xtset id Year
local Xv1 "Freshwater_withdrawal_rIR FreshwaterWithdrawal_rtrwr WaterStress Total_water_withdrawal_pc WaterProductivity WaterUseEfficiency" 
quietly { 
foreach var of varlist `Xv1'  AgricultureForestryFishing_gr Manufacturing_gr Services_gr { 
sum `var', d
replace `var' = min(r(p99), `var') if `var'<.
}
}
foreach var of varlist Total_water_withdrawal_pc { 
replace `var' = ln(`var')
}
g lnGDP = ln(GDPpcPPP2017usd)   //  Freshwater_withdrawal_rIR FreshwaterWithdrawal_rtrwr WaterStress Total_water_withdrawal_pc
g lagGDPpc = L.lnGDP
replace pop =L.pop if pop==.
g lagpop = L.pop
g Country_water_withdrawal = ln( pop*exp(Total_water_withdrawal_pc) )
replace lagpop = ln(lagpop)
g x1 = lagpop
g x2 = lagGDPpc
reghdfe Country_water_withdrawal lagpop lagGDPpc, absorb(id Year) vce(cluster id) 
outreg2 using "$pathTRaw/Water_pop_gdp.xls", replace
reghdfe Country_water_withdrawal lagpop lagGDPpc, absorb(id) vce(cluster id) 
outreg2 using "$pathTRaw/Water_pop_gdp.xls", append  //xtreg Country_water_withdrawal lagpop lagGDPpc, fe vce(r) outreg2 using "$path/tables/Water_pop_gdp.xls", append
replace lagpop = ln(pop2050)
replace lagGDPpc = x2 + 0.02*(2050-2020)
predict Country_water_withdrawal_2050 
replace Country_water_withdrawal_2050=exp(Country_water_withdrawal_2050)/exp(Country_water_withdrawal)
replace lagpop = x1
replace lagGDPpc = x2
foreach var of varlist Freshwater_withdrawal_rIR FreshwaterWithdrawal_rtrwr WaterStress {  //reghdfe `var' lagpop lagGDPpc, absorb(id Year) vce(cluster id)   
reghdfe `var' lagpop lagGDPpc, absorb(id) vce(cluster id)   // outreg2 using "$path/tables/Water_pop_gdp.xls", append 
outreg2 using "$pathTRaw/Water_pop_gdp.xls", append 
replace lagpop = ln(pop2050)
replace lagGDPpc = x2 + 0.02*(2050-2020)
predict `var'_2050 
replace `var'_2050=  max(0,min(100, `var'_2050))/`var'   //  `var'_2050/`var'
replace lagpop = x1
replace lagGDPpc = x2
}
sort iso3 Year
collapse (lastnm) pop2050 *_2050, by(iso3)
sum *_2050, d
save "$pathDs/data_temp.dta", replace 
foreach var of varlist *_2050 { 	
local var2=regexr("`var'","_2050","")	
rename `var' `var2'
foreach p of numlist 10 25 50 75 90 { 	
g `var2'_`p' = 	`var2'
}
}	
collapse (p10) *_10 (p25) *_25 (p50) *_50 (p75) *_75 (p90) *_90
g constant=1
reshape long Country_water_withdrawal_ Freshwater_withdrawal_rIR_ FreshwaterWithdrawal_rtrwr_ WaterStress_, i(constant) j(percentile)
drop constant
save "$pathDs/data_temp0.dta", replace 
use "$pathDs/data_temp.dta", clear 
replace pop2050 = ceil(pop2050)
foreach var of varlist *_2050 { 	
local var2=regexr("`var'","_2050","_")	
rename `var' `var2'
}
collapse Country_water_withdrawal_ Freshwater_withdrawal_rIR_ FreshwaterWithdrawal_rtrwr_ WaterStress_  [fw=pop2050] 
g percentile =.
joinby percentile using "$pathDs/data_temp0.dta", unmatched(both) update
drop _merge
g scenario = cond(percentile<., "Percentile " + string(percentile), "Population-weighted mean")
order percentile, first
sort percentile
save "$pathDs/data_temp0.dta", replace 
export excel using "$pathTRaw/Water_demand_2050.xlsx", firstrow(variables) nolabel replace
export delimited using "$pathTRaw/Table1_projection.csv", replace
