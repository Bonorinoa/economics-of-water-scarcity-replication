version 19.5

capture program drop ext_display_step
program define ext_display_step
	args message
	display as text ""
	display as text ">>> `message'"
end

capture program drop ext_abort
program define ext_abort
	args message
	display as error ""
	display as error "Extension pipeline halted: `message'"
	exit 459
end

if `"$FROST_REPO_ROOT"' == "" {
	local repo_root `"`c(pwd)'"'
	capture confirm file "`repo_root'/Reproducibility Package/Codes/config_mac.do"
	if _rc {
		local repo_root = subinstr(`"`c(pwd)'"', "/Reproducibility Package/Extension/code", "", 1)
	}
	capture confirm file "`repo_root'/Reproducibility Package/Codes/config_mac.do"
	if _rc {
		ext_abort "could not infer the repository root"
	}
	global FROST_REPO_ROOT `"`repo_root'"'
}

do "$FROST_REPO_ROOT/Reproducibility Package/Codes/config_mac.do"

global EXT_ROOT "$FROST_REPO_ROOT/Reproducibility Package/Extension"
global EXT_CODE "$EXT_ROOT/code"
global EXT_DATA "$EXT_ROOT/data"
global EXT_RESULTS "$EXT_ROOT/results"
global EXT_RESULTS_RAW "$EXT_RESULTS/raw"
global EXT_FIGURES "$EXT_ROOT/figures"
global EXT_TABLES "$EXT_ROOT/tables"
global EXT_PAPER "$EXT_ROOT/paper"
global EXT_LOGS "$EXT_ROOT/logs"

capture mkdir "$EXT_ROOT"
capture mkdir "$EXT_CODE"
capture mkdir "$EXT_DATA"
capture mkdir "$EXT_RESULTS"
capture mkdir "$EXT_RESULTS_RAW"
capture mkdir "$EXT_FIGURES"
capture mkdir "$EXT_TABLES"
capture mkdir "$EXT_PAPER"
capture mkdir "$EXT_LOGS"

set more off
set linesize 255

ext_display_step "Checking Stata environment and vendored ado dependencies"
capture noisily which reghdfe
local rc = _rc
if `rc' {
	ext_abort "reghdfe is not available through the vendored ado path"
}
capture noisily which xtqreg
local rc = _rc
if `rc' {
	ext_abort "xtqreg is not available through the vendored ado path"
}
capture noisily which outreg2
local rc = _rc
if `rc' {
	ext_abort "outreg2 is not available through the vendored ado path"
}
capture noisily which ftools
local rc = _rc
if `rc' {
	ext_abort "ftools is not available through the vendored ado path"
}
capture noisily findfile moremata.hlp
local rc = _rc
if `rc' {
	ext_abort "moremata help file is missing from the vendored ado path"
}

local missing_prereqs 0
foreach f in ///
	"$pathDs/Data_WB.dta" ///
	"$pathDs/Aquastat_Selected.dta" ///
	"$pathDs/WGI.dta" ///
	"$pathDs/PWT_new.dta" {
	capture confirm file `"`f'"'
	if _rc {
		local missing_prereqs 1
	}
}

if `missing_prereqs' {
	ext_display_step "Formatted replication datasets are missing; attempting to rebuild prerequisites"
	capture confirm dir "$path/Data/CSV"
	if _rc {
		ext_abort "raw data folder $path/Data/CSV is missing"
	}
	capture confirm dir "$path/Data/Excel"
	if _rc {
		ext_abort "raw data folder $path/Data/Excel is missing"
	}
	capture confirm dir "$path/Data/Stata"
	if _rc {
		ext_abort "raw data folder $path/Data/Stata is missing"
	}

	do "$path/Codes/Format_UNIDO.do"
	do "$path/Codes/format_Aquastat.do"
	do "$path/Codes/format_PWT.do"
	do "$path/Codes/format_WB.do"
	do "$path/Codes/format_WB2.do"
}
else {
	ext_display_step "Reusing existing formatted replication datasets"
}

foreach f in ///
	"$pathDs/Data_WB.dta" ///
	"$pathDs/Aquastat_Selected.dta" ///
	"$pathDs/WGI.dta" ///
	"$pathDs/PWT_new.dta" {
	capture confirm file `"`f'"'
	if _rc {
		ext_abort `"required formatted dataset is still missing: `f'"'
	}
}

global EXT_SETUP_COMPLETE 1
