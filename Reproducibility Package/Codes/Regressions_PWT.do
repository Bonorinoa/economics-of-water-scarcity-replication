local G2 = "ysize(5.4) xsize(9.2) imargin(0 0) graphregion(color(white) margin(vsmall))"
local G4 = "ysize(10.8) xsize(9.2) imargin(0 0 0 0) graphregion(color(white) margin(vsmall))"
local rep1 "replace"
local rep2 "append"

use "$pathDs/Data_WB.dta", clear
joinby iso3 Year using "$pathDs/WB_eletricity.dta", unmatched(both) update
tab _merge  
keep if _merge==3
drop _merge
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
sum rgdpo cgdpo emp hc cn ctfp 
foreach var of varlist Freshwater_withdrawal_rIR FreshwaterWithdrawal_rtrwr WaterStress {   // Total_freshwater_withdrawal
replace `var' = min(100, `var') if `var'<.
}
encode iso3, gen(id)
xtset id Year
local Xv1 "Freshwater_withdrawal_rIR FreshwaterWithdrawal_rtrwr WaterStress Total_water_withdrawal_pc WaterProductivity WaterUseEfficiency" 
quietly { 
foreach var of varlist `Xv1' AgricultureForestryFishing_gr Manufacturing_gr Services_gr { 
sum `var', d
replace `var' = min(r(p99), `var') if `var'<.
}
}
foreach var of varlist Total_water_withdrawal_pc { 
replace `var' = ln(`var')
}
foreach var of varlist rgdpo cgdpo emp hc cn ctfp  { 
g dln_`var' = L.`var'
replace dln_`var' = ln(`var'/dln_`var')
g ln_`var' = ln(`var')
local k=1
foreach var2 of varlist Freshwater_withdrawal_rIR FreshwaterWithdrawal_rtrwr WaterStress Total_water_withdrawal_pc { 
g dln_`var'_`k' = dln_`var'*`var2'
g ln_`var'_`k' = ln_`var'*`var2'
local k=1+`k'
}
}
local Xv1_1 "ln_emp ln_hc ln_cn ln_ctfp Freshwater_withdrawal_rIR Total_water_withdrawal_pc"   
local Xv2_1 "ln_emp ln_hc ln_cn ln_ctfp FreshwaterWithdrawal_rtrwr Total_water_withdrawal_pc"
local Xv3_1 "ln_emp ln_hc ln_cn ln_ctfp WaterStress Total_water_withdrawal_pc"

local dXv1_1 "dln_emp dln_hc dln_cn dln_ctfp Freshwater_withdrawal_rIR Total_water_withdrawal_pc"   
local dXv2_1 "dln_emp dln_hc dln_cn dln_ctfp FreshwaterWithdrawal_rtrwr Total_water_withdrawal_pc"
local dXv3_1 "dln_emp dln_hc dln_cn dln_ctfp WaterStress Total_water_withdrawal_pc"

local dXXv1_1 "dln_emp dln_hc dln_ctfp Freshwater_withdrawal_rIR Total_water_withdrawal_pc"   
local dXXv2_1 "dln_emp dln_hc dln_ctfp FreshwaterWithdrawal_rtrwr Total_water_withdrawal_pc"
local dXXv3_1 "dln_emp dln_hc dln_ctfp WaterStress Total_water_withdrawal_pc"

local Xv1_2 "ln_emp ln_hc ln_cn ln_ctfp Freshwater_withdrawal_rIR Total_water_withdrawal_pc ln_emp_1 ln_hc_1 ln_cn_1 ln_ctfp_1"    
local Xv2_2 "ln_emp ln_hc ln_cn ln_ctfp FreshwaterWithdrawal_rtrwr Total_water_withdrawal_pc ln_emp_2 ln_hc_2 ln_cn_2 ln_ctfp_2"
local Xv3_2 "ln_emp ln_hc ln_cn ln_ctfp WaterStress Total_water_withdrawal_pc ln_emp_3 ln_hc_3 ln_cn_3 ln_ctfp_3"

local dXv1_2 "dln_emp dln_hc dln_cn dln_ctfp Freshwater_withdrawal_rIR Total_water_withdrawal_pc dln_emp_1 dln_hc_1 dln_cn_1 dln_ctfp_1"   
local dXv2_2 "dln_emp dln_hc dln_cn dln_ctfp FreshwaterWithdrawal_rtrwr Total_water_withdrawal_pc dln_emp_2 dln_hc_2 dln_cn_2 dln_ctfp_2"
local dXv3_2 "dln_emp dln_hc dln_cn dln_ctfp WaterStress Total_water_withdrawal_pc dln_emp_3 dln_hc_3 dln_cn_3 dln_ctfp_3"

local dXXv1_2 "dln_emp dln_hc dln_ctfp Freshwater_withdrawal_rIR Total_water_withdrawal_pc dln_emp_1 dln_hc_1 dln_ctfp_1"   
local dXXv2_2 "dln_emp dln_hc dln_ctfp FreshwaterWithdrawal_rtrwr Total_water_withdrawal_pc dln_emp_2 dln_hc_2 dln_ctfp_2"
local dXXv3_2 "dln_emp dln_hc dln_ctfp WaterStress Total_water_withdrawal_pc dln_emp_3 dln_hc_3 dln_ctfp_3"

g lnGDP = ln(GDPpcPPP2017usd)
local Xe1 "lnGDP"   //  Total_gr  "lnGDP GovernmentEffectiveness"

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

rename GDP_gr Total_gr  
local k=1
foreach var of varlist ln_cgdpo ln_rgdpo { 
forv V=1/2	 { 
reghdfe `var' `Xv1_`V'', absorb(id Year) vce(cluster id)   
outreg2 using "$pathR/tables/PWT_level.xls", `rep`k'' 
local k=2
foreach v of numlist 2/3 {  
reghdfe `var' `Xv`v'_`V'', absorb(id Year) vce(cluster id)   
outreg2 using "$pathR/tables/PWT_level.xls", `rep`k'' 
}
}
}
local k=1
foreach var of varlist dln_cgdpo dln_rgdpo { 
forv V=1/2	 { 	
reghdfe `var' `dXv1_`V'', absorb(id Year) vce(cluster id)   
outreg2 using "$pathR/tables/PWT_growth.xls", `rep`k'' 
local k=2
foreach v of numlist 2/3 {  
reghdfe `var' `dXv`v'_`V'', absorb(id Year) vce(cluster id)   
outreg2 using "$pathR/tables/PWT_growth.xls", `rep`k'' 
}
}
}
//     //
local k=1
foreach var of varlist Total_gr { 
forv V=1/2	 { 
reghdfe `var' `dXv1_`V'', absorb(id Year) vce(cluster id)   
outreg2 using "$pathR/tables/GDPgr_PWT.xls", `rep`k'' 
local k=2
foreach v of numlist 2/3 {  
reghdfe `var' `dXv`v'_`V'', absorb(id Year) vce(cluster id)   
outreg2 using "$pathR/tables/GDPgr_PWT.xls", `rep`k'' 
}
}
}
local k=1
foreach var of varlist GFCF_gr dln_cn GFCF_rGDP GFCF_Private_rGDP Gross_capital_formation_rGDP Gross_capital_formation_gr { 
forv V=1/2	 { 	
reghdfe `var' `dXXv1_`V'', absorb(id Year) vce(cluster id)   
outreg2 using "$pathR/tables/Investmentgr_PWT.xls", `rep`k'' 
local k=2
foreach v of numlist 2/3 {  
reghdfe `var' `dXXv`v'_`V'', absorb(id Year) vce(cluster id)   
outreg2 using "$pathR/tables/Investmentgr_PWT.xls", `rep`k'' 
}
}
}
//   //
