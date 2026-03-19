*replace CountryN = ustrlower( ustrregexra( ustrnormalize( CountryN, "nfd" ) , "\p{Mark}", "" )  )
* Stata 19 on macOS requires the Unicode property escape with a backslash.
replace CountryN = ustrregexra( ustrnormalize( CountryN, "nfd" ) , "\p{Mark}", "" )  

replace CountryN="Republic of Korea" if CountryN=="Korea, Rep. Of"

replace CountryN="Cote d'Ivoire" if CountryN=="Côte d'Ivoire"
replace CountryN="Cote d'Ivoire" if CountryN=="CôTe D'Ivoire"
replace CountryN="China" if CountryN=="China, People's Republic of" //joinby CountryN using "$path4//country_list.dta", unmatched(both) update
replace CountryN="USA" if CountryN=="United States"
replace CountryN="Slovakia" if CountryN=="Slovak Republic"
replace CountryN="euroarea" if CountryN=="European Union" 
replace CountryN="Armenia" if CountryN=="Armenia, Republic of"
replace CountryN="Armenia" if CountryN=="Armenia, Rep. Of"

replace CountryN="FYR Macedonia" if CountryN=="Macedonia, FYR"
replace CountryN="Kosovo" if CountryN=="Kosovo, Republic of"
replace CountryN="Korea, Republic of" if CountryN=="Korea, Rep."
replace CountryN="Hong Kong SAR" if CountryN=="Hong Kong SAR, China"
replace CountryN="S Korea" if CountryN=="Korea, Republic of"
replace CountryN="Afghanistan" if CountryN=="Afghanistan, Islamic Republic of"
replace CountryN="Azerbaijan" if CountryN=="Azerbaijan, Republic of"
replace CountryN="Bahrain" if CountryN=="Bahrain, Kingdom of"
replace CountryN="Hong Kong" if CountryN=="China, P.R.: Hong Kong"
replace CountryN="Hong Kong" if CountryN=="Hong Kong SAR"
replace CountryN="Macao" if CountryN=="China, P.R.: Macao"
replace CountryN="Macao" if CountryN=="Macao SAR, China"
replace CountryN="China" if CountryN=="China, P.R.: Mainland"
replace CountryN="Congo, Dem. Rep." if CountryN=="Congo, Democratic Republic of"
replace CountryN="Congo, Dem. Rep." if CountryN=="Congo, Dem. Rep. Of The"

