*! version 2.0.1 Christopher Boyer 26jul2017

program ipacheckdups, rclass
	/* This program checks that there are no duplicate interviews.

	    */
	version 13

	#d ;
	syntax anything [if] [in], 	
		/* consent options */
	    [UNIQUEvars(string)]
		/* output filename */
	    saving(string) 
	    /* output options */
        id(varname) ENUMerator(varname) SUBMITted(varname) 
		[KEEPvars(string) SCTOdb(string)] 

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
	tempvar dup1
	
	* merge the variable lists in uniquevars and anything
	loc n = 0
	while strpos("`anything'", ";") > 0 {
		local ++n
		gettoken varlista`n' anything : anything, p(";")
		local anything : subinstr loc anything ";" ""
		
		if strpos("`uniquevars'", ";") != 1 {
			gettoken varlistb`n' uniquevars : uniquevars, p(";")
		}
		local uniquevars: subinstr loc uniquevars ";" ""
		local varlistb`n': subinstr loc varlistb`n' ";" ""
		
		loc varlist`n' `varlista`n'' `varlistb`n''
		
	}
	loc checksneeded `n'

	* define default output variable list
	unab admin : `submitted' `id' `enumerator'
	local meta `"variable label value message"'
	if !missing("`sctodb'") {
		local meta `"`meta' scto_link"'
	}
	
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

	* keep only subset of data relevant to command
	keep if `touse'

	* initialize temporary output file
	poke `tmp', var(`keeplist')

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
			
			* update values of meta data variables 
			replace value = ""
			replace variable = "`varlist`x''"
			
			loc n = 0
			foreach var in `varlist`x'' {
				loc ++n
				local varl : variable label `var'
				replace label = "`varl'" if label == ""
				cap confirm numeric variable `var' 
				if !_rc {
					replace value = value + " " + string(`var')
				}
				else {
					replace value = value + " " + `var'
				}
			}
			replace value = strtrim(value) // removes extra spaces
			replace message = `"Duplicate observation for `varlist`x''."'

				* append violations to the temporary data set
				saveappend using `tmp' if `dup1' != 0, ///
					keep("`keeplist'")
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
    gsort -`submitted'

	* export compiled list to excel
	export excel using "`saving'" ,  ///
		sheet("2. duplicates") `sheetreplace' `sheetmodify' ///
		firstrow(variables) `nolabel'
		
	*export scto links as links
	if !missing("`sctodb'") & c(version) >= 14 {
		if !missing(scto_link[1]) {
			putexcel set "`saving'", sheet("2. duplicates") modify
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
	
	return scalar ndups1 = `ndups1'
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
