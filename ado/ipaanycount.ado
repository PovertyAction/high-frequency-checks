*! version 4.0.0 11may2022
*! Innovations for Poverty Action
* ipaanycount: Count occurances of numeric & string values in varlist

program define ipaanycount
	
	syntax varlist [if] [in], GENerate(name) [NUMval(numlist missingokay) STRval(string)]
	
	* tempvar
	tempvar tmv_gen_check touse
	
	* mark sample
	mark `touse' `if' `in'
	
	qui {
		*** check syntax ***
		if "`numval'`strval'" == "" {
			disp as err "must specify options numval() or strval()"
			ex 198
		}
		if "`numval'" ~= "" {
			foreach val of numlist `numval' {
				if "`val'" == "." {
					disp as err `"generic numeric missing value "." not allowed in numval()"'
					ex 198
				}
			}
		}
		if "`strval'" ~= "" {
			loc strval = trim(itrim("`strval'"))
		}

		* generate count variable
		gen `generate' = 0 if `touse'
		gen `tmv_gen_check' = 0 if `touse'
		foreach var of varlist `varlist' {
			cap confirm string var `var'
			if !_rc & "`strval'" ~= "" {
				foreach val in `strval' {
					 replace `tmv_gen_check' =  1 if 													///
												!`tmv_gen_check' 			  &							///
												(trim(itrim(`var')) == "`val'" | 						///
												regexm(trim(itrim(`var')), "^`val' | `val' | `val'$"))
				} 
			   
			}
			else if !missing("`numval'") {
				foreach val of numlist `numval' {
					replace `tmv_gen_check' = 	1 if ///
												!`tmv_gen_check' & ///
												`var' == `val'
				}
			}
			
			replace `generate' = `generate' + `tmv_gen_check' if `touse'
			replace `tmv_gen_check' = 0 if `touse'
		}
		
		drop `touse' `tmv_gen_check'
		
	}
	
end