replace CountryN="Congo, Rep." if CountryN=="Congo, Republic of"
replace CountryN="Egypt" if CountryN=="Egypt, Arab Rep."
replace CountryN="Eswatini" if CountryN=="Eswatini, Kingdom of"
replace CountryN="Euro area" if CountryN=="Euro Area"
replace CountryN="Euro area" if CountryN=="euroarea"
replace CountryN="Iran" if CountryN=="Iran, Islamic Rep."
replace CountryN="Iran" if CountryN=="Iran, Islamic Republic of"
replace CountryN="Lao" if CountryN=="Lao PDR"
replace CountryN="Lao" if CountryN=="Lao People's Democratic Republic"
replace CountryN="Micronesia" if CountryN=="Micronesia, Fed. Sts."
replace CountryN="Micronesia" if CountryN=="Micronesia, Federated States of"
replace CountryN="North Macedonia" if CountryN=="North Macedonia, Republic of"
replace CountryN="Serbia" if CountryN=="Serbia, Republic of"
replace CountryN="Timor-Leste" if CountryN=="Timor-Leste, Dem. Rep. of"
replace CountryN="Venezuela" if CountryN=="Venezuela, RB"
replace CountryN="Venezuela" if CountryN=="Venezuela, República Bolivariana de"
replace CountryN="Venezuela" if CountryN=="Venezuela, Republica Bolivariana de"
replace CountryN="Yemen" if CountryN=="Yemen, Rep."
replace CountryN="Yemen" if CountryN=="Yemen, Republic of"	
replace CountryN="Bahamas" if CountryN=="Bahamas, The"	
replace CountryN="Bolivia" if CountryN=="Bolivia (Plurinational State of)"	
replace CountryN="Hong Kong" if CountryN=="China, Hong Kong SAR"	
replace CountryN="Macao" if CountryN=="China, Macao SAR"	
replace CountryN="Taiwan" if CountryN=="China, Taiwan Province"	
replace CountryN="Curaçao" if CountryN=="Curacao"
replace CountryN="Gambia" if CountryN=="Gambia, The"
replace CountryN="Czech Republic" if CountryN=="Czechia"	
replace CountryN="Iran" if CountryN=="Iran (Islamic Republic of)"
replace CountryN="N Korea" if CountryN=="Korea, Dem. People’s Rep."
replace CountryN="Kyrgyzstan" if CountryN=="Kyrgyz Republic"
replace CountryN="Lao" if CountryN=="Lao People's Dem Rep"
replace CountryN="S Korea" if CountryN=="Republic of Korea"
replace CountryN="Moldova" if CountryN=="Republic of Moldova"
replace CountryN="USA" if CountryN=="United States of America"
replace CountryN="USA" if CountryN=="United States"
replace CountryN="Tanzania" if CountryN=="United Republic of Tanzania"
replace CountryN="Venezuela" if CountryN=="Venezuela (Bolivarian Republic of)"
replace CountryN="Vietnam" if CountryN=="Viet Nam"
replace CountryN="São Tomé and Príncipe" if CountryN=="Sao Tome and Principe"
replace CountryN="Cabo Verde" if CountryN=="Cape Verde"
replace CountryN="Congo, Dem. Rep." if CountryN=="Democratic Republic of the Congo"
replace CountryN="North Macedonia" if CountryN=="FYR Macedonia"
replace CountryN="N Korea" if CountryN=="Korea, Democratic People's Republic of"
replace CountryN="Moldova" if CountryN=="Moldova, Republic of"
replace CountryN="St. Martin (French part)" if CountryN=="Saint Martin (French part)"
replace CountryN="St. Kitts and Nevis" if CountryN=="Saint Kitts and Nevis"
replace CountryN="St. Vincent and the Grenadines" if CountryN=="Saint Vincent and the Grenadines"
replace CountryN="Palestine" if CountryN=="Palestine, State of"
replace CountryN="Palestine" if CountryN=="State of Palestine"
replace CountryN="Virgin Islands (U.S.)" if CountryN=="US Virgin Islands"
replace CountryN="Palestine" if CountryN=="West Bank and Gaza"
replace CountryN="Virgin Islands, British" if CountryN=="British Virgin Islands"
replace CountryN="St. Lucia" if CountryN=="Saint Lucia"
replace CountryN="Eswatini" if CountryN=="Swaziland"
capture replace CountryN="Congo, Rep." if CountryN=="Congo" & CountryCode==178 //capture replace CountryN="Congo, Dem. Rep." if CountryN=="Congo"
capture replace CountryN="Congo, Rep." if CountryN=="Congo"
capture replace CountryN="Turkey" if CountryN=="Türkiye"
replace CountryN="Reunion" if CountryN=="RéUnion"

*replace CountryN="Czech Republic" if CountryN=="Czechoslovakia"	//  //   //   Attention!
*replace CountryN="Germany" if CountryN=="Germany, Fed Rep"	//  //   //   Attention!
replace CountryN="Ethiopia" if CountryN=="Ethiopia and Eritrea"	//  //   //   Attention!
replace CountryN="Serbia" if CountryN=="Serbia and Montenegro"	//  //   //   Attention!

replace CountryN="West African Economic and Monetary Union (WAEMU)" if CountryN=="West African Economic And Monetary Union (Waemu)"

replace CountryN="Afghanistan" if CountryN=="Afghanistan, Islamic Rep. Of"
replace CountryN="Azerbaijan" if CountryN=="Azerbaijan, Rep. Of"
replace CountryN="Belarus" if CountryN=="Belarus, Rep. Of"
replace CountryN="Czechia" if CountryN=="Czech Rep."
replace CountryN="Dominican Republic" if CountryN=="Dominican Rep."
replace CountryN="Egypt" if CountryN=="Egypt, Arab Rep. Of"
replace CountryN="Fiji" if CountryN=="Fiji, Rep. Of"
replace CountryN="Kazakhstan" if CountryN=="Kazakhstan, Rep. Of"
replace CountryN="Kyrgyzstan" if CountryN=="Kyrgyz Rep."
replace CountryN="Moldova" if CountryN=="Moldova, Rep. Of"
replace CountryN="Poland" if CountryN=="Poland, Rep. Of"
replace CountryN="Russian Federation" if CountryN=="Russia"
replace CountryN="São Tomé and Príncipe" if CountryN=="São Tomé and Príncipe, Dem. Rep. of"
replace CountryN="Serbia" if CountryN=="Serbia, Rep. Of"
replace CountryN="Tajikistan" if CountryN=="Tajikistan, Rep. Of"
replace CountryN="Turkey" if CountryN=="Türkiye, Rep of"
replace CountryN="Turkey" if CountryN=="TüRkiye"
replace CountryN="Uzbekistan" if CountryN=="Uzbekistan, Rep. Of"
replace CountryN="Turkey" if regexm(stritrim(strlower(CountryN)),"tu")==1 & regexm(stritrim(strlower(CountryN)),"rkiye")==1
replace CountryN="São Tomé and Príncipe" if regexm(stritrim(strlower(CountryN)),"tom")==1 & regexm(stritrim(strlower(CountryN)),"ncipe")==1 & regexm(stritrim(strlower(CountryN)),"pr")==1

