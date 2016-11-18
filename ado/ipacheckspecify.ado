*! version 1.0.0 Christopher Boyer 04may2016

program ipacheckspecify, rclass
	/* This program checks for recodes of specify other variables 
	   by listing all other values specified. */
	version 13

	#d ;
	syntax varlist, 
		/* other variables */
		OTHERvars(varlist)
		/* output filename */
	    saving(string) 
	    /* output options */
        id(varname) ENUMerator(varname) SUBMITted(varname) [KEEPvars(string)] 

		/* other options */
		[SHEETMODify SHEETREPlace NOLabel];	
	#d cr	

	di ""
	di "HFC 9 => Checking specify other variables for misscodes and new categories..."
	qui {

	* count nvars
	unab vars : _all
	local nvars : word count `vars'

	* define temporary files 
	tempfile tmp org
	save `org'

	* define temporary variable
	tempvar specified
	g `specified' = .

	* define default output variable list
	unab admin : `submitted' `id' `enumerator' 
	local meta `"variable label value choices message"'

	* add user-specified keep vars to output list
    local lines : subinstr local keepvars ";" "", all
    local lines : subinstr local lines "." "", all

    local unique : list uniq lines
    local keeplist : list admin | meta
    local keeplist : list keeplist | unique

    * initialize local counters
	local nother = 0
	local i = 1

	* initialize meta data variables
	foreach var in `meta' {
		g `var' = ""
	}

	* initialize temporary output file
	touch `tmp', var(`keeplist')

	/* idea - could add check here for additional specify other variables
	   not included in the input file */

	* loop through other specify variables in varlist and find nonmissing values
	foreach var in `varlist' {
		* get current other variable
		local other : word `i' of `othervars'

		cap confirm string variable `var'
		if !_rc {
			replace `specified' = `var' != ""

			* count the number of specified other values
			count if `specified' == 1
			local n = `r(N)'
			local nother = `nother' + `n'

			* capture variable label
			local varl : variable label `var'

			* capture choices 
			getlabel `other'
			local vall = "`r(label)'"

			* update values of meta data variables
			replace variable = "`var'"
			replace label = "`varl'"
			replace value = `var'
			replace choices = "`vall'"
	 		replace message = "Other value specified for `var'. Check for recodes."

			* append violations to the temporary data set
			saveappend using `tmp' if `specified' == 1, ///
				keep("`keeplist'")

			noisily di "  Variable {cmd:`var'} has {cmd:`n'} other values specified."
			local i = `i' + 1
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
		sheet("9. specify") `sheetreplace' `sheetmodify' ///
		firstrow(variables) `nolabel'

	* revert to original
	use `org', clear
	
	}

	di ""
	di "  Found {cmd:`nother'} total specified values."
	return scalar nspecify = `nother'

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

program getlabel, rclass

	syntax varname

	qui levelsof `varlist', local(levels)
	local lab: value label `varlist'

	local out ""
	local i = 1
	if "`lab'" != "" {
		foreach l of local levels {
			if `l' < 0 {
				local levels : subinstr local levels "`l'" ""
				local levels : list levels | l
			}
		}
		foreach l of local levels {
			local l`i' : label `lab' `l'
			local out "`out'(`l') `l`i'' "
			local i = `i' + 1
		}
	}

	return local label "`out'"
end
