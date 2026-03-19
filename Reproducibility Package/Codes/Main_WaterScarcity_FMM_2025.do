// Water scarcity analysis
// Original author-supplied entry point.
set varabbrev on
global path "C:/Users/wb558768/Downloads/rep-checks/440/Replication package"
global pathR "$path/Outputs/"   // capture mkdir "$path/Outputs/"
global pathDs "$pathR/StataData_other/"

sysdir set PLUS "$path/Codes/ado"

// 1. Data format
do "$path/Codes/Format_UNIDO.do"  // formats the INDSTAT Revision 2 UNIDO data (code takes some time)
do "$path/Codes/format_Aquastat.do" //selects 23 variables from the raw Aquastat data archive "AQUASTAT Statistics Bulk Download (English).csv" and imports these to Stata format.
do "$path/Codes/format_PWT.do" // formats the Penn-World Tables data. 
do "$path/Codes/format_WB.do" // formats 35 variables from World Bank Data, including inflation, GDP growth, sectoral growth, GDP pc PPP and others.
do "$path/Codes/format_WB2.do" //formats 10 variables from World Bank Data related to electricity use, fossil and nuclear energy shares, and share of renewable energy (hydro and non-hydro).

// 2. Summary figures and statistics
do "$path/Codes/Water_demand_pop_GDPpc.do" //creates Table 1 of a water demand model linear regression and its projections for water demand across countries in 2050.
do "$path/Codes/Summary_aquastat_WB_stats.do" //creates Table 2 with summary statistics for macro variables (GDP growth, inflation, investment) and freshwater withdrawal measures.
do "$path/Codes/Graph1_example.do" //creates Graph 1 with total water resources per capita.
do "$path/Codes/Water_analysis_Aquastat.do" //creates Graph 2 (daily water use per capita), Graph 3 (share of water withdrawal across sectors), Graph 4 (freshwater withdrawal as % of total resources) and Graph 5 (change in freshwater withdrawal rates between 2000 and 2020). 
do "$path/Codes/List_countries_aquastat_WB.do" // number of countries by development category (advanced economies (AEs), emerging markets and developing economies (EMDEs)): creates Table A.1.
do "$path/Codes/Water_analysis_New.do" //Graph A.1 (ratio of dollar value added to the volume of water used) & Graph A.2 (ratio of dollar value added to the volume of water used by sector)

// 3. Regression models
do "$path/Codes/Regressions_growth_investment_water.do" //creates Tables 3, 4, 5 and 6, with the baseline effects of freshwater withdrawal on GDP growth, investment and inflation.
do "$path/Codes/Water_analysis_More_regressions.do" //creates Table 7 with regressions of sectoral shares of GDP (agriculture, forestry, fishing; industry; services) on freshwater withdrawal.
do "$path/Codes/Water_UNIDO.do" //creates Table 8 with real manufacturing growth regressions associated with water withdrawal measures.
do "$path/Codes/Regressions_Water_pricing.do" //creates Table A.2 and Table A.3 with the statistical correlation between freshwater withdrawal and water pricing in OECD countries. Graph 6 on water pricing across OECD countries was created from the same dataset, but the code is not shown here (directly created in Excel).
do "$path/Codes/Regressions_PWT.do" //creates Table A.4 and Table A.5 with the effects of freshwater withdrawal on the level of real GDP and investment growth.
do "$path/Codes/QR_Regressions_growth_investment.do" //creates Table A.6, Table A.8 and Table A.9, with the panel quantile regressions for the effect of freshwater withdrawal on real GDP growth, investment and inflation.
do "$path/Codes/Regressions_eletricity.do" //creates Table A.7 with the estimates of freshwater withdrawal on the hydroelectricity production.
