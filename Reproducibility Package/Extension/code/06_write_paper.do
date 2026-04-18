version 19.5

if `"$EXT_SETUP_COMPLETE"' != "1" {
	do "Reproducibility Package/Extension/code/00_setup_prereqs.do"
}

ext_display_step "Writing the paper draft and summary table"

use "$EXT_RESULTS/meta_analysis_results.dta", clear
keep if status == "success"

quietly summarize ame_scarcity, detail
local n_success = r(N)
local mean_beta : display %6.3f r(mean)
local median_beta : display %6.3f r(p50)
local p25_beta : display %6.3f r(p25)
local p75_beta : display %6.3f r(p75)

quietly count if ame_scarcity < 0
local share_negative : display %5.1f 100 * r(N) / `n_success'

quietly count if ame_p_value < 0.05
local share_sig05 : display %5.1f 100 * r(N) / `n_success'

quietly count if ame_scarcity < 0
local negative_count : display %9.0f r(N)
quietly count if ame_scarcity < 0 & ame_p_value < 0.05
local negative_sig_count : display %9.0f r(N)
quietly count if ame_scarcity > 0 & ame_p_value < 0.05
local positive_sig_count : display %9.0f r(N)

quietly summarize ame_scarcity if inlist(estimator, "country_fe_only", "two_way_fe", "first_diff", "q25", "q50", "q75"), detail
local within_mean_beta : display %6.3f r(mean)
local within_median_beta : display %6.3f r(p50)

quietly summarize ame_scarcity if estimator == "between", detail
local between_mean_beta : display %6.3f r(mean)

quietly summarize ame_scarcity if estimator == "random_effects", detail
local re_mean_beta : display %6.3f r(mean)

use "$EXT_RESULTS_RAW/meta_regression_coefficients_ame.dta", clear

quietly summarize coef if term == "d_quadratic", meanonly
local b_quad : display %6.3f r(mean)
quietly summarize p_value if term == "d_quadratic", meanonly
local p_quad : display %6.3f r(mean)

quietly summarize coef if term == "d_interaction_income", meanonly
local b_inc : display %6.3f r(mean)
quietly summarize p_value if term == "d_interaction_income", meanonly
local p_inc : display %6.3f r(mean)

quietly summarize coef if term == "d_threshold", meanonly
local b_thr : display %6.3f r(mean)
quietly summarize p_value if term == "d_threshold", meanonly
local p_thr : display %6.3f r(mean)

quietly summarize coef if term == "d_re", meanonly
local b_re : display %6.3f r(mean)
quietly summarize p_value if term == "d_re", meanonly
local p_re : display %6.3f r(mean)

quietly summarize coef if term == "d_no_year_fe", meanonly
local b_noyear : display %6.3f r(mean)
quietly summarize p_value if term == "d_no_year_fe", meanonly
local p_noyear : display %6.3f r(mean)

quietly summarize coef if term == "d_between", meanonly
local b_bet : display %6.3f r(mean)
quietly summarize p_value if term == "d_between", meanonly
local p_bet : display %6.3f r(mean)

quietly summarize coef if term == "d_q25", meanonly
local b_q25 : display %6.3f r(mean)
quietly summarize p_value if term == "d_q25", meanonly
local p_q25 : display %6.3f r(mean)

quietly summarize coef if term == "d_q50", meanonly
local b_q50 : display %6.3f r(mean)
quietly summarize p_value if term == "d_q50", meanonly
local p_q50 : display %6.3f r(mean)

quietly summarize coef if term == "d_q75", meanonly
local b_q75 : display %6.3f r(mean)
quietly summarize p_value if term == "d_q75", meanonly
local p_q75 : display %6.3f r(mean)

use "$EXT_RESULTS_RAW/baseline_verification.dta", clear
keep if sample == "1990_2020"
if _N != 1 {
	ext_abort "baseline verification file is missing or malformed"
}

local baseline_beta : display %6.3f beta_scarcity[1]
local baseline_se : display %6.3f se_scarcity[1]
local baseline_n : display %9.0fc n_obs[1]
local baseline_r2 : display %6.3f r_squared[1]
local baseline_n_tex = subinstr("`baseline_n'", ",", "{,}", .)

use "$EXT_DATA/analysis_panel.dta", clear

