*! version 1.0.0 Christopher Boyer 04may2016

program ipachecknomiss, rclass
	/* This program checks that certain variables have no 
	   missing values, where missing indicates a skip.
	   Examples: 
	       - unique ID
	       - name
	       - dates
	       - other identifying information
	       - survey meta data
	       - the consent variable.
	   Note: A variable at the start of a section often 
	   should not be missing. */
	version 13

	#d ;
	syntax varlist, 
		/* output filename */
	    saving(string) 
	    /* output options */
        id(varname) ENUMerator(varname) SUBMITted(varname) [KEEPvars(string)] 

		/* other options */
		[SHEETMODify SHEETREPlace NOLabel];	
	#d cr	

	* test for fatal conditions

	di ""
	di "HFC 4 => Checking that certain critical variables have no missing values..."
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
	unab admin : `submitted' `id' `enumerator'
	local meta `"variable label value message"'

	* add user-specified keep vars to output list
    local lines : subinstr local keepvars ";" "", all
    local lines : subinstr local lines "." "", all

    local unique : list uniq lines
    local keeplist : list admin | meta
    local keeplist : list keeplist | unique

    * initialize local counters
	local nmiss = 0
	local missvar = 0

	* initialize meta data variables
	foreach var in `meta' {
		g `var' = ""
	}

	* initialize temporary output file
	touch `tmp', var(`keeplist')

	/* Due to the way Stata handles missing values, 
	   we check numeric and string variables separately. */

	* numeric variables
	ds `varlist', has(type numeric)
	foreach var in `r(varlist)' {
		local npvar = 0

		replace `viol' = `var' == .
		
		* count the missing values
		count if `viol' == 1
		local nmiss = `nmiss' + `r(N)'
		local npvar = `npvar' + `r(N)'
		
		* capture variable label
		local varl : variable label `var'

		* update values of meta data variables
		replace variable = "`var'"
		replace label = "`varl'"
		replace value = string(`var')
 		replace message = "Interview is missing value of `var'."

		* append violations to the temporary data set
		saveappend using `tmp' if `viol' == 1, ///
			keep("`keeplist'")

		noi di "  Variable `var' has `npvar' missing values"
		if `npvar' > 0 { 
			local missvar = `missvar' +  1
		}
	}

	* string variables
	ds `varlist', has(type string)
	foreach var in `r(varlist)' {
		local npvar = 0

		replace `viol' = `var' == ""
		
		* count the missing values
		count if `viol' == 1
		local nmiss = `nmiss' + `r(N)'
		local npvar = `npvar' + `r(N)'
		
		* capture variable label
		local varl : variable label `var'

		* update values of meta data variables
		replace variable = "`var'"
		replace label = "`varl'"
		replace value = `var'
 		replace message = "Interview is missing value of `var'."

		* append violations to the temporary data set
		saveappend using `tmp' if `viol' == 1, ///
			keep("`keeplist'")

		noi di "  Variable `var' has `npvar' missing values"
		if `npvar' > 0 { 
			local missvar = `missvar' +  1
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
    gsort -`submitted'

	* export compiled list to excel
	export excel using "`saving'" ,  ///
		sheet("4. no miss") `sheetreplace' `sheetmodify' ///
		firstrow(variables) `nolabel'

	* revert to original
	use `org', clear

	}
	* display check statistics to output screen
	di ""
	di "  Found `nmiss' total missing values among `missvar' variables."
	return scalar nmiss = `nmiss'
	return scalar missvar = `missvar'
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

program touch
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


