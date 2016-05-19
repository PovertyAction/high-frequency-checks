/*----------------------------------------*
 |file:    ipacheckcomplete.ado           | 
 |project: high frequency checks          |
 |author:  christopher boyer              |
 |         matthew bombyk                 |
 |         innovations for poverty action |
 |date:    2016-02-13                     |
 *----------------------------------------*/

 // this program checks that all interviews are complete

capture program drop ipacheckcomplete
program ipacheckcomplete, rclass
	di ""
	di "HFC 1 => Checking that all interviews are complete..."
	qui {

	syntax varlist,  saving(string) complete(numlist) id(varname) enumerator(varname) [sheetmodify sheetreplace]
	
	version 13.1
	 
	 /* Check that all interviews were completed.
	    Example: If an interview has no end time, the enumerator may have stopped
	    midway through the interview, or may never have started it. */

	// define temporary variables 
	tempfile tmp org
	save `org', replace

	// define temporary file
	file open myfile using `tmp', text write replace
	file write myfile "id,enumerator,variable,label,value,message" _n 
	
	// define locals
	local nincomplete = 0
	local i = 1

	// loop through varlist and capture the number of incomplete surveys 
	foreach var in `varlist' {
		local ival : word `i' of `complete'
		cap assert `var' == `ival'
		if _rc {
			generate _complete = `var' == `ival'
			count if _complete == 0
			sort _complete
			local num = `r(N)'
			forval j = 1/`num' {
				local message "Interview is marked as incomplete."
				local value = `var'[`j']
				local varl : variable label `var'
				file write myfile ("`=`id'[`j']'") _char(44) ("`=`enumerator'[`j']'") _char(44) ("`var'") _char(44) (`""`varl'""') _char(44) (`value') _char(44) ("`message'") _n
			}
			drop _complete
		}
		else {
			local num = 0
		}
		local nincomplete = `nincomplete' + `num'
		local i = `i' + 1
	}

	// add a blank line if no incomplete encountered
	if `nincomplete' == 0 {
		file write myfile ("") _char(44) ("") _char(44) ("") _char(44) ("") _char(44) ("") _char(44) ("") _n
	}

	// close tmp file
	file close myfile

	import delimited using `tmp', clear
	if `=_N' > 0 {
		g notes = ""
		g drop = ""
		g newvalue = ""	
		export excel using `saving' , sheet("1. incomplete") `sheetreplace' `sheetmodify' firstrow(variables) nolabel
	}
	
	use `org', clear
	}
	// display stats and return 
	di "  Found `nincomplete' total incomplete interviews."
	return scalar nincomplete = `nincomplete'
end
