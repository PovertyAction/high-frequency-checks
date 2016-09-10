*! version 1.0.0 Christopher Boyer 04may2016

program ipacheckconsent, rclass
	/* Check that all interviews have consent.

	   IPA best practice is generally to include one or more
	   questions at that asks the enumerator to document 
	   the consent of the interviewee. This check verifies 
	   that all surveys have appropriate consent values for
	   all consent variables. */
	version 13

	#d ;
	syntax varlist, 
		/* consent options */
	    CONSENTvalue(numlist) 
		/* output filename */
	    saving(string) 
	    /* output options */
        id(varname) ENUMerator(varname) [KEEPvars(string)] 
		/* other options */
		[SHEETMODify SHEETREPlace NOLabel];	
	#d cr

	* test for fatal conditions

	* display header text
	di ""
	di "HFC 3 => Checking that all interviews have consent..."

	qui {
	* count nvars
	unab vars : _all
	local nvars : word count `vars'

	* define temporary files 
	tempfile tmp org
	save `org'

	* define temporary variable
	tempvar consent
	g `consent' = .

	* define default output variable list
	unab admin : `id' `enumerator'
	local meta `"variable label value message"'

	* add user-specified keep vars to output list
    local lines : subinstr local keepvars ";" "", all
    local lines : subinstr local lines "." "", all

    local unique : list uniq lines
    local keeplist : list admin | unique
    local keeplist : list keeplist | meta

 	* define loop locals
	local numnoconsent = 0
	local i = 1

	* initialize meta data variables
	foreach var in `meta' {
		g `var' = ""
	}

	* initialize temporary output file
	touch `tmp', var(`keeplist')

	* loop through varlist and capture the number of unconsented surveys 
	foreach var in `varlist' {
		local val : word `i' of `consentvalue'

		* check if there are any violations
		cap assert `var' == `val'
		if _rc {
			* create temp marker variable
			replace `consent' = `var' == `val'

			* count the unconsented
			count if `consent' == 0
			local num = `r(N)'

			* capture variable label
			local varl : variable label `var'

			* update values for additional variables
			replace variable = "`var'"
			replace label = "`varl'"
			replace value = string(`var') if `consent' == 0
			replace message = "Interview does not have valid consent."

			* append violations to the temporary data set
			saveappend using `tmp' if `consent' == 0, ///
			    keep("`keeplist'") sort(`id')
		}
		else {
			* if all consented, set the number of no consent to zero
			local num = 0
		}
		* update the total number of no consents
		local numnoconsent = `numnoconsent' + `num'
		local i = `i' + 1
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

	* export compiled list to excel
	export excel using "`saving'" ,  ///
		sheet("3. consent") `sheetreplace' `sheetmodify' ///
		firstrow(variables) `nolabel'

	* revert to original 
	use `org', clear
	}

	* display stats and return
	di "  Found `numnoconsent' interviews with no consent."
	return scalar noconsent = `numnoconsent'
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

