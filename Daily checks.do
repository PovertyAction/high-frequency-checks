

	set more off

	use `preproc_data' , clear

	
********************************************************************************	
*Check Metadata (survey ID, dates, and other survey metadata)
******************************************************************************** 


*Check unique ID
****************************************
	isid $survey_id
	
	
*Check survey completion
****************************************
	*LIST incomplete surveys - simple export excel


*Drop incomplete surveys
****************************************
	
	
*Fix known errors
****************************************
	*readreplace using stufff
	
	
	
********************************************************************************
*Now recode missing values
********************************************************************************
	/* now we'd load in the missing value data from the excel sheet,
		but for now I'll just do this manually */
	forval x = 1/$kk_miss {
		loc vartyp_tmp : word `x' of $vartype
		loc code_tmp : word `x' of $misscode
		loc stval_tmp : word `x' of $stata_value
		if `"`vartyp_tmp'"' == "numeric" {
			qui ds, has(type numeric)
			recode `r(varlist)' (`code_tmp' = `stval_tmp')
		}
		else if `"`vartyp_tmp'"' == "string" {
			qui ds, has(type string)
			foreach var in `r(varlist)' {
				replace `var' = `"`stval_tmp'"' if `var' == `"`code_tmp'"'
			}
		}
		else di in red "NO TYPE SPECIFIED"
	}
	
	
********************We need to add in fixes to the value labels here as well,
*but that's low priority.

	*Save the recoded dataset. We need this because of the way the output is
		*written in later steps.
	tempfile recoded_data
	save `recoded_data' 


********************************************************************************
*Check don't know/ refusal percentage (item nonresponse) for all variables
********************************************************************************

	* /!\ we need to add in the number of non-missing obs as well.
	
	use `recoded_data' , clear
	tempfile item_nonr_output
	cap file close myfile
	file open myfile using `item_nonr_output' , text write replace
	file write myfile "Variable,Label,N,ItemNonResponsePercent,DontKnowPercent,RefusalPercent" _n 
	foreach var of varlist _all {
		cap loc varlabb: variable label `var'
		cap loc varlabb = subinstr(`"`varlabb'"',",","-",.)
		cap confirm numeric var `var' 
		if _rc == 0 {
			qui count if `var' != .
			loc nonskip = r(N)
			qui count if inlist(`var',.d,.r) // Here you can add other missing 
				// value codes if necessary
			loc nonresp_perc = r(N)/`nonskip'
			qui count if `var' == .d
			loc dk_perc = r(N)/`nonskip'
			qui count if `var' == .r
			loc ref_perc = r(N)/`nonskip'
			if `nonresp_perc' > $missing_perc & `nonskip' != 0 {
				file write myfile "`var',`varlabb',`nonskip',`nonresp_perc',`dk_perc',`ref_perc'" _n	
			}
		}
		else {
			qui count if `var' != ""
			loc nonskip = r(N)
			qui count if inlist(`var',".don't know",".refusal")
			loc nonresp_perc = r(N)/`nonskip'
			qui count if `var' == ".don't know"
			loc dk_perc = r(N)/`nonskip'
			qui count if `var' == ".refusal"
			loc ref_perc = r(N)/`nonskip'
			if `nonresp_perc' > $missing_perc & `nonskip' != 0  {
				file write myfile "`var',`varlabb',`nonskip',`nonresp_perc',`dk_perc',`ref_perc'" _n	
			}
		}
	}
	file close myfile
			
			
*Output this to Excel:
	insheet using `item_nonr_output' , comma case clear
	
	*Format the variables
	foreach var in ItemNonResponsePercent DontKnowPercent RefusalPercent {
		replace `var' = round(`var',.01) 
	}
	
	*Export
	
	/* do we need this?
	qui count
	if r(N) == 0 { 
		set obs 1
		tostring Variable
		replace Variable = "No variables have high item non-response"
	}
	*/
	
	cap export excel using "New HFC templates/Example_HFC output.xlsx" , sheet("Item Non-Response") sheetreplace firstrow(variables) nolabel
	if _rc != 0 { 
		di as error "Check that your minimum percentage global is in the correct format."
		exit 198
	}



	
********************************************************************************	
*Check minimums & maximums
********************************************************************************
	use `recoded_data' , clear
	set more off
	*set trace on 
	tempfile minmax_output
	cap file close myfile
	file open myfile using `minmax_output' , text write replace
	file write myfile "Enumerator,Survey ID,Variable,Label,Value,Message" _n 

	forval v=1/$kk_outlier {
		loc vartmp: word `v' of $Variable
		loc minsoft: word `v' of $soft_min
		loc minhard: word `v' of $hard_min
		loc maxsoft: word `v' of $soft_max
		loc maxhard: word `v' of $hard_max
		
		if `"`minsoft'"' == "" loc minsoft .
		if `"`minhard'"' == "" loc minhard .
		if `"`maxsoft'"' == "" loc maxsoft .
		if `"`maxhard'"' == "" loc maxhard .		
		
		cap loc varlabb: variable label `vartmp'
		cap loc varlabb = subinstr(`"`varlabb'"',",","-",.)
		forval x = 1/`=_N' {
			loc enum = ${enum_id}[`x']
			loc survey = ${survey_id}[`x']
			loc varval = `vartmp'[`x']
			
			*Check Hard and Soft minimums
			if `varval' < `minhard' & `minhard' < . {
				loc message `"Value is too small. Hard Min. = `minhard'"'
				file write myfile `"`enum',`survey',`vartmp',`varlabb',`varval',`message'"' _n
			}
			else if `varval' < `minsoft' & `minsoft' < . {
				loc message `"Value is small. Soft Min. = `minsoft'"'
				file write myfile `"`enum',`survey',`vartmp',`varlabb',`varval',`message'"' _n
			}
			
			*Check Hard and Soft Maximums
			if `varval' > `maxhard' & `maxhard' < . & `varval' < . {
				loc message `"Value is too high. Hard Max. = `maxhard'"'
				file write myfile `"`enum',`survey',`vartmp',`varlabb',`varval',`message'"' _n	
			}
			else if `varval' > `maxsoft' & `maxsoft' < . & `varval' < . {
				loc message `"Value is high. Soft Max. = `maxsoft'"'
				file write myfile `"`enum',`survey',`vartmp',`varlabb',`varval',`message'"' _n	
			}

		}
	}
	file close myfile	
		
		
		
		
*Output this to Excel:
	insheet using `minmax_output' , comma case clear
	export excel using "New HFC templates/Example_HFC output.xlsx" , sheet("Outliers") sheetreplace firstrow(variables) nolabel
		
	
	/*

	*THIS NEEDS MUCH WORK - EXPORT EXCEL MIGHT BE BETTER
	forval v=1/$kk_outlier {
		loc vartmp: word `v' of $Variable
		loc mintmp: word `v' of $Minimum

		listtab KEY `vartmp' if `vartmp' < `mintmp', delimiter(",") appendto("SHPS tracking/somefile.csv") replace headlines("Displaying minimum soft value violations") // headchars(charname)
	}
	
	*/
	
	*/
