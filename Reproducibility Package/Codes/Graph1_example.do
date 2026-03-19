*----------------------------------------------------------------------------------------------
*								Water scarcity analysis 
*----------------------------------------------------------------------------------------------
*link: https://data.apps.fao.org/aquastat/?lang=en
*--------------------------------------------------------------------------------------------------------------------------
*	Graph 1: Total renewable water resources per capita
*--------------------------------------------------------------------------------------------------------------------------

*America
use "$pathDs/Aquastat_Bulk.dta", clear
keep if variable == "Total renewable water resources per capita" 
joinby iso3 Year using "$pathDs/Data_WB.dta", unmatched(master) update
g population = Population
drop _merge
keep if Year==2020
keep if Reg=="Americas"
save "$pathDs/data_temp.dta", replace

*No America
use "$pathDs/Aquastat_Bulk.dta", clear
keep if variable == "Total renewable water resources per capita" 
joinby iso3 Year using "$pathDs/Data_WB.dta", unmatched(master) update
g population = Population
drop _merge
keep if Year == 2020
keep if Reg != "Americas"
egen population_t = sum(populatio), by(Reg)
gen country_share = (value*population)/population_t
collapse (sum) value = country_share, by(Reg)
save "$pathDs/data_temp0.dta", replace

use "$pathDs/data_temp.dta", clear
append using "$pathDs/data_temp0.dta"
replace iso2="Oc." 	  if Reg == "Oceania"
replace iso2="Eu."    if Reg == "Europe"
replace iso2="Af."    if Reg == "Africa"
replace iso2="As."    if Reg == "Asia"
replace SubReg = "Central and North America" if inlist(SubReg,"Central America","Northern America")
gen ind = 4
replace ind = 1 if SubReg == "South America"
replace ind = 2 if SubReg == "Central and North America"
replace ind = 3 if SubReg == "Caribbean"
gen aux = - value
sort ind aux
gen n= _n
graph box value, nooutsides ytitle("Total renewable water resources per capita", size(mediumsmall) a(90))
replace value = 80000 if value > 80000
graph bar value, over(iso2, sort(n))  scale(*.6) ytitle("") title("Total renewable water resources per capita") ///
				note("In cubic meters", size(medium)) text(75000 12 "South America", size(medium)) ///
				text(75000 43 "Central and North America", size(medium)) ///
				text(75000 76 "Caribbean", size(medium)) ///
				text(75000 96 "Rest of the world", size(medium))
if "`c(os)'" == "Windows" {
	graph export "$pathR/graphs/Fig1_water_pc.emf", replace
}
graph export "$pathR/graphs/Fig1_water_pc.png", replace
