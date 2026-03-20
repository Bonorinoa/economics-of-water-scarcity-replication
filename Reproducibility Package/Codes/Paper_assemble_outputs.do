if `"$path"' == "" {
	capture confirm file "config_mac.do"
	if !_rc {
		do "config_mac.do"
	}
	else {
		capture confirm file "Reproducibility Package/Codes/config_mac.do"
		if !_rc {
			do "Reproducibility Package/Codes/config_mac.do"
		}
		else {
			display as error `"{p}Could not locate config_mac.do. From the repository root, run: do ""run_paper_replication_mac.do""{p_end}"'
			exit 601
		}
	}
}

display "Rendering paper-ready LaTeX tables..."
shell python3 "$path/Codes/build_paper_tables.py" "$pathTRaw" "$pathR/tables"
