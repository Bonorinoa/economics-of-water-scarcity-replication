local Alphabet "A B C D E F G H I J K L M N O P Q R S T V W X Y Z"
local year_min = 1959 // start analysis in 1989, because MaPP data starts in 1990

local Y1 "Establishments"
local Y4 "Workers"
local Y5 "Wages"
local Y14 "Output"
local Y20 "VA"
local Y21 "GFCF"
local Y31 "Female_workers"
local Y51 "IIP"

clear     // 2023 UNIDO data, creation of labels
import excel "$path/Data/Excel/INDSTAT2 national_currency metadata.xlsx", sheet("Data") firstrow  
g constant=1
collapse constant, by(CountryC CountryD)
drop constant
destring CountryCode, replace force
save "$pathDs/UN_CountryCodes0.dta", replace
clear
import excel "$path/Data/Excel/ISO 3166 Codes.xlsx", sheet("Hoja1") firstrow
destring CountryCode, replace force
save "$pathDs/UN_CountryCodes4.dta", replace

clear     // 2023 UNIDO data, creation of labels
import excel "$path/Data/Excel/INDSTAT2 national_currency.xlsx", sheet("Data") firstrow  // INDSTAT2 national_currency.xlsx  /2023/
run "$path/Codes/UNIDO_labels.do" 
run "$path/Codes/ISIC_labels.do" //run "$path/Codes/ISICComb_labels.do" 

replace ISIC = "38" if ISIC=="D"
g ISIC_C = ISICCombination
replace ISIC_C = "38" if ISIC_C=="D"
replace ISIC_C = substr(ISIC_C,1,2)  /*foreach x of local Alphabet { replace ISIC_C = regexr(ISIC_C, "`x'", "") if ISIC_C=="`x'"  }*/
/*joinby ISICCombination using "$path/Codes/INDSTAT2_ISICCombCode.dta", unmatched(master) update   tab _merge  replace ISICComb_nr=ISIC if ISICComb_nr==.*/
g ISIC_Cletter = substr(ISICCombination,3,.)

destring Value TableCode TableDefinitionCode ISIC ISIC_C Year, replace force
label values TableCode TDC0
label values TableDefinitionCode TDC
label values ISIC ISIC3
label values ISIC_C ISIC3

pwcorr ISIC ISIC_C
sum ISIC ISIC_C if ISIC!=ISIC_C
bysort Unit: tab TableCode
rename Value Value_sel

