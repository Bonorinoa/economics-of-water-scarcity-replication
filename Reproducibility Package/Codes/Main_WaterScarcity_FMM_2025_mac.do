// Mac-native entry point for the Frost et al. water scarcity replication.
if `"$path"' == "" {
	capture confirm file "config_mac.do"
	if !_rc {
		do "config_mac.do"
	}
	else {
		capture confirm file "Reproducibility Package/Codes/config_mac.do"
		if !_rc {
			do "Reproducibility Package/Codes/config_mac.do"
		}
		else {
			display as error `"{p}Could not locate config_mac.do. From the repository root, run: do ""run_paper_replication_mac.do""{p_end}"'
			exit 601
		}
	}
}

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
do "$path/Codes/Figure6_OECD.do"
do "$path/Codes/List_countries_aquastat_WB.do"
do "$path/Codes/Water_analysis_New.do"

// 3. Regression models
do "$path/Codes/Regressions_growth_investment_water.do"
do "$path/Codes/Water_analysis_More_regressions.do"
do "$path/Codes/Water_UNIDO.do"
do "$path/Codes/Regressions_Water_pricing.do"
do "$path/Codes/QR_Regressions_growth_investment.do"
do "$path/Codes/Regressions_eletricity.do"
do "$path/Codes/Paper_assemble_outputs.do"
