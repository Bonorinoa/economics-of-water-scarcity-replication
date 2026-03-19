local G2 = "ysize(5.4) xsize(9.2) imargin(0 0) graphregion(color(white) margin(vsmall))"
local G4 = "ysize(10.8) xsize(9.2) imargin(0 0 0 0) graphregion(color(white) margin(vsmall))"

local sdg0 "6.4.1 Change in water-use efficiency over time > Water-use efficiency (USD/m3) > Overall"
local sdg1 "6.4.1 Change in water-use efficiency over time > Water-use efficiency (USD/m3) > Agriculture, forestry and fishing"
local sdg2 "6.4.1 Change in water-use efficiency over time > Water-use efficiency (USD/m3) > Industry"
local sdg3 "6.4.1 Change in water-use efficiency over time > Water-use efficiency (USD/m3) > Services"

local VN0 "Total"   
local VN1 "Agriculture, forestry & fishing"
local VN2 "Industry"
local VN3 "Services"

clear
import excel "$path/Data/Excel/sdg6data_download10Mar2024_641_642.xlsx", sheet("Sheet1") firstrow
destring Year, replace force
collapse (max) Year, by(Indicatorname SDG6Dataportallevel)
tab Year
export excel using "$pathDs/SDG_UN_Dictionary.xls", firstrow(variables) replace  

clear
import excel "$path/Data/Excel/sdg6data_download10Mar2024_641_642.xlsx", sheet("Sheet1") firstrow
rename Geographicalareaname CountryName
run "$path/Codes/format_country_names.do" 
run "$path/Codes/format_country_names2.do"   //replace CountryN="Reunion" if CountryN=="RéUnion"
joinby CountryName using "$path/Data/Stata/CountryDataMatching_vs0.dta", unmatched(master) update
tab _merge   //tab CountryName if _merge!=3
drop _merge
tab Year
keep if Indicatorname=="Water Use Efficiency (United States dollars per cubic meter)"
keep if Year=="2020"
drop if Caribbean12==0 & SubReg=="Caribbean"
drop if SubReg=="Northern America" & iso3!="CAN" & iso3!="USA"
drop if SouthAmerica12==0 & SubReg=="South America"  // drop if iso3=="BLZ"  // another small Central America country
save "$pathDs/Aqua_642.dta", replace 
keep if SDG6Dataportallevel=="`sdg0'"
bysort CountryName: egen nr=count(Value)
tab nr
graph bar Value if SubReg=="Caribbean", over(iso3, sort(Value) descending) ytitle("USDm3") subtitle("Caribbean") saving(graph1.gph, replace)
graph bar Value if SubReg=="Central America" | SubReg=="Northern America", over(iso3, sort(Value) descending) ytitle("USDm3") subtitle("Central and North America") saving(graph2.gph, replace)
graph bar Value if SubReg=="South America", over(iso3, sort(Value) descending) ytitle("USDm3") subtitle("South America") saving(graph3.gph, replace)
*graph combine graph1.gph graph2.gph graph3.gph, rows(3) cols(1) `G4' subtitle("Ratio of dollar value added to the volume of water used")
*graph export "$pathR/graphs/FigA1_USDm3.emf", replace
*graph export "$pathR/graphs/FigA1_USDm3.png", replace
clear
import excel "$path/Data/Excel/sdg6data_download10Mar2024_641_642.xlsx", sheet("Sheet1") firstrow
rename Geographicalareaname CountryName
run "$path/Codes/format_country_names.do" 
run "$path/Codes/format_country_names2.do"   //replace CountryN="Reunion" if CountryN=="RéUnion"
joinby CountryName using "$path/Data/Stata/CountryDataMatching_vs0.dta", unmatched(master) update
tab _merge   //tab CountryName if _merge!=3
drop _merge
tab Year
keep if Indicatorname=="Water Use Efficiency (United States dollars per cubic meter)"
keep if Year=="2020"
keep if SDG6Dataportallevel=="`sdg0'"
bysort CountryName: egen nr=count(Value)
destring Year, replace force
joinby iso3 Year using "$pathDs/Data_WB.dta", unmatched(master) update
g popW = ceil(Population/1000)
collapse Value [fw=popW], by(Reg)
graph bar Value, over(Reg, sort(Value) descending) ytitle("USDm3") subtitle("Continents") saving(graph4.gph, replace)
graph combine graph1.gph graph2.gph graph3.gph graph4.gph, rows(4) cols(1) `G4' subtitle("Ratio of dollar value added to the volume of water used")
if "`c(os)'" == "Windows" {
	graph export "$pathR/graphs/FigA1_USDm3.emf", replace
}
graph export "$pathR/graphs/FigA1_USDm3.png", replace