capture drop id ln_value lag_ln_value growth_value
bysort TableDefinitionCode CountryCode ISIC Year: egen nr_industry_repeat=count(ISICCombination)
tab nr_industry_repeat // Great there are no repeated values of the same ISIC (although some countries have different combinations)
drop nr_industry_repeat
egen id=group( TableDefinitionCode CountryCode ISIC )
sum Year
drop if Year<`year_min'
xtset id Year
g lag_Value=L.Value_sel
bysort TableDefinitionCode CountryCode Year: egen lag_ValueT=total(lag_Value)
g Size_TD_lag=lag_Value/lag_ValueT if ISIC!=38
replace Size_TD_lag=1 if ISIC==38 & Size_TD_lag==.
replace Size_TD_lag = min(1, max(0, Size_TD_lag) ) if Size_TD_lag<.
drop lag_Value lag_ValueT
save "$pathDs/INDSTAT2_natcur_sel.dta", replace

use "$pathDs/INDSTAT2_natcur_sel.dta", clear  // Check Manufacturing totals 
g Value_sel2=Value_sel if ISIC<38  // Industry 38 is indeed Manufacturing total
g ValueT38_0=Value_sel if ISIC==38
bysort TableCode CountryCode Year: egen ValueT=total(Value_sel2)
bysort TableCode CountryCode Year: egen ValueT38=mean(ValueT38_0)
pwcorr ValueT ValueT38 Value_sel if ISIC==38 & TableCode<50
sum ValueT ValueT38 Value_sel if ISIC==38 & Value_sel<. & TableCode<50  // Values are similar!
g ValueT2 = max(ValueT,ValueT38)    // Values are now the same!
pwcorr ValueT ValueT2 ValueT38 Value_sel if ISIC==38 & TableCode<50
sum ValueT ValueT2 ValueT38 Value_sel if ISIC==38 & Value_sel<. & TableCode<50 
drop Value_sel2 ValueT38_0 ValueT2
save "$pathDs/INDSTAT2_natcur_sel.dta", replace

local K=1 
foreach Yv of numlist 1 4 5 14 20 21 31 51 {  
use "$pathDs/INDSTAT2_natcur_sel.dta", clear   // keep other Y variables
keep if TableCode==`Yv'
drop id
egen id=group( CountryCode ISIC )
xtset id Year
g ln_value=ln(Value_sel)
g lag_ln_value=L.ln_value
g `Y`Yv''_gr=ln_value-lag_ln_value   // growth_value   //rename Value_sel `Y`Yv''
rename Value_sel `Y`Yv''
keep Year CountryCode ISIC *_gr `Y`Yv''  //drop ln_value lag_ln_value Value_sel
if `K'>1  {
joinby Year ISIC CountryCode using "$pathDs/UNIDO_OtherY.dta", unmatched(both) update 
tab _merge
drop _merge	
}	
save "$pathDs/UNIDO_OtherY.dta", replace
local K=2
}	
//  //  //

use "$pathDs/INDSTAT2_natcur_sel.dta", clear  // Create Value-Added shares of each industry
keep if TableCode==20
tab TableCode
tab TableDefinitionCode
xtset id Year
g Size_VA=Value_sel/ValueT38
replace Size_VA=Value_sel/ValueT if Size_VA==.
replace Size_VA=1 if ISIC==38
replace Size_VA = min(1, max(0, Size_VA) ) if Size_VA<.
g Size_VA_lag=L.Size_VA
pwcorr Size_TD_lag Size_VA_lag // similar values
keep CountryCode Year ISIC ValueT38 ValueT Size_VA_lag
replace ValueT38=max(ValueT38, ValueT) if ValueT>0 
drop if ValueT38==.
drop ValueT
save "$pathDs/INDSTAT2_VA.dta", replace
keep CountryCode ISIC Year Size_VA_lag
save "$pathDs/data_temp.dta", replace
sort CountryCode ISIC Year
collapse (firstnm) Size_VA_lag, by(ISIC CountryCode)
rename Size_VA_lag first_Size_VA_lag
save "$pathDs/data_temp0.dta", replace
use "$pathDs/data_temp.dta", clear
joinby ISIC CountryCode using "$pathDs/data_temp0.dta", unmatched(master) update
drop _merge
save "$pathDs/data_temp.dta", replace

use "$pathDs/INDSTAT2_natcur_sel.dta", clear  // Create Output shares of each industry
keep if TableCode==14
tab TableCode
tab TableDefinitionCode
xtset id Year
g Size_Y=Value_sel/ValueT38
replace Size_Y=Value_sel/ValueT if Size_Y==.
replace Size_Y=1 if ISIC==38
replace Size_Y = min(1, max(0, Size_Y) ) if Size_Y<.
g Size_Y_lag=L.Size_Y
pwcorr Size_TD_lag Size_Y_lag // similar values
keep CountryCode ISIC Year Size_Y_lag
save "$pathDs/data_temp0.dta", replace

use "$pathDs/INDSTAT2_natcur_sel.dta", clear  // lagged values and Industrial Production Index dataset
xtset id Year
g ln_value=ln(Value_sel)
g lag_ln_value=L.ln_value
g growth_value=ln_value-lag_ln_value
g growth_valueLag1=L.growth_value

tab ISIC_Cletter
tab TableDefinitionCode if TableDefinitionCode==5 | TableDefinitionCode==21 | TableDefinitionCode==31 | TableDefinitionCode==51
keep if TableDefinitionCode==51
joinby Year ISIC CountryCode using "$pathDs/UNIDO_OtherY.dta", unmatched(both) update 
tab _merge
drop _merge
tab TableDefinitionCode 
tab ISIC_Cletter

sum Year
joinby CountryCode ISIC Year using "$pathDs/data_temp.dta", unmatched(both) update
tab _merge
drop _merge
joinby CountryCode ISIC Year using "$pathDs/data_temp0.dta", unmatched(both) update
tab _merge
drop _merge ISIC_Cletter TableCode TableDefinitionCode id
egen id=group( CountryCode ISIC )
xtset id Year
sum Size_VA_lag Size_Y_lag Size_TD_lag if Size_VA_lag<. & Size_Y_lag<. & Size_TD_lag<. 
pwcorr Size_VA_lag Size_Y_lag Size_TD_lag 
save "$pathDs/INDSTAT2_natcur_sel.dta", replace

use "$pathDs/INDSTAT2_natcur_sel.dta", clear  // UN Country codes
destring CountryCode, replace force
sum CountryCode Year
joinby CountryCode using "$pathDs/UN_CountryCodes0.dta", unmatched(master) update  
tab _merge   
drop _merge*
joinby CountryCode using "$pathDs/UN_CountryCodes4.dta", unmatched(master) update  
tab _merge 
rename _merge _merge4
tab CountryDescription if _merge4!=3
replace ISO3="CSK" if CountryCode==200
replace ISO3="ETH" if CountryCode==230
replace ISO3="DDR" if CountryCode==278
replace ISO3="DEU" if CountryCode==280
replace ISO3="XXK" if CountryCode==412
replace ISO3="ANT" if CountryCode==530
replace ISO3="SDN" if CountryCode==736
replace ISO3="SUN" if CountryCode==810
replace ISO3="YUG" if CountryCode==890
replace ISO3="SCG" if CountryCode==891
labmask CountryCode, values(CountryDescription)
save "$pathDs/INDSTAT2_natcur_sel.dta", replace

use "$pathDs/INDSTAT2_natcur_sel.dta", clear  // IMF, WB Country codes
g CountryName=CountryDescription  //run "$path/CountryCodes/format_country_names.do" 
rename CountryName CountryN
run "$path/Codes/format_country_names.do"
run "$path/Codes/format_country_names2.do"
rename CountryN CountryName 
g A3=ISO3
sum Year
drop CountryDescription SourceCode Unit
save "$pathDs/INDSTAT2_natcur_sel.dta", replace

use "$pathDs/INDSTAT2_VA.dta", clear
destring Cou, replace force
keep if ISIC==38
drop ISIC Size_VA_lag
save "$pathDs/INDSTAT2_VA.dta", replace
