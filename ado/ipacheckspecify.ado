/*----------------------------------------*
 |file:    ipacheckspecify.ado            | 
 |project: high frequency checks          |
 |author:  christopher boyer              |
 |         matthew bombyk                 |
 |         innovations for poverty action |
 |date:    2016-02-13                     |
 *----------------------------------------*/

 // this program checks specify other variables

capture program drop ipacheckspecify
program ipacheckspecify, rclass
	di ""
	di "HFC 9 => Checking specify other variables for misscodes and new categories..."
	qui {

	syntax varlist(min=1),  id(name) saving(string) enumerator(name) [sheetmodify sheetreplace]
	
	version 13.1
	foreach var in `varlist' {
		preserve
			keep `id' `enumerator' `var'
			keep if `var' != ""
			local varl : variable label `var'
			g message = ""
			g label = "`varl'"
			g variable = "`var'"
			g notes = ""
			g drop = ""
			g newvalue = ""
			ren `var' value
			order `id' `enumerator' variable label value notes drop newvalue
			file write myfile (`id'[`i']) _char(44) (`enumerator'[`i']) _char(44) ("`var'") _char(44) ("`varl'") _char(44) (`value') _char(44) ("`message'") _n

		restore
	}
	export excel using "`using'", sheet("9. other") sheetreplace firstrow(var)

	}
end
