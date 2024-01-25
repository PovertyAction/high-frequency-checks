*! version 4.0.2 28mar2023
*! Innovations for Poverty Action
* ipachecklogic: Flag logic violations in Survey

program ipachecklogic, rclass
	
	
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
		tempname tmv_var tmv_lab tmv_value tmv_logic_viol tmv_logic tmv_dups
		
		* set default insheet values
		if "`sheet'" == "" loc sheet "logic"
		
		* set default outsheet values
		if "`outsheet'" == "" loc outsheet "logic"
		
		* create inputsframe
		cap frame drop frm_inputs
		frames create frm_inputs
		
		frames frm_inputs {
			
			* import input data	
			import excel using "`using'", clear sheet("`sheet'") first case(l) allstr
			drop if missing(variable)

			* check that the assert column is not missing for any of the rows

			count if missing(assert) 
			if `r(N)' > 0 {
				di as err "Assert column is required for all rows"
				noi list variable assert if_condition if missing(assert)
				exit 459
			}
			

			* add "if" to beginning of valid if_conditions, gen new var
			replace if_condition = " if (" + if_condition + ")" if !missing(if_condition) 
			
			* save keep vars locals
			levelsof keep, loc(keep) clean
			
			* keep only relevant vars
			keep variable assert if_condition
			loc cnt `c(N)'
			
		}
		
		* expand and replace vars in input sheet
		forval i = 1/`cnt' {
			
			* check variable column
			frames frm_inputs: loc vars = variable[`i']
		
			unab vars: `vars'
			loc vars: list uniq vars

			loc varcount = wordcount("`vars'")

			if `varcount' > 1 {
				disp as err "Only one variable is allowed in each cell of the variable column."
				disp as err "Input sheet contains the following `varcount' variables on row `i'"
				disp as err "`vars'"
				exit 459
			}
			
			frames frm_inputs: replace variable = "`vars'" in `i'
			
		}

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
		
		* save data that is required
		save "`tmf_data'", replace


		* save an empty dataset for violations
		clear
		save "`tmf_viols'", emptyok

	
		* Run logic checks for each variable	
		forval i = 1/`cnt' {
		    
			frames frm_inputs: loc var 				= variable[`i']
			frames frm_inputs: loc assert 			= assert[`i']
			frames frm_inputs: loc if_condition 	= if_condition[`i']			
			
			use "`tmf_data'", clear

			gen `tmv_logic_viol' = !(`assert') `if_condition'	

			keep if `tmv_logic_viol' == 1

			if `c(N)' > 0 {
				
				* save value / convert to string if numeric var
				cap confirm numeric var `var'
				if !_rc {
					gen `tmv_value' = string(`var')
				}
				else gen `tmv_value' = `var'

				gen `tmv_var'	= "`var'"
				gen `tmv_lab'	= "`:var lab `var''"
				gen `tmv_logic' = cond(missing("`if_condition'"), "`assert'", "`assert' `if_condition'")

				append using "`tmf_viols'"
				save "`tmf_viols'", replace
			}

		}
		

		use "`tmf_viols'", clear

		if `c(N)' > 0 {
			
			keep `id' `enumerator' `date' `keep' `tmv_var' `tmv_lab' `tmv_value' `tmv_logic'

			* drop if already marked as ok
			if `checkok' {
			    frame frm_hfcokay: loc okaycnt `c(N)'
				forval i = 1/`okaycnt' {
				    loc vars = _frval(frm_hfcokay, _hfcokayvar, `i')
				    drop if `id' == _frval(frm_hfcokay, `id', `i') & (regexm("`vars'", "^" + `tmv_var' + "/") | regexm("`vars'", "/" + `tmv_var' + "/"))
				}
			}
			
			if `c(N)' > 0 {
				* remove duplicates / for values that violate multiple logic conditions			
				duplicates drop `id' `enumerator' `tmv_var' `tmv_value', force
				
				* export logic violations
				
				if `c(N)' > 0 {
					keep `enumerator' `keep' `date' `id' `tmv_var' `tmv_lab' `tmv_value' `tmv_logic'
					order `enumerator' `keep' `date' `id' `tmv_var' `tmv_lab' `tmv_value' `tmv_logic'
					
					foreach var of varlist _all {
						lab var `var' "`var'"
						
						lab var `tmv_var'		"variable" 
						lab var `tmv_lab'		"label"
						lab var `tmv_value' 	"value"
						lab var `tmv_logic'		"logic"
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
		
		return local N_logic = `c(N)'
		
		if `c(N)' > 0 {
			tab `tmv_var'
			return local N_vars = `r(r)'
		}
		else return local N_vars = 0
	}
	
end
