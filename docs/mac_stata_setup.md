# Mac Stata Setup

## First-pass install
- Install Stata 19 for macOS. `Stata/SE` is the default recommendation; `Stata/MP` is only for faster runs.
- Open Stata from the GUI once before using VSCode tasks.
- In Stata, run `ssc install moremata`.

## Environment check
- Open [verify_stata_environment_mac.do](/Users/bonorinoa/Desktop/ECN726/TermProject_2/Reproducibility%20Package/Codes/verify_stata_environment_mac.do) in Stata and run it.
- Confirm that `which reghdfe`, `which xtqreg`, `which outreg2`, `which ftools`, and `findfile moremata.hlp` all succeed.

## Formatting smoke test
- Run [Main_WaterScarcity_FMM_2025_mac_formatting.do](/Users/bonorinoa/Desktop/ECN726/TermProject_2/Reproducibility%20Package/Codes/Main_WaterScarcity_FMM_2025_mac_formatting.do) from the Stata GUI.
- Confirm these files are created under `Reproducibility Package/Outputs/StataData_other/`:
  - `INDSTAT2_natcur_sel.dta`
  - `Aquastat_Bulk.dta`
  - `Aquastat_Selected.dta`
  - `PWT_new.dta`
  - `WGI.dta`
  - `Data_WB.dta`
  - `WB_eletricity.dta`

## Full run
- Run [Main_WaterScarcity_FMM_2025_mac.do](/Users/bonorinoa/Desktop/ECN726/TermProject_2/Reproducibility%20Package/Codes/Main_WaterScarcity_FMM_2025_mac.do) from the Stata GUI.
- Verify generated files in `Reproducibility Package/Outputs/tables/`, `Reproducibility Package/Outputs/graphs/`, and the root `Reproducibility Package/Outputs/` directory.
- Figure 5 is exported to `Outputs/` root, not `Outputs/graphs/`.
- Graph 6 is not code-generated in the public package. Reconstruct it manually from the OECD figures cited in [README.pdf](/Users/bonorinoa/Desktop/ECN726/TermProject_2/README.pdf).

## VSCode task
- Only use the VSCode task after the GUI run succeeds.
- Set `STATA_BIN` in your shell or VSCode environment to your Stata batch executable.
- Then run the `Stata: full mac replication` task from `.vscode/tasks.json`.
