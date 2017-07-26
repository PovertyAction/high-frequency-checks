*! version 2.0.1 Christopher Boyer 26jul2017

program ipacheckdates, rclass
	/* This program checks for common issues with date
	   variables, including: 
	       1. survey start and end dates are unmissing
           2. survey start and end dates are equal
           3. survey start dates are not before start 
              of data collection
           4. survey start dates are not after the 
              current date
           5. survey start dates within the same geographic 
              cluster are within X days of each other */
    version 13

	#d ;
	syntax varlist, 
		/* date options */
	    SURVEYstart(integer) [ENUMArea(varname) DAYs(integer 4)]
		/* output filename */
	    saving(string) 
	    /* output options */
        id(varname) ENUMerator(varname) SUBMITted(varname) 
		[KEEPvars(string) SCTOdb(string)] 

		/* other options */
		[SHEETMODify SHEETREPlace NOLabel];	
	#d cr

	* set start and end date variables
	gettoken start end : varlist
	gettoken end : end

	foreach date in `start' `end' {
		local fmt_`date' : format `date'
		cap assert regexm("`fmt_`date''", "%t[cCd]")
		if _rc {
			di as err "invalid syntax: variable `date' is not a date or date time variable."
			error 198
		}
	}
	nois di "`start' `end'"
	cap assert lower("`fmt_`start''") == lower("`fmt_`end''")
	if _rc {
		di as err "invalid syntax: `start' and `end' are different date types."
		error 198
	}

	local fmt "`fmt_`start''"

	tempvar startdate enddate

	if regexm("`fmt'", "%tc") {
		g `startdate' = dofc(`start')
		g `enddate' = dofc(`end')
	}
	else if regexm("`fmt'", "%tC") {
		g `startdate' = dofC(`start')
		g `enddate' = dofC(`end')
	}
	else {
		g `startdate' = `start'
		g `enddate' = `end'
	}

	di ""
	di "HFC 10 => Checking date variables for common issues..."
	
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
	local meta `"`start' `end' message"'
	if !missing("`sctodb'") {
		local meta `"`meta' scto_link"'
	}

	* add user-specified keep vars to output list
    local lines : subinstr local keepvars ";" "", all
    local lines : subinstr local lines "." "", all

    local unique : list uniq lines
    local keeplist : list admin | meta
    local keeplist : list keeplist | unique
	
	* initialize locals
	local missing = 0
	local diff_end = 0
	local diff_start = 0
	local diff_today = 0
	local diff_enumarea = 0
	local surveystart_f : di %tdnn/dd/YY `surveystart'
	local today = date(c(current_date), "DMY")
	local today_f : di %tdnn/dd/YY `today'

	* initialize meta data variables
	g message = ""
	*generate scto_link variable
	if !missing("`sctodb'") {
		gen scto_link = subinstr(key, ":", "%3A", 1)
		replace scto_link = `"=HYPERLINK("https://`sctodb'.surveycto.com/view/submission.html?uuid="' + scto_link + `"", "View Submission")"'
	}

	* initialize temporary output file
	poke `tmp', var(`keeplist')

	/* =====================
	    PERFORM DATE CHECKS
	   ===================== */	

	* 1. check that no dates are missing
	cap assert !(missing(`startdate') | missing(`enddate'))
	if _rc {
		replace `viol' = missing(`startdate') | missing(`enddate')
		
		* count the missing dates
		count if `viol' == 1
		local missing = `r(N)'

		* update values of meta data variables
 		replace message = "Interview has missing start or end date."

		* append violations to the temporary data set
		saveappend using `tmp' if `viol' == 1, ///
			keep("`keeplist'")
	}

	* 2. check that interview start and end date are the same.
	cap assert !(`startdate' == `enddate')
	if _rc {
		replace `viol' = `startdate' != `enddate'
		
		* count the missing dates
		count if `viol' == 1
		local diff_end = `r(N)'

		* update values of meta data variables
 		replace message = "Interview has unequal start and end dates."

		* append violations to the temporary data set
		saveappend using `tmp' if `viol' == 1, ///
			keep("`keeplist'")
	}

	* 3. check that interview date is not before the start of data collection. 
    cap assert !(`startdate' < `surveystart')
    if _rc {
    	replace `viol' = `startdate' < `surveystart'
		
		* count the missing dates
		count if `viol' == 1
		local diff_start = `r(N)'

		* update values of meta data variables
 		replace message = "Interview is before the start of" + ///
 		    " data collection (`surveystart_f')."

		* append violations to the temporary data set
		saveappend using `tmp' if `viol' == 1, ///
			keep("`keeplist'")
	}
	
	* 4. check that interview date is not after the system date.
	cap assert !(`startdate' > `today')
	if _rc {
		replace `viol' = `startdate' > `today'
		
		* count the missing dates
		count if `viol' == 1
		local diff_today = `r(N)'

		* update values of meta data variables
 		replace message = "Interview is after the current " + ///
 		    "system date (`today_f')."

		* append violations to the temporary data set
		saveappend using `tmp' if `viol' == 1, ///
			keep("`keeplist'")
	}

	* Last check only applies if an enumeration area is specified
	if "`enumarea'" != "" {
		bysort `enumarea': egen modedate = mode(`startdate')
		
		/* 5. check that, within the same enumeration area, 
		      interview dates are close to the same date. */
		cap assert !(`startdate' > modedate + `days' | `startdate' < modedate - `days')
		if _rc {
			replace `viol' = `startdate' > modedate + `days' | `startdate' < modedate - `days'
	
			* count the missing dates
			count if `viol' == 1
			local diff_enumarea = `r(N)'

			* update values of meta data variables
	 		replace message = "Interview is more than `days' days " + ///
	 		    "apart from others in the same enumeration area."

			* append violations to the temporary data set
			saveappend using `tmp' if `viol' == 1, ///
				keep("`keeplist'")
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
		sheet("10. dates") `sheetreplace' `sheetmodify' ///
		firstrow(variables) `nolabel'
		
	*export scto links as links
	if !missing("`sctodb'") & c(version) >= 14 {
		if !missing(scto_link[1]) {
			putexcel set "`saving'", sheet("10. dates") modify
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
	* return list
	return scalar missing = `missing'
	return scalar diff_end = `diff_end'
	return scalar diff_start = `diff_start'
	return scalar diff_today = `diff_today'
	return scalar diff_enumarea = `diff_enumarea'

	local message1 = return(missing)
	local message2 = return(diff_end)
	local message3 = return(diff_start)
	local message4 = return(diff_today)
	local message5 = return(diff_enumarea)

	* report QA stats
	di "  Number of interviews with missing start or end dates: `message1'"
	di "  Number of interviews with unequal start and end dates: `message2'"
	di "  Number of interviews with start date before survey start: `message3'"
	di "  Number of interviews with start date later than current date: `message4'"
	di "  Number of interviews with start dates more than `days' days apart within an area: `message5'"
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
