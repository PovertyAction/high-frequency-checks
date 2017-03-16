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
syntax varname,  //varname is the form version variable - must be num. 
	/* specify uid for the survey, enumerator id */
    id(varname) ENUMerator(varname) 
	/* list of other vars to keep */
	[KEEPvars(string)] 
	/* specify date var, i.e. submission date var */
	submit(varname numeric)
	/* output filename */
	saving(string) 
	;	
#delimit cr

	
	di ""
	di "Compiling information on survey form versions by submission date..."

	qui {
	
	* test for fatal conditions 
	cap confirm numeric var `varlist'
	if _rc {
		di as err "Variable used for form version (`varlist') not numeric."
		di as err "Must be numeric and ordinal for the program to work correctly."
		di as err "Check that you imported 
		error 101
	}
		
	if !mi("`keep'") {
		foreach var of varlist `keep' {
			cap confirm var `var'
			if _rc {
				di as err `"Tried to specify keeping the var "`var'" - "`var'" does not exist in the dataset"'
				error 101
			}
		}
	}
	
	count if `submit' == . 
	if `r(N)' > 0 {
		di as err `"There are missing values of `submit'. Drop these observations before continuing."'
		error 101
	}

	
	* initialize tempvars  
	tempvar header_submit header_fvs formatted_subdate ///
	outdated_fvs_header max_fv_by_subdate wrong_fv wrong_fv_today 
	
	* export sheet headers 
	gen `header_submit' = . 
	gen `header_fvs' = . 
	lab var `header_submit' "Submission Date" 
	lab var `header_fvs' "Form Versions" 	
	export excel `header_submit' `header_fvs'  using "`saving'" in 1, sheet("T3. form versions") firstrow(varl) sheetreplace	

	* convert `header_submit' to %td format if needed	
	
	foreach letter in d c C b w m q h y {
		ds `submit', has(format %t`letter'*)
		if !mi("`r(varlist)'") {
			gen `formatted_subdate' = dof`letter'(`submit')
		}
	}
	
	format `formatted_subdate' %tdCCYY/NN/DD
	
	tab `formatted_subdate' `varlist'
	if mi("`r(N)'") {
		di as err `"No observations in cross-tab of `submit' and `varlist' - check your data"'
		error 122
	}
	
	* format and export submission dates (left hand column of table)
	preserve 
	keep `formatted_subdate'
	duplicates drop `formatted_subdate', force
	sort `formatted_subdate' 
	export excel using "`saving'", sheet("T3. form versions") cell(A3) sheetmodify  datestring("%tdCCYY/NN/DD") 
	restore
	
	* export form def versions (column headers of table)
	preserve 
	table `varlist', replace
	xpose, clear promote
	drop in 2
	export excel using "`saving'", sheet("T3. form versions") cell(B2) sheetmodify 
	restore 

	* export form def version counts by subdate (body of table) 
	clear matrix
	ta `formatted_subdate' `varlist', matcell(fvs_counts_by_subdate)
	local num_subdates = `r(r)'
	
	preserve 
	svmat fvs_counts_by_subdate, names(fvs_string)
	keep fvs_string* 
	export excel using "`saving'", sheet("T3. form versions") cell(B3) sheetmodify 
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
	gen `outdated_fvs_header' = . 
	lab var `outdated_fvs_header' "List of entries using outdated survey form version on `frmt_max_subdate'"	
	local row_for_outdated_fvs_header = `num_subdates' + 5 
	export excel using "`saving'", sheet("T3. form versions") sheetmodify firstrow(varl) cell(A`row_for_outdated_fvs_header')
	restore 
	
	* get total count of surveys
	local num_surveys = _N

	* gen wrong today & counts 
	sum `varlist', d
	gen `wrong_fv_today' = `varlist' != `r(max)' & !mi(`varlist') & `formatted_subdate' == `max_subdate'
	
	count if `wrong_fv_today' == 1 
	local num_wrong_fvs_today = `r(N)'
	
	* get percent of num wrong versions on most recent sub date	
	local perc_wrong_fvs_today: disp %12.2f `num_wrong_fvs_today'*100/`num_surveys'
	local perc_wrong_fvs_today = trim("`perc_wrong_fvs_today'")

	local row_for_outdated_fvs= `row_for_outdated_fvs_header' + 1
	if `num_wrong_fvs_today' > 0 {
		export excel `enumerator' `id' `keepvars'  using "`saving'" if `wrong_fv_today' == 1, sheet("T3. form versions") sheetmodify cell(A`row_for_outdated_fvs') firstrow(var)
	}
}
	
	display `"Information saved in "`saving'""'
	display "Most recent submission date was `frmt_max_subdate'"
	display "`num_wrong_fvs_today' (`perc_wrong_fvs_today'%) survey(s) completed with an outdated form version on `frmt_max_subdate'"
	

	end