replace CountryN="Taiwan" if regexm(stritrim(strlower(CountryN)),"taipei")==1 | regexm(stritrim(strlower(CountryN)),"taiwan")==1
replace CountryN="Congo, Rep." if regexm(stritrim(strlower(CountryN)),"congo")==1 & regexm(stritrim(strlower(CountryN)),"dem")==0 
replace CountryN="Lao" if regexm(stritrim(strlower(CountryN)),"lao")==1  
replace CountryN="Macao" if regexm(stritrim(strlower(CountryN)),"macao")==1 
replace CountryN="Micronesia" if regexm(stritrim(strlower(CountryN)),"micronesia")==1
replace CountryN="North Macedonia" if regexm(stritrim(strlower(CountryN)),"macedonia")==1 
replace CountryN="South Sudan" if regexm(stritrim(strlower(CountryN)),"sudan")==1 & regexm(stritrim(strlower(CountryN)),"south")==1 
replace CountryN="Syria" if regexm(stritrim(strlower(CountryN)),"syria")==1 
capture replace CountryN="Palestine" if regexm(stritrim(strlower(CountryN)),"palesti")==1 

replace CountryN="Euro area" if CountryN=="Euro Area"
replace CountryN="Andorra" if regexm(stritrim(strlower(CountryN)),"andorra")==1 
replace CountryN="Aruba" if regexm(stritrim(strlower(CountryN)),"aruba")==1 
replace CountryN="Central African Republic" if regexm(stritrim(strlower(CountryN)),"african")==1 & regexm(stritrim(strlower(CountryN)),"central")==1 & regexm(stritrim(strlower(CountryN)),"rep")==1
replace CountryN="Comoros" if regexm(stritrim(strlower(CountryN)),"comoros")==1 
replace CountryN="Croatia" if regexm(stritrim(strlower(CountryN)),"croatia")==1 
replace CountryN="Equatorial Guinea" if regexm(stritrim(strlower(CountryN)),"guinea")==1 & regexm(stritrim(strlower(CountryN)),"equa")==1
replace CountryN="Eritrea" if regexm(stritrim(strlower(CountryN)),"eritrea")==1 
replace CountryN="Estonia" if regexm(stritrim(strlower(CountryN)),"estonia")==1 
replace CountryN="Ethiopia" if regexm(stritrim(strlower(CountryN)),"ethiopia")==1 & regexm(stritrim(strlower(CountryN)),"eritrea")==0
replace CountryN="Iran" if regexm(stritrim(strlower(CountryN)),"iran")==1 
replace CountryN="Kosovo" if regexm(stritrim(strlower(CountryN)),"kosovo")==1 
replace CountryN="Lesotho" if regexm(stritrim(strlower(CountryN)),"lesotho")==1 
replace CountryN="Madagascar" if regexm(stritrim(strlower(CountryN)),"madagascar")==1 
replace CountryN="Marshall Islands" if regexm(stritrim(strlower(CountryN)),"marshall")==1 
replace CountryN="Mauritania" if regexm(stritrim(strlower(CountryN)),"mauritania")==1 
replace CountryN="Mozambique" if regexm(stritrim(strlower(CountryN)),"mozambique")==1 
replace CountryN="Nauru" if regexm(stritrim(strlower(CountryN)),"nauru")==1 
replace CountryN="Netherlands" if regexm(stritrim(strlower(CountryN)),"netherlands")==1 & regexm(stritrim(strlower(CountryN)),"anti")==0
replace CountryN="Palau" if regexm(stritrim(strlower(CountryN)),"palau")==1 
replace CountryN="San Marino" if regexm(stritrim(strlower(CountryN)),"marino")==1 & regexm(stritrim(strlower(CountryN)),"s")==1 
replace CountryN="Slovakia" if regexm(stritrim(strlower(CountryN)),"slovak")==1 
replace CountryN="Slovenia" if regexm(stritrim(strlower(CountryN)),"slovenia")==1 
replace CountryN="Tanzania" if regexm(stritrim(strlower(CountryN)),"tanzania")==1 

