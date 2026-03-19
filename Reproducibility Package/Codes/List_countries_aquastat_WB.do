local G2 = "ysize(5.4) xsize(9.2) imargin(0 0) graphregion(color(white) margin(vsmall))"
local G4 = "ysize(10.8) xsize(9.2) imargin(0 0 0 0) graphregion(color(white) margin(vsmall))"

local VN1 "Agriculture, forestry & fishing"
local VN2 "Industry"
local VN3 "Services"

use "$pathDs/Aquastat_Selected.dta", clear
describe, short
run "$path/Codes/format_country_names.do" 
run "$path/Codes/format_country_names2.do" 
joinby CountryName using "$path/Data/Stata/CountryDataMatching_vs0.dta", unmatched(master) update
order iso3 *AE*, first
tab _merge //tab CountryN if _merge!=3   //keep if _merge==3
drop _merge-SouthAmerica12
save "$pathDs/Aquastat_Selected.dta", replace


use "$pathDs/Data_WB.dta", clear  // Aquastat_Bulk.dta 
joinby iso3 Year using "$pathDs/Aquastat_Selected.dta", unmatched(both) update  // joinby CountryName Year
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
egen a = rowmax(Total_freshwater_withdrawal Total_water_withdrawal FreshwaterWithdrawal_rtrwr Total_water_withdrawal_pc Freshwater_withdrawal_rIR WaterProductivity WaterUseEfficiency)
sum GDP_gr if WaterStress<.
sum GDP_gr WaterStress Total_freshwater_withdrawal Total_water_withdrawal FreshwaterWithdrawal_rtrwr Total_water_withdrawal_pc
keep if a<. & GDP_gr<.
egen AE = rowmax(*AE*)
recode AE 2=1
sum AE
collapse Year, by(iso2 CountryName AE)
keep AE CountryName iso2
sort AE CountryName
order AE Coun iso2
export excel using "$pathR/tables/ListCountries_Water.xlsx", firstrow(variables) replace
