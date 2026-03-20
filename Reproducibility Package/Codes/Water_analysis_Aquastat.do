local G2 = "ysize(5.4) xsize(9.2) imargin(0 0) graphregion(color(white) margin(vsmall))"
local G4 = "ysize(10.8) xsize(9.2) imargin(0 0 0 0) graphregion(color(white) margin(vsmall))"

local VN1 "Agriculture, forestry & fishing"
local VN2 "Industry"
local VN3 "Services"
local gc0 "over(iso3, sort(value) descending)" 
local gc00 "over(iso2, sort(value) descending)" 
local gc1 "over(Reg, sort(value) descending)" 

local sdg00 "6.4.2 Level of water stress: freshwater withdrawal as a proportion of available freshwater resources > Overall (%) > Total"
local sdg0 "6.4.2 Level of water stress: freshwater withdrawal as a proportion of available freshwater resources > Overall (%)"
local sdg1 "6.4.2 Level of water stress: freshwater withdrawal as a proportion of available freshwater resources > Overall (%) > Agriculture, forestry and fishing"
local sdg2 "6.4.2 Level of water stress: freshwater withdrawal as a proportion of available freshwater resources > Overall (%) > Industry"
local sdg3 "6.4.2 Level of water stress: freshwater withdrawal as a proportion of available freshwater resources > Overall (%) > Services"


clear   // Prepare 6.4.2 data section of SDG-UN tables based on Aquastat
import excel "$path/Data/Excel/sdg6data_download10Mar2024_641_642.xlsx", sheet("Sheet1") firstrow
rename Geographicalareaname CountryName
run "$path/Codes/format_country_names.do" 
run "$path/Codes/format_country_names2.do"   //replace CountryN="Reunion" if CountryN=="RéUnion"
joinby CountryName using "$path/Data/Stata/CountryDataMatching_vs0.dta", unmatched(master) update
tab _merge   //tab CountryName if _merge!=3
drop _merge
tab Year
keep if Year=="2020"  //keep if SDGindicator=="6.4.2"
sum Value if SDG6Dataportallevel=="`sdg0'"
sum Value if SDG6Dataportallevel=="`sdg00'"  // tab if Reg=="Americas"  // SubReg  "Caribbean" "Central America" "Northern America" "South America"
*drop if Caribbean12==0 & SubReg=="Caribbean"
*drop if SubReg=="Northern America" & iso3!="CAN" & iso3!="USA"
*drop if SouthAmerica12==0 & SubReg=="South America"  // drop if iso3=="BLZ"  // another small Central America country
save "$pathDs/Aqua_642.dta", replace 

use "$pathDs/Aqua_642.dta", clear  // Figure2
keep if Indicatorname=="Total water withdrawal"
sum Value
destring Year, replace force  
joinby iso3 Year using "$pathDs/Data_WB.dta", unmatched(master) update
tab _merge
drop _merge
g value = Value*(1000*1000*1000)/(Population*365)  // daily_water_use_per_capita
keep iso2 iso3 value Reg SubReg Popu Year
save "$pathDs/data_temp.dta", replace 
keep if iso2=="KN" | iso2=="DM" | iso2=="LC" | iso2=="GD"
save "$pathDs/data_temp0.dta", replace 
use "$pathDs/Aquastat_Bulk.dta", clear
keep if variable=="Total water withdrawal per capita"  //keep if Reg=="Americas" 
tab Unit
keep if Year==2020
replace value = value/365
joinby iso2 Year using "$pathDs/data_temp.dta", unmatched(both) update
tab _merge
drop _merge
joinby iso2 Year using "$pathDs/data_temp0.dta", unmatched(both) update replace
tab _merge
drop _merge
local Vyl "m3" //"Daily water use per capita (m3)"
graph bar value if SubReg=="Caribbean", `gc00' ytitle("`Vyl'") subtitle("Caribbean") saving(graph1.gph, replace)
graph bar value if SubReg=="Central America" | SubReg=="Northern America", `gc00' ytitle("`Vyl'") subtitle("Central and North America") saving(graph2.gph, replace)
graph bar value if SubReg=="South America", `gc00' ytitle("`Vyl'") subtitle("South America") saving(graph3.gph, replace)
joinby iso3 Year using "$pathDs/Data_WB.dta", unmatched(master) update
g popW = ceil(Population/1000)
collapse value [fw=popW], by(Reg)
drop if Reg=="Americas"
graph bar value, `gc1' ytitle("`Vyl'") subtitle("Continents") saving(graph4.gph, replace)
graph combine graph1.gph graph2.gph graph3.gph graph4.gph, rows(4) cols(1) `G4' subtitle("Daily water use per capita (m3)")
if "`c(os)'" == "Windows" {
	graph export "$pathR/graphs/Fig2_daily_water_use_per_capita.emf", replace
}
graph export "$pathR/graphs/Fig2_daily_water_use_per_capita.png", replace 

