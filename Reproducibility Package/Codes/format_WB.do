local d1 "API_CC.EST_DS2_en_excel_v2_402383"
local d2 "API_GE.EST_DS2_en_excel_v2_424793"
local d3 "API_PV.EST_DS2_en_excel_v2_427160"
local d4 "API_RL.EST_DS2_en_excel_v2_406588"  
local d5 "API_RQ.EST_DS2_en_excel_v2_327322"
local d6 "API_VA.EST_DS2_en_excel_v2_445466"

local v1 "ControlCorruption"
local v2 "GovernmentEffectiveness "
local v3 "PoliticalStability"
local v4 "RuleLaw" 
local v5 "RegulatoryQuality"
local v6 "VoiceAccountability"

forv d=1/6 { // More World Bank Data
clear
import excel "$path/Data/Excel/`d`d''.xls", sheet("Data") cellrange(A4:BP270) firstrow
local k=1960
foreach var of varlist E-BP {
rename `var' V`k' 
local k=1+`k' 
}
local vInd =IndicatorName[1]
drop IndicatorCode IndicatorName CountryName V2023
reshape long V, i(CountryCode) j(Year)
label var V "`vInd'"
rename V `v`d'' 
if `d'>1 {
joinby CountryCode Year using "$pathDs/WGI.dta", unmatched(both) update
tab _merge
drop _merge
}	
save "$pathDs/WGI.dta", replace   
}
rename CountryCode iso3 
save "$pathDs/WGI.dta", replace  

local d1 "CPI inflation"
local d2 "GDP growth at constant local currency"
local d3 "GDP pc PPP constant 2017 USD"
local d4 "Aquastat water stress"  // freshwater withdrawal
local d5 "Population"
local d6 "Gross capital formation as a fraction of GDP"
local d7 "Gross capital formation real annual growth"
local d8 "Gross fixed capital formation of private sector"  // as a fraction of GDP
local d9 "Gross fixed capital formation as a fraction of GDP"
local d10 "Industry as a fraction of GDP"
local d11 "Industry real annual growth"
local d12 "Services as a fraction of GDP"
local d13 "Services real annual growth"
local d14 "Manufacturing as a fraction of GDP"
local d15 "Manufacturing real annual growth"
local d16 "Agriculture Forestry Fishing as a fraction of GDP"
local d17 "Agriculture Forestry Fishing real annual growth"
local d18 "freshwater withdrawals as a fraction of available internal resources"
local d19 "WaterProductivity"
local d20 "freshwater withdrawal Agriculture"
local d21 "freshwater withdrawal Industry"
local d22 "freshwater withdrawal DomesticServices"
local d23 "Gross fixed capital formation real annual growth"
local d24 "Food production index"
local d25 "Total natural resources rents as a fraction of GDP"

local v1 "CPI_inf"
local v2 "GDP_gr"
local v3 "GDPpcPPP2017usd"
local v4 "WaterStress" //Freshwater_Withdrawal //Freshwater_withdrawal_rAFR
local v5 "Population"
local v6 "Gross_capital_formation_rGDP"
local v7 "Gross_capital_formation_gr"
local v8 "GFCF_Private_rGDP"  
local v9 "GFCF_rGDP"
local v10 "Industry_rGDP"
local v11 "Industry_gr"
local v12 "Services_rGDP"
local v13 "Services_gr"
local v14 "Manufacturing_rGDP"
local v15 "Manufacturing_gr"
local v16 "AgricultureForestryFishing_rGDP"
local v17 "AgricultureForestryFishing_gr"
local v18 "Freshwater_withdrawal_rIR"
local v19 "WaterProductivity"
local v20 "FreshwaterWithdrawal_Agriculture"
local v21 "FreshwaterWithdrawal_Industry"
local v22 "FreshwaterWithdrawal_Services"
local v23 "GFCF_gr"
local v24 "FoodProduction"
local v25 "NaturalResourceRents"

forv d=1/25 {
clear
import excel "$path/Data/Excel/WB `d`d''.xls", sheet("Data") firstrow
local k=1960
foreach var of varlist E-BO {
rename `var' V`k' 
local k=1+`k' 
}
local vInd =IndicatorName[1]
drop IndicatorCode IndicatorName
reshape long V, i(CountryName CountryCode) j(Year)
label var V "`vInd'"
rename V `v`d'' 
if `d'>1 {
joinby CountryName CountryCode Year using "$pathDs/Data_WB.dta", unmatched(both) update
tab _merge
drop _merge
}	
save "$pathDs/Data_WB.dta", replace  
}
capture rename CountryCode iso3 
run "$path/Codes/format_country_names.do" 
run "$path/Codes/format_country_names2.do"
joinby iso3 using "$path/Data/Stata/CountryDataMatching_vs0.dta", unmatched(master) update
tab _merge   // tab CountryName if _merge!=3  tab iso3 if _merge!=3
drop _merge  //drop if Caribbean12==0 & SubReg=="Caribbean"   drop if SubReg=="Northern America" & iso3!="CAN" & iso3!="USA" drop if SouthAmerica12==0 & SubReg=="South America"  // drop if iso3=="BLZ"  // another small Central America country
save "$pathDs/Data_WB.dta", replace 
