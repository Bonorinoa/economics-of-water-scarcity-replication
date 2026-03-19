local G2 = "ysize(5.4) xsize(9.2) imargin(0 0) graphregion(color(white) margin(vsmall))"
local G4 = "ysize(10.8) xsize(9.2) imargin(0 0 0 0) graphregion(color(white) margin(vsmall))"
local rep1 "replace"
local rep2 "append"

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
encode iso3, gen(id)
drop if Year<1990
drop if Year>2020
xtset id Year
local Xv1 "Freshwater_withdrawal_rIR FreshwaterWithdrawal_rtrwr WaterStress Total_water_withdrawal_pc WaterProductivity WaterUseEfficiency" 
quietly { 
foreach var of varlist `Xv1' { 
sum `var', d
replace `var' = min(r(p99), `var') if `var'<.
}
}
foreach var of varlist Total_water_withdrawal_pc WaterProductivity WaterUseEfficiency { 
replace `var' = ln(`var')
}
local Xv1 "Freshwater_withdrawal_rIR Total_water_withdrawal_pc"   // Use regressions 1, 2, 3
local Xv2 "FreshwaterWithdrawal_rtrwr Total_water_withdrawal_pc"
local Xv3 "WaterStress Total_water_withdrawal_pc"
g lnGDP = ln(GDPpcPPP2017usd)
local Xe1 "lnGDP"   // i.(Year)
local Xe2 "lnGDP GovernmentEffectiveness"

rename GDP_gr Total_gr  
foreach qr of numlist 0.25 0.50 0.75 {  
local q=100*`qr'
local k=1
foreach var of varlist Total_gr CPI_inf { 
xtqreg `var' `Xv1' `Xe1', id(id) q(`qr') 
outreg2 using "$pathR/tables/GDPgr_QR`q'.xls", `rep`k'' 
local k=2
foreach v of numlist 2 3 {  
xtqreg `var' `Xv`v'' `Xe1', id(id) q(`qr')  
outreg2 using "$pathR/tables/GDPgr_QR`q'.xls", `rep`k'' 
}
}
local k=1
foreach var of varlist FoodProduction NaturalResourceRents { 
xtqreg `var' `Xv1' `Xe1', id(id) q(`qr') 
outreg2 using "$pathR/tables/Food_NatResR_QR`q'.xls", `rep`k'' 
local k=2
foreach v of numlist 2 3 { 
xtqreg `var' `Xv`v'' `Xe1', id(id) q(`qr')  
outreg2 using "$pathR/tables/Food_NatResR_QR`q'.xls", `rep`k'' 
}
}
local k=1
foreach var of varlist GFCF_gr { // Gross_capital_formation_gr Gross_capital_formation_rGDP GFCF_Private_rGDP GFCF_rGDP GFCF_Private_rGDP GFCF_rGDP
xtqreg `var' `Xv1' `Xe1', id(id) q(`qr') 
outreg2 using "$pathR/tables/Investment_QR`q'.xls", `rep`k''
local k=2
foreach v of numlist 2 3 {  
xtqreg `var' `Xv`v'' `Xe1', id(id) q(`qr')  
outreg2 using "$pathR/tables/Investment_QR`q'.xls", `rep`k'' 
}
}
}
//   //
