local d1 "access to eletricity"
local d2 "eletricity from coal in %"
local d3 "electricity from fossil fuels in %"
local d4 "eletricity from hydro in %"  
local d5 "eletric power losses in %"
local d6 "eletricity from nuclear in %"
local d7 "eletricity from oil sources in %"
local d8 "eletricity from renewable non hydro sources in %"  
local d9 "eletricity from renewable non hydro sources in Kwh"  
local d10 "USDxr"  

local v1 "AccessElec"
local v2 "ElecCoalSh"
local v3 "ElecFossilSh"
local v4 "ElecHydroSh"
local v5 "PowerLossSh"
local v6 "ElecNuclearSh"
local v7 "ElecOilSh"
local v8 "ElecRenewablesNonHydroSh"  
local v9 "ElecRenewablesNonHydro_Kwh"  
local v10 "USDxr"

forv d=1/10 {
clear
import excel "$path/Data/Excel/WB `d`d''.xls", sheet("Data") cellrange(A4:BP270) firstrow
local k=1960
foreach var of varlist E-BP {
rename `var' V`k' 
local k=1+`k' 
}
local vInd =IndicatorName[1]
drop IndicatorCode IndicatorName
reshape long V, i(CountryName CountryCode) j(Year)
label var V "`vInd'"
rename V `v`d'' 
if `d'>1 {
joinby CountryName CountryCode Year using "$pathDs/WB_eletricity.dta", unmatched(both) update
tab _merge
drop _merge
}	
save "$pathDs/WB_eletricity.dta", replace  
}
rename CountryCode iso3 
run "$path/Codes/format_country_names.do" 
run "$path/Codes/format_country_names2.do"
joinby iso3 using "$path/Data/Stata/CountryDataMatching_vs0.dta", unmatched(master) update
tab _merge   
drop _merge  
save "$pathDs/WB_eletricity.dta", replace 
