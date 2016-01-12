


	use "SHPS tracking/data_cleaned.dta" , clear

	
********************************************************************************	
*Check Metadata (survey ID, dates, and other survey metadata)
******************************************************************************** 


*Check unique ID
****************************************
	isid $survey_id
	
	
*Fix known errors
****************************************
	*readreplace using stufff
	
	
	
********************************************************************************
*Now recode missing values
********************************************************************************
	use "$raw_data" , clear
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

	
	
********************************************************************************	
*Check minimums & maximums
********************************************************************************
	
	set more off
	*set trace on 
	tempfile output_tmp
	cap file close myfile
	file open myfile using `output_tmp' /* "New HFC templates/writeout_trial.csv" */ , text write replace
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
	insheet using `output_tmp' , comma case clear
	export excel using "New HFC templates/Example_HFC output.xlsx" , sheet("Outliers") sheetreplace firstrow(variables) nolabel
		
	
	/*

	*THIS NEEDS MUCH WORK - EXPORT EXCEL MIGHT BE BETTER
	forval v=1/$kk_outlier {
		loc vartmp: word `v' of $Variable
		loc mintmp: word `v' of $Minimum

		listtab KEY `vartmp' if `vartmp' < `mintmp', delimiter(",") appendto("SHPS tracking/somefile.csv") replace headlines("Displaying minimum soft value violations") // headchars(charname)
	}
	
	*/
	
	