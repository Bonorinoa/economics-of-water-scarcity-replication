// Mac-native entry point for the Frost et al. water scarcity replication.
do "/Users/bonorinoa/Desktop/ECN726/TermProject_2/Reproducibility Package/Codes/config_mac.do"

// 1. Data format
do "$path/Codes/Format_UNIDO.do"
do "$path/Codes/format_Aquastat.do"
do "$path/Codes/format_PWT.do"
do "$path/Codes/format_WB.do"
do "$path/Codes/format_WB2.do"

// 2. Summary figures and statistics
do "$path/Codes/Water_demand_pop_GDPpc.do"
do "$path/Codes/Summary_aquastat_WB_stats.do"
do "$path/Codes/Graph1_example.do"
do "$path/Codes/Water_analysis_Aquastat.do"
do "$path/Codes/List_countries_aquastat_WB.do"
do "$path/Codes/Water_analysis_New.do"

// 3. Regression models
do "$path/Codes/Regressions_growth_investment_water.do"
do "$path/Codes/Water_analysis_More_regressions.do"
do "$path/Codes/Water_UNIDO.do"
do "$path/Codes/Regressions_Water_pricing.do"
do "$path/Codes/Regressions_PWT.do"
do "$path/Codes/QR_Regressions_growth_investment.do"
do "$path/Codes/Regressions_eletricity.do"

// Graph 6 is not code-generated in the public package. Reconstruct it manually from the
// OECD water pricing figures documented in README.pdf after the full run succeeds.
