/*----------------------------------------*
 |file:    ipacheckoutliers.ado           | 
 |project: high frequency checks          |
 |author:  christopher boyer              |
 |         matthew bombyk                 |
 |         innovations for poverty action |
 |date:    2016-02-13                     |
 *----------------------------------------*/

 // this program checks for outliers among unconstrained survey variables

capture program drop ipacheckoutliers
program ipacheckoutliers, rclass
	di ""
	di "HFC 11 => Checking that unconstrained variables have no outliers..."
	qui {

	syntax varlist, saving(string) id(varname) enumerator(varname) iqrmulti(numlist missingokay) [ sheetmodify sheetreplace ]
	
	version 13.1

	// check that all variables are numeric
	foreach var in `varlist' {
		cap confirm numeric variable `var'
		if _rc {
			di as err "Variable `var' is not numeric."
			error 198
		}
	}

	// set locals
	local noutliers = 0
	local i = 1
 	
	// set tempfile
	tempfile tmp
	
	// set output file
	file open myfile using `tmp', text write replace
	file write myfile "id,enumerator,variable,label,value,message" _n 

	foreach var in `varlist' {
		// get current value of iqr
		local iqrval : word `i' of `iqrmulti'
		
		// calculate iqr stats
		egen _iqr = iqr(`var')
		egen _q1 = pctile(`var'), p(25)
		egen _q3 = pctile(`var'), p(75)

		// calculate min/max 
		g _max = _q3 + `iqrval' * _iqr
		g _min = _q1 - `iqrval' * _iqr
		g _outlier = (`var' > _max | `var' < _min) & !mi(`var')

		// sort and count outliers
		gsort -_outlier
		count if _outlier == 1

		// loop through outliers and output them to file
		local n = `r(N)'
		forval j = 1/`n' {
			local value = `var'[`j']
			local min = _min[`j']
			local max = _max[`j']
			local varl : variable label `var'
			local message = "Potential outlier `value' in variable `var' (`iqrval' * IQR: `min' to `max')."
			file write myfile ("`=`id'[`j']'") _char(44) ("`=`enumerator'[`j']'") _char(44) ("`var'") _char(44) (`""`varl'""') _char(44) (`value') _char(44) ("`message'") _n
		}

		// update outlier count
		local noutliers = `noutliers' + `n'

		// alert user
		nois di "  Variable `var' has `n' potential outliers."

		// drop variables
		drop _iqr _q1 _q3 _min _max _outlier
	}

	// close the output file
	file close myfile	

	// export outlier list to excel
	preserve
	import delimited using `tmp', clear
	if `=_N' > 0 {
		g notes = ""
		g drop = ""
		g newvalue = ""	
		export excel using `saving' , sheet("11. outliers") `sheetreplace' `sheetmodify' firstrow(variables) nolabel
	}
	restore
	}

	// return scalars
	return scalar noutliers = `noutliers'

end