use "$pathDs/Aqua_642.dta", clear
keep if Reg=="Americas" 
drop if SDG6Dataportallevel=="`sdg0'" 
keep Value SubReg iso2 CountryName SDG6Dataportallevel  // iso3
forv s=1/3 {
replace SDG6Dataportallevel = "`s'" if SDG6Dataportallevel=="`sdg`s''"
}
destring SDG6Dataportallevel, replace force
reshape wide Value, i(SubReg iso2 CountryName) j(SDG6Dataportallevel)  // iso3
local gc "ytitle("USDm3") leg(lab(1 "`VN1'") lab(2 "`VN2'") lab(3 "`VN3'") bplace("b") pos(6) cols(3))"   // stack
local gc1 "over(iso2, sort(Value1) descending) `gc'"   // iso3
local gc2 "over(iso2, sort(Value2) descending) `gc'"  
local gc3 "over(iso2, sort(Value3) descending) `gc'"  
keep if Value1<. & Value2<. & Value3<.
graph bar Value1 if SubReg=="Caribbean", `gc1' subtitle("Agriculture, forestry & fishing") saving(graph1.gph, replace)
graph bar Value2 if SubReg=="Caribbean", `gc2' subtitle("Industry") saving(graph2.gph, replace)
graph bar Value3 if SubReg=="Caribbean", `gc3' subtitle("Services") saving(graph3.gph, replace)
graph combine graph1.gph graph2.gph graph3.gph, rows(1) cols(3) subtitle("Caribbean") saving(graph01.gph, replace)
graph bar Value1 if SubReg=="Central America" | SubReg=="Northern America", `gc1' subtitle("Agriculture, forestry & fishing") saving(graph1.gph, replace)
graph bar Value2 if SubReg=="Central America" | SubReg=="Northern America", `gc2' subtitle("Industry") saving(graph2.gph, replace)
graph bar Value3 if SubReg=="Central America" | SubReg=="Northern America", `gc3' subtitle("Services") saving(graph3.gph, replace)
graph combine graph1.gph graph2.gph graph3.gph, rows(1) cols(3) subtitle("Central and North America") saving(graph02.gph, replace)
graph bar Value1 if SubReg=="South America", `gc1' subtitle("Agriculture, forestry & fishing") saving(graph1.gph, replace)
graph bar Value2 if SubReg=="South America", `gc2' subtitle("Industry") saving(graph2.gph, replace)
graph bar Value3 if SubReg=="South America", `gc3' subtitle("Services") saving(graph3.gph, replace)
graph combine graph1.gph graph2.gph graph3.gph, rows(1) cols(3) subtitle("South America") saving(graph03.gph, replace)
*graph combine graph01.gph graph02.gph graph03.gph, rows(3) cols(1) `G4' subtitle("Ratio of dollar value added to the volume of water used:" "primary, secondary, tertiary sectors")
*graph export "$pathR/graphs/FigA2_USDm3_Sectors.emf", replace
*graph export "$pathR/graphs/FigA2_USDm3_Sectors.png", replace 

clear
import excel "$path/Data/Excel/sdg6data_download10Mar2024_641_642.xlsx", sheet("Sheet1") firstrow
rename Geographicalareaname CountryName
run "$path/Codes/format_country_names.do" 
run "$path/Codes/format_country_names2.do"   //replace CountryN="Reunion" if CountryN=="RéUnion"
joinby CountryName using "$path/Data/Stata/CountryDataMatching_vs0.dta", unmatched(master) update
tab _merge   //tab CountryName if _merge!=3
drop _merge
tab Year
keep if Indicatorname=="Water Use Efficiency (United States dollars per cubic meter)"
keep if Year=="2020"
drop if SDG6Dataportallevel=="`sdg0'" 
keep Value iso3 SDG6Dataportallevel  
forv s=1/3 {
replace SDG6Dataportallevel = "`s'" if SDG6Dataportallevel=="`sdg`s''"
}
destring SDG6Dataportallevel, replace force
drop if SDG6Dataportallevel==.
collapse (sum) Value*, by(iso3 SDG6Dataportallevel)
reshape wide Value, i(iso3) j(SDG6Dataportallevel)  
g Year=2020
joinby iso3 Year using "$pathDs/Data_WB.dta", unmatched(master) update
g popW = ceil(Population/1000)
collapse Value* [fw=popW], by(Reg)
local gc1 "over(Reg, sort(Value1) descending label(labsize(*.52))) `gc'"   
local gc2 "over(Reg, sort(Value2) descending label(labsize(*.52))) `gc'"  
local gc3 "over(Reg, sort(Value3) descending label(labsize(*.52))) `gc'"  
graph bar Value1, `gc1' subtitle("Agriculture, forestry & fishing") saving(graph1.gph, replace)
graph bar Value2, `gc2' subtitle("Industry") saving(graph2.gph, replace)
graph bar Value3, `gc3' subtitle("Services") saving(graph3.gph, replace)
graph combine graph1.gph graph2.gph graph3.gph, rows(1) cols(3) subtitle("Continents") saving(graph04.gph, replace)
graph combine graph01.gph graph02.gph graph03.gph graph04.gph, rows(4) cols(1) `G4' ///
subtitle("Ratio of dollar value added to the volume of water used:" "primary, secondary, tertiary sectors")
if "`c(os)'" == "Windows" {
	graph export "$pathR/graphs/FigA2_USDm3_Sectors.emf", replace
}
graph export "$pathR/graphs/FigA2_USDm3_Sectors.png", replace 
