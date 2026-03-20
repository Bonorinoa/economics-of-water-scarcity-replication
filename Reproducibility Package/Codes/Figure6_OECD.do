clear
import delimited "$pathRef/oecd_water_pricing_2008.csv", clear

local G2 "graphregion(color(white) margin(vsmall)) plotregion(color(white))"

preserve
keep if panel_total_order<.
sort panel_total_order
graph bar total_wss_price_usd_m3, over(display_code, sort(panel_total_order) label(angle(45) labsize(*0.75))) ///
	ytitle("USD/m3") title("Figure 6. Unit price of water services") ///
	subtitle("Panel A. Water supply and sanitation services") ///
	blabel(bar, format(%4.2f) size(vsmall)) bargap(20) legend(off) `G2' ///
	saving(graph6_panel_a.gph, replace)
restore

keep if panel_component_order<.
sort panel_component_order
graph bar water_price_usd_m3 wastewater_price_usd_m3, ///
	over(display_code, sort(panel_component_order) label(angle(45) labsize(*0.75))) ///
	ytitle("USD/m3") title("Figure 6. Unit price of water services") ///
	subtitle("Panel B. Water and wastewater service components") ///
	legend(order(1 "Water" 2 "Wastewater") rows(1) pos(6)) ///
	bargap(20) `G2' saving(graph6_panel_b.gph, replace)

graph combine graph6_panel_a.gph graph6_panel_b.gph, rows(2) cols(1) `G4' ///
	title("Figure 6. Unit price of water services in OECD countries, 2008")

if "`c(os)'" == "Windows" {
	graph export "$pathR/graphs/Fig6_OECD_WaterPrices.emf", replace
}
graph export "$pathR/graphs/Fig6_OECD_WaterPrices.png", replace
