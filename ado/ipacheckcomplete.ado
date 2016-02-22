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
	preserve
		generate incomplete = `varlist' == `ivalue'
		keep if incomplete
		g message = "Interview is marked as incomplete."
		g notes = ""
		g drop = ""
		g newvalue = ""	
		cap local varl: variable label `varlist'
		*cap loc varl = subinstr(`"`varl'"',",","-",.)
		local nincomplete = _N
		g label = "`varl'"
		g variable = "`varlist'"
		g value = `ivalue'
		keep `id' `enumerator' variable label value message notes drop newvalue
		order `id' `enumerator' variable label value message notes drop newvalue
		export excel using `saving' , sheet("1. incomplete") sheetreplace firstrow(variables) nolabel
	restore
	}
	di "  Found `nincomplete' total incomplete interviews."
	return scalar nincomplete = `nincomplete'
end
