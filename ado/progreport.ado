*! version 2.0.0 Rosemarie Sandino 24aug2018
*! version 1.0.1 Rosemarie Sandino 17jul2018

program progreport
	syntax, 	/// 
		Master(string) 			/// sample_dta
		Survey(string) 			/// questionnaire data
		ID(string) 				/// id variable from questionnaire data
		SORTby(string) 			///	sorting variable
		KEEPMaster(string)		/// sample variables
		[KEEPSurvey(string)]	/// keep from survey data
		[MID(string)] 			/// id variable from master data
		[FILEname(string)]		/// default is "Progress Report"
		[Target(real 1)]		/// target rate
		[DTA(string)] 			///	if you want an output file of those not interviewed yet
		[VARiable]				/// default is to use variable labels
		[NOLabel]				/// default is to use value labels
		[clear]					///	to show merged dataset; if not included, console remains the same
		[summary]				// if used, does not include individual observations

	version 14.1

/* ------------------------------ Load Sample ------------------------------- */
qui {
if "`clear'" == "" {
	tempfile orig
	save "`orig'", emptyok
}

* load the sample list
use "`master'", clear

if !mi("`mid'") {
	ren `mid' `id'
}

if "`filename'" == "" {
	local filename "Progress Report"
}	

if regexm("`filename'", ".xls") {
	local filename = substr("`filename'", 1, strpos("`filename'", ".xl")-1) 
}
tempvar status
/* -------------------------- Merge Questionnaire --------------------------- */

	merge 1:1 `id' using "`survey'", ///
		keepusing(submissiondate `keepsurvey')

	ren submissiondate questionnaire_date
	replace questionnaire_date = dofc(questionnaire_date)
	format questionnaire_date %td	

	lab def _merge 1 "Not submitted" 2 "Only in Questionnaire Data" 3 "Submitted", modify
	decode _merge, gen(`status')

	local allvars `id' `keepmaster' `keepsurvey' questionnaire_date `status'
	lab var `status' "Status"
	lab var questionnaire_date "Date Submitted"
	order `allvars' 
	gsort _merge -questionnaire_date `id' `keepmaster'
	
	/* -------------------------- Create Summary Sheet -------------------------- */

	preserve
		gen completed = 1 if _merge == 3
		gen total = 1 if _merge != 2
		collapse (sum) completed total (min) first_submitted=questionnaire_date (max) last_submitted=questionnaire_date, by(`sortby')
		gen pct_completed = completed/total, after(total)
		lab var completed "Submitted"
		lab var total "Total"
		lab var pct_completed "% Submitted"
		
		g first_submission = string(first_submitted, "%td")
		g last_submission = string(last_submitted, "%td")
		lab var first_submission "First Submission"
		lab var last_submission "Last Submission"
		sum first_submitted
		loc first_tot = string(`r(min)', "%td")
		sum last_submitted 
		loc last_tot = string(`r(max)', "%td")
		
		sort pct_completed `sortby'
		local all `sortby' completed total pct_completed first_submission last_submission

		export excel `all' using "`filename'.xlsx", ///
			firstrow(varl) sheet("Summary") cell(A2) sheetmodify
		local d $S_DATE
		qui count
		local N = `r(N)' + 3
		*tostring `all', replace force
		summ completed
		loc comp `r(sum)'
		summ total
		loc tot `r(sum)'

		mata : create_summary_sheet("`filename'", tokens("`all'"), `N')
		noi di ""
		noi di "{ul:Created summary sheet by `sortby': interviewed `comp' out of `tot' in total}"
		noi di ""
	restore

	/* --------------------------- Create Sheets ---------------------------- */

if "`summary'"	== "" {
	
	if mi("`variable'") {
		local variable = "varl"
	}

	*If want value labels, encode variable so those are used as colwidth
	if "`nolabel'" == "" {
		ds `allvars', has(vallab)
		foreach var in `r(varlist)' {
			decode `var', gen(`var'_new)
			drop `var'
			ren `var'_new `var'
		}
	}

	local check `:type `sortby''
	if substr("`check'", 1, 3) != "str" {
		loc labels : val l `sortby'
		if mi("`labels'") {
			tostring `sortby', replace
		}
		else {

			loc upper = strproper("`sortby'")
			decode `sortby', gen(`upper')
			loc sortby `upper'

		}
	}

	levelsof `sortby', local(byvalues)

	preserve
	if "`variable'" == "variable" {
		ds `status', not
		foreach var in `r(varlist)' {
			lab var `var' "`var'"
		}
	}

	foreach sortval in `byvalues' {
		export excel `allvars' if `sortby' == "`sortval'" using "`filename'.xlsx", ///
			firstrow(varl) sheet("`sortval'") sheetreplace `nolabel'
			
		qui count if `sortby' == "`sortval'"
		local N = `r(N)' + 1
		
		mata : create_progress_report("`filename'.xlsx", "`sortval'", tokens("`allvars'"), `N')
		local den = `N' - 1
		qui count if `sortby' == "`sortval'" & _merge == 3
		local num = `r(N)'
		noi dis "Created sheet for `sortval': interviewed `num' out of `den'"
	}
	restore
}
	if !mi("`dta'") {	
		preserve
			keep if _merge == 1
			keep `sortby' `id' `keepmaster'
			order `sortby' `id' `keepmaster'
			save "`dta'", replace
			noi dis "Saved remaining respondents to `dta'."
		restore

	}
	if "`clear'" == "" {
		use "`orig'", clear
	}
	
}
end

mata: 
mata clear
void create_summary_sheet(string scalar filename, string matrix allvars, real scalar N) 
{
	class xl scalar b
	b = xl()
	string scalar date
	real scalar target, per
	real vector varname_widths
	b.load_book(filename)
	b.set_sheet("Summary")
	b.set_mode("open")
	date = st_local("d")
	
	b.put_string(N, 1, "Total")
	b.put_formula(N, 2, "SUM(B3:B" + strofreal(N-1) + ")")
	b.put_formula(N, 3, "SUM(C3:C" + strofreal(N-1) + ")")
	b.put_formula(N, 4, "B" + strofreal(N) + "/C" + strofreal(N))
	b.set_number_format(N, 4, "percent")
	b.put_string(N, 5, st_local("first_tot"))
	b.put_string(N, 6, st_local("last_tot"))
	b.set_number_format(N, (5,6), "date")
	b.set_top_border(1, (1,	6), "thick")
	b.set_bottom_border((1,2), (1,6), "thick")
	b.set_bottom_border(N-1, (1,6), "thick")
	b.set_left_border((1, N), 1, "thick")
	b.set_left_border((1, N), 7, "thick")
	b.set_font_bold((1,2), (1,6), "on")
	b.set_horizontal_align((1, N),(1,6), "center")	
	b.put_string(1, 1, "Summary by " + st_local("sortby") + ": " + st_local("d"))
	b.set_horizontal_align(1, (1,6), "merge")
		
	b.set_number_format((3,N), 4, "percent")
	b.set_font_bold(N, (1,6), "on")
	b.set_bottom_border(N, (1,6), "thick")
	
	stat = st_data(., "pct_completed")
	target = strtoreal(st_local("target"))-0.005
	for (i=1; i<=length(stat); i++) {
		
		if (stat[i] == 0) {
			b.set_fill_pattern(i + 2, (4), "solid", "red")
		}
		else if (stat[i] >= target) {
			b.set_fill_pattern(i + 2, (4), "solid", "green")
		}
		else {
			b.set_fill_pattern(i + 2, (4), "solid", "yellow")
		}
		
	}
	
	per = strtoreal(st_local("comp"))/strtoreal(st_local("tot"))
	
	if (per == 0) {
		b.set_fill_pattern(N, 4, "solid", "red")
	}
	else if (per >= target) {
		b.set_fill_pattern(N, 4, "solid", "green")
	}
	else {
		b.set_fill_pattern(N, 4, "solid", "yellow")
	}
	
	column_widths = colmax(strlen(st_sdata(., allvars)))	
	varname_widths = strlen(allvars)
	
	for (i=1; i<=cols(column_widths); i++) {
		if	(column_widths[i] < varname_widths[i]) {
			column_widths[i] = varname_widths[i]
		}
		b.set_column_width(i, i, column_widths[i] + 2)
	}
	b.close_book()
}
void create_progress_report(string scalar filename, string scalar sortval, string matrix allvars, real scalar N) 
{
	class xl scalar b
	real scalar i
	real vector rows, status
	real vector column_widths, varname_widths
	string matrix sortvar
	
	b = xl()
	
	b.load_book(filename)
	b.set_sheet(sortval)
	b.set_mode("open")
	varname_widths = strlen(allvars)
	column_widths = colmax(strlen(st_sdata(., allvars)))
	for (i=1; i<=cols(column_widths); i++) {
		if (st_local("variable") == "varl") {
			varlabel = st_varlabel(allvars[i])
			if (varname_widths[i] < strlen(varlabel)) {
				varname_widths[i] = strlen(varlabel)
			}
		}
		if	(column_widths[i] < (varname_widths[i])) {
			column_widths[i] = (varname_widths[i])
		}
		b.set_column_width(i, i, column_widths[i]+2)
	}
	
	b.set_right_border((1,N), length(varname_widths)-2, "thick")
	b.set_right_border((1,N), length(varname_widths), "thick")
	b.set_left_border((1,N), 1, "thick")
	b.set_top_border(1, (1,length(varname_widths)), "thick")
	b.set_bottom_border(1, (1,length(varname_widths)), "thick")
	b.set_bottom_border(N, (1,length(varname_widths)), "thick")
	b.set_font_bold((1), (1,length(varname_widths)), "on")
	b.set_horizontal_align((1,N), (1,length(varname_widths)), "center")
	
	sortvar = st_sdata(., st_local("sortby"))
	rows = selectindex(sortvar :== sortval)
	status = st_data(rows, "_merge")
	for (i=1; i<=length(rows); i++) {
		if (status[i] == 1) {
			b.set_fill_pattern(i + 1, (length(varname_widths)), "solid", "red")
		}
		else if (status[i] == 2) {
			b.set_fill_pattern(i + 1, (length(varname_widths)), "solid", "yellow")
		}
		else if (status[i] == 3) {
			b.set_fill_pattern(i + 1, (length(varname_widths)), "solid", "green")
		}
	}
	b.close_book()
}
end
