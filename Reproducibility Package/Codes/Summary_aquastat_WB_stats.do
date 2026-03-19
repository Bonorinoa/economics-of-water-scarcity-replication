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
sum Freshwater_withdrawal_rIR FreshwaterWithdrawal_rtrwr WaterStress, d
pwcorr Freshwater_withdrawal_rIR FreshwaterWithdrawal_rtrwr WaterStress
foreach var of varlist Freshwater_withdrawal_rIR FreshwaterWithdrawal_rtrwr WaterStress {   // Total_freshwater_withdrawal
replace `var' = min(100, `var') if `var'<.
}
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
tabstat D_Freshwater_withdrawal_rIR D_FreshwaterWithdrawal_rtrwr D_WaterStress D_WaterProductivity  D_WaterUseEfficiency, statistics(sd)

rename GDP_gr Total_gr  
local YXvars "Total_gr GFCF_gr CPI_inf Freshwater_withdrawal_rIR FreshwaterWithdrawal_rtrwr WaterStress Total_water_withdrawal_pc WaterProductivity WaterUseEfficiency lnGDP" 
local xstats "min max median mean sd"
save "$pathDs/data_temp.dta", replace

local k=1
foreach stat of local xstats {  
use "$pathDs/data_temp.dta", clear
collapse (`stat') `YXvars'
xpose, clear varname
rename v1 `stat'
if `k'>1  { 
joinby _varname using "$pathDs/data_temp0.dta", unmatched(both) update
tab _merge
drop _merge
}	
local k=2
save "$pathDs/data_temp0.dta", replace
}
order _varname min max median mean sd, first
export excel using "$pathR/tables/SummaryStats.xls", firstrow(variables) nolabel replace		
