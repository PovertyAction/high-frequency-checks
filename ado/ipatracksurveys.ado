*! version 1.0.0 Caton brewster 10nov2016

program ipatracksurveys, rclass
	/* Create a sheet that shows progress of surveying by a specified geographic unit
		The sheet generated shows number of surveys completed in each geo unit, number 
		surveys left to complete (based on list of expected sample/respondents, specified
		by user), first day of surveying in that geo unit and last day of surveying. */


//define inputs
version 13

#delimit ;
syntax using/,  
	/* unit that will be used (e.g. community) */
	unit(varname)
	/* specify uid for the survey */
	id(varname) 
	/* specify date var, i.e. submission date var */
	submit(varname numeric)
	/* sample/respondents list file name */
	sample(string)
	/* specify unit and uid in sample/respondent list data if they are named differently */
	[s_unit(string) s_id(string)]	
	;	
#delimit cr

	di ""
	di "Generating status of surveys..."

qui {

	* format outfile 
	if !(regexm("`using'", ".xlsx") | regexm("`using'", ".xls")) {
		local using = "`using'.xlsx"
	}
	
	* tempvars and tempfiles 
	tempfile dates master
	#delimit ;
	tempvar 
	tagdupids 
	formatted_submit
	unit_string 
	id_string
	survey_start_date 
	survey_end_date 
	num_surveys_done 
	tagdupids_sample
	num_surveys_planned 
	num_surveys_left 
	num_surveys_left_s
	total_surveys_done 
	total_surveys_left 
	;	
	#delimit cr

	
	* test for fatal conditions 
	duplicates tag `id', gen(`tagdupids')
	count if `tagdupids' > 0 
	if `r(N)' > 0{
		di as err "Duplicate IDs (`id') are not allowed. Please correct this before running ipatracksurveys."
		error 101
		}
		
	count if `submit' == . 
	if `r(N)' > 0 {
		di as err `"Missing values of `submit' are not allowed. Please correct this before running ipatracksurveys."'
		error 101
		}
		
	cap confirm string var `id'
	if _rc {
		count if `id' == . 
		if `r(N)' > 0 {
			di as err `"Missing values of `id' are not allowed. Please correct this before running ipatracksurveys."'
			error 101
		}
	}
	else {
		count if `id' == "" 
		if `r(N)' > 0 {
			di as err `"Missing values of `id' are not allowed. Please correct this before running ipatracksurveys."'
			error 101
		}
	}

	
	* convert submit to %td format if needed	
	foreach letter in d c C b w m q h y {
		ds `submit', has(format %t`letter'*)
		if !mi("`r(varlist)'") {
			gen `formatted_submit' = dof`letter'(`submit')
		}
	}
	cap confirm var `formatted_submit' 
	if _rc {
		di as err "The submission date variable, `submit', is not in an acceptable format. 
		di as err "Must be %td, %tc, %tC, %tb, %tw, %tm, %tq, %th, or %ty."
		error 101
	}
	format `formatted_submit' %tdCCYY/NN/DD	
	
	* prep unit and id variables
	cap confirm string var `unit' 
	if _rc {
		tostring `unit', gen(`unit_string')
	}
	else {
		gen `unit_string' = `unit' 
	}

	count if `unit_string' == ""
	local num_mi_unit_var = `r(N)'
	replace `unit_string' = "MISSING `unit'" if `unit_string' == ""
	
	cap confirm string var `id' 
	if _rc {
		tostring `id', gen(`id_string')
	}
	else {
		gen `id_string' = `id' 
	}

	* save current data as master
	save `master', replace
	
	* create dates data  
	keep `unit_string' `formatted_submit' 
	bysort `unit_string': egen `survey_start_date' = min(`formatted_submit') 
	bysort `unit_string': egen `survey_end_date' = max(`formatted_submit') 
	gen `num_surveys_done' = 1 	
	collapse (sum) `num_surveys_done' (first) `survey_start_date' `survey_end_date', by(`unit_string')	
	sort `unit_string' 
	format %tdCCYY/NN/DD `survey_start_date' `survey_end_date' 
	save `dates', replace

	* create sample data 
	if regexm("`sample'", ".csv") {
		insheet using "`sample'", names clear 
	}
	else if regexm("`sample'", ".xls") | regexm("`sample'", ".xlsx") {
		import excel using "`sample'", firstrow clear 
	}
	else if regexm("`sample'", ".dta") {
		use "`sample'", clear
	}
	else if regexm("`sample'", ".raw") {
		infile using "`sample'", automatic clear
	}
	else {
		di as err `"Must specify file type for sample data, "`sample'"  Valid options include .xls, .xlsx, .csv, .dta, and .raw."'
		error 100 
	}
		
	* test fatal conditions (sample)
	foreach sample_var in s_unit s_id {
		if "`sample_var'" == "s_unit" {
			local main_var `unit'
			local new_main_var `unit_string'
		}
		else {
			local main_var `id'
			local new_main_var `id_string'
		}
		if !mi("``sample_var''") {
			cap confirm var ``sample_var''
			if _rc {
				noisily di as err `"The var "``sample_var''" does not exist in your sample data, , "`sample'"."' 
				error 111
			}
			else {
				cap confirm string var ``sample_var'' 
				if _rc {
					tostring ``sample_var'', gen(`new_main_var')
				}
				else {
					gen `new_main_var' = ``sample_var''
				}
			}
		}
		else {
			cap confirm var `main_var'
			if _rc {
				noisily di as err `"ERROR: Your var "`main_var'" does not exist in your sample data, , "`sample'". If it exists but is named differently, specify the alternate name using "s_unit()"."'
				error 111 
			}
			else {
				cap confirm string var `main_var'
				if _rc {
					tostring `main_var', gen(`new_main_var')
				}
				else {
					gen `new_main_var' = `main_var'
				}
			}
		}
	}

	count if `id_string' == ""
	if `r(N)' > 0{
		if !mi("`s_id'") {
			di as err `"Missing IDs (`s_id') in your sample data ("`sample'") are not allowed."'
			error 101
		}
		else {
			di as err `"Missing IDs (`id') in your sample data ("`sample'") are not allowed."'
			error 101
		}
	}

	count if `unit_string' == "" 
	if `r(N)' > 0{
		if !mi("`s_unit'") {
			di as err `"Missing values of the unit variable (`s_unit') in your sample data ("`sample'") are not allowed."'
			error 101
		}
		else {
			di as err `"Missing values of the unit variable (`unit') in your sample data ("`sample'") are not allowed."'
			error 101
		}
	}

	* check duplicates (sample)
	duplicates tag `id_string', gen(`tagdupids_sample')
	count if `tagdupids_sample' > 0 
	if `r(N)' > 0{
		if !mi("`s_id'") {
			di as err `"Dupliacte IDs (`s_id') in your sample data ("`sample'") are not allowed."'
			error 101
		}
		else {
			di as err `"Duplicate IDs (`id') in your sample data ("`sample'") are not allowed."'
			error 101
		}
	}
		
	* calc num planned surveys based on sample data 
	gen `num_surveys_planned' = 1
	collapse (sum) `num_surveys_planned', by(`unit_string')		
	
	* merge in dates data
	merge 1:1 `unit_string' using `dates'	
	
	* if missing, means incomplete
	replace `num_surveys_done' = 0 if `num_surveys_done' == . 	
	
	* num_surveys_planned = 0 if missing `unit' 
	replace `num_surveys_planned' = 0 if _merge == 2

	* gen num surveys left 
	gen `num_surveys_left' = `num_surveys_planned' - `num_surveys_done' 
	
	count if `num_surveys_left' < 0 
	local num_surveyed_not_in_sample = `r(N)' 
	
	if `num_surveyed_not_in_sample' > 0 {
		gen `num_surveys_left_s' = `num_surveys_left'
		replace `num_surveys_left_s' = -99 if `num_surveys_left_s' < 0
		tostring `num_surveys_left_s', replace
		replace `num_surveys_left_s' = "num surveys completed > num surveys planned" if `num_surveys_left_s' == "-99"
		replace `num_surveys_left' = 0 if `num_surveys_left' < 0 
	}

	* calc some overview stats 
	egen `total_surveys_done' = total(`num_surveys_done')
	sum `total_surveys_done'
	local done = `r(max)'
	
	egen `total_surveys_left'  = total(`num_surveys_left')
	sum `total_surveys_left'  
	local left = `r(max)' 

	local total = `done' + `left' 

	local perc_done: disp %12.2f `done'*100/`total'
	local perc_done = trim("`perc_done'")
	local perc_left: disp %12.2f `left'*100/`total'
	local perc_left = trim("`perc_left'")

	local done: disp %9.0gc `done'
	local done = trim("`done'")
	local left: disp %9.0gc `left'
	local left = trim("`left'")
	local total: disp %9.0gc `total'
	local total = trim("`total'")

	sum `survey_start_date'
	local first = `r(min)' 
	local first: disp %tdCCYY/NN/DD `first'
	local first = trim("`first'")
	sum `survey_end_date'
	local last = `r(max)' 
	local last: disp %tdCCYY/NN/DD `last'
	local last = trim("`last'")
	
	* keep the appropriate version of num_surveys_left*
	cap confirm var `num_surveys_left_s'
	if !_rc {
		drop `num_surveys_left'
		rename `num_surveys_left_s' `num_surveys_left'
	}

	* export 
	keep `unit_string' `num_surveys_planned' `num_surveys_done' `num_surveys_left' `survey_start_date' `survey_end_date' 
	order `unit_string' `num_surveys_planned' `num_surveys_done' `num_surveys_left' `survey_start_date' `survey_end_date' 
	gsort- `num_surveys_done'

	lab var `num_surveys_done' "Num Surveys Complete"
	lab var `num_surveys_left' "Num Surveys Remaining"
	lab var `num_surveys_planned' "Num Surveys Planned (based on sample data)"
	lab var `survey_start_date' "First date Survey Submitted"
	lab var `survey_end_date' "Last date Survey Submitted"
	lab var `unit_string' "Unit Variable: `unit'"
	
	format %tdCCYY/NN/DD `survey_start_date' `survey_end_date' 
	export excel using "`using'", sheet("T2. track surveys") firstrow(varl) datestring("%tdCCYY/NN/DD") cell(A2)  sheetreplace	
	
	* export header 
	local today = date(c(current_date), "DMY")
	local today_f : di %tdCCYY/NN/DD `today'
	putexcel set "`using'", sheet("T2. track surveys") modify  
	putexcel A1 = ("Survey Statuses as of `today_f'")

	use `master', replace 
}

	display `"Saved tracking information on `total' surveys in "`using'""'
	display "`done' survey(s) complete (`perc_done'%)"
	display "`left' survey(s) remain (`perc_left'%)"
	display "First survey completed on `first'"
	display "Last survey completed on `last'"
	if `num_mi_unit_var' > 0 {
		noisily disp in r `"WARNING: `num_mi_unit_var' observations are missing `unit' in your data. Listed as "MISSING `unit'" in "`using'"."'
	}
	if `num_surveyed_not_in_sample' > 0 {
		disp in r "WARNING: For `num_surveyed_not_in_sample' value(s) of `unit', the number of surveys completed exceeds the number of scheduled surveys from your sample() data." 	
		disp in r "This suggests there are missing values of id() or the unit varible in your sample() data. Ensure that your sample() dataset includes all IDs you plan(ned) to survey." 
		disp in r `"These observations are flagged in "`using'"."'
	}
		
	end
