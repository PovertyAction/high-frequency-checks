/*----------------------------------------*
 |file:    ipachecknomiss.ado             |
 |project: high frequency checks          |
 |author:  christopher boyer              |
 |         matthew bombyk                 |
 |         innovations for poverty action |
 |date:    2016-02-13                     |
 *----------------------------------------*/

 // this program checks that certain critical variables have no missing values

capture program drop ipachecknomiss
program ipachecknomiss, rclass
	di ""
	di "HFC 4 => Checking that certain critical variables have no missing values..."
	qui {

	syntax varlist, saving(string) id(name) enumerator(name) [sheetmodify sheetreplace]
	
	tempfile tmp

	file open myfile using `tmp', text write replace
	file write myfile "id,enumerator,variable,label,value,message" _n 

	version 13.1

	/* Check that certain variables have no missing values, where missing
	   indicates a skip.
	    - Examples: The unique ID, name, other identifying information, survey date
	   and time variables, the consent confirmation variable.
	    - Example: A variable at the start of a section often should never be
	   missing. */

	sort `id'
	local nmiss = 0
	local missvar = 0

	// For simplicity, we'll check numeric and string variables separately.

	// numeric variables
	ds `varlist', has(type numeric)
	foreach var in `r(varlist)' {
		local npvar = 0
		forval i = 1/`=_N' {
			local value = `var'[`i']
			if `value' == . {
				local message = "Interview is missing value of `var'."
				local nmiss = `nmiss' + 1
				local npvar = `npvar' + 1
				file write myfile (`id'[`i']) _char(44) (`enumerator'[`i']) _char(44) ("`var'") _char(44) ("`varl'") _char(44) (`value') _char(44) ("`message'") _n
			}
		}
		noisily di "  Variable `var' has `npvar' missing values"
		if `npvar' > 0 { 
			local missvar = `missvar' + 1 
		}
	}

	// string variables
	ds `varlist', has(type string)
	foreach var in `r(varlist)' {
		local npvar = 0
		forval i = 1/`=_N' {
			local value = `"`var'[`i']"'
			if `value' == "" {
				local message = "Interview is missing value of `var'."
				local nmiss = `nmiss' + 1
				local npvar = `npvar' + 1
				file write myfile (`id'[`i']) _char(44) (`enumerator'[`i']) _char(44) ("`var'") _char(44) ("`varl'") _char(44) (`value') _char(44) ("`message'") _n
			}
		}
		noisily di "  Variable `var' has `npvar' missing values"
		if `npvar' > 0 { 
			local missvar = `missvar' + 1 
		}
	}

	file close myfile

	preserve
	import delimited using `tmp', clear
	g notes = ""
	g drop = ""
	g newvalue = ""
	export excel using `saving', firstrow(var) sheet("4. no miss") `sheetmodify' `sheetreplace'
	restore
	}
	return scalar nmiss = `nmiss'
	return scalar missvar = `missvar'
	di ""
	di "  Found `nmiss' total missing values among `missvar' variables."
end
