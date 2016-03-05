/*----------------------------------------*
 |file:    ipacheckimport.ado             | 
 |project: high frequency checks          |
 |author:  christopher boyer              |
 |         innovations for poverty action |
 |date:    2016-02-13                     |
 *----------------------------------------*/

 // this program imports metadata from the input file

capture program drop ipacheckimport
program ipacheckimport, rclass
	di ""
	qui {

	syntax using/ , 
	
	preserve
	
	#delimit ;
	local sheets `""1. incomplete" "2. duplicates" "3. consent" "4. no miss" "5. follow up" "6. skip" "7. all miss" "8. constraints" "9. specify" "10. dates" "11. outliers" "enumdb" "researchdb""' ;
	#delimit cr
	
	*nois di `"`sheets'"'
	
	local wc: word count `sheets'
	*nois di "`wc'"

    foreach sheet in `sheets' {
		nois di `"`sheet'"'
    	// read the data from the input file
    	cap import excel using "`using'", sheet(`"`sheet'"') firstrow clear
		
		// return error if unable to read sheet
		if _rc {
			di as err "Input sheet `sheet' not found"
			error 198
		}
		
    	// collect the headers
    	unab allvars: _all
				
    	// drop missing rows
		local idvar : word 1 of `allvars'
    	drop if mi(`idvar')
		
    	// get current sheet number and row numbers
    	local n : list posof `"`sheet'"' in sheets		
		local rows = _N
		*nois di "position is `n' and there are `rows' rows"
    	foreach var of local allvars {
			*nois di "Variable is `var'"
			mata: st_global("`var'`n'", "")
    		forval i=1/`rows' {
    			mata: st_global("`var'`n'", `"${`var'`n'} `=`var'[`i']'"')
    		}
			*nois di "${`var'`n'}"
    	}
		
    }
	restore

	}

end
