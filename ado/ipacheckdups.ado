/*----------------------------------------*
 |file:    ipacheckdups.ado               | 
 |project: high frequency checks          |
 |author:  christopher boyer              |
 |         matthew bombyk                 |
 |         innovations for poverty action |
 |date:    2016-02-13                     |
 *----------------------------------------*/

 // this program checks that all interviews are complete

capture program drop ipacheckdups
program ipacheckdups, rclass
	di ""
	di ""
	qui {

	syntax varlist, saving(string) enumerator(varlist) [uniquevars(varlist) sheetmodify sheetreplace]
	
	version 13.1
	
	local var `varlist'
	
	// define temporary variables 
	tempfile tmp orig
	tempvar dup1 dup2

	// preserve data set
	save `orig'

	// define temporary file
	file open myfile using `tmp', text write replace
	file write myfile "id,enumerator,variable,label,value,message" _n 

	// tag duplicates of id variable 
	duplicates tag `var', gen(`dup1')

	// sort data set
	if "`var'" != "" {
		sort `var'
	}
	
	// if there are any duplicates
	cap assert `dup1' == 0 
	if _rc {

		// count the duplicates for id var
		count if `dup1' != 0
		local ndups1 = `r(N)'

		if "`uniquevars'" != "" {
		
			/* if specified, tag any duplicates for the id and a combination
			   of other variables that should uniquely identify the data set.
			   Example - data set in memory has multiple interviews with 
			   same subject and id + date uniquely identify data. */
			duplicates tag `var' `uniquevars', gen(`dup2')

			// if there are still duplicates
			cap assert (`dup2' == 0) | (`dup2' == `dup1')
			
			if _rc {
				// count the duplicates
				count if `dup2' != 0
				local ndups2 = `r(N)'

				// alert the user
				nois di "  Variable `var' has `ndups1' duplicate observations."
				nois di "  The variable combination `var' `uniquevars' has `ndups2' duplicate observations"

				// keep the modified duplicate list
				keep if `dup2' != 0
				
				// record the duplicate 
				/* note -this still needs to be edited so that the excel output 
				   makes sense for duplicates with multiple id variables." */
				forval i = 1 / `=_N' {
					local value "`=`var'[`i']'"
					local varl : variable label `var'
					local message = "Duplicate observation for `var' `value'"
					file write myfile ("`=`var'[`i']'") _char(44) (`enumerator'[`i']) _char(44) ("`var'") _char(44) ("`varl'") _char(44) ("`value'") _char(44) ("`message'") _n
				}
				
				// close the file
				file close myfile
				
				// export to excel
				import delimited using `tmp', clear
				g notes = ""
				g drop = ""
				g newvalue = ""
				export excel using `saving', firstrow(var) sheet("2. duplicates") `sheetmodify' `sheetreplace'
			}
			else {
				// alert the user
				nois di "  No duplicates found for ID combination `var' `uniquevars'."
				
				// close the file
				file close myfile
			}
		}
		else {
		
			// keep the id variable duplicates
			keep if `dup1' != 0
			
			// alert the user
			nois di "  Variable `var' has `ndups1' duplicate observations."
			
			// record the duplicate observations
			forval i = 1 / `=_N' {
				local value "`=`var'[`i']'"
				local varl : variable label `var'
				local message = "Duplicate observation for `var' `value'"
				file write myfile ("`=`var'[`i']'") _char(44) (`enumerator'[`i']) _char(44) ("`var'") _char(44) ("`varl'") _char(44) ("`value'") _char(44) ("`message'") _n
			
			}
			
			// close the file
			file close myfile
			
			// export to excel
			import delimited using `tmp', clear
			g notes = ""
			g drop = ""
			g newvalue = ""
			export excel using `saving', firstrow(var) sheet("2. duplicates") `sheetmodify' `sheetreplace'
		}
	}
	else {
		// alert the user
		nois di "  No duplicates found for ID variable `var'."
		
		// close the file
		file close myfile
	}
	
	// restore original data set
	use `orig', clear
	}

end
