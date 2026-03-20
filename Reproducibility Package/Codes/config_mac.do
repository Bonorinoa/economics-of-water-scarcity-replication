// macOS configuration for the Frost et al. replication package.
set varabbrev on
set more off

local repo_root `"$FROST_REPO_ROOT"'
if "`repo_root'" == "" {
	local cwd `"`c(pwd)'"'

	capture confirm file "Reproducibility Package/Codes/Main_WaterScarcity_FMM_2025_mac.do"
	if !_rc {
		local repo_root `"`cwd'"'
	}

	if "`repo_root'" == "" {
		capture confirm file "Main_WaterScarcity_FMM_2025_mac.do"
		if !_rc {
			local repo_root = subinstr(`"`cwd'"', "/Reproducibility Package/Codes", "", 1)
		}
	}
}

if "`repo_root'" == "" {
	display as error "Could not infer the cloned repository root."
	display as error `"{p}From the repository root, run: do ""run_paper_replication_mac.do""{p_end}"'
	exit 601
}

global FROST_REPO_ROOT "`repo_root'"
global path "$FROST_REPO_ROOT/Reproducibility Package"
global pathR "$path/Outputs"
global pathDs "$pathR/StataData_other"
global pathTRaw "$pathR/tables/raw"
global pathRef "$path/Reference"

capture mkdir "$path/Outputs"
capture mkdir "$pathR/graphs"
capture mkdir "$pathR/tables"
capture mkdir "$pathTRaw"
capture mkdir "$pathDs"
capture mkdir "$pathRef"

sysdir set PLUS "$path/Codes/ado"

display "Repository root: $FROST_REPO_ROOT"
display "Replication root: $path"
display "Output root: $pathR"
display "Stata data root: $pathDs"
display "Raw table root: $pathTRaw"
