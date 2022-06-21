*! version 4.0.0 11may2022
*! Innovations for Poverty Action
* ipagettd: Convert datetime vars to %td

program define ipagettd
	
	syntax varlist
	
	tempvar tmv_date
	
	qui {
		foreach var of varlist `varlist' {
			* datevar: format datevar in %td format
			loc varformat = substr("`:format `var''", 1, 3)
			if lower("`varformat'") == "%tc"	{
				gen `tmv_date' = dofc(`var'), after(`var')
				format %td `tmv_date'
				lab var `tmv_date' "`:var lab `var''"
				drop `var'
				ren `tmv_date' `var'
			}
			else if lower("`varformat'") ~= "%td" {
				disp as err `"variable `varlist' is not a %td, %tc or %tC date/datetime variable"'
				if `=_N' > 5 loc limit = `=_N'
				else 		 loc limit = 5
				noi list `varlist' in 1/`limit'
			}
		}
	}
end