local G2 = "ysize(5.4) xsize(9.2) imargin(0 0) graphregion(color(white) margin(vsmall))"
local G4 = "ysize(10.8) xsize(9.2) imargin(0 0 0 0) graphregion(color(white) margin(vsmall))"
local rep1 "replace"
local rep2 "append"
local sdg0 "6.4.1 Change in water-use efficiency over time > Water-use efficiency (USD/m3) > Overall"
local sdg1 "6.4.1 Change in water-use efficiency over time > Water-use efficiency (USD/m3) > Agriculture, forestry and fishing"
local sdg2 "6.4.1 Change in water-use efficiency over time > Water-use efficiency (USD/m3) > Industry"
local sdg3 "6.4.1 Change in water-use efficiency over time > Water-use efficiency (USD/m3) > Services"
local VN0 "Total"   
local VN1 "Agriculture, forestry & fishing"
local VN2 "Industry"
local VN3 "Services"  //use "$path/DataF/Aquastat_Bulk.dta", clear use "$path/DataF/Aquastat_Selected.dta", clear  use "$path/DataF/WGI.dta", clear

use "$pathDs/INDSTAT2_natcur_sel.dta", clear
sum growth_value IIP_gr Female_workers_gr GFCF_gr VA_gr Output_gr Wages_gr Workers_gr Establishments_gr
sum ISIC*
drop if ISIC_C==.
rename ISO3 iso3
joinby iso3 Year using "$pathDs/Data_WB.dta", unmatched(both) update
tab _merge  
keep if _merge==3
drop _merge
joinby CountryName Year using "$pathDs/Aquastat_Selected.dta", unmatched(both) update
tab _merge  
keep if _merge==3
drop _merge
joinby iso3 Year using "$pathDs/WGI.dta", unmatched(master) update
drop _merge
joinby iso3 Year using "$pathDs/PWT_new.dta", unmatched(master) update
drop _merge
foreach var1 of varlist growth_value* IIP_gr Female_workers_gr GFCF_gr Output_gr Wages_gr Workers_gr Establishments_gr VA_gr Size_VA_lag first_Size_VA_lag {
replace `var1'=100*`var1' if `var1'<.  //sum `var1', d //replace `var1' = max( r(p1), min(r(p99),`var1') ) if `var1'<.  // Does not change results much
}	
foreach var1 of varlist GFCF_gr Output_gr Wages_gr VA_gr {
replace `var1'=`var1'-CPI_inf 	
}	
sum growth_value GDP_gr IIP_gr Female_workers_gr GFCF_gr VA_gr Output_gr Wages_gr Workers_gr Establishments_gr

// Source: Worldmetrics.org https://worldmetrics.org/water-consumption-by-industry-statistics/
g WD = 0.54 if ISIC==15
replace WD = 0.17 if ISIC==17    // 0.26 ? di 0.04/0.1540
replace WD = 0.015 if ISIC==18
replace WD = 0.015 if ISIC==19
replace WD = 0.03 if ISIC==21  // 0.12 ?
replace WD = 0.03 if ISIC==23
replace WD = 0.05 if ISIC==24   // 0.04 or 0.05
replace WD = 0.005 if ISIC==26
replace WD = 0.005 if ISIC==27
replace WD = 0.06 if ISIC==30
replace WD = 0.07 if ISIC==34
replace WD = 0.01 if ISIC==35   // di 12*.0833333 = .9999996  //di 12*0.0841667  = 1.0100004
replace WD = 0 if ISIC!=38 & WD==.

