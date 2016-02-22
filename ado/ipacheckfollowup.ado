/*----------------------------------------*
 |file:    ipacheckfollowup.ado           | 
 |project: high frequency checks          |
 |author:  christopher boyer              |
 |         matthew bombyk                 |
 |         innovations for poverty action |
 |date:    2016-02-13                     |
 *----------------------------------------*/

 // this program checks id variables against the master tracking list 

capture program drop ipacheckfollowup
program ipacheckfollowup, rclass
	di ""
	di "HFC 5 => Checking that follow up variables match master tracking sheet..."
	qui {

	syntax varlist using/, id(varlist) enumerator(varlist) saving(string) [sheetmodify sheetreplace]
	
	version 13.1

	preserve 

	local master "`using'"

	// define temporary variables 
	tempfile tmp

    /* Check that a survey matches other records for its unique ID.
	   Example: For each ID, check that the name in the baseline data matches
	   the one in the master tracking list. */

	cfout `varlist' using `master', id(`id') lower nopunct  ///
	    saving(`tmp', replace variable("variable") masterval("current_value") ///
		  usingval("tracking_value") keepmaster(enumerator) properties(varlabel("label")))

	// record returned values
	local ncomp = `r(N)'
	local ndiscrep = `r(discrep)'
	local nonlym = `r(Nonlym)'
	local nonlyu = `r(Nonlyu)'

	// export to excel
	use `tmp', clear
	export excel using `saving', firstrow(var) sheet("5. follow up") `sheetmodify' `sheetreplace'

	restore
	}
	
	// alert the user 
	di "  Compared master and using on `ncomp' values."
	di "  Found `ndiscrep' discrepancies."
	di "  Found `nonlym' ids only in current data set."
	di "  Found `nonlyu' ids only in the master tracking sheet."
end

