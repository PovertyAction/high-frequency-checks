*! version 4.0.5 25jan2024
*! Innovations for Poverty Action
* ipacheckoutliers: Flag constraints in numeric variables

program ipacheckconstraints, rclass
	
	
	version 17

	#d;
	syntax 	using/,
			[SHeet(string)]
        	OUTFile(string)
        	[OUTSheet(string)]  
			id(varname) 
        	ENUMerator(varname) 
        	date(varname) 
			[SHEETMODify SHEETREPlace] 
			[NOLABel]
		;	
	#d cr

	qui {
	    
		preserve
		
		tempfile tmf_data tmf_viols
		tempname tmv_var tmv_lab tmv_value tmv_hard_flag tmv_constraint tmv_dups
		
		* set default insheet values
		if "`sheet'" == "" loc sheet "constraints"
		
		* set default outsheet values
		if "`outsheet'" == "" loc outsheet "constraints"
		
		* create inputsframe
		cap frame drop frm_inputs
		frames create frm_inputs
		
		frames frm_inputs {
			
			save "`tmf_viols'", replace emptyok
			
			* import input data	
			import excel using "`using'", clear sheet("`sheet'") first case(l) allstr

			* check for duplicates in variable comlumn
			drop if missing(variable)
			cap isid variable
			if _rc == 459 {
				duplicates tag variable, gen (`tmv_dups')
				di as err "Duplicates found in inputs sheet:"
				noi list variable hard_min soft_min soft_max hard_max if dups
				exit 459 
			}
			
			* check that no column has all missing constraints condition
			egen _cons_check = rownonmiss(hard_min soft_min soft_max hard_max), strok
			count if !_cons_check
			if `r(N)' > 0 {
				di as err "The following rows in the inputs sheet have no constraints conditions:"
				noi list variable hard_min soft_min soft_max hard_max if !_cons_check
				exit 459 
			}
			
			* save keep vars locals
			levelsof keep, loc(keep) clean
			
			* keep only relevant vars
			keep variable hard_min soft_min soft_max hard_max
			loc cnt `=_N'
			
		}
		
		* local to keep list of variables in constraints
		loc cvars ""

		* expand and replace vars in input sheet
		forval i = 1/`cnt' {
			
			* check variable column
			frames frm_inputs: loc vars = variable[`i']
		
			unab vars: `vars'
			loc vars: list uniq vars
			
			foreach var of varlist `vars' {
				cap confirm numeric var `var', exact
				if _rc == 7 {
					dis as err "{p}variable `var' found where numeric variable is expected. Only numeric variables are allowed in constraints check{p_end}" 
					ex 7
				}
			}
			
			frames frm_inputs: replace variable = "`vars'" in `i'
			
			* check other columns
			foreach col in hard_min soft_min soft_max hard_max {
			    frames frm_inputs: loc val = `col'[`i']
				if !missing("`val'") {
				    cap confirm number `val'
					if _rc == 7 {
					    unab val: `val'
						loc val: list uniq val
						* check that expanded list match
						if wordcount("`vars'") > 1 | wordcount("`val'") > 1 {
						    if (wordcount("`vars'") ~= wordcount("`val'")) & wordcount("`val'") > 1 {
							    di as err "Number of variables in variable & `col' columns don't match after expansion:"
								di as err "variables column: `vars'"
								di as err "`col' column: `val'"
								exit 459 
							}
						}
						
						* check that all vars are numeric
						
						foreach valvar of varlist `val' {
						    cap confirm numeric var `valvar', exact
							if _rc == 7 {
							    dis as err "{p}variable `valvar' found where numeric variable is expected. Only numeric variables are allowed in constraints check{p_end}" 
								ex 7
							}
						}
						
						frames frm_inputs: replace `col' = "`val'" in `i'
						
						loc cvars "`cvars' `val'"
					}
				}
			}
			
		}
	
		* get a unique list if cvars
		if !missing("`cvars'") loc cvars: list uniq cvars
		
		* keep only relevant variables
		frames frm_inputs: levelsof variable, loc (vars) clean
		loc vars: list uniq vars

		* check for okay var. Add if missing
		cap confirm var _hfcokay
		if !_rc {
		    cap confirm var _hfcokayvar 
			if !_rc {
			    loc checkok 1
				cap frame drop frm_hfcokay
				frames put `id' _hfcokay _hfcokayvar if _hfcokay == 1, into(frm_hfcokay)
			}
			else loc checkok 0
		}
		else {
		    loc checkok 0
		}
		
		keep `vars' `cvars' `keep' `id' `enumerator' `date'
		
		* save data that is required
		save "`tmf_data'", replace

		
		* check constraints		
		forval i = 1/`cnt' {
		    
			frames frm_inputs: loc vars = variable[`i']
			
			* count the number of vars
			loc vars_cnt = wordcount("`vars'")
			
			forval j = 1/`vars_cnt' {
			    
				* loop through each var and apply constraint conditions
				loc var = word("`vars'", `j')
				loc k = 1
			
				foreach col in hard_min soft_min soft_max hard_max {
				    
					use `var' `cvars' `keep' `id' `enumerator' `date' using"`tmf_data'", clear
					
					frames frm_inputs: loc cval = `col'[`i']
					if "`cval'" ~= "" {
						cap confirm number `cval'
						loc rc `=_rc'
						if `rc' == 7 loc cval = cond(wordcount("`cval'")  == 1, "`cval'", word("`cval'", `j'))
						
						gen `col'_viol = cond(`k' <= float(2), `var' < float(`cval') & !missing(`var'),  ///
													   `var' > float(`cval') & !missing(`var'))
													   
						keep if `col'_viol
										
						gen `tmv_var' 		= "`var'"
						gen `tmv_lab' 		= "`:var lab `var''"
						gen `tmv_value' 		= `var'
						if !`rc' 			gen `tmv_constraint' 	= "`=subinstr("`col'", "_", " ", .)' is `cval'"	
						else 				gen `tmv_constraint' 	= "`=subinstr("`col'", "_", " ", .)' [`cval'] is " + string(`cval')	
						
						if `=_N' > 0 {
							append using "`tmf_viols'"
							save "`tmf_viols'", replace 
						}
						
					}
					
					loc ++k
					
				}
			}
		}
		

		use "`tmf_viols'", clear

		if `c(N)' > 0 {
			
			keep `id' `enumerator' `date' `keep' `tmv_var' `tmv_lab' `tmv_value' `tmv_constraint'
			
			* drop if already marked as ok
			if `checkok' {
			    frame frm_hfcokay: loc okaycnt `c(N)'
				forval i = 1/`okaycnt' {
				    loc vars = _frval(frm_hfcokay, _hfcokayvar, `i')
				    drop if `id' == _frval(frm_hfcokay, `id', `i') & (regexm("`vars'", "^" + `tmv_var' + "/") | regexm("`vars'", "/" + `tmv_var' + "/"))
				}
			}
		
			if `c(N)' > 0 {
				
				* remove duplicates
				duplicates drop `id' `enumerator' `tmv_var' `tmv_value' `tmv_constraint', force
				
				gen `tmv_hard_flag' = regexm(`tmv_constraint', "^hard")
				duplicates tag `id' `enumerator' `tmv_var' `tmv_value', gen(`tmv_dups')
				gsort `id' `enumerator' `tmv_var' `tmv_value' -`tmv_hard_flag'
				
				duplicates drop `id' `enumerator' `tmv_var' `tmv_value', force
				
				* export constraint violations
				
				if `c(N)' > 0 {
					keep `enumerator' `keep' `date' `id' `tmv_var' `tmv_lab' `tmv_value' `tmv_constraint'
					order `enumerator' `keep' `date' `id' `tmv_var' `tmv_lab' `tmv_value' `tmv_constraint'
					
					foreach var of varlist _all {
						lab var `var' "`var'"
						
						lab var `tmv_var'			"variable" 
						lab var `tmv_lab'			"label"
						lab var `tmv_value' 		"value"
						lab var `tmv_constraint'	"constraint"
					}
					
					if "`keep'" ~= "" ipalabels `keep', `nolabel'
					ipalabels `id' `enumerator', `nolabel'
					
					sort `date'
					
					export excel using "`outfile'", first(varl) sheet("`outsheet'") `sheetreplace'

					cap mata: colwidths("`outfile'", "`outsheet'")
					cap mata: colformats("`outfile'", "`outsheet'", ("`date'"), "date_d_mon_yy")
					cap mata: setheader("`outfile'", "`outsheet'")
				}
			}
		}
		
		return local N_constraints = `c(N)'
		
		if `c(N)' > 0 {
			tab `tmv_var'
			return local N_vars = `r(r)'
		}
		else return local N_vars = 0
	}
	
end