capture drop id
egen id = group(iso3 ISIC)
xtset id Year
foreach var of varlist Freshwater_withdrawal_rIR FreshwaterWithdrawal_rtrwr WaterStress {   // Total_freshwater_withdrawal
replace `var' = min(100, `var') if `var'<.
}
sum AgricultureForestryFishing_rGDP Industry_rGDP Services_rGDP
local Xv1 "Freshwater_withdrawal_rIR FreshwaterWithdrawal_rtrwr WaterStress Total_water_withdrawal_pc WaterProductivity WaterUseEfficiency" 
quietly { 
foreach var of varlist `Xv1' growth_value AgricultureForestryFishing_gr Manufacturing_gr Services_gr { 
sum `var', d
replace `var' = min(r(p99), `var') if `var'<.
}
}
foreach var of varlist Total_water_withdrawal_pc { 
replace `var' = ln(`var')
}
local Xv1 "Freshwater_withdrawal_rIR Total_water_withdrawal_pc"   // Use regressions 1, 2, 3, 7, 8, 
local Xv2 "FreshwaterWithdrawal_rtrwr Total_water_withdrawal_pc"
local Xv3 "WaterStress Total_water_withdrawal_pc"
local Xv_1 "c.(Freshwater_withdrawal_rIR Total_water_withdrawal_pc)#c.(WD)"   // Use regressions 1, 2, 3, 7, 8, 
local Xv_2 "c.(FreshwaterWithdrawal_rtrwr Total_water_withdrawal_pc)#c.(WD)"
local Xv_3 "c.(WaterStress Total_water_withdrawal_pc)#c.(WD)"

g lnGDP = ln(GDPpcPPP2017usd)
local Xe1 " lagGDPpc GDP_gr" //  Size_VA_lag

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

g lagGDPpc = L.lnGDP
g lagpop = L.pop
replace lagpop = ln(lagpop)

reghdfe growth_value `Xv1' `Xe1' if ISIC==38, absorb(id) vce(cluster id)   
outreg2 using "$pathR/tables/IIP_gr.xls", replace
foreach v of numlist 2/3 {  // Total manufacturing
reghdfe growth_value `Xv`v'' `Xe1' if ISIC==38, absorb(id) vce(cluster id)   
outreg2 using "$pathR/tables/IIP_gr.xls", append
}
foreach v of numlist 1/3 {  // Individual manufactures
reghdfe growth_value `Xv_`v'' `Xe1', absorb(id Year) vce(cluster id)   
outreg2 using "$pathR/tables/IIP_gr.xls", append
}
foreach v of numlist 1/3 {  // Individual manufactures
reghdfe growth_value `Xv`v'' `Xv_`v'' `Xe1', absorb(id Year) vce(cluster id)   
outreg2 using "$pathR/tables/IIP_gr.xls", append
}
foreach var1 of varlist Female_workers_gr GFCF_gr Output_gr Wages_gr Workers_gr Establishments_gr VA_gr {
reghdfe `var1' `Xv1' `Xe1' if ISIC==38, absorb(id) vce(cluster id)   
outreg2 using "$pathR/tables/`var1'.xls", replace
foreach v of numlist 2/3 {  // Total manufacturing
reghdfe `var1' `Xv`v'' `Xe1' if ISIC==38, absorb(id) vce(cluster id)   
outreg2 using "$pathR/tables/`var1'.xls", append
}
foreach v of numlist 1/3 {  // Individual manufactures
reghdfe `var1' `Xv_`v'' `Xe1', absorb(id Year) vce(cluster id)   
outreg2 using "$pathR/tables/`var1'.xls", append
}
foreach v of numlist 1/3 {  // Individual manufactures
reghdfe `var1' `Xv`v'' `Xv_`v'' `Xe1', absorb(id Year) vce(cluster id)   
outreg2 using "$pathR/tables/`var1'.xls", append
}
}
//   //
local i=34   // Motor vehicles, trailers, semi-trailers 
reghdfe growth_value `Xv_1' `Xe1' if ISIC==`i', absorb(id) vce(cluster id)   
outreg2 using "$pathR/tables/Automotive_gr.xls", replace
foreach v of numlist 2/3 {  // for each water measure
reghdfe growth_value `Xv_`v'' `Xe1' if ISIC==`i', absorb(id) vce(cluster id)   
outreg2 using "$pathR/tables/Automotive_gr.xls", append
}
//     //

quietly { 
foreach v of numlist 1/3 {  // for each water measure
reghdfe growth_value `Xv`v'' `Xe1' if ISIC==15, absorb(id) vce(cluster id)   
outreg2 using "$pathR/tables/IIP_gr_W`v'.xls", replace
foreach i of numlist 16/36 {  // each industry (look: Non-metallic mineral products 26, Medical, precision and optical instruments 33, Motor vehicles, trailers, semi-trailers 34)
reghdfe growth_value `Xv`v'' `Xe1' if ISIC==`i', absorb(id) vce(cluster id)   
outreg2 using "$pathR/tables/IIP_gr_W`v'.xls", append
}
}
}
//   //