use "$pathDs/Aqua_642.dta", clear    // Figure 3
keep if Reg=="Americas" 
keep if Indicatorname=="Level of water stress: freshwater withdrawal as a proportion of available freshwater resources (%)"
drop if SDG6Dataportallevel=="`sdg0'"  |  SDG6Dataportallevel=="`sdg00'"
keep Value SubReg iso2 iso3 CountryName SDG6Dataportallevel
drop if iso2=="VC"
drop if iso2=="BM"
forv s=1/3 {
replace SDG6Dataportallevel = "`s'" if SDG6Dataportallevel=="`sdg`s''"
}
destring SDG6Dataportallevel, replace force
reshape wide Value, i(SubReg iso2 iso3 CountryName) j(SDG6Dataportallevel) 
egen ValueAll = rowtotal(Value*)
replace Value1 = 100*Value1/ValueAll
replace Value2 = 100*Value2/ValueAll
replace Value3 = 100*Value3/ValueAll
local gc "over(iso2, sort(Value1) descending) stack ytitle("%") leg(lab(1 "`VN1'") lab(2 "`VN2'") lab(3 "`VN3'") bplace("b") pos(6) cols(3))" // iso3  // ytitle("Water stress (%)")
graph bar Value1 Value2 Value3 if SubReg=="Caribbean", `gc' subtitle("Caribbean") saving(graph1.gph, replace)
graph bar Value1 Value2 Value3 if SubReg=="Central America" | SubReg=="Northern America", `gc' subtitle("Central and North America") saving(graph2.gph, replace)
graph bar Value1 Value2 Value3 if SubReg=="South America", `gc' subtitle("South America") saving(graph3.gph, replace)
graph combine graph1.gph graph2.gph graph3.gph, rows(3) cols(1) `G4' subtitle("Freshwater withdrawal as a proportion of available" "freshwater resources: primary, secondary, tertiary sectors")
if "`c(os)'" == "Windows" {
	graph export "$pathR/graphs/Fig3_WaterStress_SectorsSDG.emf", replace
}
graph export "$pathR/graphs/Fig3_WaterStress_SectorsSDG.png", replace 


use "$pathDs/Data_WB.dta", clear    // Figure 4 with WB data
keep if Year==2020
drop if WaterStress==.
rename WaterStress value
drop if iso2=="GD"
graph bar value if SubReg=="Caribbean", `gc00' ytitle("%") subtitle("Caribbean") saving(graph1.gph, replace)
graph bar value if SubReg=="Central America" | SubReg=="Northern America", `gc00' ytitle("%") subtitle("Central and North America") saving(graph2.gph, replace)
graph bar value if SubReg=="South America", `gc00' ytitle("%") subtitle("South America") saving(graph3.gph, replace)
destring Year, replace force
joinby iso3 Year using "$pathDs/Data_WB.dta", unmatched(master) update
g popW = ceil(Population/1000)
collapse value [fw=popW], by(Reg)
drop if Reg=="Americas"
graph bar value, `gc1' ytitle("%") subtitle("Continents") saving(graph4.gph, replace)
graph combine graph1.gph graph2.gph graph3.gph graph4.gph, rows(4) cols(1) `G4' subtitle("Freshwater withdrawal as a proportion of available" "freshwater resources: Total")
if "`c(os)'" == "Windows" {
	graph export "$pathR/graphs/Fig4_WaterStress_WB.emf", replace
}
graph export "$pathR/graphs/Fig4_WaterStress_WB.png", replace

