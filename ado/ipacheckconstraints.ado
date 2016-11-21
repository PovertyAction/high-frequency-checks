*! version 1.0.0 Christopher Boyer 04may2016

program ipacheckconstraints, rclass
	/* Check that certain numeric variables fall within
	   reasonable hard and soft constraints..

	   Most numeric questions that are asked during an 
	   interview have a logical range of possible values.
	   Entries that exceed these limits could be a sign of
	   misentry or fraud. */
	version 13

	#d ;
	syntax varlist, 
		/* soft constraint options */
	    [smin(numlist miss) smax(numlist miss)]
		/* hard constraint options */
	    [hmin(numlist miss) hmax(numlist miss)]
		/* output filename */
	    saving(string) 
	    /* output options */
        id(varname) ENUMerator(varname) SUBMITted(varname) [KEEPvars(string)] 
		/* other options */
		[SHEETMODify SHEETREPlace NOLabel];	
	#d cr

	* test for fatal conditions
	if mi("`smin'`smax'`hmin'`hmax'") {
			di as err "must specify at least one constraint value."
			error 198
	}

	di ""
	di "HFC 8 => Checking that values do not exceed soft/hard minimums and maximums..."

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

 	* define loop locals
	local nviol = 0 
	local nhard = 0
	local nsoft = 0
	local i = 1

	* initialize meta data variables
	foreach var in `meta' {
		g `var' = ""
	}

	* initialize temporary output file
	touch `tmp', var(`keeplist')

	/* loop through varlist and check that values
	   fall within hard and soft constraints */
	foreach var in `varlist' {
		* get constraint values for current variable
		local minsoft: word `i' of `smin'
		local minhard: word `i' of `hmin'
		local maxsoft: word `i' of `smax'
		local maxhard: word `i' of `hmax'
		local npvar = 0
		
		* replace unspecified constraints with Stata missing value
		if `"`minsoft'"' == "" local minsoft .
		if `"`minhard'"' == "" local minhard .
		if `"`maxsoft'"' == "" local maxsoft .
		if `"`maxhard'"' == "" local maxhard .		

		* capture variable label
		local varl : variable label `var'

		* update values for additional variables
		replace variable = "`var'"
		replace label = "`varl'"
		replace value = string(`var')
			
		/* =======================
		   = check hard minimums =
		   ======================= */
		replace `viol' = `var' < `minhard' & `minhard' < .
		replace message = "Value is too small. Hard Min. = `minhard'"

		* count the violations
		count if `viol' == 1
		local nviol = `nviol' + `r(N)'
		local npvar = `npvar' + `r(N)'
		local nhard = `nhard' + `r(N)'

		* append violations to the temporary data set
		saveappend using `tmp' if `viol' == 1, ///
			    keep("`keeplist'") sort(`id')

		/* =======================
		   = check hard maximums =
		   ======================= */
		replace `viol' = `var' > `maxhard' & `maxhard' < . & `var' < . 
		replace message = "Value is too high. Hard Max. = `maxhard'"

		* count the violations
		count if `viol' == 1
		local nviol = `nviol' + `r(N)'
		local npvar = `npvar' + `r(N)'
		local nhard = `nhard' + `r(N)'

		* append violations to the temporary data set
		saveappend using `tmp' if `viol' == 1, ///
			    keep("`keeplist'") sort(`id')

	    /* =======================
		   = check soft minimums =
		   ======================= */

		replace `viol' = `var' < `minsoft' & `minsoft' < .
		replace message = "Value is too small. Soft Min. = `minsoft'"

		* count the violations
		count if `viol' == 1
		local nviol = `nviol' + `r(N)'
		local npvar = `npvar' + `r(N)'
		local nsoft = `nsoft' + `r(N)'

		* append violations to the temporary data set
		saveappend using `tmp' if `viol' == 1, ///
			    keep("`keeplist'") sort(`id')

		/* =======================
		   = check soft maximums =
		   ======================= */

		replace `viol' = `var' > `maxsoft' & `maxsoft' < . & `var' < . 
		replace message = "Value is too high. Soft Max. = `maxsoft'"

		* count the violations
		count if `viol' == 1
		local nviol = `nviol' + `r(N)'
		local npvar = `npvar' + `r(N)'
		local nsoft = `nsoft' + `r(N)'

		* append violations to the temporary data set
		saveappend using `tmp' if `viol' == 1, ///
			    keep("`keeplist'") sort(`id')

		if `npvar' > 0 {
			nois di "  Variable `var' has `npvar' constraint violations."
		}
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
    gsort -`submitted'

	* export compiled list to excel
	export excel using "`saving'" ,  ///
		sheet("8. constraints") `sheetreplace' `sheetmodify' ///
		firstrow(variables) `nolabel'

	* revert to original
	use `org', clear
	}
	* display check statistics to output screen
	di ""
	di "  Found `nviol' total constraint violations: `nhard' hard and `nsoft' soft."
	return scalar nviol = `nviol'
	return scalar nhard = `nhard'
	return scalar nsoft = `nsoft'
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

	append using `using', force

	if "`sort'" != "" {
		sort `sort'
	}

	drop `touse'
	save `using', replace

	restore
end

