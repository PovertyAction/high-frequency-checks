*! version 3.0.0 Innovations for Poverty Action 22oct2018

program progreport
	syntax, 	/// 
		Master(string) 			/// sample_dta
		Survey(string) 			/// questionnaire data
		ID(string) 				/// id variable from questionnaire data
		SORTby(string) 			///	sorting variable
		KEEPMaster(string)		/// sample variables
		[KEEPSurvey(string)]	/// keep from survey data
		[MID(string)] 			/// id variable from master data
		[TRACKing(string)]		/// tracking sheet ***
		[TVar(string)]			/// tracking variable(s) ***
		[FILEname(string)]		/// default is "Progress Report"
		[Target(real 1)]		/// target rate
		[DTA(string)] 			///	if you want an output file of those not interviewed yet
		[VARiable]				/// default is to use variable labels
		[NOLabel]				/// default is to use value labels
		[clear]					///	to show merged dataset; if not included, console remains the same
		[summary]				/// if used, does not include individual observations
		[WORKbooks]				/// separates into workbooks instead of worksheets in one workbook
		[surveyok]				// allows people who are in survey data only
		
		version 14.1

qui {
/* ------------------------------ Load Sample ------------------------------- */

if "`clear'" == "" {
	tempfile orig
	save "`orig'", emptyok
}

if (!mi("`tracking'") & mi("`tvar'")) | (mi("`tracking'") & !mi("`tvar'")) {
	dis as error "-tracking- option and -tvar- option must be used together."
	exit 198
}
	
* prepare tracking data
if !mi("`tracking'") {
	use "`tracking'", clear
	
	cap confirm double variable submissiondate
	if _rc {
		dis as error "There is no submissiondate variable in `tracking'. This commands requires a double variable named -submissiondate-."
		exit 198
	}
	gsort -submissiondate
	local val : value label `tvar'
	local misslab : variable label `tvar'
	collapse (firstnm) track_date = submissiondate `tvar' (count) pr_attempts = `tvar', by(`id')  
	keep track_date `id' pr_attempts `tvar'
	lab var track_date "Most Recent Track"
	lab var pr_attempts "Attempts"
	lab var `tvar' "`misslab'"
	lab val `tvar' `val'

	tempfile track
	save "`track'"
}

* load the sample list
use "`master'", clear

if !mi("`mid'") {
	ren `mid' `id'
}

keep `id' `sortby' `keepmaster'

if "`filename'" == "" {
	local filename "Progress Report"
}	

if regexm("`filename'", ".xls") {
	local filename = substr("`filename'", 1, strpos("`filename'", ".xl")-1) 
}

tempvar  status tmerge tstatus

