/*----------------------------------------*
 |file:    ipacheckdates.ado              | 
 |project: high frequency checks          |
 |author:  christopher boyer              |
 |         matthew bombyk                 |
 |         innovations for poverty action |
 |date:    2016-02-13                     |
 *----------------------------------------*/

 // this program checks survey date variables for consistency

capture program drop ipacheckdates
program ipacheckdates, rclass
	di ""
	di "HFC 10 => Checking that certain date variables fall within survey range..."
	qui {
	syntax varlist(min=2 max=2), SURVEYstart(integer) [ SAVing(string) Id(name) ENUMerator(name) ENUMArea(name) Days(integer 4) MODify Replace ]
	
	version 13.1

	/* ================
	    VALIDATE INPUT 
	   ================ */

	// set start and end date variables
	gettoken startdate rest : varlist
	gettoken enddate : rest
	
	// set export options
	local sheetmodify = cond("`modify'" == "", "", "sheetmodify")
	local sheetreplace = cond("`replace" == "", "", "sheetreplace")

	// set tempfile
	tempfile tmp nomiss
	
	*tempname memhold
	*postfile `memhold' `id' str32 `enumerator' `enumarea' `startdate' `enddate' message
	
	// sort data set
	if "`id'" != "" {
		sort `id'
	}
	
	/* =====================
	    PERFORM DATE CHECKS
	   ===================== */	
	   
	// Check that no dates are missing
	cap assert !(missing(`startdate') | missing(`enddate'))
	if _rc {
		preserve
		g message = "Interview has missing start or end date."
		keep if missing(`startdate') | missing(`enddate')
		keep `id' `enumerator' `enumarea' `startdate' `enddate' message 
		order `id' `enumerator' `enumarea' `startdate' `enddate' message 
		local missing = _N
		save `tmp'
		restore
	}

	preserve
	drop if missing(`startdate') | missing(`enddate')
	save `nomiss'
	restore

	// Check that interview start date and interview end date are the same.
	cap assert !(`startdate' == `enddate')
	if _rc {
		preserve
		use `nomiss', clear
		g message = "Interview has unequal start and end dates."
		keep if `startdate' != `enddate'
		keep `id' `enumerator' `enumarea' `startdate' `enddate' message 
		order `id' `enumerator' `enumarea' `startdate' `enddate' message 
		local diff_end = _N
		cap confirm file `tmp'
		if _rc == 0 {
			append using `tmp'
		}
		save `tmp', replace
		restore
	}

	// Check that interview date is not before the start of data collection. 
    cap assert !(`startdate' < `surveystart')
    if _rc {
    	preserve
		use `nomiss', clear
		local surveystart_f : di %tdnn/dd/YY `surveystart'
		g message = "Interview is before the start of data collection (`surveystart_f')."
		keep if `startdate' < `surveystart'
		keep `id' `enumerator' `enumarea' `startdate' `enddate' message 
		order `id' `enumerator' `enumarea' `startdate' `enddate' message 
		local diff_start = _N
		cap confirm file `tmp'
		if _rc == 0 {
			append using `tmp'
		} 
		save `tmp', replace
		restore
	}

	// Check that interview date is not after the system date.
	local today = date(c(current_date), "DMY")
	local today_f : di %tdnn/dd/YY `today'
	cap assert !(`startdate' > `today')
	if _rc {
		preserve
		use `nomiss', clear
		g message = "Interview is after the current system date (`today_f')."
		keep if `startdate' > `today'
		keep `id' `enumerator' `enumarea' `startdate' `enddate' message
		order `id' `enumerator' `enumarea' `startdate' `enddate' message 
		local diff_today = _N
		cap confirm file `tmp'
		if _rc == 0 {
			append using `tmp'
		}
		save `tmp', replace
		restore
	}

	// Last check only applies if an enumeration area is specified
	if "`enumarea" != "" {
		preserve
		use `nomiss', clear
		bysort `enumarea': egen modedate = mode(`startdate')
		
		// Check that within the same enumeration area, interview dates are close to the same date.
		cap assert !(`startdate' > modedate + `days')
		if _rc {
			g message = "Interview is more than `days' days apart from others in the same enumeration area."
			keep if `startdate' > modedate + `days'
			keep `id' `enumerator' `enumarea' `startdate' `enddate' message
			order `id' `enumerator' `enumarea' `startdate' `enddate' message 
			local diff_enumarea = _N
			cap confirm file `tmp'
			if _rc == 0 {
				append using `tmp'
			}
			save `tmp', replace
			restore
		}
	}

	/* =======================
	    RETURN, SAVE & REPORT
	   ======================= */	

	// return list
	return scalar missing       = cond("`missing'" == "", 0, `missing')
	return scalar diff_end      = cond("`diff_end'" == "", 0, `diff_end')
	return scalar diff_start    = cond("`diff_start'" == "", 0, `diff_start')
	return scalar diff_today    = cond("`diff_today'" == "", 0, `diff_today')
	return scalar diff_enumarea = cond("`diff_enumarea'" == "", 0, `diff_enumarea')

	// save errors to excel file
	if "`saving'" != "" {
		preserve
		use `tmp', clear
		g notes = ""
		g drop = ""
		g newvalue = ""
		export excel using `saving', firstrow(var) sheet("10. dates") `sheetmodify' `sheetreplace'
		restore
	}
	}

	local message1 = return(missing)
	local message2 = return(diff_end)
	local message3 = return(diff_start)
	local message4 = return(diff_today)
	local message5 = return(diff_end)

	// report QA stats
	di "  Number of interviews with missing start or end dates: `message1'"
	di "  Number of interviews with unequal start and end dates: `message2'"
	di "  Number of interviews with start date before survey start: `message3'"
	di "  Number of interviews with start date later than current date: `message4'"
	di "  Number of interviews with start dates more than `days' days apart within an area: `message5'"

end
