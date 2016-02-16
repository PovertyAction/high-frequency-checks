/*----------------------------------------*
 |file:    ipacheckimport.ado             | 
 |project: high frequency checks          |
 |author:  christopher boyer              |
 |         innovations for poverty action |
 |date:    2016-02-13                     |
 *----------------------------------------*/

 // this program imports metadata from the input file

capture program drop ipacheckimport
program ipacheckimport, rclass
	di ""
	qui {

	syntax using ,  Version(string) [noclear maxvar(numlist) matsize(numlist)]

	/* <=========== HFC 1. Check that all interviews were completed ===========> */

	import excel using "`using'" , sheet("1. incomplete") firstrow case(preserve) clear
	unab allvars: _all
	di "`allvars'"

	drop if mi(variable)
	local kk_outlier = _N

 	//Turn the variables into locals
	forval x=1/`=_N' {
		foreach var of local allvars {
			if `x'==1 local `var' ""
			local `var' `"${`var'} `"`=`var'[`x']'"'"'
		}
	}

	/* <======== HFC 2. Check that there are no duplicate observations ========> */

	import excel using "`using'" , sheet("2. duplicates") firstrow case(preserve) clear
	unab allvars: _all

	/* <============== HFC 3. Check that all surveys have consent =============> */

	import excel using "`using'" , sheet("3. consent") firstrow case(preserve) clear
	unab allvars: _all

	/* <===== HFC 4. Check that critical variables have no missing values =====> */

	import excel using "`using'" , sheet("4. no miss") firstrow case(preserve) clear
	unab allvars: _all

	drop if mi(variable)
	local kk_outlier = _N

 	//Turn the variables into locals
	forval x=1/`=_N' {
		foreach var of local allvars {
			if `x'==1 local `var' ""
			local `var' `"${`var'} `"`=`var'[`x']'"'"'
		}
	}

	/* <======== HFC 5. Check that follow up record ids match original ========> */

	import excel using "`using'" , sheet("5. follow up") firstrow case(preserve) clear
	unab allvars: _all

	/* <====== HFC 6. Check that no variable has only one distinct value ======> */

	import excel using "`using'" , sheet("6. distinct") firstrow case(preserve) clear
	unab allvars: _all


	/* <======== HFC 7. Check that no variable has all missing values =========> */

	import excel using "`using'" , sheet("7. all miss") firstrow case(preserve) clear
	unab allvars: _all

	drop if mi(variable)
	local kk_outlier = _N

 	//Turn the variables into locals
	forval x=1/`=_N' {
		foreach var of local allvars {
			if `x'==1 local `var' ""
			local `var' `"${`var'} `"`=`var'[`x']'"'"'
		}
	}

	/* <============= HFC 8. Check for outliers/soft constraints ==============> */

	import excel using "`using'" , sheet("8. constraints") firstrow case(preserve) clear
	unab allvars: _all
	di "`allvars'"

	drop if mi(variable)
	local kk_outlier = _N

 	//Turn the variables into locals
	forval x=1/`=_N' {
		foreach var of local allvars {
			if `x'==1 local `var' ""
			local `var' `"${`var'} `"`=`var'[`x']'"'"'
		}
	}

	/* <================== HFC 9. Check specify other values ==================> */

	import excel using "`using'" , sheet("9. other") firstrow case(preserve) clear
	unab allvars: _all

	/* <========== HFC 10. Check that dates fall within survey range ==========> */

	import excel using "`using'" , sheet("10. date") firstrow case(preserve) clear
	unab allvars: _all
	di "`allvars'"

	drop if mi(variable)
	local kk_outlier = _N

 	//Turn the variables into locals
	forval x=1/`=_N' {
		foreach var of local allvars {
			if `x'==1 local `var' ""
			local `var' `"${`var'} `"`=`var'[`x']'"'"'
		}
	}

	/* <============= HFC 11. Check for outliers/soft constraints =============> */

	import excel using "`using'" , sheet("11. outlier") firstrow case(preserve) clear
	unab allvars: _all

	/* <============= HFC 12. Check survey and section durations ==============> */

	import excel using "`using'" , sheet("12. duration") firstrow case(preserve) clear
	unab allvars: _all

	}

end
