/*----------------------------------------*
 |file:    ipacheckconsent.ado            | 
 |project: high frequency checks          |
 |author:  christopher boyer              |
 |         matthew bombyk                 |
 |         innovations for poverty action |
 |date:    2016-02-13                     |
 *----------------------------------------*/

 // this program checks that all interviews have consent

capture program drop ipacheckconsent
program ipacheckconsent, rclass
	di ""
	di "HFC 3 => Checking that all interviews have consent..."
	qui {

	syntax varlist,  saving(string) consentvalue(numlist) id(varname) enumerator(varname) [sheetmodify sheetreplace]
	
	version 13.1
	 
	 /* Check that all interviews have consent.... */

	// preserve data set
	preserve

	// define temporary variables 
	tempfile tmp 

	// define temporary file
	file open myfile using `tmp', text write replace
	file write myfile "id,enumerator,variable,label,value,message" _n 

	// define locals
	local numnoconsent = 0
	local i = 1

	// loop through varlist and capture the number of incomplete surveys 
	foreach var in `varlist' {
		local ival : word `i' of `consentvalue'
		cap assert `var' == `ival'
		if _rc {
			generate _consent = `var' == `ival'
			count if _consent == 0
			sort _consent
			local num = `r(N)'
			forval j = 1/`num' {
				local message "Interview does not have valid consent."
				local value = `var'[`j']
				local varl : variable label `var'
				file write myfile ("`=`id'[`j']'") _char(44) ("`=`enumerator'[`j']'") _char(44) ("`var'") _char(44) (`""`varl'""') _char(44) (`""`value'""') _char(44) ("`message'") _n
			}
			drop _consent
		}
		local numnoconsent = `numnoconsent' + `num'
		local i = `i' + 1
	}

	// add a blank line if no incomplete encountered
	if `numnoconsent' == 0 {
		file write myfile ("") _char(44) ("") _char(44) ("") _char(44) ("") _char(44) ("") _char(44) ("") _n
	}

	// close tmp file
	file close myfile

	// export to Excel
	import delimited using `tmp', clear
	g notes = ""
	g drop = ""
	g newvalue = ""
	export excel using `saving' , sheet("3. consent") `sheetreplace' `sheetmodify' firstrow(variables) nolabel

	restore
	}

	// display stats and return
	di "  Found `numnoconsent' interviews with no consent."
	return scalar noconsent = `numnoconsent'
end
