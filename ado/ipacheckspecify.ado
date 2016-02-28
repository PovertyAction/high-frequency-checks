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

	/* idea - could add check here for additional specify other variables
	   not included in the input file */

	// create temporary file for recording specify other values
	tempfile tmp
	file open myfile using `tmp', text write replace
	file write myfile "id,enumerator,variable,label,value,message" _n 

	preserve

	// initialize variable recording total number of other values specified
	local nother = 0

	// loop through other specify variables in varlist and find nonmissing values
	foreach var in `varlist' {
		cap confirm string variable `var'
		if !_rc {
			g nonmissing = `var' != ""
			gsort -nonmissing
			count if nonmissing
			local n = `r(N)'
			forval i = 1/`n' {
				local value = `var'[`i']
				local varl : variable label `var'
				local message "Other value specified. Check for recodes."
				file write myfile (`id'[`i']) _char(44) (`enumerator'[`i']) _char(44) ("`var'") _char(44) (`""`varl'""') _char(44) ("`value'") _char(44) ("`message'") _n
			}
			drop nonmissing
			noisily di "  Variable {cmd:`var'} has {cmd:`n'} other values specified."
			local nother = `nother' + `n'
		}
	}
	file close myfile

	// Export to excel
	import delimited using `tmp', clear
	g notes = ""
	g drop = ""
	g newvalue = ""	
	export excel using "`saving'", sheet("9. other") sheetreplace firstrow(var)
	
	restore
	}

	di ""
	di "  Found {cmd:`nother'} total specified values."
	return scalar nspecify = `nother'

end
