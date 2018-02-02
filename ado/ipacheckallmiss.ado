*! version 2.0.1 Christopher Boyer 26jul2017

program ipacheckallmiss, rclass
	/* Check that no variables have only missing values, where missing indicates
	   a skip. This could mean that the routing of the survey program was
	   incorrectly programmed. 
	   
	   version 2.0.1: includes formatting for stata 14 and above
	   */
	
	* version 15

	#d ;
	syntax varlist, 
		/* output filename */
	    saving(string) 
	    /* output options */
        id(varname) ENUMerator(varname)
		/* other options */
		[SHEETMODify SHEETREPlace NOLabel];	
	#d cr	

	* test for fatal conditions

	di ""
	di "HFC 7 => Checking that no variables have only missing values..."

	qui {

	* count nvars
	unab vars : _all
	local nvars : word count `vars'

	* define temporary files 
	tempfile tmp org
	save `org'

	* define temporary variable
	tempvar viol
	g `viol' = .

	* define default output variable list
	unab admin : `id' `enumerator'
	local meta `"variable label value message"'
	
	* add user-specified keep vars to output list
    local keeplist : list admin | meta

    * initialize local counters
	local nallmiss = 0

	* initialize meta data variables
	foreach var in `meta' {
		g `var' = ""
	}

	* initialize temporary output file
	poke `tmp', var(`keeplist')
	
	/* Due to the way Stata handles missing values, 
	   we check numeric and string variables separately. */

	* numeric variables
	ds `varlist', has(type numeric)
	foreach var in `r(varlist)' {
		replace `viol' = `var' == .
		
		* count the missing values
		count if `viol' == 1

		if `r(N)' == _N  {
			* capture variable label
			local varl : variable label `var'

			* update values of meta data variables
			replace variable = "`var'"
			replace label = "`varl'"
			replace value = ""
	 		replace message = "Variable `var' has only missing values. Consider checking survey programming and skip patterns."

			* append violations to the temporary data set
			saveappend using `tmp' if _n == 1, ///
				keep("`meta'")

			noi di "  Variable `var' has ALL missing values"
			local nallmiss = `nallmiss' +  1
		}
	}

	* string variables
	ds `varlist', has(type string)
	foreach var in `r(varlist)' {
		replace `viol' = `var' == ""

		* count the missing values
		count if `viol' == 1

		if `r(N)' == _N  {
			* capture variable label
			local varl : variable label `var'

			* update values of meta data variables
			replace variable = "`var'"
			replace label = "`varl'"
			replace value = ""
	 		replace message = "Variable `var' has only missing values. Consider checking survey programming and skip patterns."

			* append violations to the temporary data set
			saveappend using `tmp' if _n == 1, ///
				keep("`meta'")

			noi di "  Variable `var' has ALL missing values"
			local nallmiss = `nallmiss' +  1
		}
	}
	* import compiled list of violations
	use `tmp', clear

	* if there are no violations
	if `=_N' == 0 {
		set obs 1
	} 

	* create additional meta data for tracking
	g notes = ""
	g drop = ""
	g newvalue = ""	

	order `keeplist' notes drop newvalue
	keep variable label value message notes drop newvalue
	
	* export compiled list to excel
	export excel using "`saving'" ,  ///
		sheet("7. all missing") `sheetreplace' `sheetmodify' ///
		firstrow(variables) `nolabel'
	
	* Format to headers
	if `c(version)' >= 14.0 {
		d, s
		loc endcol = char(65 + `r(k)' - 1)
				
		putexcel set "`saving'", sheet("7. all missing") modify
		putexcel A1:`endcol'1, bold border(bottom)
	}

	* revert to original
	use `org', clear

	}
	di ""
	di "  Found `nallmiss' variables with all missing values."
	return scalar nallmiss = `nallmiss'
end

program saveappend
	/* this program appends the data in memory, or a subset 
	   of that data, to a stata file on disk. */
	syntax using/ [if] [in] [, keep(varlist) sort(varlist)]

	marksample touse 
	preserve

	keep if `touse'

	if "`keep'" != "" {
		keep `keep' `touse'
	}

	append using `using'

	if "`sort'" != "" {
		sort `sort'
	}

	drop `touse'
	save `using', replace

	restore
end

program poke
	syntax [anything], [var(varlist)] [replace] 

	* remove quotes from filename, if present
	local file = `"`=subinstr(`"`anything'"', `"""', "", .)'"'

	* test fatal conditions
	cap assert "`file'" != "" 
	if _rc {
		di as err "must specify valid filename."
		error 100
	}

	preserve 

	if "`var'" != "" {
		keep `var'
		drop if _n > 0
	}
	else {
		drop _all
		g var = 1
		drop var
	}
	* save 
	save "`file'", emptyok `replace'

	restore

end
