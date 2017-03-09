*! version 1.0.0 Caton brewster 10nov2016

program ipatrackversions, rclass
	/* Create a sheet that shows the survey versions used for each day of surveying. 
	For the most recent day of surveying, if there are surveys that have been submitted
	using the wrong version, list the enumerator ID, respondent ID, etc. for those observations
	to facilitate finding that enumerator and ensuring they upload the latest version of the 
	survey */
	
	

//define inputs
version 13

#delimit ;
syntax varname,  //varname is the form version variable  
	/* specify uid for the survey, enumerator id */
    id(varname) ENUMerator(varname) 
	/* list of other vars to keep */
	[KEEPvars(string)] 
	/* specify date var, i.e. submission date var */
	subdate(varname numeric)
	/* output filename */
	saving(string) 
	;	
#delimit cr

	
	di ""
	di "Compiling information on survey form versions by submission date..."

	qui {
	
	* test for fatal conditions 
	if !mi("`keep'") {
		foreach var of varlist `keep' {
			cap confirm var `var'
			if _rc {
				di as err `"Tried to specify keeping the var "`var'" - "`var'" does not exist in the dataset"'
				error 101
			}
		}
	}
	
	count if `subdate' == . 
	if `r(N)' > 0 {
		di as err `"There are missing values of `subdate'. Either drop these observations or restrict them using an "if" statement."'
		error 101
	}

	
	* initialize tempvars  
	tempvar header_subdate header_formversions formatted_subdate header_outdated_formversions ///
	max_formdef_by_subdate wrong_formversion wrong_formversion_today
	
	* export sheet headers 
	preserve
	clear 
	set obs 1 
	gen `header_subdate' = .
	gen `header_formversions' = . 
	
	* get today's date for sheet's header
	lab var `header_subdate' "Submission Date" 
	lab var `header_formversions' "Form Versions" 
	
	export excel using "`saving'", sheet("Form Versions Used") firstrow(varl) sheetreplace	
	restore 

	* convert `subdate' to %td format if needed	
	ds `subdate', has(format %td*)
	if !mi("`r(varlist)'") {
		gen `formatted_subdate' = `subdate'
		}

	ds `subdate', has(format %tc*)
	if !mi("`r(varlist)'") {
		gen `formatted_subdate' = dofc(`subdate')
		}
		
	ds `subdate', has(format %tC*)
	if !mi("`r(varlist)'") {
		gen `formatted_subdate' = dofC(`subdate')
		}
		
	ds `subdate', has(format %tb*)
	if !mi("`r(varlist)'") {
		gen `formatted_subdate' = dofb(`subdate')
		}
	
	ds `subdate', has(format %tw*)
	if !mi("`r(varlist)'") {
		gen `formatted_subdate' = dofw(`subdate')
		}
		
	ds `subdate', has(format %tm*)
	if !mi("`r(varlist)'") {
		gen `formatted_subdate' = dofm(`subdate')
		}

	ds `subdate', has(format %tq*)
	if !mi("`r(varlist)'") {
		gen `formatted_subdate' = dofq(`subdate')
		}
		
	ds `subdate', has(format %th*)
	if !mi("`r(varlist)'") {
		gen `formatted_subdate' = dofh(`subdate')
		}

	ds `subdate', has(format %ty*)
	if !mi("`r(varlist)'") {
		gen `formatted_subdate' = dofy(`subdate')
		}
	
	format `formatted_subdate' %tdCCYY/NN/DD
	
	tab `formatted_subdate' `varlist'
	if !(`r(N)'){
		di as err `"No observations in cross-tab of `subdate' and `varlist' - check your data"'
		error 122
	}
	
	* format and export submission dates (left hand column of table)
	preserve 
	keep `formatted_subdate'
	duplicates drop `formatted_subdate', force
	sort `formatted_subdate' 
	export excel using "`saving'", sheet("Form Versions Used") cell(A3) sheetmodify  datestring("%tdCCYY/NN/DD") 
	restore
	
	* export form def versions (column headers of table)
	preserve 
	table `varlist', replace
	xpose, clear promote
	drop in 2
	export excel using "`saving'", sheet("Form Versions Used") cell(B2) sheetmodify 
	restore 

	* export form def version counts by subdate (body of table) 
	clear matrix
	ta `formatted_subdate' `varlist', matcell(form_version_counts_by_subdate)
	local num_subdates = `r(r)'
	
	preserve 
	svmat form_version_counts_by_subdate, names(formdef_versions_string)
	keep formdef_versions_string* 
	export excel using "`saving'", sheet("Form Versions Used") cell(B3) sheetmodify 
	restore 
	
	* save max submissiondate
	sum `formatted_subdate'
	local max_subdate = `r(max)'
	
	local frmt_max_subdate: disp %tdCCYY/NN/DD `max_subdate'
	local frmt_max_subdate = trim("`frmt_max_subdate'")

	
	* export list of obs that didn't use most recent survey version on most recent submission date 

	* export header 
	preserve
	clear
	set obs 1
	gen `header_outdated_formversions' = . 
	lab var `header_outdated_formversions' "List of entries using outdated survey form version on `frmt_max_subdate'"	
	local row_for_error_entries_header = `num_subdates' + 5 
	export excel using "`saving'", sheet("Form Versions Used") sheetmodify firstrow(varl) cell(A`row_for_error_entries_header')
	restore 
	
	* get total count of surveys
	local survey_count = _N

	* gen wrong today & counts 
	sum `varlist', d
	gen `wrong_formversion_today' = `varlist' != `r(max)' & !mi(`varlist') & `formatted_subdate' == `max_subdate'
	
	count if `wrong_formversion_today' == 1 
	local num_wrong_formversions_today = `r(N)'
	
	* get percent of num wrong versions on most recent sub date	
	local perc_wrong_formversions_today: disp %12.2f `num_wrong_formversions_today)'*100/`survey_count'
	local perc_wrong_formversions_today = trim("`perc_wrong_formversions_today'")

	local row_for_flagging_errors= `row_for_error_entries_header' + 1
	if `num_wrong_formversions_today' > 0 {
		export excel `enumerator' `id' `keepvars'  using "`saving'" if `wrong_formversion_today' == 1, sheet("Form Versions Used") sheetmodify cell(A`row_for_flagging_errors') firstrow(var)
	}
}
	
	display `"Information saved in "`saving'""'
	display "Most recent submission date was `frmt_max_subdate'"
	display "`num_wrong_formversions_today' (`perc_wrong_formversions_today'%) survey(s) completed with an outdated form version on `frmt_max_subdate'"
	

	end