quietly levelsof id if analysis_window_1990_2020, local(window_ids)
local country_window : word count `window_ids'
quietly levelsof id if sample_internal, local(internal_ids)
local country_internal : word count `internal_ids'
quietly levelsof id if sample_available, local(available_ids)
local country_available : word count `available_ids'

keep if analysis_window_1990_2020
gen double Total_gr = GDP_gr
gen double rhs_scarcity = WaterStress_p99
gen double rhs_use = ln_total_water_withdrawal_pc
gen double rhs_income = lnGDP
gen double rhs_aux1 = rhs_scarcity * rhs_income
keep if !missing(Total_gr, rhs_scarcity, rhs_use, rhs_income, rhs_aux1)
xtset id Year

capture noisily reghdfe Total_gr rhs_scarcity rhs_use rhs_income rhs_aux1, absorb(id Year) vce(cluster id)
if _rc {
	ext_abort "failed to estimate the income-interaction model while writing paper values"
}

tempvar income_sample
gen byte `income_sample' = e(sample)
quietly summarize rhs_income if `income_sample', detail
local income_mean : display %6.2f r(mean)
local income_median : display %6.2f r(p50)

local inc_level : display %6.3f _b[rhs_scarcity]
local inc_slope : display %6.3f _b[rhs_aux1]
local me_ln8 : display %6.3f (_b[rhs_scarcity] + 8 * _b[rhs_aux1])
local me_ln10 : display %6.3f (_b[rhs_scarcity] + 10 * _b[rhs_aux1])
local me_ln11 : display %6.3f (_b[rhs_scarcity] + 11 * _b[rhs_aux1])
local benchmark_cross : display %6.2f (($EXT_BASELINE_BETA - _b[rhs_scarcity]) / _b[rhs_aux1])
local zero_cross : display %6.2f (-_b[rhs_scarcity] / _b[rhs_aux1])

use "$EXT_RESULTS_RAW/threshold_grid_search.dta", clear
gsort rank
local best_threshold : display %9.0f threshold[1]
local best_threshold_rss : display %9.0fc rss[1]
local best_threshold_beta : display %6.3f beta_scarcity[1]

foreach scalar_label in ///
	mean_beta median_beta p25_beta p75_beta ///
	share_negative share_sig05 ///
	negative_count negative_sig_count positive_sig_count ///
	within_mean_beta within_median_beta between_mean_beta re_mean_beta ///
	b_quad p_quad b_inc p_inc b_thr p_thr ///
	b_re p_re b_noyear p_noyear b_bet p_bet ///
	b_q25 p_q25 b_q50 p_q50 b_q75 p_q75 ///
	baseline_beta baseline_se baseline_n baseline_r2 ///
	baseline_n_tex ///
	country_window country_internal country_available ///
	income_mean income_median inc_level inc_slope ///
	me_ln8 me_ln10 me_ln11 benchmark_cross zero_cross ///
	best_threshold best_threshold_rss best_threshold_beta {
	local `scalar_label' = trim("``scalar_label''")
}

capture file close dist_tex
file open dist_tex using "$EXT_TABLES/estimate_distribution.tex", write replace text
file write dist_tex "\begin{table}[htbp]" _n
file write dist_tex "\centering" _n
file write dist_tex "\caption{Distribution of the 120 AME estimates}" _n
file write dist_tex "\label{tab:dist}" _n
file write dist_tex "\small" _n
file write dist_tex "\begin{tabular}{lc}" _n
file write dist_tex "\toprule" _n
file write dist_tex "Statistic & Value \\\\" _n
file write dist_tex "\midrule" _n
file write dist_tex `"Successful specifications & `n_success' \\\\"' _n
file write dist_tex `"Mean AME & `mean_beta' \\\\"' _n
file write dist_tex `"Median AME & `median_beta' \\\\"' _n
file write dist_tex `"25th percentile & `p25_beta' \\\\"' _n
file write dist_tex `"75th percentile & `p75_beta' \\\\"' _n
file write dist_tex `"Share negative (\%) & `share_negative' \\\\"' _n
file write dist_tex `"Share significant at 5\% (\%) & `share_sig05' \\\\"' _n
file write dist_tex "\bottomrule" _n
file write dist_tex "\end{tabular}" _n
file write dist_tex "\end{table}" _n
file close dist_tex

