clear
import excel "$path/Data/Excel/FRED CPIAUCSL.xls", sheet("FRED Graph") firstrow
g Year=year( observation_date)
g month = month( observation_date)
collapse CPIAUCSL, by(Year)
sum CPIAUCSL if Year==2017
local dn=r(mean)
g USD2017 = `dn'/CPIAUCSL
save "$pathDs/US_CPIAUCSL.dta", replace

use "$path/Data/Stata/pwt91_na_data.dta", clear   // old data
replace xr=xr2 if xr==.  //keep countrycode year v_gdp q_gdp pop xr
sum v_gdp xr* pop if countrycode=="USA"   // needs to be multiplied by *1000*1000
g GDP_LCU = v_gdp*1000*1000
g CPI = v_gdp/q_gdp
egen id=group(countrycode)
xtset id year
g CPI_gr = L.CPI
replace CPI_gr = ln(CPI/CPI_gr)
g gq_gdp = L.q_gdp 
replace gq_gdp = ln(q_gdp/gq_gdp)
keep countrycode year GDP_LCU gq_gdp CPI_gr pop xr  //drop if year==.  //drop if country==""
rename GDP_LCU GDP_LCU_PWTold
rename xr xr_old
save "$pathDs/PWT_old.dta", replace

use "$path/Data/Stata/pwt1001.dta", clear  
sum rgdpna xr* pop if countrycode=="USA"  // gdp needs to be multiplied by *1000*1000
rename year Year
joinby Year using "$pathDs/US_CPIAUCSL.dta", unmatched(master) update
tab _merge
drop _merge
g GDP_LCU = rgdpna*1000*1000*xr*(1/USD2017)
sum ctfp cwtfp rtfpna rwtfpna  
pwcorr _all
rename countrycode iso3
drop country currency_unit
save "$pathDs/PWT_new.dta", replace
