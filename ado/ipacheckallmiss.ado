/*----------------------------------------*
 |file:    ipacheckallmiss.ado            | 
 |project: high frequency checks          |
 |author:  christopher boyer              |
 |         matthew bombyk                 |
 |         innovations for poverty action |
 |date:    2016-02-13                     |
 *----------------------------------------*/

 // this program checks that all interviews are complete

capture program drop ipacheckallmiss
program ipacheckallmiss, rclass
	di ""
	di "HFC 7 => Checking that no variables have only missing values..."
	qui {

	syntax,  id(varlist) enumerator(varlist) saving(string) [sheetmodify sheetreplace]
	
	version 13.1
	
	preserve
	
	/* Check that no variables have only missing values, where missing indicates
	   a skip. This could mean that the routing of the CAI survey program was
	   incorrectly programmed. */
	
	// create temporary file for recording specify other values
	tempfile tmp
	file open myfile using `tmp', text write replace
	file write myfile "id,enumerator,variable,label,value,message" _n 

	local i = 0
	
	// check numeric variables
	ds, has(type numeric)
	foreach var in `r(varlist)' {
		count if `var' == .
		if r(N) == _N {
			nois display "  Variable `var' has only missing values."
			local varl : variable label `var'
			local message "  Variable `var' has only missing values. Consider checking survey programming and skip patterns."
			file write myfile ("") _char(44) ("") _char(44) ("`var'") _char(44) ("`varl'") _char(44) ("") _char(44) ("`message'") _n
			local i = `i' + 1
		}
	}

    // check string variables
	ds, has(type string)
	foreach var in `r(varlist)' {
		count if `var' == ""
		if r(N) == _N {
			nois display "  Variable `var' has only missing values."
			local varl : variable label `var'
			local message "  Variable `var' has only missing values. Consider checking survey programming and skip patterns."
			file write myfile ("") _char(44) ("") _char(44) ("`var'") _char(44) ("`varl'") _char(44) ("") _char(44) ("`message'") _n
			local i = `i' + 1
		}
	}
	
	file close myfile
	
	import delimited using `tmp', clear
	g notes = ""
	g drop = ""
	g newvalue = ""	
	export excel using "`saving'", sheet("7. all missing") `sheetreplace' `sheetmodify' firstrow(var)
	
	}
	di ""
	di "  Found `i' variables with all missing values."
	return scalar nallmiss = `i'
end