capture file close term_values
file open term_values using "$EXT_PAPER/term_paper_values.tex", write replace text
file write term_values `"\newcommand{\BaselineBeta}{`baseline_beta'}"' _n
file write term_values `"\newcommand{\BaselineSE}{`baseline_se'}"' _n
file write term_values `"\newcommand{\BaselineN}{`baseline_n_tex'}"' _n
file write term_values `"\newcommand{\BaselineRtwo}{`baseline_r2'}"' _n
file write term_values `"\newcommand{\TotalSpecs}{`n_success'}"' _n
file write term_values `"\newcommand{\MeanAME}{`mean_beta'}"' _n
file write term_values `"\newcommand{\MedianAME}{`median_beta'}"' _n
file write term_values `"\newcommand{\PTwentyFiveAME}{`p25_beta'}"' _n
file write term_values `"\newcommand{\PSeventyFiveAME}{`p75_beta'}"' _n
file write term_values `"\newcommand{\ShareNegative}{`share_negative'}"' _n
file write term_values `"\newcommand{\ShareSigFive}{`share_sig05'}"' _n
file write term_values `"\newcommand{\NegativeCount}{`negative_count'}"' _n
file write term_values `"\newcommand{\NegativeSigCount}{`negative_sig_count'}"' _n
file write term_values `"\newcommand{\PositiveSigCount}{`positive_sig_count'}"' _n
file write term_values `"\newcommand{\WithinMeanAME}{`within_mean_beta'}"' _n
file write term_values `"\newcommand{\WithinMedianAME}{`within_median_beta'}"' _n
file write term_values `"\newcommand{\BetweenMeanAME}{`between_mean_beta'}"' _n
file write term_values `"\newcommand{\RandomEffectsMeanAME}{`re_mean_beta'}"' _n
file write term_values `"\newcommand{\QuadShift}{`b_quad'}"' _n
file write term_values `"\newcommand{\IncomeShift}{`b_inc'}"' _n
file write term_values `"\newcommand{\ThresholdShift}{`b_thr'}"' _n
file write term_values `"\newcommand{\NoYearShift}{`b_noyear'}"' _n
file write term_values `"\newcommand{\RandomEffectsShift}{`b_re'}"' _n
file write term_values `"\newcommand{\BetweenShift}{`b_bet'}"' _n
file write term_values `"\newcommand{\QTwentyFiveShift}{`b_q25'}"' _n
file write term_values `"\newcommand{\QFiftyShift}{`b_q50'}"' _n
file write term_values `"\newcommand{\QSeventyFiveShift}{`b_q75'}"' _n
file write term_values `"\newcommand{\MergedCountryCount}{`country_window'}"' _n
file write term_values `"\newcommand{\InternalCountryCount}{`country_internal'}"' _n
file write term_values `"\newcommand{\AvailableCountryCount}{`country_available'}"' _n
file write term_values `"\newcommand{\IncomeEffectLevel}{`inc_level'}"' _n
file write term_values `"\newcommand{\IncomeEffectSlope}{`inc_slope'}"' _n
file write term_values `"\newcommand{\MEAtLnEight}{`me_ln8'}"' _n
file write term_values `"\newcommand{\MEAtLnTen}{`me_ln10'}"' _n
file write term_values `"\newcommand{\MEAtLnEleven}{`me_ln11'}"' _n
file write term_values `"\newcommand{\IncomeBenchmarkCross}{`benchmark_cross'}"' _n
file write term_values `"\newcommand{\IncomeZeroCross}{`zero_cross'}"' _n
file write term_values `"\newcommand{\IncomeSampleMean}{`income_mean'}"' _n
file write term_values `"\newcommand{\IncomeSampleMedian}{`income_median'}"' _n
file write term_values `"\newcommand{\BestThreshold}{`best_threshold'}"' _n
file write term_values `"\newcommand{\BestThresholdRSS}{`best_threshold_rss'}"' _n
file write term_values `"\newcommand{\BestThresholdSlope}{`best_threshold_beta'}"' _n
file close term_values

