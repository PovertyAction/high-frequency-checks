*! version 4.0.0 11may2022
*! Innovations for Poverty Action
* ipacheckspecifyrecode: Recode other specify

program define ipacheckspecifyrecode, rclass
	
	#d;
	syntax using/, 
			[SHeet(string)]
			id(varname)
			[KEEP(varlist)]
			[LOGFile(string)]
			[LOGSheet(string)]
			[SHEETMODify SHEETREPlace]
			[NOLabel]
		;
	#d cr
	
	version 17 

	qui {
	    
		preserve
		
		tempvar tmv_modified tmv_oldval tmv_newval tmv_oldval_lab tmv_newval_lab
		
		tempfile tmf_main_data tmf_recodelog
		
		save "`tmf_main_data'", replace
		
		clear
		save "`tmf_recodelog'", emptyok
				
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
		
		* Clean data and check for errors
		keep if !missing(parent) & !missing(child)
		
		loc recode_cnt `c(N)'
		if `recode_cnt' > 0 {
		    foreach var of varlist parent child match_type match_text recode_from {
			    cap confirm string var `var'
				if _rc == 7 {
					tostring `var', replace
				}
				
				cap assert !missing(`var')
				if _rc == 9 {
				    disp as err "`var' should never be missing"
					noi list if missing(`var')
					ex 9
				}
			}
			
			tostring new_label, replace	
			
			replace match_text = 	"^" + match_text if match_type == "begins with"
			replace match_text = 	match_text + "$" if match_type == "ends with" 
			
			cap frame drop frm_recode
			frame put *, into(frm_recode)
			
			use "`tmf_main_data'", clear
			
			* expand keepvars
			if "`keep'" ~= "" unab keep: `keep'
			
			gen `tmv_modified' 	= 0
			gen `tmv_oldval'   	= ""
			gen `tmv_newval'		= ""
			forval i = 1/`recode_cnt' {
				
				frame frm_recode {
				    loc pvars 	= parent[`i']
					loc cvars 	= child[`i']
					loc vfrom 	= recode_from[`i']
					loc vto		= recode_to[`i']
					loc mtype 	= match_type[`i']
					loc mtext 	= match_text[`i']
					loc nlab 	= new_label[`i']
				}
	
				unab pvars: `pvars'				
				unab cvars: `cvars'
				
				if wordcount("`pvars'") ~=  wordcount("`cvars'") {
					disp as err "number of vars specified in parent (`parent') does not" , 	///
								"does not match the number of vars specified in ", 			///
								"child (`child') on row `=`i'+1'"
								
					noi disp "{p}parent vars: `pvars'{p_end}"
					noi disp
					noi disp "{p}child vars: `cvars'{p_end}" 
					ex 198
				}
				
				loc p_cnt = wordcount("`pvars'")
				forval j = 1/`p_cnt' {
				    loc pvar = word("`pvars'", `j')
					loc cvar = word("`cvars'", `j')
					
					count if !missing(`cvar')
					if `r(N)' > 0 {
						replace `tmv_modified' = 0	
					    cap confirm string var `pvar'
						if !_rc {
							replace `tmv_oldval' = `pvar'
						    replace `pvar' = trim(itrim(`pvar'))
							replace `pvar' = "//" + subinstr(`pvar', " ", "//", .)   + "//"
							if "`mtype'" == "exact" {	
								replace `tmv_modified' = 1 if `cvar' == "`mtext'"
								replace `pvar' = subinstr(`pvar', "//`vfrom'//", "//`vto'//", 1) ///
									if `cvar' == "`mtext'"
							}
							else {
								replace `tmv_modified' = 1 if regexm(`cvar', "`mtext'")
								replace `pvar' = subinstr(`pvar', "//`vfrom'//", "//`vto'//", 1) ///
									if regexm(`cvar', "`mtext'")
							}
															
							replace `pvar' = subinstr(`pvar', "//", " ", .)	
							replace `tmv_newval' = `pvar'						
						}
						else {
							loc plab "`:val lab `pvar''"
							cap drop `tmv_oldval_lab'
							if "`plab'" ~= "" decode `pvar', gen(`tmv_oldval_lab')
							else gen `tmv_oldval_lab' = ""
							replace `tmv_oldval' = string(`pvar')
							if "`mtype'" == "exact" {
								replace `tmv_modified' = 1 if `cvar' == "`mtext'"
								recode `pvar' (`vfrom' = `vto') if `cvar' == "`mtext'"
							}
							else {
								replace `tmv_modified' = 1 if regexm(`cvar', "`mtext'")
								recode `pvar' (`vfrom' = `vto') if regexm(`cvar', "`mtext'")
							}
							
							if "`nlab'" ~= "" {
								loc n_vlab = "`:val label `pvar''"
								if "`n_vlab'" ~= "" {
									lab define `n_vlab' `vto' "`nlab'", modify
								}
							}
							
							cap drop `tmv_newval_lab'
							if "`plab'" ~= "" decode `pvar', gen(`tmv_newval_lab')
							else gen `tmv_newval_lab' = ""
							replace `tmv_newval' = string(`pvar')
						}
						
						count if `tmv_modified'
						if `r(N)' > 0 {
							cap frames drop frm_recodelog
							frames put `id' `keep' `tmv_oldval' `tmv_oldval_lab' `tmv_newval' `tmv_newval_lab' `pvar' `cvar' if `tmv_modified', into(frm_recodelog)
							replace `cvar' = "" if `tmv_modified'
							
							frame frm_recodelog {
								ren (`tmv_oldval' `tmv_oldval_lab' `tmv_newval' `tmv_newval_lab' `cvar') ///
									(recode_from recode_from_lab recode_to recode_to_lab child_value)
								gen parent 		= "`pvar'"
								gen parent_lab 	= "`:var lab `pvar''"
								gen child  		= "`cvar'"
								gen child_lab 	= "`:var lab child_value'"
								loc vallab 		"`:val lab `pvar''"
								drop `pvar'
								
								append using "`tmf_recodelog'"
								save "`tmf_recodelog'", replace
								
								loc recoded `c(N)'
							}
						}
					}
				}
			}
			
			if "`logfile'" ~= "" {
				use "`tmf_recodelog'", clear	
				
				if `c(N)' > 0 {
					order `id' `keep' parent parent_lab child child_lab child_value recode_from recode_from_lab recode_to recode_to_lab
				
					foreach var of varlist `id' `keep' child_value {
						lab var `var' "`var'"
					}
					foreach var of varlist parent child recode_from recode_to {
						lab var `var'_lab "`var' label"
					}
					
					if "`keep'" ~= "" ipalabels `id' `keep', `nolabel'
					
					export excel using "`logfile'", sheet("`logsheet'") first(varl) `sheetreplace' `sheetmodify'
					mata: colwidths("`logfile'", "`logsheet'")
					mata: setheader("`logfile'", "`logsheet'")
				}
			}
		}
		else {
			loc recoded `c(N)'
		}
		
		return local N_recoded = `recoded'
		
	}
end