use "$pathDs/Data_WB.dta", clear    // Figure 5 with WB data
keep if Year==2020 | Year==2000
egen Period = group(Year)
egen id = group(iso3)
xtset id Period  // Year
g value = L.WaterStress
replace value = WaterStress-value
keep if Year==2020 & value<.
graph bar value if SubReg=="Caribbean", `gc00' ytitle("%") subtitle("Caribbean") saving(graph1.gph, replace)
graph bar value if SubReg=="Central America" | SubReg=="Northern America", `gc00' ytitle("%") subtitle("Central and North America") saving(graph2.gph, replace)
graph bar value if SubReg=="South America", `gc00' ytitle("%") subtitle("South America") saving(graph3.gph, replace)
joinby iso3 Year using "$pathDs/Data_WB.dta", unmatched(master) update
g popW = ceil(Population/1000)
collapse value [fw=popW], by(Reg)
drop if Reg=="Americas"
graph bar value, `gc1' ytitle("%") subtitle("Continents") saving(graph4.gph, replace)
graph combine graph1.gph graph2.gph graph3.gph graph4.gph, rows(4) cols(1) `G4' ///
subtitle("Freshwater withdrawal as a proportion of available" "freshwater resources: change between 2000 and 2020")
if "`c(os)'" == "Windows" {
	graph export "$pathR/graphs/Fig5_WaterStress_2000_2020_WB.emf", replace
}
graph export "$pathR/graphs/Fig5_WaterStress_2000_2020_WB.png", replace


clear   // 0 - Import and format Aquastat data
import delimited "$path/Data/CSV/AQUASTAT Statistics Bulk Download (English).csv"
rename m49 CountryCode      // over(... sort(var1) descending)
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
tab _merge //tab CountryN if _merge!=3   //keep if _merge==3
drop _merge
rename year Year
encode iso3, gen(id)
compress
drop if Caribbean12==0 & SubReg=="Caribbean"
drop if SubReg=="Northern America" & iso3!="CAN" & iso3!="USA"
drop if SouthAmerica12==0 & SubReg=="South America"  // drop if iso3=="BLZ"  // another small Central America country
save "$pathDs/Aquastat_Bulk.dta", replace
collapse value, by(variable)
keep variable
save "$pathDs/Aquastat_FullVariableList.dta", replace
export excel using "$pathDs/Aquastat_Dictionary.xls", firstrow(variables) replace  

//  This is another version of the same code with Aquastat (Bulk data): it creates the same Figures 2, 3, 4, 5 (but the bulk data has fewer countries)

/* use "$pathDs/Aquastat_Bulk.dta", clear
keep if variable=="Total water withdrawal per capita"  //keep if Reg=="Americas" 
tab Unit
keep if Year==2020
replace value = value/365
local Vyl "m3" //"Daily water use per capita (m3)"
graph bar value if SubReg=="Caribbean", `gc0' ytitle("`Vyl'") subtitle("Caribbean") saving(graph1.gph, replace)
graph bar value if SubReg=="Central America" | SubReg=="Northern America", `gc0' ytitle("`Vyl'") subtitle("Central and North America") saving(graph2.gph, replace)
graph bar value if SubReg=="South America", `gc0' ytitle("`Vyl'") subtitle("South America") saving(graph3.gph, replace)
joinby iso3 Year using "$pathDs/Data_WB.dta", unmatched(master) update
g popW = ceil(Population/1000)
collapse value [fw=popW], by(Reg)
graph bar value, `gc1' ytitle("`Vyl'") subtitle("Continents") saving(graph4.gph, replace)
graph combine graph1.gph graph2.gph graph3.gph graph4.gph, rows(4) cols(1) `G4' subtitle("Daily water use per capita (m3)")
graph export "$pathR/graphs/Fig2vs1_daily_water_use_per_capita.emf", replace
graph export "$pathR/graphs/Fig2vs1_daily_water_use_per_capita.png", replace */