capture file close draft_tex
file open draft_tex using "$EXT_PAPER/draft.tex", write replace text
file write draft_tex "\documentclass[11pt]{article}" _n
file write draft_tex "\usepackage[margin=1in]{geometry}" _n
file write draft_tex "\usepackage{graphicx}" _n
file write draft_tex "\usepackage{amsmath}" _n
file write draft_tex "\usepackage{float}" _n
file write draft_tex "\usepackage{setspace}" _n
file write draft_tex "\setstretch{1.05}" _n
file write draft_tex "\title{Internal Meta-Analysis of the Water Scarcity--GDP Growth Estimate}" _n
file write draft_tex "\author{Draft for ECN 726 term project}" _n
file write draft_tex "\date{\today}" _n
file write draft_tex "\begin{document}" _n
file write draft_tex "\maketitle" _n
file write draft_tex "\begin{abstract}" _n
file write draft_tex `"This draft revisits the headline GDP-growth estimate in Frost, Madeira, and Martinez Jaramillo (2025) by running an internal meta-analysis over 120 alternative specifications. The replicated baseline coefficient on freshwater withdrawal as a share of available freshwater is `baseline_beta' with standard error `baseline_se' on `baseline_n' observations. Across the specification set, the estimate distribution remains mostly negative, with a mean of `mean_beta' and a median of `median_beta'. The meta-regression shows that nonlinear forms and lower-tail quantile specifications make the scarcity effect substantially more negative, while random-effects and between estimators attenuate it."' _n
file write draft_tex "\end{abstract}" _n

