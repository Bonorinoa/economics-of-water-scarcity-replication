capture confirm file "Reproducibility Package/Codes/Main_WaterScarcity_FMM_2025_mac.do"
if _rc {
	display as error `"{p}Run this file from the cloned repository root so the relative paths resolve correctly.{p_end}"'
	exit 601
}

global FROST_REPO_ROOT `"`c(pwd)'"'
do "Reproducibility Package/Codes/Main_WaterScarcity_FMM_2025_mac.do"