/*use "$pathDs/Aqua_642.dta", clear  // Figure2 with SDG-UN values
keep if Indicatorname=="Total water withdrawal"
sum Value
destring Year, replace force  
joinby iso3 Year using "$pathDs/Data_WB.dta", unmatched(master) update
tab _merge
drop _merge
g value = Value*(1000*1000*1000)/(Population*365)  // daily_water_use_per_capita
local Vyl "m3" //"Daily water use per capita (m3)"
graph bar value if SubReg=="Caribbean", `gc00' ytitle("`Vyl'") subtitle("Caribbean") saving(graph1.gph, replace)
graph bar value if SubReg=="Central America" | SubReg=="Northern America", `gc00' ytitle("`Vyl'") subtitle("Central and North America") saving(graph2.gph, replace)
graph bar value if SubReg=="South America", `gc00' ytitle("`Vyl'") subtitle("South America") saving(graph3.gph, replace)
g popW = ceil(Population/1000)
collapse value [fw=popW], by(Reg)
graph bar value, `gc1' ytitle("`Vyl'") subtitle("Continents") saving(graph4.gph, replace)
graph combine graph1.gph graph2.gph graph3.gph graph4.gph, rows(4) cols(1) `G4' subtitle("Daily water use per capita (m3)")
graph export "$pathR/graphs/Fig2_daily_water_use_per_capita_SDG.emf", replace
graph export "$pathR/graphs/Fig2_daily_water_use_per_capita_SDG.png", replace */

/*use "$pathDs/Aquastat_Bulk.dta", clear   // This is another version of Figure 3 (if the researcher wants to do it, it has fewer countries)
keep if Reg=="Americas" 
keep if variable=="Agricultural water withdrawal as % of total water withdrawal" | variable=="Industrial water withdrawal as % of total water withdrawal" ///
  | variable=="Municipal water withdrawal as % of total withdrawal"
g SDG6Dataportallevel = 1 if variable=="Agricultural water withdrawal as % of total water withdrawal"
replace SDG6Dataportallevel = 2 if variable=="Industrial water withdrawal as % of total water withdrawal"
replace SDG6Dataportallevel = 3 if variable=="Municipal water withdrawal as % of total withdrawal"
rename value Value
keep if Year==2020
keep Value SubReg iso3 CountryName SDG6Dataportallevel
reshape wide Value, i(SubReg iso3 CountryName) j(SDG6Dataportallevel) 
replace Value3 = 100-Value1-Value2 if Value3==.   // g Value3 = 100-Value1-Value2
replace Value1 = 100-Value3-Value2 if Value1==.
replace Value2 = 100-Value3-Value1 if Value2==.
replace Value1 = max(0,Value1,100-Value3-Value2)
replace Value2 = max(0,Value2,100-Value3-Value1)
replace Value3 = max(0,Value3,100-Value1-Value2)
local gc "over(iso3, sort(Value1) descending) stack ytitle("%") leg(lab(1 "`VN1'") lab(2 "`VN2'") lab(3 "`VN3'") bplace("b") pos(6) cols(3))"   // ytitle("Water stress (%)")
graph bar Value1 Value2 Value3 if SubReg=="Caribbean", `gc' subtitle("Caribbean") saving(graph1.gph, replace)
graph bar Value1 Value2 Value3 if SubReg=="Central America" | SubReg=="Northern America", `gc' subtitle("Central and North America") saving(graph2.gph, replace)
graph bar Value1 Value2 Value3 if SubReg=="South America", `gc' subtitle("South America") saving(graph3.gph, replace)
graph combine graph1.gph graph2.gph graph3.gph, rows(3) cols(1) `G4' subtitle("Percentage of total water withdrawal used" "by the primary, secondary, tertiary sectors")
graph export "$pathR/graphs/Fig3vs1_WaterStress_Sectors.emf", replace
graph export "$pathR/graphs/Fig3vs1_WaterStress_Sectors.png", replace */