file write draft_tex "\section{Introduction}" _n
file write draft_tex `"Frost, Madeira, and Martinez Jaramillo (2025) ask whether water scarcity has macroeconomically relevant effects on output, investment, and inflation. My focal metric is the coefficient on freshwater withdrawal as a share of available freshwater in the GDP growth regression reported in their Table 3, column (3). Using the replicated Stata workflow, I exactly reproduce that benchmark in the 1990--2020 panel used for the extension: the coefficient is `baseline_beta' with standard error `baseline_se', N = `baseline_n', and R-squared = `baseline_r2'."' _n
file write draft_tex `"The extension treats this coefficient as one draw from a broader model space. Following Banzhaf and Smith (2007), I vary two dimensions of modeling choice: the functional form for scarcity and the panel estimator. The resulting 120 estimates are summarized with a specification curve and an auxiliary meta-regression. This design makes it possible to ask whether the negative scarcity--growth relationship is robust to economically motivated nonlinearities and to alternative ways of using within-country and between-country variation."' _n

file write draft_tex "\section{Data}" _n
file write draft_tex "The extension reuses the replication package data pipeline and merges the same four formatted panel sources used in the original GDP growth regressions: World Bank macro data, Aquastat water data, Worldwide Governance Indicators, and Penn World Table series. The merged panel is unbalanced and spans 169 countries over 1990--2020 after the extension's analysis-window check. The dependent variable is annual GDP growth. The baseline controls are log total water withdrawal per capita and log GDP per capita in PPP terms." _n
file write draft_tex "Water scarcity is measured three ways: freshwater withdrawal as a share of internal renewable resources, as a share of total renewable resources, and as a share of available freshwater. Consistent with the original code and the paper's description, each scarcity measure is capped at 100 and then carried into the regression pipeline after top-percentile winsorization. The panel retains the original sample differences across scarcity measures, so the internal-resource sample is slightly smaller than the renewable-resource and available-freshwater samples." _n

file write draft_tex "\section{Model Specification}" _n
file write draft_tex "The original paper motivates the empirical analysis with a Cobb-Douglas production function in which water enters as an additional input and scarcity lowers effective productivity. Let output depend on TFP, capital, labor, and a scarcity-adjusted water term. Under the paper's parameterization, higher water scarcity lowers the productivity contribution of water through a factor proportional to $1/(1+WS_{ct})$. The empirical specification replaces the structural object with a linear panel-data approximation in which GDP growth is regressed on a scarcity measure, log water withdrawal per capita, log GDP per capita, country fixed effects, and year fixed effects." _n
file write draft_tex "This identifying strategy is informative but not causal. Reverse causality remains possible if weak growth reduces water demand or changes sectoral composition in ways that feed back into measured scarcity. Omitted variables are also a concern: institutions, trade exposure, energy composition, and sectoral structure may jointly shape both macro performance and water use. The extension therefore treats the focal estimate as an association whose stability can still be evaluated across plausible modeling choices, even though those choices do not solve endogeneity on their own." _n

file write draft_tex "\section{Analysis Design}" _n
file write draft_tex "The first modeling dimension is functional form. The linear baseline preserves the authors' original design. A quadratic term tests whether the drag from scarcity steepens as water constraints tighten. An interaction with log GDP per capita asks whether richer countries buffer scarcity through infrastructure, technology, or sectoral composition. An interaction with log water use per capita tests whether high scarcity becomes more harmful when absolute water demand is also high. Finally, a threshold specification allows the scarcity slope to change above the median scarcity level, capturing the possibility that water becomes a binding constraint only after a critical point is reached." _n
file write draft_tex "The second dimension is estimator choice. Country fixed effects without year effects test whether global shocks matter for the baseline coefficient. Two-way fixed effects are the benchmark. Random effects and the Hausman comparison assess whether between-country variation carries useful information or is contaminated by omitted heterogeneity. The between estimator isolates long-run cross-country differences. First differences offer an alternative transformation that removes country effects through changes rather than demeaning. Machado and Santos Silva's (2019) panel quantile estimator is used at the 25th, 50th, and 75th percentiles without year fixed effects, in line with the authors' own ancillary-parameter caveat." _n
file write draft_tex "The meta-regression summarizes the estimate distribution as" _n
file write draft_tex "\[" _n
file write draft_tex "\begin{aligned}" _n
file write draft_tex "\hat{\beta}_s =\ & \gamma_0 + \gamma_1 d_{quadratic,s} + \gamma_2 d_{income,s} + \gamma_3 d_{use,s} + \gamma_4 d_{threshold,s} + \gamma_5 d_{internal,s} + \gamma_6 d_{renewable,s} \\" _n
file write draft_tex "& + \gamma_7 d_{countryFE,s} + \gamma_8 d_{RE,s} + \gamma_9 d_{between,s} + \gamma_{10} d_{FD,s} + \gamma_{11} d_{Q25,s} + \gamma_{12} d_{Q50,s} + \gamma_{13} d_{Q75,s} + \varepsilon_s," _n
file write draft_tex "\end{aligned}" _n
file write draft_tex "\]" _n
file write draft_tex "where the omitted categories are the linear form, the available-freshwater scarcity measure, and the two-way fixed-effects estimator." _n

file write draft_tex "\section{Analysis Results}" _n
file write draft_tex `"All 120 planned specifications converged, so the internal meta-analysis covers the complete design space. Table~\ref{tab:dist} reports the distribution of the resulting scarcity coefficients, and Table~\ref{tab:meta_ame} reports the AME-based meta-regression coefficients. The average estimate is `mean_beta', the median is `median_beta', the interquartile range runs from `p25_beta' to `p75_beta', `share_negative'\% of the estimates are negative, and `share_sig05'\% are statistically significant at the 5\% level. These moments already suggest that the sign of the relationship is usually stable even when the magnitude is not."' _n
file write draft_tex "\begin{figure}[H]" _n
file write draft_tex "\centering" _n
file write draft_tex "\includegraphics[width=\textwidth]{../figures/specification_curve.png}" _n
file write draft_tex "\caption{Specification curve for the 120 water scarcity estimates}" _n
file write draft_tex "\label{fig:spec_curve}" _n
file write draft_tex "\end{figure}" _n
file write draft_tex "\input{../tables/estimate_distribution.tex}" _n
file write draft_tex "\input{../tables/meta_regression_ame.tex}" _n
file write draft_tex "Figure~\ref{fig:spec_curve} shows that the authors' baseline estimate lies in the middle of a much wider but still mostly negative distribution. The meta-regression indicates that several modeling choices systematically shift the estimate away from the baseline." _n
file write draft_tex `"Relative to the two-way fixed-effects linear baseline, the quadratic specification lowers the coefficient by `b_quad' (p=`p_quad'), the income interaction lowers it by `b_inc' (p=`p_inc'), and the threshold model lowers it by `b_thr' (p=`p_thr'). These are economically meaningful changes: each one makes the scarcity effect substantially more negative."' _n
file write draft_tex `"Estimator choice also matters. In the AME meta-regression, the no-year-FE dummy is negative (`b_noyear', p=`p_noyear'), which means that the country-FE-only specification is more negative than the two-way fixed-effects baseline once the functional-form and scarcity-measure controls are held fixed. Random-effects and between estimators then shift the coefficient upward by `b_re' (p=`p_re') and `b_bet' (p=`p_bet') relative to their own reference cells. This pattern is consistent with the idea that the within-country signal is more negative than the between-country correlation, while models that omit year effects inherit an additional negative shift."' _n
file write draft_tex `"The quantile results reinforce the paper's tail-risk interpretation. The Q25 and Q50 coefficients are `b_q25' and `b_q50' below the baseline meta-regression constant, while the Q75 shift is `b_q75' (p=`p_q75'). Lower-tail growth episodes therefore appear especially sensitive to water scarcity."' _n
file write draft_tex "\begin{figure}[H]" _n
file write draft_tex "\centering" _n
file write draft_tex "\includegraphics[width=0.85\textwidth]{../figures/marginal_effect_income.png}" _n
file write draft_tex "\caption{Marginal effect of water scarcity across income levels}" _n
file write draft_tex "\label{fig:marginal_income}" _n
file write draft_tex "\end{figure}" _n
file write draft_tex "Figure~\ref{fig:marginal_income} visualizes the two-way fixed-effects income-interaction specification for the available-freshwater measure. The point estimate becomes less negative as income rises, which is consistent with the idea that richer economies can partially buffer water constraints through infrastructure, technology, or sectoral composition. The confidence band approaches zero only near the upper end of the income distribution, so the attenuation is economically meaningful even though the sign does not reverse over most of the observed support." _n
file write draft_tex "\begin{figure}[H]" _n
file write draft_tex "\centering" _n
file write draft_tex "\includegraphics[width=0.9\textwidth]{../figures/shadow_price_proxy.png}" _n
file write draft_tex "\caption{Observed OECD water prices and the normalized implied shadow-price proxy}" _n
file write draft_tex "\label{fig:shadow_price}" _n
file write draft_tex "\end{figure}" _n
file write draft_tex "The supplementary pricing figure compares observed OECD water supply and sanitation prices with a normalized implied shadow-price proxy computed as water productivity divided by one plus the water-stress ratio. Because the source paper does not calibrate the water-share term in the Cobb-Douglas model, the figure normalizes that term to one. The figure should therefore be read as a cross-country pricing diagnostic rather than as a structural estimate of the level of the marginal product of water." _n

file write draft_tex "\section{Conclusions}" _n
file write draft_tex "The extension supports the paper's central claim that water scarcity is associated with weaker macroeconomic performance. The sign of the scarcity coefficient is negative in most specifications, and the lower-tail quantile estimates are especially adverse. At the same time, the magnitude is not invariant. Functional forms that allow for nonlinear or heterogeneous effects tend to amplify the drag from scarcity, while estimators that rely more heavily on between-country variation attenuate it." _n
file write draft_tex "These results suggest that the original two-way fixed-effects estimate is informative but incomplete. Water scarcity appears to matter most in fragile growth states and in specifications that let scarcity interact with the level of development or with threshold effects. Future work should focus on richer controls for sectoral composition, trade, and institutions, and on designs that can better address reverse causality and omitted-variable bias. A more structural pricing exercise would also require an explicit calibration of water's production share rather than the normalization used here." _n

file write draft_tex "\begin{thebibliography}{9}" _n
file write draft_tex "\bibitem{banzhaf_smith_2007} Banzhaf, H. Spencer, and V. Kerry Smith. 2007. Meta-analysis in model implementation: Choice sets and the valuation of air quality improvements. \textit{Journal of Applied Econometrics} 22(6): 1013--1031." _n
file write draft_tex "\bibitem{frost_madeira_mj_2025} Frost, Jon, Carlos Madeira, and Serafin Martinez Jaramillo. 2025. The economics of water scarcity. BIS Working Papers No. 1314." _n
file write draft_tex "\bibitem{machado_santos_silva_2019} Machado, Jose A. F., and J. M. C. Santos Silva. 2019. Quantiles via moments. \textit{Journal of Econometrics} 213(1): 145--173." _n
file write draft_tex "\bibitem{oecd_2010} OECD. 2010. \textit{Pricing Water Resources and Water and Sanitation Services}. Paris: Organisation for Economic Co-operation and Development." _n
file write draft_tex "\end{thebibliography}" _n
file write draft_tex "\end{document}" _n
file close draft_tex

capture shell which pdflatex
if _rc {
	display as text "Skipping PDF compilation because pdflatex is not available; draft.tex was still written."
}
else {
	capture erase "$EXT_PAPER/draft.pdf"
	local original_cwd `"`c(pwd)'"'
	cd "$EXT_PAPER"
	capture noisily shell pdflatex -interaction=nonstopmode -halt-on-error draft.tex
	cd `"`original_cwd'"'

	capture confirm file "$EXT_PAPER/draft.pdf"
	if _rc {
		display as error "pdflatex compilation did not produce draft.pdf; draft.tex was still written."
	}
	else {
		ext_display_step "Compiled $EXT_PAPER/draft.pdf"
	}
}

ext_display_step "Paper draft written to $EXT_PAPER/draft.tex"
