

	
	set more off
	
	
********************************************************************************
*Next load the metadata
********************************************************************************


*Missing value codes
****************************************
	import excel using "$hfc_metadata" , sheet("Missing codes") firstrow case(preserve) clear
	keep vartype misscode stata_value
	unab allvars: _all
	drop if mi(misscode)
	global kk_miss =_N
	di "$kk_miss `allvars'"
	
*Turn the variables into globals
	forval x=1/`=_N' {
		foreach var of local allvars {
			if `x'==1 global `var' ""
			global `var' `"${`var'} `"`=`var'[`x']'"'"'
		}
	}

	
*Outliers (hard and soft limits)
****************************************
	import excel using "$hfc_metadata" , sheet("Outliers") firstrow case(preserve) clear
	unab allvars: _all
	di "`allvars'"

	drop if mi(Variable)
	global kk_outlier = _N

*Turn the variables into globals
	forval x=1/`=_N' {
		foreach var of local allvars {
			if `x'==1 global `var' ""
			global `var' `"${`var'} `"`=`var'[`x']'"'"'
		}
	}
	
	
	
*Hard Limits
****************************************


	
	
	
	
	
