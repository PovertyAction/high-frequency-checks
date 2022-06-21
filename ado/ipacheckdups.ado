*! version 4.0.0 11may2022
*! Innovations for Poverty Action
* ipacheckdups: check for duplicates in other variables

program ipacheckdups, rclass
	
	#d;
	syntax varlist, 
		id(varname) 
		ENUMerator(varname) 
		date(varname) 
		OUTFile(string) 
		[OUTSHeet(string)]
		[keep(varlist)]
		[SHEETMODify SHEETREPlace]
		[NOLabel]
		;
	#d cr

	qui {
	    
		preserve
				
		tempfile tmf_main_data
		
		tempvar tmv_dv_check tmv_dv_flag tmv_serial
		tempvar tmv_max_serial tmv_index tmv_variable tmv_label
	   
		* check that ID var is unique
		cap isid `id'
		if _rc == 459 {
		    disp as err "id() variable `id' does not uniquely identify the observations"
			exit 459
		}
		
		* set default outsheet
		if "`outsheet'" == "" loc outsheet "duplicates"
		
		* keep variables of interest
		keep `date' `varlist' `id' `enumerator' `date' `keep'
		
		ipagettd `date'
		
		* check for duplicates 
		gen `tmv_dv_check' = 0
		foreach var in `varlist' {
			duplicates tag `var' if !mi(`var'), gen(`tmv_dv_flag')
			replace `tmv_dv_check' = 1 if `tmv_dv_flag' & !mi(`tmv_dv_flag')
			drop `tmv_dv_flag'
		}
		
		* keep only observations with at least one duplicate
		drop if !`tmv_dv_check'
		
		if `c(N)' > 0 {
			* save variable information in locals
			loc i 1
			foreach var of varlist `varlist' {
				loc var`i' 		"`var'"
				loc varlab`i'		"`:var lab `var''"
				
				cap confirm numeric var `var'
				if !_rc {
					gen _v`i' 	= string(`var')
				}
				else gen _v`i' = `var'
				drop `var'
				
				loc ++i
			}
			
			loc vl_cnt = `i' - 1
			loc obs_cnt `c(N)'
			
			* reshape data to long
			expand `vl_cnt'
			bys `id': gen `tmv_index' = _n
			cap confirm string var `id'
			if !_rc {
				mata: ids = st_sdata(., "`id'")
				gen _v = ""
				forval i = 1/`obs_cnt' {
					mata: st_local("instanceid", ids[`i'])
					forval j = 1/`vl_cnt' {
						replace _v = _v`j' if `id' == "`instanceid'" & `tmv_index' == `j'
					}
				}
			}
			else {
				mata: ids = st_data(., "`id'")
				gen _v = ""
				forval i = 1/`obs_cnt' {
					mata: st_local("instanceid", ids[`i'])
					forval j = 1/`vl_cnt' {
						replace _v = _v`j' if `id' == `instanceid' & `tmv_index' == `j'
					}
				}
			}
			
			drop _v?*
			drop if missing(_v)
		
			gen `tmv_variable' = "", before(_v)
			gen `tmv_label' = "", after(_v)
			forval i = 1/`vl_cnt' {
				replace `tmv_variable' 	= "`var`i''" 	if `tmv_index' == `i'
				replace `tmv_label' 	= "`varlab`i''" if `tmv_index' == `i'
			}
			
			drop `tmv_index'
			sort `tmv_variable' _v `id'
			
			bys `tmv_variable' _v (`id')			: gen `tmv_serial' 		= _n
			bys `tmv_variable' _v (`tmv_serial')	: gen `tmv_max_serial' 	= _N
			
			* remove variable labels from all vars
			foreach var of varlist _all {
				lab var `var' ""
			}
			
			* label tmp vars
			foreach var in variable label serial {
				lab var `tmv_`var'' "`var'"
			}
			
			lab var _v "variable"
			
			* check for duplicates again and drop any non duplicate values
			duplicates tag `tmv_variable' _v, gen (`tmv_dv_flag')
			drop if !`tmv_dv_flag'
			drop `tmv_dv_flag'
			
			* get row numbers for seperator line
			cap drop frm_subset
			frame put `tmv_serial' `tmv_max_serial', into(frm_subset)
			frame frm_subset {
				gen _dp_row = _n + 1
				keep if `tmv_serial' == `tmv_max_serial'
				mata: rows = st_data(., st_varindex("_dp_row"))
			}
			frame drop frm_subset
			
			keep `tmv_serial' `date' `id' `enumerator' `tmv_variable' `tmv_label' _v `keep'
			order `tmv_serial' `date' `id' `enumerator' `tmv_variable' `tmv_label' _v `keep'
			
			if "`keep'" ~= "" ipalabels `keep', `nolabel'
			ipalabels `id' `enumerator', `nolabel'
						
			export excel using "`outfile'", sheet("`outsheet'") first(varl) `sheetmodify' `sheetreplace'
			mata: colwidths("`outfile'", "`outsheet'")
			mata: setheader("`outfile'", "`outsheet'")
			mata: addlines("`outfile'", "`outsheet'", rows, "thin")
			
			tab `tmv_variable'
			loc var_cnt `r(r)'
			loc obs_cnt `r(N)'
			
			noi disp "Found {cmd:`obs_cnt'} duplicates in `var_cnt' variable(s)."
		
		}
		else {
		    loc var_cnt 0
			loc obs_cnt 0
			
			noi disp "Found {cmd:0} duplicates."
		}
		
		return local N_obs = `obs_cnt'
		return local N_vars = `var_cnt'
	}
end 
