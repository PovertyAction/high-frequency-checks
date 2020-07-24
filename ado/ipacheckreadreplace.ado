*! version 3.0.0 Innovations for Poverty Action 22oct2018

prog ipacheckreadreplace, rclass
	/* This program makes corrections to a database from a second database of 
		corrections. The corrections sheet should have the following columns:
			 - id: Specifies the uniqueid of the obs to be corrected
			 - variable: specifies the variable to be corrected
			 - value: specifies the current value of variable
			 - newvalue: specifies the new variable for variable
			 - action: specifies the action to take ie. drop, replace, okay
		options:
			 - logusing: correction log file. .xlsx or .xls
			 - sheet: sheetname
	*/
	
	#d;
	syntax using/, 
		id(varname) 
		VARiable(name) 
		VALue(name) 
		NEWVALue(name) 
		ACTion(name)
		COMMents(name)
		[LOGUSing(string) sheet(string)]
		;
	#d cr
	
	cap version 15.1 
	
	noi di
	di "applying corrections {hline}"

	qui {
		* check syntax
		isid `id'
			
		* confirm using data exist
		cap conf file "`using'"
		if _rc {
			#d;
			noi disp as err 
				"{p} file `using' not found. If the file is not in stata dataset (.dta)
					 Please ensure that you have included the appropraite file 
					 extension. File format allows are .xlsx, .xls and .csv 
				{p_end}"
				;
			#d cr
			ex 601
		}
		
		* temp files and vars
		tempfile 	_data 
			
		* import corrections dataset
		* save dataset
		* generate okay vars 
		gen _hfcokay 	= 0
		gen _hfcokayvar	= ""
		
		label var _hfcokay 		"Generated During HFC: 1 if HFC violation was marked as okay"
		label var _hfcokayvar 	"Generated During HFC: Contains variables marked as okay"
		
		save "`_data'"
		
		* Get file extension
		loc ext = substr("`using'", -(strpos(reverse("`using'"), ".")), .)
		* if extension is valid, import data
		if "`ext'" == ".xlsx" | "`ext'" == ".xls" | "`ext'" == ".xlsm" {
			if "`sheet'" ~= "" import exc using "`using'", sheet("`sheet'") firstrow clear
			else import exc using "`using'", firstrow clear
		}
		
		else if "`ext'" == ".csv" {
			import delim using "`using'", clear
		}
		else if "`ext'" == "" {
			di as err "Specify file extension for replacement file ie..xlsx, .xls, .csv"
			ex 609 
		}
		else {
			di as err "file type `ext' not allowed. Use .xlsx, .xls, .xlsm or .csv file"
			ex 609 
		}
		
		* Clean data and check for fatal errors
		keep if !missing(`id')
		tostring action, replace
		replace action = itrim(trim(lower(action)))
		gen row = _n + 1
				
		* End program if there are no replacements
		if `=_N' == 0 {
			noi disp "{red}No observations in replacement file. Skipping readreplace ..."
			use "`_data'", clear
			ex
		}
		
		* If replacement file contains data
		* Check for fatal errors in replacement data
		* Check that id, variable, value, comments do not have missing data
		foreach var of varlist `id' `variable' `action' {
			cap assert !missing(`var')
			if _rc == 9 {
				di as err "The following row(s) in replacement sheet have missing values for `var'"
				noi list row `var' if missing(`var')
				use "`_data'", clear
				ex 9
			}
		}
		
		* check action contains only values okay, replace, drop
		cap assert inlist(action, "okay", "replace", "drop")
		if _rc == 9 {
			di as err "{p} The following row(s) in replacement sheet have invalid values for column `action'. Expected Values are okay, replace, drop {p_end}"
			noi list row action if !inlist(action, "okay", "replace", "drop")
			use "`_data'", clear
			ex 9
		}
				
		* Save all values in locals
		loc rep_count `=_N'
		if `rep_count' > 0 {
			foreach var of varlist `id' `variable' `value' `newvalue' `action' `comments'{
				forval i = 1/`rep_count' {
					loc `var'_`i' = `var'[`i']
				}
			}
			
			* display header
			noi disp "Applying `rep_count' corrections ... "
			
			if "`logusing'" ~= "" putexcel set "`logusing'", sh("log") replace
			if "`logusing'" ~= "" & `c(version)' >= 14.0 {
				putexcel A1:G1 = ("REPLACEMENTS LOG"), hcenter merge bold font(calibri, 12) border(bottom, double)
				putexcel A2 = ("`id'") 		///
					 B2 = ("`variable'") 	///
					 C2 = ("`value'") 		///
					 D2 = ("`newvalue'")	///
					 E2 = ("`action'")		///
					 F2 = ("`comments'")	///
					 G2 = ("Status")		///
					 , bold border(bottom)
			}
			else {
				putexcel A1 = ("REPLACEMENTS LOG") ///
					 A2 = ("`id'") ///
					 B2 = ("`variable'") ///
					 C2 = ("`value'") ///
					 D2 = ("`newvalue'") ///
					 E2 = ("`action'")	///
					 F2 = ("`comments'") ///
					 G2 = ("Status")
			}
					
		}
		
		* Display message if no changes are required
		else {
			noi di "No Observations in replacement file. Skipping ipacheckreadreplace ..."
		}
		
		* import main dataset and begin replacements
		use "`_data'", clear
		
		* check if id var is str or numeric
		cap conf str var `id'
		if _rc == 7 loc numid 1
		else loc numid 0

		* Make Changes
		forval i = 1/`rep_count' {
			if `numid' == 0 {
				* confirm obs
				count if `id' == "``id'_`i''"
				if `r(N)' > 0 {
					cap conf str var ``variable'_`i''
					if _rc == 7 {
						loc numvar 1
						cap confirm float var ``variable'_`i''
						if !_rc loc floatvar 1
						else 	loc floatvar 0
					}	
					else loc numvar 0
					* drop
					if "``action'_`i''" == "drop" {
						if `numvar' == 0 drop if `id' == "``id'_`i''" & ``variable'_`i'' == "``value'_`i''"
						else drop if `id' == "``id'_`i''" & ``variable'_`i'' == ``value'_`i''
						* confirm drop
						count if `id' == "``id'_`i''"
						if `r(N)' == 0 loc status "Successful"
						else loc status "Failed"
					}	
					* Replace
					if "``action'_`i''" == "replace" {
						if `numvar' == 0 replace ``variable'_`i'' = "``newvalue'_`i''" if `id' == "``id'_`i''" & ``variable'_`i'' == "``value'_`i''"
						else replace ``variable'_`i'' = ``newvalue'_`i'' if `id' == "``id'_`i''" & ``variable'_`i'' == ``value'_`i''
						* confirm replace
						if `numvar' == 0 count if `id' == "``id'_`i''" & ``variable'_`i'' == "``newvalue'_`i''"
						else if `floatvar' == 0 count if `id' == "``id'_`i''" & ``variable'_`i'' == ``newvalue'_`i''
						else count if `id' == "``id'_`i''" & ``variable'_`i'' == float(``newvalue'_`i'')
						if `r(N)' == 0 loc status "Failed"
						else loc status = "Successful"
					}
					* Okay
					if "``action'_`i''" == "okay" {
						if `numvar' == 0 replace _hfcokay = 1 if `id' == "``id'_`i''" & ``variable'_`i'' == "``value'_`i''"
						else if `floatvar' == 0 replace _hfcokay = 1 if `id' == "``id'_`i''" & ``variable'_`i'' == ``value'_`i''
						else replace _hfcokay = 1 if `id' == "``id'_`i''" & ``variable'_`i'' == float(``value'_`i'')
						* confirm okay
						if `numvar' == 0 count if `id' == "``id'_`i''" & ``variable'_`i'' == "``value'_`i''" & _hfcokay == 1
						else if `floatvar' == 0 count if `id' == "``id'_`i''" & ``variable'_`i'' == ``value'_`i'' & _hfcokay == 1
						else count if `id' == "``id'_`i''" & ``variable'_`i'' == float(``value'_`i'') & _hfcokay == 1
						if `r(N)' == 0 {
							loc status "Failed"
						}
						else {
							loc status = "Successful"
							if `numvar' == 0 replace _hfcokayvar = _hfcokayvar + "``variable'_`i''" if "``id'_`i''" & ``variable'_`i'' == "``value'_`i''"
							else replace _hfcokayvar = _hfcokayvar + "``variable'_`i''" if `id' == "``id'_`i''" & ``variable'_`i'' == ``value'_`i''
						}
					
					}		
				}
				* display error if id is not found
				else {
					noi di `trigg'
					di as err "Value ``id'_`i'' not valid for ID variable `id'"
					ex 9
				}
			}
			* IF id is numeric
			else {
				* confirm obs
				count if `id' == ``id'_`i''
				if `r(N)' > 0 {
					cap conf str var ``variable'_`i''
					if _rc == 7 loc numvar 1
					else loc numvar 0
					* drop
					if "``action'_`i''" == "drop" {
						if `numvar' == 0 drop if `id' == ``id'_`i'' & ``variable'_`i'' == "``value'_`i''"
						else drop if `id' == ``id'_`i'' & ``variable'_`i'' == ``value'_`i''
						* confirm drop
						count if `id' == ``id'_`i''
						if `r(N)' == 0 loc status "Successful"
						else loc status "Failed"
					}	
					* Replace
					if "``action'_`i''" == "replace" {
						if `numvar' == 0 replace ``variable'_`i'' = "``newvalue'_`i''" if `id' == ``id'_`i'' & ``variable'_`i'' == "``value'_`i''"
						else replace ``variable'_`i'' = ``newvalue'_`i'' if `id' == ``id'_`i'' & ``variable'_`i'' == ``value'_`i''
						* confirm replace
						if `numvar' == 0 count if `id' == ``id'_`i'' & ``variable'_`i'' == "``newvalue'_`i''"
						else count if `id' == ``id'_`i'' & ``variable'_`i'' == ``newvalue'_`i''
						if `r(N)' == 0 loc status "Failed"
						else loc status = "Successful"
					}
					* Okay
					if "``action'_`i''" == "okay" {
						if `numvar' == 0 replace _hfcokay = 1 if `id' == ``id'_`i'' & ``variable'_`i'' == "``value'_`i''"
						else replace _hfcokay = 1 if `id' == ``id'_`i'' & ``variable'_`i'' == ``value'_`i''
						* confirm okay
						if `numvar' == 0 count if `id' == ``id'_`i'' & ``variable'_`i'' == "``value'_`i''" & _hfcokay == 1
						else count if `id' == ``id'_`i'' & ``variable'_`i'' == ``value'_`i'' & _hfcokay == 1
						if `r(N)' == 0 {
							loc status "Failed"
						}
						else {
							loc status = "Successful"
							if `numvar' == 0 replace _hfcokayvar = _hfcokayvar + "``variable'_`i''" if ``id'_`i'' & ``variable'_`i'' == "``value'_`i''"
							else replace _hfcokayvar = _hfcokayvar + "``variable'_`i''" if `id' == ``id'_`i'' & ``variable'_`i'' == ``value'_`i''
						}
					
					}
				}
				* display error if id is not found
				else {
					di as err "Value ``id'_`i'' not valid for ID variable `id'"
					ex 9
				}				
			}
			
			* Show result
			noi disp
			noi disp "{ul:`id': ``id'_`i''}"
			noi disp "Variable: ``variable'_`i''"
			noi disp "Value   : ``value'_`i''"
			noi disp "Action  : ``action'_`i''"
			noi disp "Comments: ``comments'_`i''"
			if "`status'" == "Successful" {
				noi disp "Status  : Successful"
				loc color "black"
			}
			else {
				noi disp "Status  : {red:Failed}"
				loc color "red"
			}
				
			* Output status to excel
			if "`logusing'" ~= "" {
				loc row = `i' + 2
				putexcel A`row' = ("``id'_`i''") ///
					B`row' = ("``variable'_`i''") ///
					C`row' = ("``value'_`i''") ///
					D`row' = ("``newvalue'_`i''") ///
					E`row' = ("``action'_`i''")	///
					F`row' = ("``comments'_`i''")	///
					G`row' = ("`status'"), font(calibri, 11, `color')
					
					* reset color 
					loc color "black"
			}
		}
		if "`logusing'" ~= "" & `c(version)' >= 15.1 putexcel close
		
		replace _hfcokay = 0 if missing(_hfcokay)
		
		noi disp
		noi disp "Replacements complete."
		
		* returnlist
		return local repl = `rep_count'
	}
	
	noi di
	di "{hline}"
end
