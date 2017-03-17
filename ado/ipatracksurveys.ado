*! version 1.0.0 Caton brewster 10nov2016

program ipatracksurveys, rclass
	/* Create a sheet that shows progress of surveying by a specified geographic unit
		The sheet generated shows number of surveys completed in each geo unit, number 
		surveys left to complete (based on list of expected sample/respondents, specified
		by user), first day of surveying in that geo unit and last day of surveying. */


//define inputs
version 13

#delimit ;
syntax varname,  //varname is the geographic unit that will be used (e.g. community) 
	/* specify uid for the survey */
	id(varname) 
	/* specify date var, i.e. submission date var */
	submit(varname numeric)
	/* output filename */
	saving(string) 
	/* sample/respondents list file name */
	sample(string)
	/* specify geographic unit and uid in sample/respondent list data if it's named differently */
	[s_unit(string) s_id(string)]
	;	
#delimit cr

	
	di ""
	di "Generating status of surveys..."

qui {

	* format outfile 
	if !(regexm("`saving'", ".xlsx") | regexm("`saving'", ".xls")) {
		local saving = "`saving'.xlsx"
	}
	
	//first save number of interviews completed and first and last submission for each geographic unit
	tempfile dates
		
	tempvar tagdupids
	//flag if there are duplicates
	duplicates tag `id', gen(`tagdupids')
	count if `tagdupids' > 0 
	if `r(N)' > 0{
		di as err "Duplicate IDs (`id') are not allowed. Please correct this before running ipatracksurveys or exclude them using an 'if' statement."
		error 101
		}
	
		
	//flag if there are missing values of submissiondate
	count if `submit' == . 
	if `r(N)' > 0 {
		di as err `"There are missing values of `submit'. Either drop these observations or restrict them using an "if" statement."'
		error 101
		}
	
	//now convert `submit' to %td format if needed using tempvar, sub
	tempvar sub 
	
	* convert `header_submit' to %td format if needed	
	foreach letter in d c C b w m q h y {
		ds `submit', has(format %t`letter'*)
		if !mi("`r(varlist)'") {
			gen `formatted_submit' = dof`letter'(`submit')
		}
	}
	
	//format consistantly
	format `formatted_submit' %tdCCYY/NN/DD	
		
	tostring `varlist', replace //make string to be consistent

	//replace `varlist' with warning message if missing
	count if `varlist' == ""
	local missing = `r(N)'
	replace `varlist' = "MISSING `varlist'" if `varlist' == ""
	
	tempvar survey_start survey_end survey_num_done
	keep `varlist' `formatted_submit' //only interested in the geo var and submissiondate 
	bysort `varlist': egen `survey_start' = min(`formatted_submit') //get first submissiondate per geographic unit 
	bysort `varlist': egen `survey_end' = max(`formatted_submit') //get last submissiondate per geographic unit 
	gen `survey_num_done' = 1 	//in the collapse below this will get summed to become number interviews per community 
	collapse (sum) `survey_num_done' (first) `survey_start' `survey_end', by(`varlist')	//collapse so the dataset is at the geo unit level (1 obs per geo unit)
	sort `varlist' //sort by geographic unit var 
	format %tdCCYY/NN/DD `survey_start' `survey_end' //format our dates
	save `dates', replace

//now prep sample data - want to use this form/data to compare all completed surveys against full list of expected surveys 
	preserve
	
	//must run through different types of data possible and use correct command for importing it
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
		
	//check that we have the geo var in the sample data
	//if they did specify diff geo var (s_unit()) make sure it exists then rename it to our main geographic unit variable specified
	if !mi("`s_unit'") {
		cap confirm var `s_unit' 
		if _rc {
			noisily di as err `"The var "`s_unit'" does not exsit in your sample data, , "`sample'"."' 
			error 111
			}
		else {
			rename `s_unit' `varlist'		//in case they are different, rename to be the same 
			}
		}
	//if didn't specify diff geographic var name (s_unit()), make sure we have the main geo var (`varlist') in this sample data
	else {
		cap confirm var `varlist'
		if _rc {
			noisily di as err `"ERROR: Your var "`varlist'" does not exist in your sample data, , "`sample'". If it exists but is named differently, specify the alternate name using "s_unit()"."'
			error 111 
			}
		}

	//check that we have the id var in the sample data
	//if they did specify diff id var (s_id()) make sure it exists then rename it to our main id variable
	if !mi("`s_id'") {
		cap confirm var `s_id' 
		if _rc {
			noisily di as err `"The var "`s_id'" does not exsit in your sample data, , "`sample'"."' 
			error 111
			}
		else {
			rename `s_id' `id'		//in case they are different, rename to be the same 
			}
		}
	//if didn't specify diff geographic var name (s_unit()), make sure we have the main geo var (`varlist') in this sample data
	else {
		cap confirm var `id'
		if _rc {
			noisily di as err `"ERROR: Your id var "`id'" does not exist in your sample data, , "`sample'". If it exists but is named differently, specify the alternate name using "s_id()"."'
			error 111 
			}
		}
	
	tempvar tagdupids2
	//flag if there are duplicates
	duplicates tag `id', gen(`tagdupids2')
	count if `tagdupids2' > 0 
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
		

	//get the data at the geographic unit level (e.g. 1 obs per community) then will also get num surveys we expect in each geographic unit based on the sample data
	tempvar to_do
	gen `to_do' = 1
	collapse (sum) `to_do', by(`varlist')		
	
	//after making `varlist' a string in dataset above; convert to a string here to be consistent
	tostring `varlist', replace 
	
	//merge in our submission dates + completed survey temp data from above
	merge 1:1 `varlist' using `dates'
	
	count if _merge == 2 //these are people in our survey data but not sample data - shouldn't happen 
	local errors = `r(N)' 
		
	//for communities we haven't interviewed anyone in, certain vars will come in as missing, reset to 0
	replace `survey_num_done' = 0 if `survey_num_done' == . 	
	
	//generate num left for that community based on number we expect (to_do)
	tempvar survey_num_left
	gen `survey_num_left' = `to_do' - `survey_num_done' 
	drop _merge
	replace `survey_num_left' = 0 if `survey_num_left' < 0 //display it as an error 
	
	//clean up to_do if `varlist' is missing 
	replace `to_do' = 0 if `varlist' == "MISSING `varlist'"
	
	//put in order we want in our outputs sheet 
	keep `varlist' `to_do' `survey_num_done' `survey_num_left' `survey_start' `survey_end' 
	order `varlist' `to_do' `survey_num_done' `survey_num_left' `survey_start' `survey_end' 
	
	//label these vars to use as column headers
	lab var `survey_num_done' "Num Surveys Complete"
	lab var `survey_num_left' "Num Surveys Remaining"
	lab var `survey_start' "First date Survey Submitted"
	lab var `survey_end' "Last date Survey Submitted"
	lab var `to_do' "Num Surveys to Complete (based on sample data)"
	

	//sort by geo units with most interviews done 
	gsort- `survey_num_done'

	tempfile full_data
	save `full_data', replace
	restore
	
	//first export the header for the sheet with today's data
	preserve
	clear 
	set obs 1 
	tempvar var1
	gen `var1' = .
	
	//get today's date for sheet's header
	local today = date(c(current_date), "DMY")
	local today_f : di %tdCCYY/NN/DD `today'
	label var `var1' "Survey Statuses as of `today_f'"


	//now export our header
	export excel using "`saving'", sheet("Survey Tracking") firstrow(varl) datestring("%tdCCYY/NN/DD")  sheetreplace	
	restore 
	

	//now go back to data set before and export our table below the header
	preserve
	use `full_data', clear
	format %tdCCYY/NN/DD `survey_start' `survey_end'	//format our dates
	export excel using "`saving'", sheet("Survey Tracking") firstrow(varl) datestring("%tdCCYY/NN/DD") cell(A2)  sheetmodify	
	
	//save some stats to display after running the program 
	tempvar total
	egen `total' = total(`survey_num_done')
	sum `total'
	local done = `r(max)' 
	drop `total'
	egen `total'  = total(`survey_num_left')
	sum `total'  
	local left = `r(max)' 
	drop `total'
	local count = `done' + `left' 
	
	//calculate and format percentage progress
	local perc_done: disp %12.2f `done'*100/`count'
	local perc_done = trim("`perc_done'")
	local perc_left: disp %12.2f `left'*100/`count'
	local perc_left = trim("`perc_left'")

	//format counts with commas
	local left: disp %9.0gc `left'
	local left = trim("`left'")
	local done: disp %9.0gc `done'
	local done = trim("`done'")
	local count: disp %9.0gc `count'
	local count = trim("`count'")
	
	//get date range
	sum `survey_start'
	local first = `r(min)' 
	local first: disp %tdCCYY/NN/DD `first'
	local first = trim("`first'")
	sum `survey_end'
	local last = `r(max)' 
	local last: disp %tdCCYY/NN/DD `last'
	local last = trim("`last'")

	restore 
	
	}
	display `"Saved tracking information on `count' surveys in "`saving'""'
	display "`done' survey(s) complete (`perc_done'%)"
	display "`left' survey(s) remain (`perc_left'%)"
	display "First survey completed on `first'"
	display "Last survey completed on `last'"
	if `missing' > 0 {
		noisily disp in r `"WARNING: `missing' observations are missing `varlist' in your data. Listed as "MISSING" in "`saving'"."'
		}
	if `errors' > 0 {
		disp in r "WARNING: For `errors' value(s) of `varlist', the number of surveys completed exceeds the number of scheduled surveys from your sample() data. This suggests there are missing IDs (`id') in your sample() data. Ensure that your sample() dataset includes all IDs you plan(ned) to survey." 
		}
		
	end
