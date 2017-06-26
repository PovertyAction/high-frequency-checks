*! Version 1.0.0 Kelsey Larson March 16
prog ipacheckreadreplace, rclass
	/* This program makes corrections to a database from a second database of 
		corrections. The corrections sheet should have five columns:
			 - unique id variables, a column or combination of columns
				that uniquely identifies each entry in the survey. This can be
				one variable or multiple variables, and each column in the 
				corrections spreadsheet should be named the same as in the 
				survey.
			 - variable, a variable that indicates what variable is to be 
			    replaced for the correction sheet entry.\
			 - value, a column that specifies the value the variable is to be 
			    changed to.
			 - selectmultiple. write YES if the variable is a selectmultiple.
			 - oldvalue, the value to be replaced in a selectmultiple variable.
			    Fill out only for selectmultiples.
		*/

	syntax using/, id(varlist) variable(name) ///
					value(name) selectmultiple(name) oldvalue(name) ///
					[drop(name) insheet use excel import(string)]
	version 13
	
	di "Starting readreplace..."

qui {
	************************** check for fatal errors **************************
	cap isid `id'
	if _rc {
		di as error "variables `id' do not uniquely identify entries in the master."
		error 9
	}

	cap assert missing("`insheet'`use'") | missing("`insheet'`excel'") | missing("`use'`excel'")
	if _rc {
		di as error "options insheet, use, and excel may not be combined."
		error 184
	}
	
	foreach var in `variable' `value' `selectmultiple' `oldvalue' {
		cap confirm variable `var'
		if _rc == 0 {
			di "`var' already defined in master"
			error 110
		}
	}
	****** import corrections dataset and check for fatal errors ***************
	preserve
	if missing("`use'") & missing("`excel'") {
		local insheet insheet
		import delimited using "`using'", `import' clear
	}
	else if !missing("`excel'") {
		import excel using "`using'", `import' firstrow clear
	}
	else if !missing("`use'") {
		use "`using'", `import' clear
	}
	if _N == 0 {
		di "no replacements"
		exit
	}
	
	cap assert !missing(`id')
	if _rc {
		count if !missing(`id')
		di as error "missing id variable `id' for `r(N)' observations"
		error 416
	}
	
	foreach var in `id' `variable' `value' {
		confirm variable `var'
		cap confirm string variable `var'
		if !_rc {
			replace `var' = strtrim(`var')
		}
	}
	foreach var in `selectmultiple' `oldvalue' `drop' {
		confirm variable `var'
	}
	keep `id' `variable' `value' `selectmultiple' `oldvalue' `drop'
	* check to make sure that the "selectmultiple" box is chosen iff there is 
	* also a value in the oldvalue column
	tostring `selectmultiple', replace
	tostring `oldvalue', replace
	replace `oldvalue' = "" if `oldvalue' == "."
	replace `selectmultiple' = "" if `selectmultiple' == "."
	replace `selectmultiple' = "" if regexm(`selectmultiple', "N")
	replace `selectmultiple' = "" if regexm(`selectmultiple', "n")
	cap assert missing(`selectmultiple') if missing(`oldvalue')
	if _rc {
		count if !missing(`selectmultiple') & missing(`oldvalue')
		di as error "selectmultiple specified for `r(N)' corrections entries without oldvalue"
		error 498
	}
	
	***************** remove entries that should be dropped ********************
	tempfile selectmult allcorrections droplist
	save `allcorrections'
	if !missing("`drop'") {
		cap tostring `drop', replace
		replace `drop' = lower(strtrim(`drop'))
		save `allcorrections', replace
		keep if `drop' == "drop"
		keep `drop' `id'
		count
		if `r(N)' > 0 {
			save `droplist'
			restore 
			tempvar drop_merge
			merge 1:1 `id' using "`droplist'", gen(`drop_merge')
			drop if `drop_merge' != 1
			drop `drop_merge' `drop'
			preserve
		}
		use `allcorrections', clear
		drop if `drop' == "drop"
		save `allcorrections', replace
	}
	******************* split selectmultiples and other corrections ************
	keep if !missing(`selectmultiple')
	count 
	if `r(N)' > 0 {
		tostring `value', replace
		tostring `oldvalue', replace
		bysort `id': gen j = _n
		sum j
		local numloops = `r(max)'
		levelsof `variable'
		local correction_vars `r(levels)'
		reshape wide `variable' `value' `selectmultiple' `oldvalue', i(`id') j(j)
		save `selectmult'
		
		use `allcorrections', clear
		drop if !missing(`selectmultiple')
		save `allcorrections', replace
		
		******************* replace the selectmultiples ***********************
		restore
		tempvar mult_merge
		merge 1:1 `id' using "`selectmult'", gen(`mult_merge')
		count if `mult_merge' == 2
		if `r(N)' > 0 {
			noi di in red "`r(N)' corrections failed to merge"
			noi list `id' if `mult_merge' == 2
		}
		drop if `mult_merge' == 2
		drop `mult_merge'

		tempvar concat
		foreach var in `"`correction_vars'"' {
			tostring `var', replace
			split `var', generate(__`var')
			local stublist `r(varlist)'
			foreach stub in `stublist' {
				forval n = 1 / `numloops' {
					replace `stub' = `value'`n' if `variable'`n' == "`var'" ///
													& `stub' == `oldvalue'`n'
				}
			}
			egen `concat' = concat(`stublist'), punct(" ")
			forval n = 1 / `numloops' {
				replace `var' = `concat' if `variable'`n' == "`var'"
			}
			drop `concat' `stublist'
		}
		* drop the merged variables
		forval n = 1 / `numloops' {
			drop `variable'`n' `value'`n' `selectmultiple'`n' `oldvalue'`n'
		}
	}
	else {
		restore // if there were no selectmultiple variables
	}
	******************** add in the other corrections **************************
	preserve
	use `allcorrections', clear
	count 
	if `r(N)' > 0 {
		restore
		readreplace using `allcorrections', ///
			id(`id') variable(`variable') value(`value') use
	}
	else {
		restore
	}
	}
	noi di "Replacements complete."
	
	end
	
	

