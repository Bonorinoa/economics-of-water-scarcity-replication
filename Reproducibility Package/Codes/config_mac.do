// macOS configuration for the Frost et al. replication package.
set varabbrev on
set more off

global path "/Users/bonorinoa/Desktop/ECN726/TermProject_2/Reproducibility Package"
global pathR "$path/Outputs"
global pathDs "$pathR/StataData_other"

capture mkdir "$path/Outputs"
capture mkdir "$pathR/graphs"
capture mkdir "$pathR/tables"
capture mkdir "$pathDs"

sysdir set PLUS "$path/Codes/ado"

display "Replication root: $path"
display "Output root: $pathR"
display "Stata data root: $pathDs"