/* -------------------------- Merge Questionnaire --------------------------- */

	merge 1:1 `id' using "`survey'", ///
		keepusing(submissiondate `keepsurvey') gen(pr_merge)

	ren submissiondate questionnaire_date
	replace questionnaire_date = dofc(questionnaire_date)
	format questionnaire_date %td

	lab def _merge 1 "Not submitted" 2 "Only in Questionnaire Data" 3 "Submitted", modify

	decode pr_merge, gen(`status')
	qui count if pr_merge == 2
	loc surveyonly `r(N)'
	if `surveyonly' > 0 {

		if "`surveyok'" == "" {
			dis as err "`surveyonly' IDs appear in survey data only. Use -surveyok- option to allow or check for incorrect IDs."
			exit 198

		}
		else {
			noi di ""
			noi di "`surveyonly' IDs appear in the survey data only. These IDs are not counted in the totals."

		}
	}


	local allvars `id' `keepmaster' `keepsurvey' questionnaire_date `status'
	lab var `status' "Status"
	lab var questionnaire_date "Date Submitted"
	order `allvars' 
	gsort pr_merge -questionnaire_date `id' `keepmaster'
	
	/* -------------------------- Create Summary Sheet -------------------------- */

	preserve
		gen completed = 1 if pr_merge == 3
		gen total = 1 if pr_merge != 2
		collapse (sum) completed total (min) first_submitted=questionnaire_date (max) last_submitted=questionnaire_date, by(`sortby')
		drop if mi(`sortby') // so it doesn't show in the table
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
	*************Merge in tracking info
	if !mi("`tracking'") {
		merge 1:1 `id' using "`track'", gen(`tmerge')
		replace `tvar' = . if pr_merge == 3 
		replace pr_attempts = . if pr_merge == 3
		replace track_date = . if pr_merge == 3
		
		decode `tvar', gen(`tstatus')
		replace pr_merge = 2 if !mi(`tstatus')
		replace `status' = `tstatus' if !mi(`tstatus')
		lab def _merge 2 "Only Tracking Form", modify
		
		gsort pr_merge track_date pr_attempts -questionnaire_date `id' `keepmaster'
		local allvars `allvars' track_date pr_attempts 
		replace track_date = dofc(track_date)
		format track_date %td
	}


if "`surveyok'" == "surveyok" & `surveyonly' > 0 {

	if mi("`variable'") {
		local variable = "varl"
	}

	*If want value labels, encode variable so those are used as colwidth
	if "`nolabel'" == "" {
		ds `allvars', has(vallab)
		foreach var in `r(varlist)' {
			cap decode `var', gen(`var'_new)
			if _rc == 111 {
				lab val `var' .
			}
			if !_rc {
				drop `var'
				ren `var'_new `var'
			}
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
	
	preserve
	
	if "`variable'" == "variable" {
		ds `status', not
		foreach var in `r(varlist)' {
			lab var `var' "`var'"
		}
	}
	export excel `id' `keepsurvey' questionnaire_date `status' if pr_merge == 2 using "`filename'.xlsx", ///
	firstrow(varl) sheet("Only in Survey") sheetreplace `nolabel'
	
	restore
	
	mata : create_progress_report("`filename'.xlsx", "Only in Survey", tokens("`id' `keepsurvey' questionnaire_date `status'"), `=`surveyonly'+1')

}
	
if "`summary'"	== "" {
	
	if mi("`variable'") {
		local variable = "varl"
	}

	*If want value labels, encode variable so those are used as colwidth
	if "`nolabel'" == "" {
		ds `allvars', has(vallab)
		foreach var in `r(varlist)' {
			cap decode `var', gen(`var'_new)
			if _rc == 111 {
				lab val `var' .
			}
			if !_rc {
				drop `var'
				ren `var'_new `var'
			}
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
			loc old `sortby'
			loc sortby `upper'

		}
	}
	
	levelsof `sortby', local(byvalues)
	qui tab `sortby'
	loc sortcount `r(r)'
	
	if `sortcount' > 30 & "`workbooks'" == "" {
	dis as error "`sortby' has more than 30 unique values. Please use the -workbooks- option to create workbooks instead of worksheets."
	error 134
	}

	preserve
	if "`variable'" == "variable" {
		ds `status', not
		foreach var in `r(varlist)' {
			lab var `var' "`var'"
		}
	}

	foreach sortval in `byvalues' {
		if "`workbooks'" == "workbooks" {
			export excel `allvars' if `sortby' == "`sortval'" using "`filename'_`sortval'.xlsx", ///
			firstrow(varl) sheet("`sortval'") replace `nolabel'
			}
		else {
			export excel `allvars' if `sortby' == "`sortval'" using "`filename'.xlsx", ///
			firstrow(varl) sheet("`sortval'") sheetreplace `nolabel'
		}
			
		count if `sortby' == "`sortval'"

    local N = `r(N)' + 1
		
		if "`workbooks'" == "workbooks" {
			mata : create_progress_report("`filename'_`sortval'.xlsx", "`sortval'", tokens("`allvars'"), `N')
		}
		
		else {
			mata : create_progress_report("`filename'.xlsx", "`sortval'", tokens("`allvars'"), `N')

		}
		local den = `N' - 1
		count if `sortby' == "`sortval'" & pr_merge == 3
		local num = `r(N)'
		noi dis "Created sheet for `sortval': interviewed `num' out of `den'"
	}
	
	restore
}

	if !mi("`dta'") {	
		preserve
			keep if pr_merge <= 2
			if !mi("`tracking'") {
			keep `sortby' `id' `keepmaster' pr_merge track_date `tvar' pr_attempts
			order `sortby' `id' `keepmaster' pr_merge track_date `tvar' pr_attempts
			}
			else {
			keep `sortby' `id' `keepmaster' 
			order `sortby' `id' `keepmaster' 
			}
			save "`dta'", replace
			noi dis "Saved remaining respondents to `dta'."
		restore

	}

	if !mi("`old'") loc sortby `old'
	if !mi("`tracking'") order `sortby' `id' pr_merge track_date `tvar' pr_attempts
	else order `sortby' `id' pr_merge
	
	if "`clear'" == "" use "`orig'", clear
	
} //qui bracket
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
	b.put_string(1, 1, "Tracking Summary: " + st_local("d"))
	b.set_horizontal_align(1, (1,6), "merge")
	b.set_number_format((3,N), 4, "percent")
	
	b.set_font_bold(N, (1,6), "on")
	b.set_bottom_border(N, (1,6), "thick")
	
	stat = st_data(., "pct_completed")
	target = strtoreal(st_local("target"))-0.005
	for (i=1; i<=length(stat); i++) {
		
		if (stat[i] == 0) {
			b.set_fill_pattern(i + 2, 4, "solid", "red")
		}


		else if (stat[i] >= target) {
			b.set_fill_pattern(i + 2, 4, "solid", "green")

		}
		else {
			b.set_fill_pattern(i + 2, 4, "solid", "yellow")
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
					varlabel = st_varlabel(allvars[i])
					if (varname_widths[i] < strlen(varlabel)) {
						varname_widths[i] = strlen(varlabel)
				}
		
		if	(column_widths[i] < (varname_widths[i])) {
			column_widths[i] = (varname_widths[i])
		}
		b.set_column_width(i, i, column_widths[i] + 2)
	}
	
	if (st_local("surveyok") == "surveyok" & strtoreal(st_local("surveyonly")) > 0) {
		b.put_string(N+2, 1, st_local("surveyonly") + " IDs did not appear in master dataset. Review 'Only in Survey' sheet.")
	}
	
	
	b.close_book()
}
void create_progress_report(string scalar filename, string scalar sortval, string matrix allvars, real scalar N) 
{
	class xl scalar b
	real scalar i, count
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
	
	
	if (st_local("tracking") != "") {
		count = length(varname_widths)-2
		b.set_left_border((1,N), length(varname_widths)-2, "thick")
	}
	else count = length(varname_widths)
	
	sortvar = st_sdata(., st_local("sortby"))
	rows = selectindex(sortvar :== sortval)
	status = st_data(rows, "pr_merge")
	for (i=1; i<=length(rows); i++) {
		if (status[i] == 1) {
			b.set_fill_pattern(i + 1, count, "solid", "red")
		}
		else if (status[i] == 2) {
			b.set_fill_pattern(i + 1, count, "solid", "yellow")
		}
		else if (status[i] == 3) {
			b.set_fill_pattern(i + 1, count, "solid", "green")
		}
	}
	b.close_book()
}
end
