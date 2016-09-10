*! version 1.0.0 Christopher Boyer 04may2016

program ipacheckenum
	/* This command constructs the enumerator dashboard, a
	   collection of summary indicators of enumerator performance
	   including: 
	      * Number of interviews
	      * Rates of don't know/refusal
	      * Rates of missing response
	      * Duration of interview */
	version 13 
	
	#d ;
	syntax varname using/ ,
	    dkrfvars(varlist) 
	    missvars(varlist) 
	    durvars(varlist) 
	    subdate(varname) 
		[exclude(varlist) foteam(varlist) days(integer 7)]
		[replace modify];
	#d cr
	qui {
	
	// capture enumerator variable
	local enum `varlist'
	
	// capture variable list in memory
	unab allvars : _all
	local loopvars : list allvars - exclude
	local loopvars : list loopvars - durvars
	
	// define temp file
	tempfile summary missing dontknow refusal duration

	// set count variables
	g interviews = 1
	g row_nonmiss = 0
	g row_miss = 0
	g row_dk = 0
	g row_rf = 0
	
	// initialize duration variable
	g duration = (endtime - starttime)/60000
	replace duration = . if duration < 0

	/* loop through all variables, count number of interviews;
	   nonmissing and missing responses; don't knows; refusals and
	   durations by enumerator */
	foreach var of varlist `loopvars' {

		cap confirm numeric variable `var' 
		// numeric variables
		if _rc == 0 {
			scalar miss = .
			scalar dk = .d
			scalar rf = .r
		}
		// string variables
		else {
			scalar miss = ""
			scalar dk = "don't know"
			scalar rf = "refusal"
		}
		count if `var' != miss
		if r(N) > 0 {
		// count the number of nonmissing, don't know, or refusal by obs
		replace row_nonmiss = row_nonmiss + cond(`var' != miss, 1, 0)
		replace row_miss = row_miss + cond(`var' == miss, 1, 0)
		replace row_dk = row_dk + cond(`var' == dk, 1, 0)
		replace row_rf = row_rf + cond(`var' == rf, 1, 0)

		// count the number of nonmissing, don't know, or refusal per variable
		quietly count if `var' != miss
		local col_nonmiss = r(N)
		quietly count if `var' == miss
		local col_miss = r(N)
		quietly count if `var' == dk
		local col_dk = r(N)
		quietly count if `var' == rf
		local col_rf = r(N)
		
		// variable subtotals by enumerator
		bysort `enum': egen col_sub_nonmiss = total(`var' != miss)
		bysort `enum': egen col_sub_miss = total(`var' == miss)
		bysort `enum': egen col_sub_dk = total(`var' == dk)
		bysort `enum': egen col_sub_rf = total(`var' == rf)

		// don't know and refusal rates by enumerator
		g col_sub_dkrate = col_sub_dk / col_sub_nonmiss
		g col_sub_rfrate = col_sub_rf / col_sub_nonmiss
		g col_sub_missrate = col_sub_miss / (col_sub_nonmiss + col_sub_miss)
		
		/* if variable is in the list of important don't know 
		   or refusal variables update respective sub sheets */
		local inlist : list var in dkrfvars
		if `inlist' {
			_updatesheet col_sub_dkrate using `dontknow', by(`enum') rename(`var')
			_updatesheet col_sub_rfrate using `refusal', by(`enum') rename(`var')
		}

		/* if variable is in the list of important missing
		   variables update respective sub sheets */
		local inlist : list var in missvars
		if `inlist' {
			_updatesheet col_sub_missrate using `missing', by(`enum') rename(`var')
		}
		
		// drop col vars
		drop col_*
		}
	}
	
	/* loop through the duration variables, calculate the mean
	   and update the duration sheet */
	foreach var of varlist `durvars' {
		replace `var' = 0 if `var' < 0 & !mi(`var')
		bysort `enum': egen col_sub_dur = mean(`var')
		_updatesheet col_sub_dur using `duration', by(`enum') rename(`var')
		drop col_sub_dur
	}
	
	// create summary sheet
	preserve 
	
	// caluculate subtotals by enumerator
	collapse (sum) interviews row_nonmiss row_miss row_dk row_rf (mean) duration, by(`enum') cw

	// calculate rates
	g missing = row_miss / (row_miss + row_nonmiss)
	g dontknow = row_dk / row_nonmiss
	g refusal = row_rf / row_nonmiss

	// drop and save
	drop row_*
	save `summary', replace

	restore

	preserve

	// restrict to specified number of days
	local today = date(c(current_date), "DMY")
	keep if dofc(`subdate') > `today' - `days' 

	// caluculate subtotals by enumerator
	if `=_N' > 0 {
		collapse ///
		   (sum) interviews row_nonmiss row_miss row_dk row_rf ///
		   (mean) duration, by(`enum') cw

		// calculate rates
	    g interviews_`days'days = interviews
	    g duration_`days'days = duration
	    g missing_`days'days = row_miss / (row_miss + row_nonmiss)
	    g dontknow_`days'days = row_dk / row_nonmiss
	    g refusal_`days'days = row_rf / row_nonmiss

	    // drop row totals
		drop row_*
	}
	else {
		keep `enum'

		// calculate rates
	    g interviews_`days'days = 0
	    g duration_`days'days = 0
	    g missing_`days'days = 0
	    g dontknow_`days'days = 0
	    g refusal_`days'days = 0
	}



	// merge with overall totals
	merge 1:1 `enum' using `summary', nogenerate

	// order and save 
	order `enum' interviews* missing* dontknow* refusal* duration*
	format interviews* missing* dontknow* refusal* duration* %9.2f
	save `summary', replace

	restore
	
	// drop count variables
	drop interviews row_* duration

	preserve

	// set export locals
	local i = 0
	local sheet_names "summary missing dontknow refusal duration"
	
	/* loop through tempfiles and export them as sheets in the
	   excel workbook; set the filename of the workbook equal
	   to the string in `using' */
	foreach sheet in `summary' `missing' `dontknow' `refusal' `duration' {

		local i = `i' + 1
		local name : word `i' of `sheet_names'
		
		// confirm the tempfile exist before writing
		cap confirm file `sheet'	
		if !_rc {
			use `sheet', clear
			if _N > 0 {
				if "`name'" == "summary" {
					// summary sheet conditions
					export excel using "`using'", sheet("`name'") sheetmodify cell(A4) missing("0")
				} 
				else {
					// sub sheet conditions
					export excel using "`using'", sheet("`name'") firstrow(var) sheetmodify cell(A1) missing("0")
				}
			}
		}
	}

	restore 
	
	}
end

capture program drop _updatesheet
program _updatesheet
	/* this subroutine updates the sub sheet temp files
	   that capture per variable rates and stats */
	qui {
	syntax varname using/ , by(varname) rename(varname)
	preserve

	tempfile tmp
	
	format `varlist' %9.3f
	collapse (max) `varlist', by(`by')
	ren `varlist' `rename'
	
	save `tmp', replace 

	cap confirm file "`using'"
	if _rc {
		save "`using'", replace
	}
	else {
		use "`using'", clear
		merge 1:1 `by' using `tmp', nogenerate
		save "`using'", replace
	}
	restore
	}
end

