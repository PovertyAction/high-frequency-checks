/*----------------------------------------*
 |file:    ipacheckskip.ado               |    
 |project: high frequency checks          |
 |author:  christopher boyer              |
 |         matthew bombyk                 |
 |         innovations for poverty action |
 |date:    2016-02-13                     |
 *----------------------------------------*/

 // this program checks skip patterns and logical constraints

capture program drop ipacheckskip
program ipacheckskip, rclass
	di ""
	di "HFC 6 => Checking skip patterns and survey logic..."
	qui {

	syntax varlist, assert(string) condition(string) saving(string) id(varname) enumerator(varname) [addvars(varlist) sheetmodify sheetreplace]
	
	version 13.0
	
	preserve
	
	tempfile tmp
	file open myfile using `tmp', text write replace
	file write myfile "id,enumerator,variable,label,value,message" _n 
	
	local i = 1
	local nviol = 0
	foreach var in `varlist' {
		local cond1: word `i' of `assert'
		local cond2: word `i' of `condition'

		if "`condition'" == "" {
			cap assert `cond1'
			if _rc {
				g _fine = `cond1'
			}
			else {
				local i = `i' + 1
				continue
			}
		} 
		else {
			cap assert `cond1' if `cond2'
			if _rc {
				g _fine = `cond1' if `cond2'
			}
			else {
				local i = `i' + 1
				continue
			}
		}
		
		sort _fine
		count if _fine == 0
		local viol = `r(N)'
		forval j=1/`viol' {
			local message `"Assertion `cond1' if `cond2' is invalid "'
			local varl : variable label `var'
			local varl = subinstr(`"`varl'"',",","-",.)
			local value = `var'[`j']
			local idv = `id'[`j']
			local enum = `enumerator'[`j']
			local outline `"`idv',`enum',`var',`varl',`value',`message'"'
			if "`addvars'" != "" {
				foreach addvar in `addvars' {
					local addval = `addvar'[`j']
					local outline `"`outline',`addval'"'
				}
			}
			file write myfile "`outline'" _n
		}
		local i = `i' + 1
		local nviol = `nviol' + `viol'
		drop _fine
	}

	file close myfile
	restore
	
	// Output temp file to Excel
	preserve
	import delimited using `tmp', clear
	g notes = ""
	g drop = ""
	g newvalue = ""	
	export excel using `saving' , sheet("6. skip") `sheetreplace' `sheetmodify' firstrow(variables) nolabel
	restore
	}
	di ""
	di "  Found `nviol' total skip pattern and survey logic violations."
	return scalar nviol = `nviol'
end
