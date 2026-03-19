// Quick environment check before running the full package on macOS.
do "/Users/bonorinoa/Desktop/ECN726/TermProject_2/Reproducibility Package/Codes/config_mac.do"

display c(stata_version)
display c(flavor)
display c(os)
adopath

which reghdfe
which xtqreg
which outreg2
which ftools
findfile moremata.hlp
