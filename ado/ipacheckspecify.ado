*! version 2.0.1 Christopher Boyer 26jul2017

program ipacheckspecify, rclass
	/* This program checks for recodes of specify other variables 
	   by listing all other values specified. */
	version 13

	#d ;
	syntax varlist, 
		/* parent variables */
		PARENTvars(varlist)
		/* output filename */
	    saving(string) 
	    /* output options */
        id(varname) ENUMerator(varname) SUBMITted(varname) 
		[KEEPvars(string) SCTOdb(string)] 

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
	local meta `"parent parent_label parent_value child child_label child_value choices message"'
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
	local nother = 0
	local i = 1

	* initialize meta data variables
	foreach var in `meta' {
		g `var' = ""
	}
	
	*generate scto_link variable
	if !missing("`sctodb'") {
		replace scto_link = subinstr(key, ":", "%3A", 1)
		replace scto_link = `"=HYPERLINK("https://`sctodb'.surveycto.com/view/submission.html?uuid="' + scto_link + `"", "View Submission")"'
	}

	* initialize temporary output file
	poke `tmp', var(`keeplist')

	/* idea - could add check here for additional specify other variables
	   not included in the input file */

	* loop through other specify variables in varlist and find nonmissing values
	foreach var in `varlist' {
		* get current other variable
		local parent : word `i' of `parentvars'

		cap confirm string variable `var'
		if !_rc {
			replace `specified' = `var' != ""

			* count the number of specified other values
			count if `specified' == 1
			local n = `r(N)'
			local nother = `nother' + `n'

			* capture variable label
			local pvarl : variable label `parent'
			local cvarl : variable label `var'

			* capture choices 
			getlabel `parent'
			local vall = "`r(label)'"

			* update values of meta data variables
			replace parent = "`parent'"
			replace parent_label = "`pvarl'"
			replace child = "`var'"
			replace child_label = "`cvarl'"
			replace child_value = `var'
			replace choices = "`vall'"
	 		replace message = "Other value specified for `var'. Check for possible recodes."

	 		cap confirm numeric variable `parent'
	 		if !_rc {
	 			replace parent_value = string(`parent')
	 		}

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

	*export scto links as links
	if !missing("`sctodb'") & c(version) >= 14 {
		if !missing(scto_link[1]) {
			putexcel set "`saving'", sheet("9. specify") modify
			ds
			loc allvars `r(varlist)'
			loc linkpos: list posof "scto_link" in allvars
			alphacol `linkpos'
			loc col = r(alphacol)
			count
			forval x = 1 / `r(N)' {
				loc row = `x' + 1
				loc formula = scto_link[`x']
				loc putlist `"`putlist' `col'`row' = formula(`"`formula'"')"'
			}
			putexcel `putlist'
		}
	}
	
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

program alphacol, rclass
	syntax anything(name = num id = "number")

	local col = ""

	while `num' > 0 {
		local let = mod(`num'-1, 26)
		local col = char(`let' + 65) + "`col'"
		local num = floor((`num' - `let') / 26)
	}

	return local alphacol = "`col'"
end