replace CountryN="United Kingdom" if regexm(stritrim(strlower(CountryN)),"kingdom")==1 & regexm(stritrim(strlower(CountryN)),"britain")==1
replace CountryN="N Korea" if regexm(stritrim(strlower(CountryN)),"korea")==1 & regexm(stritrim(strlower(CountryN)),"dem")==1
replace CountryN="N Korea" if regexm(stritrim(strlower(CountryN)),"korea")==1 & regexm(stritrim(strlower(CountryN)),"north")==1
replace CountryN="Reunion" if regexm(stritrim(strlower(CountryN)),"reunion")==1
replace CountryN="Bosnia" if regexm(stritrim(strlower(CountryN)),"bosnia")==1  
replace CountryN="China" if regexm(stritrim(strlower(CountryN)),"china")==1 & regexm(stritrim(strlower(CountryN)),"main")==1 
replace CountryN="Cote d'Ivoire" if regexm(stritrim(strlower(CountryN)),"cote")==1 & regexm(stritrim(strlower(CountryN)),"ivo")==1
replace CountryN="Dominican Republic" if regexm(stritrim(strlower(CountryN)),"dominican")==1 & regexm(stritrim(strlower(CountryN)),"rep")==1
replace CountryN="Kyrgyzstan" if regexm(stritrim(strlower(CountryN)),"kyrgyz")==1  
replace CountryN="São Tomé and Príncipe" if regexm(stritrim(strlower(CountryN)),"tomé")==1 & regexm(stritrim(strlower(CountryN)),"ncipe")==1
replace CountryN="São Tomé and Príncipe" if regexm(stritrim(strlower(CountryN)),"tom")==1 & regexm(stritrim(strlower(CountryN)),"cipe")==1
replace CountryN="Cote d'Ivoire" if regexm(stritrim(strlower(CountryN)),"cot")==1 & regexm(stritrim(strlower(CountryN)),"voir")==1
replace CountryN="Cote d'Ivoire" if regexm(stritrim(strlower(CountryN)),"co")==1 & regexm(stritrim(strlower(CountryN)),"voir")==1
*replace CountryN="Cote d'Ivoire" if regexm(stritrim(strlower(CountryN)),"co")==1 & regexm(stritrim(strlower(CountryN)),"oir")==1
*replace CountryN="São Tomé and Príncipe" if regexm(stritrim(strlower(CountryN)),"om")==1 & regexm(stritrim(strlower(CountryN)),"ipe")==1 & regexm(stritrim(strlower(CountryN)),"nd")==1
*replace CountryN="São Tomé and Príncipe" if regexm(stritrim(strlower(CountryN)),"om")==1 & regexm(stritrim(strlower(CountryN)),"ipe")==1 & regexm(stritrim(strlower(CountryN)),"s")==1

capture replace CountryN="Cote d'Ivoire" if iso3=="CIV"
capture replace CountryN="São Tomé and Príncipe" if iso3=="STP"

replace CountryN="Vatican City State" if regexm(stritrim(strlower(CountryN)),"holy")==1

replace CountryN="Afghanistan" if regexm(stritrim(strlower(CountryN)),"afghanistan")==1
replace CountryN="Armenia" if regexm(stritrim(strlower(CountryN)),"armenia")==1
replace CountryN="Azerbaijan" if regexm(stritrim(strlower(CountryN)),"azerbaijan")==1
replace CountryN="Belarus" if regexm(stritrim(strlower(CountryN)),"belaru")==1
replace CountryN="Congo, Dem. Rep." if regexm(stritrim(strlower(CountryN)),"congo")==1 & regexm(stritrim(strlower(CountryN)),"dem")==1
replace CountryN="Egypt" if regexm(stritrim(strlower(CountryN)),"egypt")==1
replace CountryN="Fiji" if regexm(stritrim(strlower(CountryN)),"fiji")==1
replace CountryN="Kazakhstan" if regexm(stritrim(strlower(CountryN)),"kazak")==1
replace CountryN="S Korea" if regexm(stritrim(strlower(CountryN)),"korea")==1 & regexm(stritrim(strlower(CountryN)),"n")==0 & regexm(stritrim(strlower(CountryN)),"dem")==0 
replace CountryN="Moldova" if regexm(stritrim(strlower(CountryN)),"moldova")==1
replace CountryN="Poland" if regexm(stritrim(strlower(CountryN)),"poland")==1
replace CountryN="Serbia"  if regexm(stritrim(strlower(CountryN)),"serbia")==1 & regexm(stritrim(strlower(CountryN)),"montenegr")==0
replace CountryN="Tajikistan" if regexm(stritrim(strlower(CountryN)),"tajik")==1
replace CountryN="Uzbekistan" if regexm(stritrim(strlower(CountryN)),"uzbek")==1
replace CountryN="West African Economic And Monetary Union (Waemu)" if regexm(stritrim(strlower(CountryN)),"waemu")==1
replace CountryN="Waemu" if regexm(stritrim(strlower(CountryN)),"waemu")==1
compress CountryN
