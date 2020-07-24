*! version 3.0.0 Innovations for Poverty Action 22oct2018

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
    version 14.1

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
	save "`org'"

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
	g scto_link = ""
	g message = ""
	
	* Create scto_link variable
	if !missing("`sctodb'") {
		local bad_chars `"":" "%" " " "?" "&" "=" "{" "}" "[" "]""'
		local new_chars `""%3A" "%25" "%20" "%3F" "%26" "%3D" "%7B" "%7D" "%5B" "%5D""'
		local url "https://`sctodb'.surveycto.com/view/submission.html?uuid="
		local url_redirect "https://`sctodb'.surveycto.com/officelink.html?url="

		foreach bad_char in `bad_chars' {
			gettoken new_char new_chars : new_chars
			replace scto_link = subinstr(key, "`bad_char'", "`new_char'", .)
		}
		replace scto_link = `"HYPERLINK("`url_redirect'`url'"' + scto_link + `"", "View Submission")"'
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
		saveappend using "`tmp'" if `viol' == 1, ///
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
		saveappend using "`tmp'" if `viol' == 1, ///
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
		saveappend using "`tmp'" if `viol' == 1, ///
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
		saveappend using "`tmp' "if `viol' == 1, ///
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
			saveappend using "`tmp'" if `viol' == 1, ///
				keep("`keeplist'")
		}
	}	

	* import compiled list of violations
	use "`tmp'", clear

	* if there are no violations
	if `=_N' == 0 {
		set obs 1
	} 

	order `keeplist'
    gsort -`submitted', gen(order)

	format `submitted' %tc
	tempvar bot bottom lines

	bysort `enumerator' (message) : gen `lines' = _n
	egen `bot' = max(`lines'), by(`enumerator')
	gen `bottom' = cond(`bot' == `lines', 1, 0)
	
	* export compiled list to excel
	export excel `keeplist' using "`saving'" ,  ///
		sheet("10. dates") `sheetreplace' `sheetmodify' ///
		firstrow(variables) `nolabel'
	unab keeplist : `keeplist'	
	mata: basic_formatting("`saving'", "10. dates", tokens("`keeplist'"), tokens("`colorcols'"), `=_N')	
	
	*export scto links as links
	if !missing("`sctodb'") {
		unab allvars : _all
		local pos : list posof "scto_link" in allvars
		mata: add_scto_link("`saving'", "10. dates", "scto_link", `pos')
	}
	
	}	
	* revert to original
	use "`org'", clear

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

	append using "`using'"

	if "`sort'" != "" {
		sort `sort'
	}

	drop `touse'
	save "`using'", replace

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

mata: 
mata clear
void basic_formatting(string scalar filename, string scalar sheet, string matrix vars, string matrix colors, real scalar nrow) 
{

class xl scalar b
real scalar i, ncol
real vector column_widths, varname_widths, bottomrows
real matrix bottom


b = xl()
ncol = length(vars)

b.load_book(filename)
b.set_sheet(sheet)
b.set_mode("open")

b.set_bottom_border(1, (1, ncol), "thick")
b.set_font_bold(1, (1, ncol), "on")
b.set_horizontal_align(1, (1, ncol), "center")

if (length(colors) > 1 & nrow > 2) {	
for (j=1; j<=length(colors); j++) {
	b.set_font((3, nrow), strtoreal(colors[j]), "Calibri", 11, "lightgray")
	}
}

// Add separating bottom lines	
bottom = st_data(., st_local("bottom"))
bottomrows = selectindex(bottom :== 1)
column_widths = colmax(strlen(st_sdata(., vars)))	
varname_widths = strlen(vars)

for (i=1; i<=rows(bottomrows); i++) {
	b.set_bottom_border(bottomrows[i]+1, (1, ncol), "thick")
}

column_widths = colmax(strlen(st_sdata(., vars)))	
varname_widths = strlen(vars)
	
for (i=1; i<=cols(column_widths); i++) {
	if	(column_widths[i] < varname_widths[i]) {
		column_widths[i] = varname_widths[i]
	}

	b.set_column_width(i, i, column_widths[i] + 2)
	if (vars[i] == "startdate" | vars[i] == "enddate") b.set_column_width(i, i, 15)
	}



if (rows(bottomrows) > 1) {
for (i=1; i<=rows(bottomrows); i++) {
	b.set_bottom_border(bottomrows[i]+1, (1, ncol), "thin")
	if (length(colors) > 1) {
		for (k=1; k<=length(colors); k++) {
			b.set_font(bottomrows[i]+2, strtoreal(colors[k]), "Calibri", 11, "black")
		}
	}
}
}
else b.set_bottom_border(2, (1, ncol), "thin")
b.close_book()
}

void add_scto_link(string scalar filename, string scalar sheetname, string scalar variable, real scalar col)
{
	class xl scalar b
	string matrix links
	real scalar N

	b = xl()
	links = st_sdata(., variable)
	N = length(links) + 1

	b.load_book(filename)
	b.set_sheet(sheetname)
	b.set_mode("open")
	b.put_formula(2, col, links)
	b.set_font((2, N), col, "Calibri", 11, "5 99 193")
	b.set_font_underline((2, N), col, "on")
	b.set_column_width(col, col, 17)
	
	b.close_book()
	}

end

