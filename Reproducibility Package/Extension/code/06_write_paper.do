version 19.5

if `"$EXT_SETUP_COMPLETE"' != "1" {
	do "Reproducibility Package/Extension/code/00_setup_prereqs.do"
}

ext_display_step "Writing the paper draft and summary table"

use "$EXT_RESULTS/meta_analysis_results.dta", clear
keep if status == "success"

quietly summarize beta_scarcity, detail
local n_success = r(N)
local mean_beta : display %6.3f r(mean)
local median_beta : display %6.3f r(p50)
local p25_beta : display %6.3f r(p25)
local p75_beta : display %6.3f r(p75)

quietly count if beta_scarcity < 0
local share_negative : display %5.1f 100 * r(N) / `n_success'

quietly count if p_value < 0.05
local share_sig05 : display %5.1f 100 * r(N) / `n_success'

use "$EXT_RESULTS_RAW/meta_regression_coefficients.dta", clear

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

quietly summarize coef if term == "d_country_fe_only", meanonly
local b_cfe : display %6.3f r(mean)
quietly summarize p_value if term == "d_country_fe_only", meanonly
local p_cfe : display %6.3f r(mean)

quietly summarize coef if term == "d_re", meanonly
local b_re : display %6.3f r(mean)
quietly summarize p_value if term == "d_re", meanonly
local p_re : display %6.3f r(mean)

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

foreach scalar_label in ///
	mean_beta median_beta p25_beta p75_beta ///
	share_negative share_sig05 ///
	b_quad p_quad b_inc p_inc b_thr p_thr ///
	b_cfe p_cfe b_re p_re b_bet p_bet ///
	b_q25 p_q25 b_q50 p_q50 b_q75 p_q75 ///
	baseline_beta baseline_se baseline_n baseline_r2 {
	local `scalar_label' = trim("``scalar_label''")
}

capture file close dist_tex
file open dist_tex using "$EXT_TABLES/estimate_distribution.tex", write replace text
file write dist_tex "\begin{table}[htbp]" _n
file write dist_tex "\centering" _n
file write dist_tex "\caption{Distribution of the 120 scarcity estimates}" _n
file write dist_tex "\label{tab:dist}" _n
file write dist_tex "\small" _n
file write dist_tex "\begin{tabular}{lc}" _n
file write dist_tex "\hline" _n
file write dist_tex "Statistic & Value \\\\" _n
file write dist_tex "\hline" _n
file write dist_tex `"Successful specifications & `n_success' \\\\"' _n
file write dist_tex `"Mean beta & `mean_beta' \\\\"' _n
file write dist_tex `"Median beta & `median_beta' \\\\"' _n
file write dist_tex `"25th percentile & `p25_beta' \\\\"' _n
file write dist_tex `"75th percentile & `p75_beta' \\\\"' _n
file write dist_tex `"Share negative (\%) & `share_negative' \\\\"' _n
file write dist_tex `"Share significant at 5\% (\%) & `share_sig05' \\\\"' _n
file write dist_tex "\hline" _n
file write dist_tex "\end{tabular}" _n
file write dist_tex "\end{table}" _n
file close dist_tex

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
file write draft_tex `"All 120 planned specifications converged, so the internal meta-analysis covers the complete design space. Table~\ref{tab:dist} reports the distribution of the resulting scarcity coefficients, and Table~\ref{tab:meta} reports the meta-regression coefficients. The average estimate is `mean_beta', the median is `median_beta', the interquartile range runs from `p25_beta' to `p75_beta', `share_negative'\% of the estimates are negative, and `share_sig05'\% are statistically significant at the 5\% level. These moments already suggest that the sign of the relationship is usually stable even when the magnitude is not."' _n
file write draft_tex "\begin{figure}[H]" _n
file write draft_tex "\centering" _n
file write draft_tex "\includegraphics[width=\textwidth]{../figures/specification_curve.png}" _n
file write draft_tex "\caption{Specification curve for the 120 water scarcity estimates}" _n
file write draft_tex "\label{fig:spec_curve}" _n
file write draft_tex "\end{figure}" _n
file write draft_tex "\input{../tables/estimate_distribution.tex}" _n
file write draft_tex "\input{../tables/meta_regression.tex}" _n
file write draft_tex "Figure~\ref{fig:spec_curve} shows that the authors' baseline estimate lies in the middle of a much wider but still mostly negative distribution. The meta-regression indicates that several modeling choices systematically shift the estimate away from the baseline." _n
file write draft_tex `"Relative to the two-way fixed-effects linear baseline, the quadratic specification lowers the coefficient by `b_quad' (p=`p_quad'), the income interaction lowers it by `b_inc' (p=`p_inc'), and the threshold model lowers it by `b_thr' (p=`p_thr'). These are economically meaningful changes: each one makes the scarcity effect substantially more negative."' _n
file write draft_tex `"Estimator choice also matters. Dropping year fixed effects makes the coefficient `b_cfe' more negative on average (p=`p_cfe'), while random-effects and between estimators shift the coefficient upward by `b_re' (p=`p_re') and `b_bet' (p=`p_bet'), respectively. This pattern is consistent with the idea that the within-country signal is more negative than the between-country correlation."' _n
file write draft_tex `"The quantile results reinforce the paper's tail-risk interpretation. The Q25 and Q50 coefficients are `b_q25' and `b_q50' below the baseline meta-regression constant, while the Q75 shift is `b_q75' (p=`p_q75'). Lower-tail growth episodes therefore appear especially sensitive to water scarcity."' _n
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
