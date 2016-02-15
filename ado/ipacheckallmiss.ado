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

	syntax,  saving(string) [modify replace]
	
	version 13.1

	/* Check that no variables have only missing values, where missing indicates
	   a skip. This could mean that the routing of the CAI survey program was
	   incorrectly programmed. */

	putexcel set "`saving'", sheet("all missing") `modify' `replace'
	putexcel A1=("Variable") B1=("Message")
	local i = 2
	quietly ds, has(type numeric)
	foreach var in `r(varlist)' {
		quietly count if `var' == .
		if r(N) == _N {
			display "`var' has only missing values."
			putexcel A`i'=("`var'") B`i'=("Variable `var' has only missing values. Consider checking survey programming and skip patterns.")
			local i = `i' + 1
		}
	}
	local i = 2
	quietly ds, has(type string)
	foreach var in `r(varlist)' {
		quietly count if `var' == ""
		if r(N) == _N {
			display "`var' has only missing values."
			putexcel A`i'=("`var'") B`i'=("`var' has only missing values. Consider checking survey programming and skip patterns.")
			local i = `i' + 1
		}
	}
	putexcel clear
	}
end
