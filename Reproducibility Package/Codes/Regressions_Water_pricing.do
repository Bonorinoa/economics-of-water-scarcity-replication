local G2 = "ysize(5.4) xsize(9.2) imargin(0 0) graphregion(color(white) margin(vsmall))"
local G4 = "ysize(10.8) xsize(9.2) imargin(0 0 0 0) graphregion(color(white) margin(vsmall))"
local rep1 "replace"
local rep2 "append"
tempfile pricing_reference

use "$pathDs/Data_WB.dta", clear
joinby CountryName Year using "$pathDs/Aquastat_Selected.dta", unmatched(both) update
tab _merge  
keep if _merge==3
drop _merge
joinby iso3 Year using "$pathDs/WGI.dta", unmatched(master) update
tab _merge  //keep if _merge==3
drop _merge
joinby iso3 Year using "$pathDs/PWT_new.dta", unmatched(master) update
tab _merge  //keep if _merge==3
drop _merge
foreach var of varlist Freshwater_withdrawal_rIR FreshwaterWithdrawal_rtrwr WaterStress {   // Total_freshwater_withdrawal
replace `var' = min(100, `var') if `var'<.
}
g Agriculture_WaterProductivity = WaterProductivity*(AgricultureForestryFishing_rGDP/FreshwaterWithdrawal_Agriculture)
g Industry_WaterProductivity = WaterProductivity*(Industry_rGDP/FreshwaterWithdrawal_Industry)
g Services_WaterProductivity = WaterProductivity*(Services_rGDP/FreshwaterWithdrawal_Services)

encode iso3, gen(id)
xtset id Year
local Xv1 "Freshwater_withdrawal_rIR WaterProductivity Total_water_withdrawal_pc" 
local Xv2 "FreshwaterWithdrawal_rtrwr WaterUseEfficiency Total_water_withdrawal_pc"
quietly { 
foreach var of varlist `Xv1' `Xv2' { 
sum `var', d
replace `var' = min(r(p99), `var') if `var'<.
}
}
g Level_Total_water_withdrawal_pc = Total_water_withdrawal_pc
foreach var of varlist Total_water_withdrawal_pc WaterProductivity WaterUseEfficiency { 
replace `var' = ln(`var')
}
sum `Xv1' `Xv2'
pwcorr `Xv1' `Xv2'

local Xv1 "Freshwater_withdrawal_rIR Total_water_withdrawal_pc"   // Use regressions 1, 2, 3, 7, 8, 
local Xv2 "FreshwaterWithdrawal_rtrwr Total_water_withdrawal_pc"
local Xv3 "WaterStress Total_water_withdrawal_pc"
local Xv4 "Freshwater_withdrawal_rIR"
local Xv5 "FreshwaterWithdrawal_rtrwr"
local Xv6 "Total_water_withdrawal_pc"
local Xv7 "WaterProductivity"
local Xv8 "WaterUseEfficiency"
local Xv9 "Freshwater_withdrawal_rIR Total_water_withdrawal_pc WaterUseEfficiency"
local Xv10 "FreshwaterWithdrawal_rtrwr Total_water_withdrawal_pc WaterUseEfficiency"

g lnGDP = ln(GDPpcPPP2017usd)
local Xe1 "lnGDP"
local Xe2 "lnGDP GovernmentEffectiveness"

tabstat Freshwater_withdrawal_rIR FreshwaterWithdrawal_rtrwr WaterStress WaterProductivity WaterUseEfficiency, statistics(sd)
drop if Year<2008
foreach var of varlist Freshwater_withdrawal_rIR FreshwaterWithdrawal_rtrwr WaterStress { 
g var0 = `var' if Year==2008	
g var1 = `var' if Year==2020	
bysort iso3: egen M_`var' = mean(`var')
bysort iso3: egen v08_`var' = mean(var0)
bysort iso3: egen v20_`var' = mean(var1)
g V_`var' = v20_`var'-v08_`var'

drop v20_`var' v08_`var' var0 var1
}
rename GDP_gr Total_gr  
keep if Year==2008

preserve
import delimited "$pathRef/oecd_water_pricing_2008.csv", clear
keep if regression_weight<. & regression_total_price_usd_m3<.
g weighted_price = regression_total_price_usd_m3*regression_weight
collapse (sum) weighted_price regression_weight, by(iso3)
g WSS_price = weighted_price/regression_weight
keep iso3 WSS_price
save "`pricing_reference'", replace
restore
joinby iso3 using "`pricing_reference'", unmatched(master) update
drop _merge
keep if WSS_price<.

local k=1
foreach var of varlist Freshwater_withdrawal_rIR FreshwaterWithdrawal_rtrwr WaterStress { 
reg M_`var' WSS_price //, vce(rob)
outreg2 using "$pathTRaw/TableA3_freshwater_prices.xls", `rep`k'' 
local k=2
reg M_`var' WSS_price lnGDP //reg M_`var' WSS_price GovernmentEffectiveness
outreg2 using "$pathTRaw/TableA3_freshwater_prices.xls", `rep`k'' 
}
local corrvars "Total_water_withdrawal_pc Freshwater_withdrawal_rIR FreshwaterWithdrawal_rtrwr WaterStress WSS_price"
correlate `corrvars'
matrix C = r(C)
clear
set obs 5
gen variable = ""
local i = 1
foreach var of local corrvars {
	replace variable = "`var'" in `i'
	local ++i
}
gen Total_water_withdrawal_pc = .
gen Freshwater_withdrawal_rIR = .
gen FreshwaterWithdrawal_rtrwr = .
gen WaterStress = .
gen WSS_price = .
forvalues i = 1/5 {
	replace Total_water_withdrawal_pc = C[`i',1] in `i'
	replace Freshwater_withdrawal_rIR = C[`i',2] in `i'
	replace FreshwaterWithdrawal_rtrwr = C[`i',3] in `i'
	replace WaterStress = C[`i',4] in `i'
	replace WSS_price = C[`i',5] in `i'
}
export delimited using "$pathTRaw/TableA2_correlation.csv", replace
