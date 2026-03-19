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
sum VoiceAccountability RuleLaw RegulatoryQuality PoliticalStability GovernmentEffectiveness ControlCorruption cwtfp rwtfpna
pwcorr VoiceAccountability RuleLaw RegulatoryQuality PoliticalStability GovernmentEffectiveness ControlCorruption cwtfp rwtfpna

sum Freshwater_withdrawal_rIR FreshwaterWithdrawal_rtrwr WaterStress, d
pwcorr Freshwater_withdrawal_rIR FreshwaterWithdrawal_rtrwr WaterStress
foreach var of varlist Freshwater_withdrawal_rIR FreshwaterWithdrawal_rtrwr WaterStress {   // Total_freshwater_withdrawal
replace `var' = min(100, `var') if `var'<.
}
pwcorr Freshwater_withdrawal_rIR FreshwaterWithdrawal_rtrwr WaterStress
sum FreshwaterWithdrawal_rtrwr Agriculture_WaterWithdrawal_rtww Industry_WaterWithdrawal_rtww Services_WaterWithdrawal_rtww 

g Agriculture_WaterProductivity = WaterProductivity*(AgricultureForestryFishing_rGDP/FreshwaterWithdrawal_Agriculture)
g Industry_WaterProductivity = WaterProductivity*(Industry_rGDP/FreshwaterWithdrawal_Industry)
g Services_WaterProductivity = WaterProductivity*(Services_rGDP/FreshwaterWithdrawal_Services)

sum WaterProductivity WaterUseEfficiency *_WaterProductivity Agriculture_WaterUseEfficiency Industry_WaterUseEfficiency Services_WaterUseEfficiency 
pwcorr WaterUseEfficiency WaterProductivity
pwcorr Agriculture_WaterUseEfficiency Agriculture_WaterProductivity
pwcorr Agriculture_WaterUseEfficiency Agriculture_WaterProductivity if Agriculture_WaterProductivity<55
pwcorr Industry_WaterUseEfficiency Industry_WaterProductivity
pwcorr Services_WaterUseEfficiency Services_WaterProductivity

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
foreach var of varlist Freshwater_withdrawal_rIR FreshwaterWithdrawal_rtrwr WaterStress WaterProductivity WaterUseEfficiency { 
g D_`var' = L.`var'
replace D_`var' = `var'-D_`var'
}
log using "$pathR/tables/Table6.smcl", replace
// Demeaned one-standard deviation shocks of water scarcity
tabstat D_Freshwater_withdrawal_rIR D_FreshwaterWithdrawal_rtrwr D_WaterStress D_WaterProductivity  D_WaterUseEfficiency, statistics(sd)
matrix input Bsd = (1.438162,  1.390991, 1.592205)
log close

rename GDP_gr Total_gr  
xtreg  Total_gr `Xv1' `Xe1', fe
local k=1
foreach var of varlist Total_gr { //  AgricultureForestryFishing_gr Industry_gr Manufacturing_gr Services_gr
reghdfe `var' `Xv1' `Xe1', absorb(id Year) vce(cluster id)    //xtreg `var' i.(Year), fe
outreg2 using "$pathR/tables/Table3_GDPgr.xls", `rep`k'' //GDP_`var'  //estadd listcoef, std  // help
local Coef1 = _b[Freshwater_withdrawal_rIR] 
local k=2
foreach v of numlist 2 3  { // 7 8 //forv v=2/10  { 
reghdfe `var' `Xv`v'' `Xe1', absorb(id Year) vce(cluster id)   
outreg2 using "$pathR/tables/Table3_GDPgr.xls", `rep`k'' 
if `v'==2  { 
local Coef2 = _b[FreshwaterWithdrawal_rtrwr] 
}
if `v'==3  { 
local Coef3 = _b[WaterStress] 
}
}
}
log using "$pathR/tables/Table6.smcl", append
local b1 = Bsd[1,1]*`Coef1'
local b2 = Bsd[1,2]*`Coef2'
local b3 = Bsd[1,3]*`Coef3'
// First column: GDP growth one standard-deviation effects
display("`b1'")
display("`b2'")
display("`b3'")
log close

local k=1
foreach var of varlist GFCF_gr { // Gross_capital_formation_gr Gross_capital_formation_rGDP GFCF_Private_rGDP GFCF_rGDP GFCF_Private_rGDP GFCF_rGDP
reghdfe `var' `Xv1' `Xe1', absorb(id Year) vce(cluster id)   
outreg2 using "$pathR/tables/Table4_Investment.xls", `rep`k''
local Coef1 = _b[Freshwater_withdrawal_rIR] 
local k=2
foreach v of numlist 2 3  { // 7 8 //forv v=2/10  { 
reghdfe `var' `Xv`v'' `Xe1', absorb(id Year) vce(cluster id)   
outreg2 using "$pathR/tables/Table4_Investment.xls", `rep`k''
if `v'==2  { 
local Coef2 = _b[FreshwaterWithdrawal_rtrwr] 
}
if `v'==3  { 
local Coef3 = _b[WaterStress] 
}
} 
}
log using "$pathR/tables/Table6.smcl", append
local b1 = Bsd[1,1]*`Coef1'
local b2 = Bsd[1,2]*`Coef2'
local b3 = Bsd[1,3]*`Coef3'
// Second column: Fixed Investment one standard-deviation effects
display("`b1'")
display("`b2'")
display("`b3'")
log close

local k=1
foreach var of varlist CPI_inf { //  AgricultureForestryFishing_gr Industry_gr Manufacturing_gr Services_gr
reghdfe `var' `Xv1' `Xe1', absorb(id Year) vce(cluster id)    //xtreg `var' i.(Year), fe
outreg2 using "$pathR/tables/Table5_CPI.xls", `rep`k'' //GDP_`var'  //estadd listcoef, std  // help
local Coef1 = _b[Freshwater_withdrawal_rIR] 
local k=2
foreach v of numlist 2 3 { // 7 8 //forv v=2/10  { 
reghdfe `var' `Xv`v'' `Xe1', absorb(id Year) vce(cluster id)   
outreg2 using "$pathR/tables/Table5_CPI.xls", `rep`k'' 
if `v'==2  { 
local Coef2 = _b[FreshwaterWithdrawal_rtrwr] 
}
if `v'==3  { 
local Coef3 = _b[WaterStress] 
}
}
}
log using "$pathR/tables/Table6.smcl", append
local b1 = Bsd[1,1]*`Coef1'
local b2 = Bsd[1,2]*`Coef2'
local b3 = Bsd[1,3]*`Coef3'
// Third column: CPI one standard-deviation effects
display("`b1'")
display("`b2'")
display("`b3'")
log close

local k=1
foreach var of varlist FoodProduction NaturalResourceRents { //  AgricultureForestryFishing_gr Industry_gr Manufacturing_gr Services_gr
reghdfe `var' `Xv1' `Xe1', absorb(id Year) vce(cluster id)    //xtreg `var' i.(Year), fe
outreg2 using "$pathR/tables/Food_NatResR.xls", `rep`k'' //GDP_`var'  //estadd listcoef, std  // help
local k=2
foreach v of numlist 2 3 7 8 {  //forv v=2/10  { 
reghdfe `var' `Xv`v'' `Xe1', absorb(id Year) vce(cluster id)   
outreg2 using "$pathR/tables/Food_NatResR.xls", `rep`k'' 
}
}

//  //
