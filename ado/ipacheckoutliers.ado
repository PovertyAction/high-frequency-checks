*! version 1.1.0 Kelsey Larson 21feb2017
*! version 1.0.0 Christopher Boyer 04may2016

program ipacheckoutliers, rclass
	/* This program checks for outliers among 
	   unconstrained survey variables. */
	version 13

	#d ;
	syntax varlist, 
		/* consent options */
	    MULTIplier(numlist missingokay) [SD]
		/* output filename */
	    saving(string) 
	    /* output options */
        id(varname) ENUMerator(varname) SUBMITted(varname) [KEEPvars(string)] 
		[IGNore(string)]

		/* other options */
		[SHEETMODify SHEETREPlace NOLabel];	
	#d cr
	
	* test for fatal conditions
	foreach var in `varlist' {
	    * check that all variables are numeric
		cap confirm numeric variable `var'
		if _rc {
			di as err "Variable `var' is not numeric."
			error 198
		}
	}
	
	*confirm that only numbers are in the exclude list, after removing "."
	foreach num in `ignore' {

		cap confirm number `num'
		if _rc {
			if "`num'" == "." {
				continue // the code isn't harmed by including a "."
			}
			di as err "ignore option contains non-numeric value '`num''."
			error 109
		}
	}

	di ""
	di "HFC 11 => Checking that unconstrained variables have no outliers..."
	qui {

	* count nvars
	unab vars : _all
	local nvars : word count `vars'

	* define temporary files 
	tempfile tmp org
	save `org'

	* define temporary variable
	tempvar outlier min max use
	g `outlier' = .
	g `min' = .
	g `max' = .
	g `use' = .

	* define default output variable list
	unab admin : `submitted' `id' `enumerator'
	local meta `"variable label value message"'
	if !missing("`sctodb'") {
		local meta `"`meta' scto_link"'
	}

	* add user-specified keep vars to output list
    local lines : subinstr local keepvars ";" "", all
    local lines : subinstr local lines "." "", all

    local unique : list uniq lines
    local keeplist : list admin | meta
    local keeplist : list keeplist | unique

    * initialize local counters
	local noutliers = 0
	local i = 1

	* initialize meta data variables
	foreach var in `meta' {
		g `var' = ""
	}
	* generate scto_link variable
	if !missing("`sctodb'") {
		replace scto_link = subinstr(key, ":", "%3A", 1)
		replace scto_link = `"=HYPERLINK("https://`sctodb'.surveycto.com/view/submission.html?uuid="' + scto_link + `"", "View Submission")"'
	}

	* initialize temporary output file
	touch `tmp', var(`keeplist')

	foreach var in `varlist' {
		* mark variables that contain error codes and should be ignored
		replace `use' = 1
		foreach num in `ignore' {
			replace `use' = 0 if `var' == `num'
		}
		* get current value of iqr
		local val : word `i' of `multiplier'
		
		* capture variable label
		local varl : variable label `var'

		* update values for additional variables
		replace variable = "`var'"
		replace label = "`varl'"
		replace value = string(`var')

		if "`sd'" == "" {
			* create temp stats variables
			tempvar sigma q1 q3

			* calculate iqr stats
			egen `sigma' = iqr(`var') if `use' == 1
			egen `q1' = pctile(`var') if `use' == 1, p(25)
			egen `q3' = pctile(`var') if `use' == 1, p(75)
			replace `max' = `q3' + `val' * `sigma'
			replace `min' = `q1' - `val' * `sigma'

			* drop reused egen variables
			drop `sigma' `q1' `q3'

			replace message = "Potential outlier " + value + ///
			    " in variable `var' (`val' * IQR: " + ///
			    string(`min', "%2.0f") + " to " + string(`max', "%2.0f") + ")"
		}
		else {
			* create temp stats variables
			tempvar sigma  mu

			* calculate sd stats
			egen `sigma' = sd(`var') if `use' == 1
			egen `mu' = mean(`var') if `use' == 1
			replace `max' = `mu' + `val' * `sigma'
			replace `min' = `mu' - `val' * `sigma'

			* drop reused egen variables
			drop `sigma' `mu'

			replace message = "Potential outlier " + value + ///
			    " in variable `var' (`val' * SD: " + ///
			    string(`min', "%2.0f") + " to " + string(`max', "%2.0f") + ")"
		}

		* identify outliers 
		replace `outlier' = (`var' > `max' | `var' < `min') ///
			& !mi(`var') & `use' == 1

		* count outliers
		count if `outlier' == 1
		local n = `r(N)'
		local noutliers = `noutliers' + `n'

		* append violations to the temporary data set
		saveappend using `tmp' if `outlier' == 1, ///
		    keep("`keeplist'") sort(`id')

		* alert user
		nois di "  Variable `var' has `n' potential outliers."
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
		sheet("11. outliers") `sheetreplace' `sheetmodify' ///
		firstrow(variables) `nolabel'
	
	*export scto links as links
	if !missing("`sctodb'") {
		putexcel set "`saving'", sheet("11. outliers") modify
		ds
		loc allvars `r(varlist)'
		loc linkpos: list posof "scto_link" in allvars
		loc alphabet `c(ALPHA)'
		local col: word `linkpos' of `alphabet'
		count
		forval x = 1 / `r(N)' {
			loc row = `x' + 1
			loc formula = scto_link[`x']
			loc putlist `"`putlist' `col'`row' = formula(`"`formula'"')"'
		}
		putexcel `putlist'
	}

	* revert to original
	use `org', clear
	}

	* return scalars
	return scalar noutliers = `noutliers'

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
