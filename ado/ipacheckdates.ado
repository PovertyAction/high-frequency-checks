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

	syntax varname, SURVEYstart(datelist) [SAVing(string) Id(string) ENUMerator(string) ENUMArea(string) Days(integer 4) MODify Replace]
	
	version 13.1

	/* ================
	    VALIDATE INPUT 
	   ================ */

	// check that two dates are specified
	local l : word count `varlist'
	cap assert `l' == 2
	if _rc {
		di as err "{cmd: ipacheckdates} takes two arguments."
		error 199
	}

	// set start and end date variables
	gettoken startdate rest : varlist
	gettoken enddate : rest
	
	// set export options
	local sheetmodify cond("`modify'" == "", "", "sheetmodify")
	local sheetreplace cond("`replace" == "", "", "sheetreplace")

	// set tempfile
	tempfile tmp

	sort `id'

	/* =====================
	    PERFORM DATE CHECKS
	   ===================== */	

	// Check that interview start date and interview end date are the same.
	cap assert !(`startdate' == `enddate')
	if _rc {
		preserve
		g msg = "Interview has unequal start and end dates."
		keep `id' `enum' `startdate' `enddate' msg if `startdate' != `enddate'
		save `tmp'
		local diff_end = _N
		restore
	}

	// Check that interview date is not before the start of data collection. 
    cap assert !(`startdate' < `surveystart')
    if _rc {
    	preserve
		g msg = "Interview is before the start of data collection: `surveystart'."
		keep `id' `enum' `startdate' `enddate' msg if `startdate' < `surveystart'
		append using `tmp' 
		save `tmp', replace
		local diff_start = _N
		restore
	}

	// Check that interview date is not after the system date.
	local today date(c(current_date), "DMY")
	cap assert !(`startdate' > `today')
	if _rc {
		preserve
		g msg = "Interview is after the current system date: `today'"
		keep `id' `enum' `startdate' `enddate' msg if `startdate' > `today'
		append using `tmp' 
		save `tmp', replace
		local diff_today = _N
		restore
	}

	// Last check only applies if an enumeration area is specified
	if "`enumarea" != "" {

		bysort `enumarea': egen mindate = min(startdate)
		by `enumarea': egen maxdate = max(startdate)

		// Check that within the same enumeration area, interview dates are close to the same date.
		cap assert !(maxdate > mindate + `days')
		if _rc {
			preserve
			g msg = "Interview is more than `days' days apart from others in the same enumeration area"
			sort `enumarea' `startdate' `id'
			keep `id' `enum' `enumarea' `startdate' `enddate' if maxdate > mindate + `days'
			append using `tmp'
			save `tmp', replace
			local diff_enumarea = _N
			restore
		}
		drop mindate maxdate
	}

	/* =======================
	    RETURN, SAVE & REPORT
	   ======================= */	

	// return list
	return scalar diff_end      = cond("`diff_end'" == "", 0, `diff_end')
	return scalar diff_start    = cond("`diff_start'" == "", 0, `diff_start')
	return scalar diff_today    = cond("`diff_today'" == "", 0, `diff_today')
	return scalar diff_enumarea = cond("`diff_enumarea'" == "", 0, `diff_enumarea')

	// save errors to excel file
	if "`saving'" != "" {
		preserve
		use `tmp', clear
		export excel using `saving', firstrow(var) sheet("10. dates") `sheetmodify' `sheetreplace'
		restore
	}
	}

	// report QA stats
	di "  Number of interviews with unequal start and end dates: return(diff_end)"
	di "  Number of interviews with start date before survey start: return(diff_start)"
	di "  Number of interviews with start date later than current date: return(diff_today)"
	di "  Number of interviews with start dates more than `days' days apart within an area: return(diff_end)"

end
