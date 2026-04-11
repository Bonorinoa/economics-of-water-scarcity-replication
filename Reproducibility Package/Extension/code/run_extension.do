capture log close _all

local ext_root_guess `"`c(pwd)'"'
capture confirm file "Reproducibility Package/Extension/code/00_setup_prereqs.do"
if _rc {
	display as error `"{p}Run this file from the repository root so the relative paths resolve correctly:{break}do ""Reproducibility Package/Extension/code/run_extension.do""{p_end}"'
	exit 601
}

global FROST_REPO_ROOT `"`ext_root_guess'"'
log using "Reproducibility Package/Extension/logs/run_extension.log", replace text

display as text "=== Water scarcity extension: starting full pipeline ==="
display as text "Repository root: $FROST_REPO_ROOT"

do "Reproducibility Package/Extension/code/00_setup_prereqs.do"
do "Reproducibility Package/Extension/code/01_build_analysis_panel.do"
do "Reproducibility Package/Extension/code/02_verify_baseline.do"
do "Reproducibility Package/Extension/code/03_run_spec_grid.do"
do "Reproducibility Package/Extension/code/04_meta_regression.do"
do "Reproducibility Package/Extension/code/05_make_figures.do"
do "Reproducibility Package/Extension/code/06_write_paper.do"

display as text "=== Water scarcity extension: pipeline finished ==="
log close _all
