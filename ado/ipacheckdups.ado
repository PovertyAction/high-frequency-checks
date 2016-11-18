*! version 1.0.0 Christopher Boyer 04may2016

program ipacheckdups, rclass
	/* This program checks that there are no duplicate interviews.

	    */
	version 13

	#d ;
	syntax varlist [if] [in], 	
		/* consent options */
	    [UNIQUEvars(varlist)]
		/* output filename */
	    saving(string) 
	    /* output options */
        id(varname) ENUMerator(varname) [KEEPvars(string)] 
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

	* define default output variable list
	unab admin : `id' `enumerator'
	local meta `"variable label value message"'

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

	foreach var in `varlist' {
		local uvars: word `i' of `"`uniquevars'"'
		local i = `i' + 1

		* tag duplicates of id variable 
		duplicates tag `var', gen(`dup1')

		* sort data set
		if "`var'" != "" {
			sort `var'
		}
		
		* if there are any duplicates
		cap assert `dup1' == 0 
		if _rc {

			* count the duplicates for id var
			count if `dup1' != 0
			local ndups1 = `r(N)'

			if "`uvars'" != "" {
				
				sort `var' `uvars'
				
				/* if specified, tag any duplicates for the id and a combination
				   of other variables that should uniquely identify the data set.
				   Example - data set in memory has multiple interviews with 
				   same subject and id + date uniquely identify data. */
				duplicates tag `var' `uvars', gen(`dup2')

				* if there are still duplicates
				cap assert `dup2' == 0
				if _rc {
					* count the duplicates
					count if `dup2' != 0
					local ndups2 = `r(N)'

					* alert the user
					nois di "  Variable `var' has `ndups1' duplicate observations."
					nois di "  The variable combination `var' `uniquevars' has `ndups2' duplicate observations"
					
					* capture variable label
					local varl : variable label `var'

					* update values of meta data variables
					replace variable = "`var' `uvars'"
					replace label = "`varl'"
					cap confirm numeric variable `var' 
					if !_rc {
						replace value = string(`var')
						foreach v in `uvars' {
							cap confirm numeric variable `v'
							if !_rc {
								replace value = value + " " + string(`v')
							}
							else {
								replace value = value + " " + `v'
							}
						}
					}
					else {
						replace value = `var'
						foreach v in `uvars' {
							cap confirm numeric variable `v'
							if !_rc {
								replace value = value + " " + string(`v')
							}
							else {
								replace value = value + " " + `v'
							}
						}
					}
			 		replace message = `"Duplicate observation for `var' + `uvars'."'

					* append violations to the temporary data set
					saveappend using `tmp' if `dup2' != 0, ///
						keep("`keeplist'")

				}
				else {
					* alert the user that no duplicates found for unique vars
					nois di "  No duplicates found for ID combination `var' + `uvars'."
				}
				drop `dup2'
			}
			else {
				
				* alert the user
				nois di "  Variable `var' has `ndups1' duplicate observations."
				
				* capture variable label
				local varl : variable label `var'

				* update values of meta data variables
				replace variable = "`var'"
				replace label = "`varl'"
				cap confirm numeric variable `var' 
				if !_rc {
					replace value = string(`var')
				}
				else {
					replace value = `var'
				}
		 		replace message = `"Duplicate observation for `var'."'

				* append violations to the temporary data set
				saveappend using `tmp' if `dup1' != 0, ///
					keep("`keeplist'")

			}
		}
		else {
			* alert the user
			nois di "  No duplicates found for ID variable `var'."
		}
	    drop `dup1'
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
