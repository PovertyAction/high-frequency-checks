*! version 1.0.0 Caton brewster 10nov2016

program ipatrackckversions, rclass
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
	foreach var of varlist `keep' {
		cap confirm var `var'
		if _rc {
			di as err `"Tried to specify keeping the var "`var'" - "`var'" does not exist in the dataset"'
			error 101
		}
	}
	
	count if `subdate' == . 
	if `r(N)' > 0 {
		di as err `"There are missing values of `subdate'. Either drop these observations or restrict them using an "if" statement."'
		error 101
	}


	* export sheet headers 
	preserve
	clear 
	set obs 1 
	tempvar var1 var2
	gen `var1' = .
	gen `var2' = . 
	
	* get today's date for sheet's header
	lab var `var1' "Submission Date" 
	lab var `var2' "Form Versions" 
	
	export excel using "`saving'", sheet("Form Versions Used") firstrow(varl) sheetreplace	
	restore 

	

	//now convert `subdate' to %td format if needed using tempvar, sub
	tempvar sub 
	
	ds `subdate', has(format %td*)
	if !mi("`r(varlist)'") {
		gen `sub' = `subdate'
		}

	ds `subdate', has(format %tc*)
	if !mi("`r(varlist)'") {
		gen `sub' = dofc(`subdate')
		}
		
	ds `subdate', has(format %tC*)
	if !mi("`r(varlist)'") {
		gen `sub' = dofC(`subdate')
		}
		
	ds `subdate', has(format %tb*)
	if !mi("`r(varlist)'") {
		gen `sub' = dofb(`subdate')
		}
	
	ds `subdate', has(format %tw*)
	if !mi("`r(varlist)'") {
		gen `sub' = dofw(`subdate')
		}
		
	ds `subdate', has(format %tm*)
	if !mi("`r(varlist)'") {
		gen `sub' = dofm(`subdate')
		}

	ds `subdate', has(format %tq*)
	if !mi("`r(varlist)'") {
		gen `sub' = dofq(`subdate')
		}
		
	ds `subdate', has(format %th*)
	if !mi("`r(varlist)'") {
		gen `sub' = dofh(`subdate')
		}

	ds `subdate', has(format %ty*)
	if !mi("`r(varlist)'") {
		gen `sub' = dofy(`subdate')
		}
	
	//format consistantly
	format `sub' %tdCCYY/NN/DD	
	
	//overview of form version by community 
	clear matrix
	
	//save info in matrices 
	tab `sub' `varlist', matcell(freq) matrow(names)
	if !(`r(N)'){
		di as err `"No observations in cross-tab of `subdate' and `varlist' - check your data"'
		error 122
		}
	format `varlist' %20.0f
	ta `varlist', matrow(fvs)

	//save some locals needed
	local rows = rowsof(names)
	local cols = colsof(freq) 
	local versions = rowsof(fvs)
	local row = 3
	local rows_plus = `rows' + 1 //include column headers in count 
	local error_row = `rows' + 5 
	
	//format and export submission dates 
	preserve 
	keep `sub'
	duplicates drop `sub', force
	sort `sub' 
	export excel using "`saving'", sheet("Form Versions Used") cell(A3) sheetmodify  datestring("%tdCCYY/NN/DD") 
	restore
	
	//determine number of column headers and export them
	matrix forms=J(`rows_plus',`cols',0) 
	forval j = 1/`cols' {
		local frmtd = fvs[`j',1]
		local frmtd : display %20.0f `frmtd'
		matrix forms[1,`j'] = `frmtd'
		}
	
	//loop through and fill in rest of table with num versions used each submission date
	local row = 2
	forval i = 1/`rows' {
		forval j = 1/`cols' {
			matrix forms[`row',`j'] = freq[`i',`j']
			}
		local row = `row' + 1
		}
		
			
	//export values 
	preserve 
	table `varlist', replace
	xpose, clear promote
	drop in 2
	export excel using "`saving'", sheet("Form Versions Used") cell(B2) sheetmodify 
	restore 
	
	//save max submissiondate (formatted and unformatted)
	sum `sub'
	local max_subdate = `r(max)'
	
	local frmt_max_subdate: disp %tdCCYY/NN/DD `max_subdate'
	local frmt_max_subdate = trim("`frmt_max_subdate'")

	
	//export list of obs that didn't use most recent survey version (only list for most recent submission date)

	//export header of list first
	preserve
	clear
	set obs 1
	tempvar var1
	gen `var1' = . 
	lab var `var1' "List of entries using outdated survey form version on `frmt_max_subdate'"
	
	export excel using "`saving'", sheet("Form Versions Used") sheetmodify firstrow(varl) cell(A`error_row')
	local error_row = `error_row' + 1
	restore 
	
	//get total count of surveys
	count
	local count = `r(N)'

	//now generate list with info we want to export 
	preserve 
	keep `sub' `varlist' `enumerator' `id' `keepvars' 
	
	tempvar max tag
	bysort `sub': egen double `max' = max(`varlist')
	format `max' %20.0f
	
	gen `tag' = `varlist'!=`max' & !mi(`varlist')
	
	//get count of number tagged surveys 
	count if `tag' == 1
	local tagged = `r(N)'
	
	keep if `tag' == 1 & `sub' == `max_subdate'
	
	count
	local errors = `r(N)'
	local percent = `errors'/`count' 
	local percent: disp %12.2f `errors'*100/`count'
	local percent = trim("`percent'")

	keep `enumerator' `id' `keepvars' 
	order `enumerator' `id' `keepvars' 
	sort `enumerator' 
	if _N > 0 {
		export excel using "`saving'", sheet("Form Versions Used") sheetmodify cell(A`error_row') firstrow(var)
	}
	
	restore 
	}
	
	display `"Information saved in "`saving'""'
	display "Most recent submission date was `frmt_max_subdate'"
	display "`errors' survey(s) were completed with an outdated form version on `frmt_max_subdate'"
	display "To date, `tagged' of a total of `count' survey(s) have been completed with an outdated form version"
	

	end
