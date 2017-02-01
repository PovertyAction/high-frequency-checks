*! version 1.0.1 Kelsey Larson 08jan2017
*! version 1.0.0 Christopher Boyer 04may2016

program ipacheckimport, rclass
	/* This program imports high frequency check inputs
	   as Stata globals from an excel spreadsheet. The 
	   checks are based on IPA's minimum checks for 
	   data quality assurance */
	version 13

	syntax using/ , [DOfile]
	
	di ""
	di "Reading `using'..."

	qui {
	preserve
	
	if mi("`dofile'") {
		#d ;	
		local sheets `""1. incomplete" "2. duplicates" "3. consent" "4. no miss" "5. follow up" "6. skip" "7. all miss" "8. constraints" "9. specify" "10. dates" "11. outliers" "enumdb" "researchdb""' ;
		#d cr
		
		* store number of sheets
		local wc: word count `sheets'

	    foreach sheet in `sheets' {
	    	* display sheet name to be read
			nois di `"`sheet'"'

	    	* read the data from the input file
	    	cap import excel using "`using'", sheet(`"`sheet'"') firstrow clear
			
			* return error if unable to read sheet
			if _rc {
				di as err "Input sheet `sheet' not found"
				error 198
			}
			
	    	* collect the headers
	    	unab colnames: _all
					
	    	* drop missing and/or incomplete rows
			local col1 : word 1 of `colnames'
	    	drop if mi(`col1')
			
	    	* get current sheet number
	    	local n : list posof `"`sheet'"' in sheets	

	    	* count number of rows
			local rows = _N

			* loop through columns
	    	foreach var of local colnames {
	    		* initialize Stata global
				mata: st_global("`var'`n'", "")

				* loop through rows
	    		forval i=1/`rows' {
    				* append entries to global list
    				mata: st_global("`var'`n'", `"${`var'`n'} `=`var'[`i']'"')

	    			* if the keep_variable column
	    			if inlist("`var'", "keep", "assert", "if_condition") {
	    				* add a semi-colon signifying the end of the line
	    				mata: st_global("`var'`n'", `"${`var'`n'}; "')
	    			}
					
					* if the variable column for the skip check, or variable or other_unique for duplicate check
					if ("`var'" == "variable" & `n' == 6) | (inlist("`var'", "variable", "other_unique") & `n' == 2) {
	    				* add a semi-colon signifying the end of the line
	    				mata: st_global("`var'`n'", `"${`var'`n'}; "')
					}
	    		}
	    	}
	    }
		restore
	}

	}

end
