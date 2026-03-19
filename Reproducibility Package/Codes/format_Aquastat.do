clear   // 0 - Import and format Aquastat data
import delimited "$path/Data/CSV/AQUASTAT Statistics Bulk Download (English).csv"
rename m49 CountryCode
tab symboldescription
tab symbol symboldescription
rename country CountryName
summarize
describe, short
tab unit
encode unit, g(Unit)
drop v1 unit
collapse (mean) value, by(CountryName CountryCode variable Unit year)
compress
summarize
describe, short
run "$path/Codes/format_country_names.do" 
run "$path/Codes/format_country_names2.do" 
joinby CountryName using "$path/Data/Stata/CountryDataMatching_vs0.dta", unmatched(master) update
order iso2 iso3 Reg SubReg, first
drop _merge-SouthAmerica12
rename year Year
compress _all
save "$pathDs/Aquastat_Bulk.dta", replace

local v1 "Agricultural water withdrawal as % of total renewable water resources"
local v2 "Agricultural water withdrawal as % of total water withdrawal"
local v3 "Flood occurrence (WRI)"
local v4 "Industrial water withdrawal as % of total water withdrawal"
local v5 "MDG 7.5. Freshwater withdrawal as % of total renewable water resources"
local v6 "Municipal water withdrawal as % of total withdrawal"
local v7 "SDG 6.4.1. Industrial Water Use Efficiency"
local v8 "SDG 6.4.1. Irrigated Agriculture Water Use Efficiency"
local v9 "SDG 6.4.1. Services Water Use Efficiency"
local v10 "SDG 6.4.1. Water Use Efficiency"
local v11 "SDG 6.4.2. Water Stress"
local v12 "Total dam capacity"
local v13 "Total exploitable water resources"
local v14 "Total freshwater withdrawal"
local v15 "Total population with access to safe drinking-water (JMP)"
local v16 "Total renewable water resources"
local v17 "Total renewable water resources per capita"
local v18 "Total water withdrawal"
local v19 "Total water withdrawal per capita"
local v20 "Water resources: total external renewable"
local v21 "Water withdrawal for aquaculture"
local v22 "Water withdrawal for cooling of thermoelectric plants"
local v23 "Water withdrawal for livestock (watering and cleaning)"

local n1 "Agriculture_WaterWithdrawal_rwr"
local n2 "Agriculture_WaterWithdrawal_rtww"
local n3 "Flood_occurrence"
local n4 "Industry_WaterWithdrawal_rtww"
local n5 "FreshwaterWithdrawal_rtrwr"
local n6 "Services_WaterWithdrawal_rtww"
local n7 "Industry_WaterUseEfficiency"
local n8 "Agriculture_WaterUseEfficiency"
local n9 "Services_WaterUseEfficiency"
local n10 "WaterUseEfficiency"
local n11 "WaterStress"
local n12 "Total_dam_capacity"
local n13 "Exploitable_water_resources"
local n14 "Total_freshwater_withdrawal"
local n15 "Population_access_safe_water"
local n16 "TotalRenewableWaterResources"
local n17 "TotalRenewableWaterResources_pc"
local n18 "Total_water_withdrawal"
local n19 "Total_water_withdrawal_pc"
local n20 "Water_resources_renewable"
local n21 "WaterWithdrawal_aquaculture"
local n22 "WaterWithdrawal_Thermoelectric"
local n23 "WaterWithdrawal_Livestock"

forv d=1/23 {
use "$pathDs/Aquastat_Bulk.dta", clear
keep if variable =="`v`d''"
rename value `n`d''
drop variable Unit
if `d'>1  {
joinby CountryName CountryCode Year using "$pathDs/Aquastat_Selected.dta", unmatched(both) update
tab _merge
drop _merge
}	
save "$pathDs/Aquastat_Selected.dta", replace
}
//
