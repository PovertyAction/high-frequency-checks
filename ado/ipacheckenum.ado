*! version 2.1.2 Isabel Onate & Rosemarie Sandino 15Aug2018

program ipacheckenum
	/* This command constructs the enumerator dashboard, a
	   collection of summary indicators of enumerator performance
	   including: 
	      * Number of interviews
	      * Rates of don't know/refusal
	      * Rates of missing response
		  * Rates of "other" response
	      * Duration of interview */
	version 15
	
	#d ;
	syntax varname using/ ,
	    dkrfvars(varlist) 
	    missvars(varlist) 
		othervars(varlist)
	    subdate(varname)
		[durvars(varlist) duration(varname) exclude(varlist) foteam(varlist) days(integer 7)]
		statvars(varlist) [mean] [sd] [min] [max]
		[replace modify]
		[nolab];
	#d cr
	qui {
	
	// capture enumerator variable
	local enum `varlist'
	
	// capture variable list in memory
	unab allvars : _all
	local loopvars : list allvars - exclude
	local loopvars : list loopvars - durvars
	
	// define temp file
	tempfile summary_sheet missing_sheet dontknow_sheet refusal_sheet other_sheet duration_sheet

	#d ;
	tempvar interviews 
	        missing
	        dontknow
	        refusal
			other
	        recent_interviews
	        recent_missing
	        recent_dontknow
	        recent_refusal
	        recent_duration
			recent_other
	        row_nonmiss 
	        row_miss 
	        row_dk 
	        row_rf
			row_oth 
	        col_sub_nonmiss
	        col_sub_miss
	        col_sub_dk
	        col_sub_rf
			col_sub_oth 
	        col_sub_dur
	        col_sub_dkrate
	        col_sub_rfrate
	        col_sub_missrate
			col_sub_othrate;
	#d cr

	// set count variables
	g `interviews' = 1
	g `row_nonmiss' = 0
	g `row_miss' = 0
	g `row_dk' = 0
	g `row_rf' = 0
	g `row_oth' = 0
	
	// initialize duration variable, create local have_duration to signal existence of duration variable
	if "`duration'" == "" {
		cap confirm variable duration
		if _rc == 0 {
			tempvar duration
			g `duration' = duration
			loc have_duration = 1
		}
		else {
			cap confirm variable endtime starttime
			if _rc == 0 {
				tempvar duration
				g `duration' = (endtime - starttime)/60000
				loc have_duration = 1
			}
			else {
				loc have_duration = 0
			}
		}
	}
	else {
		loc have_duration = 1
	}
	if `have_duration' {
		replace `duration' = . if `duration' < 0
	}

	/* loop through all variables, count number of interviews;
	   nonmissing and missing responses; don't knows; refusals and
	   durations by enumerator */
	foreach var of varlist `loopvars' {

		cap confirm numeric variable `var' 
		// string variables
		if _rc  {
			scalar miss = ""
			scalar dk = "don't know"
			scalar rf = "refusal"
			scalar oth = "other" 
		}
		// numeric variables
		else {
			scalar miss = .
			scalar dk = .d
			scalar rf = .r
			scalar oth = .o 
		}
		count if `var' != miss
		if r(N) > 0 {
		// count the number of nonmissing, don't know, or refusal by obs
		replace `row_nonmiss' = `row_nonmiss' + cond(`var' != miss, 1, 0)
		replace `row_miss' = `row_miss' + cond(`var' == miss, 1, 0)
		replace `row_dk' = `row_dk' + cond(`var' == dk, 1, 0)
		replace `row_rf' = `row_rf' + cond(`var' == rf, 1, 0)
		replace `row_oth' = `row_oth' + cond(`var' == oth, 1, 0)

		// count the number of nonmissing, don't know, or refusal per variable
		quietly count if `var' != miss
		local col_nonmiss = r(N)
		quietly count if `var' == miss
		local col_miss = r(N)
		quietly count if `var' == dk
		local col_dk = r(N)
		quietly count if `var' == rf
		local col_rf = r(N)
		quietly count if `var' == oth 
		local col_oth = r(N) 
		
		// variable subtotals by enumerator
		bysort `enum': egen `col_sub_nonmiss' = total(`var' != miss)
		bysort `enum': egen `col_sub_miss' = total(`var' == miss)
		bysort `enum': egen `col_sub_dk' = total(`var' == dk)
		bysort `enum': egen `col_sub_rf' = total(`var' == rf)
		bysort `enum': egen `col_sub_oth' = total(`var' == oth)

		// don't know and refusal rates by enumerator
		g `col_sub_dkrate' = `col_sub_dk' / `col_sub_nonmiss'
		g `col_sub_rfrate' = `col_sub_rf' / `col_sub_nonmiss'
		g `col_sub_missrate' = `col_sub_miss' / (`col_sub_nonmiss' + `col_sub_miss')
		g `col_sub_othrate' = `col_sub_oth' / `col_sub_nonmiss' 
		
		
		/* if variable is in the list of important don't know 
		   or refusal variables update respective sub sheets */
		local inlist : list var in dkrfvars
		if `inlist' {
			_updatesheet `col_sub_dkrate' using `dontknow_sheet', by(`enum') rename(`var')
			loc dk`var'low = `r(low)' 
			loc dk`var'hi = `r(high)'
			_updatesheet `col_sub_rfrate' using `refusal_sheet', by(`enum') rename(`var')
			loc rf`var'low = `r(low)' 
			loc rf`var'hi = `r(high)'

		}

		/* if variable is in the list of important missing
		   variables update respective sub sheets */
		local inlist : list var in missvars
		if `inlist' {
			_updatesheet `col_sub_missrate' using `missing_sheet', by(`enum') rename(`var')
			local mi`var'low = `r(low)' 
			local mi`var'hi = `r(high)'

		}
		
		/* if variable is in the list of important "other"
		   variables update respective sub sheets */
		local inlist : list var in othervars
		if `inlist' {
			_updatesheet `col_sub_othrate' using `other_sheet', by(`enum') rename(`var')
			loc oth`var'low = `r(low)' 
			loc oth`var'hi = `r(high)'
		}
		
		// drop col vars
	    drop `col_sub_nonmiss'  ///     
	         `col_sub_miss'     ///  
	         `col_sub_dk'       ///
	         `col_sub_rf'       ///
			 `col_sub_oth'       ///
	         `col_sub_dkrate'   ///    
	         `col_sub_rfrate'   ///    
	         `col_sub_missrate' ///
			 `col_sub_othrate'
		}
	}
	
	/* loop through the duration variables, calculate the mean
	   and update the duration sheet */
	if "`durvars'" != "" {
		foreach var of varlist `durvars' {
			replace `var' = 0 if `var' < 0 & !mi(`var')
			bysort `enum': egen `col_sub_dur' = mean(`var')
			_updatesheet `col_sub_dur' using `duration_sheet', by(`enum') rename(`var')
			loc dur`var'low = `r(low)' //Rosemarie
			loc dur`var'hi = `r(high)'
			drop `col_sub_dur'
		}
	}
	
	
	// create summary sheet
	preserve

	// restrict to specified number of days
	local today = date(c(current_date), "DMY")
	ds `subdate', has(format %td*)
	// tests if the date is already in td format
	if "`r(varlist)'" != "" {
		keep if `subdate' > `today' - `days'
	}
	// if not already in td format, uses dofc for date
	else {
		keep if dofc(`subdate') > `today' - `days'
	}
	
	// create collapse command for calculating subtotals by enumerator
	if !`have_duration' {
		loc collapse_command "collapse (sum) `interviews' `row_nonmiss' `row_miss' `row_dk' `row_rf' `row_oth', by(`enum') cw" 
	}
	else {
		loc collapse_command "collapse (sum) `interviews' `row_nonmiss' `row_miss' `row_dk' `row_rf' `row_oth' (mean) `duration', by(`enum') cw" 
	}
	

	// caluculate subtotals by enumerator
	if `=_N' > 0 {
	   `collapse_command'
	   isid `enum'
		
	    // calculate rates
	    g `recent_interviews' = `interviews'
		if `have_duration' {
			g `recent_duration' = `duration'
		}
		else {
			g `recent_duration' = .
		}
	    g `recent_missing' = `row_miss' / (`row_miss' + `row_nonmiss')
	    g `recent_dontknow' = `row_dk' / `row_nonmiss'
	    g `recent_refusal' = `row_rf' / `row_nonmiss'
		g `recent_other' = `row_oth' / `row_nonmiss' 

	    // drop row totals
	   drop `interviews' `row_miss' `row_nonmiss' `row_dk' `row_rf' `row_oth' 
	}
	else {
		keep `enum'

	    // calculate rates
	    g `recent_interviews' = 0
		if `have_duration' {
			g `recent_duration' = 0
		}
		else {
			g `recent_duration' = ""
		}
	    g `recent_missing' = 0
	    g `recent_dontknow' = 0
	    g `recent_refusal' = 0
		g `recent_other' = 0
	}
	
	loc cols 
	
	save `summary_sheet', replace
	restore

	preserve 
	
	// caluculate subtotals by enumerator
	`collapse_command'

	// calculate rates
	g `missing' = `row_miss' / (`row_miss' + `row_nonmiss')
	g `dontknow' = `row_dk' / `row_nonmiss'
	g `refusal' = `row_rf' / `row_nonmiss'
	g `other' = `row_oth' / `row_nonmiss'

	// drop and save
	drop `row_miss' `row_nonmiss' `row_dk' `row_rf' `row_oth'

	// merge with overall totals
	merge 1:1 `enum' using `summary_sheet', nogenerate

	// order and save 
	 order 		`enum'              ///
				`recent_interviews' ///          
				`interviews'        ///   
				`recent_missing'    ///       
				`missing'           ///
				`recent_dontknow'   ///       
				`dontknow'          ///
				`recent_refusal'    ///      
				`refusal'           ///
				`recent_other'	///
				`other'			  ///
				`recent_duration'   ///     
				`duration'     
			  
	loc vars_order		recent_interviews interviews recent_missing missing recent_dontknow'   ///       
						dontknow recent_refusal refusal recent_other other recent_duration duration

    ds, has(type numeric)
	format `r(varlist)' %9.2f
	save `summary_sheet', replace

	// Calculate lower an upper 10 percent
	foreach var of local vars_order {
		cap confirm var `var' 
		if _rc == 0 {
			qui sum ``var'', detail
			loc `var'_low = `r(p10)'
			loc `var'_hi = `r(p90)'
		}
	}
	    
	
	restore
	
	// drop count variables
	drop `interviews' `row_miss' `row_nonmiss' `row_dk' `row_rf' `row_oth'

	preserve

	// set export locals
	local i = 0
	local sheet_names "summary missing dontknow refusal other duration"
	
	/* loop through tempfiles and export them as sheets in the
	   excel workbook; set the filename of the workbook equal
	   to the string in `using' */
	foreach sheet in `summary_sheet' `missing_sheet' `dontknow_sheet' `refusal_sheet' `other_sheet' `duration_sheet' {

		local i = `i' + 1
		local name : word `i' of `sheet_names'
		
		// confirm the tempfile exist before writing
		cap confirm file `sheet'	
		if !_rc {
			use `sheet', clear
			if _N > 0 {
				if "`name'" == "summary" {
					// summary sheet conditions
					export excel using "`using'", sheet("`name'") replace cell(A4) missing("0")
					mata: format_summary("`using'", `=_N') //Rosemarie
				} 
				else {
					// sub sheet conditions
					export excel using "`using'", sheet("`name'") firstrow(var) sheetmodify cell(A1) missing("0")
					ds // Rosemarie
					loc colcount `:word count `r(varlist)''
					mata: format_sheets("`using'", "`name'", `colcount', `=_N')
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