/*use "$pathDs/Aquastat_Bulk.dta", clear
keep if Year==2020
keep if variable=="SDG 6.4.2. Water Stress"
graph bar value if SubReg=="Caribbean", `gc0' ytitle("%") subtitle("Caribbean") saving(graph1.gph, replace)
graph bar value if SubReg=="Central America" | SubReg=="Northern America", `gc0' ytitle("%") subtitle("Central and North America") saving(graph2.gph, replace)
graph bar value if SubReg=="South America", `gc0' ytitle("%") subtitle("South America") saving(graph3.gph, replace)
joinby iso3 Year using "$pathDs/Data_WB.dta", unmatched(master) update
g popW = ceil(Population/1000)
collapse value [fw=popW], by(Reg)
graph bar value, `gc1' ytitle("%") subtitle("Continents") saving(graph4.gph, replace)
graph combine graph1.gph graph2.gph graph3.gph graph4.gph, rows(4) cols(1) `G4' subtitle("Freshwater withdrawal as a proportion of available" "freshwater resources: Total")
graph export "$pathR/graphs/Fig4vs1_WaterStress.emf", replace
graph export "$pathR/graphs/Fig4vs1_WaterStress.png", replace*/

/*use "$pathDs/Aqua_642.dta", clear    // Figure 4 with SDG data
keep if Indicatorname=="Level of water stress: freshwater withdrawal as a proportion of available freshwater resources (%)"
keep if SDG6Dataportallevel=="6.4.2 Level of water stress: freshwater withdrawal as a proportion of available freshwater resources > Overall (%) > Total"
bysort CountryName: egen nr=count(Value)
tab nr
rename Value value
graph bar value if SubReg=="Caribbean", `gc00' ytitle("%") subtitle("Caribbean") saving(graph1.gph, replace)
graph bar value if SubReg=="Central America" | SubReg=="Northern America", `gc00' ytitle("%") subtitle("Central and North America") saving(graph2.gph, replace)
graph bar value if SubReg=="South America", `gc00' ytitle("%") subtitle("South America") saving(graph3.gph, replace)
destring Year, replace force
joinby iso3 Year using "$pathDs/Data_WB.dta", unmatched(master) update
g popW = ceil(Population/1000)
collapse value [fw=popW], by(Reg)
graph bar value, `gc1' ytitle("%") subtitle("Continents") saving(graph4.gph, replace)
graph combine graph1.gph graph2.gph graph3.gph graph4.gph, rows(4) cols(1) `G4' subtitle("Freshwater withdrawal as a proportion of available" "freshwater resources: Total")
graph export "$pathR/graphs/Fig4_WaterStress_SDG.emf", replace
graph export "$pathR/graphs/Fig4_WaterStress_SDG.png", replace*/

/*use "$pathDs/Aquastat_Bulk.dta", clear   // Figure 5 with Aquastat (Bulk) data
keep if variable=="SDG 6.4.2. Water Stress"   //keep if Reg=="Americas" 
rename value Freshwater_Withdrawal
keep if Year==2020 | Year==2000
egen Period = group(Year)
xtset id Period  // Year
g D_Freshwater_Withdrawal = L.Freshwater_Withdrawal
replace D_Freshwater_Withdrawal = Freshwater_Withdrawal-D_Freshwater_Withdrawal
keep if Year==2020 & D_Freshwater_Withdrawal<.
local gc "over(iso3, sort(D_Freshwater_Withdrawal) descending)"
local gcC "over(Reg, sort(D_Freshwater_Withdrawal) descending)"
graph bar D_Freshwater_Withdrawal if SubReg=="Caribbean", `gc' ytitle("%") subtitle("Caribbean") saving(graph1.gph, replace)
graph bar D_Freshwater_Withdrawal if SubReg=="Central America" | SubReg=="Northern America", `gc' ytitle("%") subtitle("Central and North America") saving(graph2.gph, replace)
graph bar D_Freshwater_Withdrawal if SubReg=="South America", `gc' ytitle("%") subtitle("South America") saving(graph3.gph, replace)
joinby iso3 Year using "$pathDs/Data_WB.dta", unmatched(master) update
g popW = ceil(Population/1000)
collapse D_Freshwater_Withdrawal [fw=popW], by(Reg)
graph bar D_Freshwater_Withdrawal, `gcC' ytitle("%") subtitle("Continents") saving(graph4.gph, replace)
graph combine graph1.gph graph2.gph graph3.gph graph4.gph, rows(4) cols(1) `G4' ///
subtitle("Freshwater withdrawal as a proportion of available" "freshwater resources: change between 2000 and 2020")
graph export "$pathR/graphs/Fig5vs1_WaterStress_2000_2020.emf", replace
graph export "$pathR/graphs/Fig5vs1_WaterStress_2000_2020.png", replace*/
