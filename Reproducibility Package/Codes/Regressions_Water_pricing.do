local G2 = "ysize(5.4) xsize(9.2) imargin(0 0) graphregion(color(white) margin(vsmall))"
local G4 = "ysize(10.8) xsize(9.2) imargin(0 0 0 0) graphregion(color(white) margin(vsmall))"
local rep1 "replace"
local rep2 "append"
capture log close

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

g WSS_price = .  // Water and sanitation prices
replace WSS_price = 0.49 if iso3=="MEX"
replace WSS_price = 0.77 if iso3=="KOR"
replace WSS_price = 1.23 if iso3=="PRT"
replace WSS_price = 1.40 if iso3=="GRC"
replace WSS_price = 1.45 if iso3=="ITA"
replace WSS_price = 1.58 if iso3=="CAN"
replace WSS_price = 1.85 if iso3=="JPN"
replace WSS_price = 1.92 if iso3=="ESP"
replace WSS_price = 1.98 if iso3=="NZL"
replace WSS_price = 2.02 if iso3=="HUN"
replace WSS_price = 2.12 if iso3=="POL"
replace WSS_price = 2.43 if iso3=="CZE"
replace WSS_price = 2.44 if iso3=="AUS"
replace WSS_price = 3.13 if iso3=="CHE"
replace WSS_price = 3.59 if iso3=="SWE"
replace WSS_price = 3.74 if iso3=="FRA"
replace WSS_price = ((65.7-5.4)/65.7)*3.82 + (5.4/65.7)*5.72 if iso3=="GBR"
replace WSS_price = ((11.7-3.7)/11.7)*4.14 + (3.7/11.7)*3.92 if iso3=="BEL"
replace WSS_price = 4.41 if iso3=="FIN"
replace WSS_price = 6.70 if iso3=="DNK"

local k=1
foreach var of varlist Freshwater_withdrawal_rIR FreshwaterWithdrawal_rtrwr WaterStress { 
reg M_`var' WSS_price //, vce(rob)
outreg2 using "$pathR/tables/Freshwater_Prices.xls", `rep`k'' 
local k=2
reg M_`var' WSS_price lnGDP //reg M_`var' WSS_price GovernmentEffectiveness
outreg2 using "$pathR/tables/Freshwater_Prices.xls", `rep`k'' 
}
local k=1
foreach var of varlist Freshwater_withdrawal_rIR FreshwaterWithdrawal_rtrwr WaterStress { 
reg V_`var' WSS_price 
outreg2 using "$pathR/tables/V2020_2008_Freshwater_Prices.xls", `rep`k'' 
local k=2
reg V_`var' WSS_price lnGDP  //reg V_`var' WSS_price GovernmentEffectiveness
outreg2 using "$pathR/tables/V2020_2008_Freshwater_Prices.xls", `rep`k'' 
}
log using "$pathR/tables/TableA2.smcl", replace
*pwcorr M_* WSS_price lnGDP GovernmentEffectiveness
*sum  Total_water_withdrawal_pc Freshwater_withdrawal_rIR FreshwaterWithdrawal_rtrwr WaterStress
pwcorr Total_water_withdrawal_pc Freshwater_withdrawal_rIR FreshwaterWithdrawal_rtrwr WaterStress WSS_price
*pwcorr Level_Total_water_withdrawal_pc Freshwater_withdrawal_rIR FreshwaterWithdrawal_rtrwr WaterStress WSS_price
log close
pwcorr V_* WSS_price lnGDP GovernmentEffectiveness
