*! version 4.0.0 11may2022
*! Innovations for Poverty Action
* ipacheckcorrections: Make corrections to data

program define ipacheckcorrections, rclass
	
	#d;
	syntax using/, 
			[SHeet(string)]
			id(varname)
			[LOGFile(string)]
			[LOGSHeet(string)]
			[NOLabel]
			[ignore]
		;
	#d cr
	
	cap version 17 

	qui {
	    
		* preserve
		preserve
		
		tempvar tmv_status tmv_id_check
		
		tempfile tmf_main_data
		
		isid `id'
		
		* gen id format
		cap confirm string var `id'
		if !_rc {
			loc str_id 1
		}
		else {
			loc str_id 0
		}
		
		save "`tmf_main_data'", replace
		
		* Get file extension
		loc ext = substr("`using'", -(strpos(reverse("`using'"), ".")), .)
		* if extension is valid, import data
		if "`ext'" == ".xlsx" | "`ext'" == ".xls" | "`ext'" == ".xlsm" {
		    if "`sheet'" == "" {
			    disp as err "sheet option required with .xlsx, .xls or .xlsm files"
				ex 198
			}
			import excel using "`using'", sheet("`sheet'") firstrow clear
		}
		else if "`ext'" == ".csv" {
			import delim using "`using'", clear varnames(1)
		}
		else {
		    cap use "`using'", clear
			if _rc == 601 {
			    di as err "file `using' not found""
				ex 609 
			}
		}
		
		if "`logfile'" ~= "" & "`logsheet'" == "" {
		    disp as err "option logsheet required with option logfile"
			ex 198
		}
		
		* check that neccesary vars exist in repfile
		foreach var in variable value newvalue action {
			cap confirm var `var'
			if _rc == 111 {
				disp as err "{p}variable `var' not found in `using'{p_end}"
				ex 111
			}
		}
		
		* Clean data, check for errors and make replacements
		keep if !missing(`id')
		loc rep_cnt `c(N)'
		if `rep_cnt' > 0 {
		    cap confirm string var action
			if _rc == 7 {
			    tostring action, replace
				cap confirm string var action
				if _rc == 7 {
				    disp as err "'action' variable found where string variable expected"
					ex 7
				}
			}
		    
			replace action = itrim(trim(lower(action)))
			
			foreach var of varlist `id' variable action {
				cap assert !missing(`var')
				if _rc == 9 {
					di as err "The following row(s) in replacement sheet have missing values for `var'"
					gen row = _n + 1
					noi list row `var' if missing(`var')
					ex 9
				}
			}
			
			cap assert inlist(action, "okay", "replace", "drop")
			if _rc == 9 {
				di as err "Invalid values for column `action'. Expected Values are okay, replace, drop"
				noi list `_reprow' action if !inlist(action, "okay", "replace", "drop")
				ex 9
			}
			
			* check that id variable matches format of main dataset
			if `str_id' {
				cap confirm string var `id'
				if _rc == 7 {
					tostring `id', replace format(%100.0f)
				}
			}
			else {
				cap confirm numeric var `id'
				if _rc == 7 {
					destring `id', replace
					cap confirm numeric var `id'
					if _rc == 7 {
						disp as err "ID column (`id') in using file cannot be converted to numeric. Contains non-numeric chars at the following"
						gen `tmv_id_check' = trim(itrim(regexs(`id', "[0-9]+", "")))
						noi list `id' if length(`tmv_id_check') > 0
					}
				}
			}
			
			gen str12 `tmv_status' = ""
			cap frames drop frm_repfile
			frames put *, into(frm_repfile)
			
			use "`tmf_main_data'", clear
			
			* generate if they don't exist
			cap gen _hfcokay 	= 0
			cap gen _hfcokayvar	= "/"
	
			forval i = 1/`rep_cnt' {
				loc var 	= _frval(frm_repfile, variable, `i')
				loc val		= _frval(frm_repfile, value, `i') 
				
				cap confirm string var `var' 
				if !_rc {
					loc str_var 1
				}
				else {
					loc str_var 0
				}
			    
			    if `str_var' cap assert `var' == "`val'" if `id' == _frval(frm_repfile, `id', `i')
				else 		 cap assert `var' == `val' 	 if `id' == _frval(frm_repfile, `id', `i')
				if _rc == 9 {
					frame frm_repfile: replace `tmv_status' = "failed" in `i'
				}
				else {
				    
					cap assert `id' ~=  _frval(frm_repfile, `id', `i')
					if !_rc {
					    loc idval = _frval(frm_repfile, `id', `i')
					    disp as err "ID value `idval' not a valid id for id variable `id'"
						ex 198
					}
					
				    loc action_type = _frval(frm_repfile, action, `i')
				    if "`action_type'" == "okay" {
					    replace _hfcokay 	= 1 		if `id' == _frval(frm_repfile, `id', `i')
						replace _hfcokayvar = "`var'/"	if `id' == _frval(frm_repfile, `id', `i')
					}
					else if "`action_type'" == "replace" {
						loc newval	= _frval(frm_repfile, newvalue, `i') 
					    if `str_var' replace `var' = "`newval'" if `id' == _frval(frm_repfile, `id', `i')
						else		 replace `var' = `newval' 	if `id' == _frval(frm_repfile, `id', `i')
					}
					else {
					    drop if `id' == _frval(frm_repfile, `id', `i')
					}
					
					frame frm_repfile: replace `tmv_status' = "successful" in `i'
				}
			}
			
			save "`tmf_main_data'", replace
			
			frame frm_repfile {
			    
				count if `tmv_status' == "failed"
				loc failed_cnt = `r(N)'
				if `failed_cnt' > 0 {
				    disp as err "List of `r(N)' failed correction ... "
					noi list `id' variable value newvalue action if `tmv_status' == "failed"
					if "`ignore'" == "" ex 198
				}
				else {
				    loc failed_cnt 0
				}
				
				if "`logfile'" ~= "" {
					lab var `tmv_status' "status"
					ipalabels `id', `nolabel'
					export excel using "`logfile'", sheet("`logsheet'") sheetreplace first(varl)
					mata: colwidths("`logfile'", "`logsheet'")
					mata: setheader("`logfile'", "`logsheet'")
				}
			}
		}
		else {
		    noi disp "No observations in replacement file. Skipping ipacheckcorrections"
			loc failed_cnt 0
		}
		
		restore
		use "`tmf_main_data'", clear
		
		return loc N_obs 		= `rep_cnt'
		return loc N_succesful  = `rep_cnt' - `failed_cnt'
		return loc N_failed     = `failed_cnt'
		
	}
end
