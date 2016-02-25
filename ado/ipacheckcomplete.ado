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

	syntax varlist(max=1),  saving(string) ivalue(integer) id(varlist) enumerator(varlist) [sheetmodify sheetreplace]
	
	version 13.1
	 
	 /* Check that all interviews were completed.
	    Example: If an interview has no end time, the enumerator may have stopped
	    midway through the interview, or may never have started it. */

	// define temporary variables 
	tempfile tmp 

	// define temporary file
	file open myfile using `tmp', text write replace
	file write myfile "id,enumerator,variable,label,value,message" _n 
	
	// preserve data set
	preserve
		cap assert `varlist' != `ivalue'
		if _rc {
			generate incomplete = `varlist' == `ivalue'
			keep if incomplete
			local nincomplete = _N
			forval i = 1/`nincomplete' {
				local message "Interview is marked as incomplete."
				local value = `varlist'[`i']
				local varl : variable label `varlist'
				file write myfile (`varlist'[`i']) _char(44) (`enumerator'[`i']) _char(44) ("`varlist'") _char(44) ("`varl'") _char(44) (`value') _char(44) ("`message'") _n
			}
		    file close myfile
			import delimited using `tmp', clear
			g notes = ""
			g drop = ""
			g newvalue = ""
			export excel using `saving' , sheet("1. incomplete") sheetreplace firstrow(variables) nolabel
		} 
		else {
			local nincomplete = 0
		    file write myfile ("") _char(44) ("") _char(44) ("") _char(44) ("") _char(44) ("") _char(44) ("") _n
			file close myfile
			import delimited using `tmp', clear
			g notes = ""
			g drop = ""
			g newvalue = ""
			export excel using `saving' , sheet("1. incomplete") sheetreplace firstrow(variables) nolabel
		}
	restore
	}
	di "  Found `nincomplete' total incomplete interviews."
	return scalar nincomplete = `nincomplete'
end
