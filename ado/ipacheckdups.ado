*! version 1.0.0 Christopher Boyer 04may2016

program ipacheckdups, rclass
	/* This program checks that there are no duplicate interviews.

	    */
	version 13

	#d ;
	syntax anything [if] [in], 	
		/* consent options */
	    [UNIQUEvars(anything)]
		/* output filename */
	    saving(string) 
	    /* output options */
        id(varname) ENUMerator(varname) SUBMITted(varname) [KEEPvars(string)] 

		/* other options */
		[SHEETMODify SHEETREPlace NOLabel];	
	#d cr

	marksample touse, novarlist

	di ""
	di "HFC 2 => Checking that there are no duplicates..."
	qui {

	* define temporary files 
	tempfile tmp org
	save `org'

	* define temporary variable
	tempvar dup1 dup2
	
	*merge the variable lists in uniquevars and anything
	loc n = 0
	loc maxvarcount = 1
	while strpos("`anything'", ";") > 0  {
		local ++n
		gettoken varlista anything : anything, p(";")
		local anything : subinstr loc anything ";" ""
		
		if strpos("`uniquevars'", ";") != 1 {
			gettoken varlistb uniquevars : uniquevars, p(";")
		}
		local uniquevars: subinstr loc uniquevars ";" ""
		
		loc varlist`n' `varlista' `varlistb'
		
		*calculate maximum number of variables in a check
		loc newcount : word count "`varlist`n'"
		if `newcount' > `maxvarcount' {
			loc maxvarcount `newcount'
		}
		
	}
	loc checksneeded `n'

	* define default output variable list
	unab admin : `submitted' `id' `enumerator'
	local meta `"variable value message"'

	* add user-specified keep vars to output list
    local keeprows : subinstr local keepvars ";" "", all
    local keeprows : subinstr local keeprows "." "", all

    local uniquekeepvars : list uniq keeprows
    local uniqueidvars: list uniq uniquevars
    local keeplist : list admin | uniqueidvars
    local keeplist : list keeplist | meta
    local keeplist : list keeplist | uniquekeepvars
	
    * define locals
	local ndups1 = 0
	local ndups2 = 0
	local i = 1

	* initialize meta data variables
	foreach var in `meta' {
		g `var' = ""
	}

	* keep only subset of data relevant to command
	keep if `touse'

	* initialize temporary output file
	touch `tmp', var(`keeplist')

	forval x = 1 / `checksneeded' {

		* tag duplicates of id variable 
		duplicates tag `varlist`x'', gen(`dup1')

		* sort data set
		if "`varlist`x''" != "" {
			sort `varlist`x''
		}
		
		* if there are any duplicates
		cap assert `dup1' == 0 
		if _rc {

			* count the duplicates for id var
			count if `dup1' != 0
			local ndups1 = `r(N)'

			* alert the user
			loc length : word count "`varlist`x'"
			if `length' == 1 {
				nois di "  Variable `varlist`x'' has `ndups1' duplicate observations."
			}
			else {
				nois di "  The variable combination `varlist`x'' has `ndups1' duplicate observations"
			}
			
			* capture variable labels
			loc n == 0
			foreach var in `varlist`x''{
				loc ++n
				local varl : variable label `var'

				* update values of meta data variables //NEED TO ADD LOOP FOR EXTRA VARS
				replace variable`n' = "`var'"
				replace label`n' = "`varl'"
				cap confirm numeric variable `var' 
				if !_rc {
					replace value`n' = string(`var')
				}
				else {
					replace value`n' = `var'
				}
			}
			replace message = `"Duplicate observation for `varlist`x''."'

				* append violations to the temporary data set
				saveappend using `tmp' if `dup2' != 0, ///
					keep("`keeplist'")

			}
		}
		else {
			* alert the user
			nois di "  No duplicates found for ID variable `var'."
		}
	    drop `dup1'
	

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
		sheet("2. duplicates") `sheetreplace' `sheetmodify' ///
		firstrow(variables) `nolabel'

	* revert to original
	use `org', clear
	}
	
	return scalar ndups1 = `ndups1'
	return scalar ndups2 = `ndups2'
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
