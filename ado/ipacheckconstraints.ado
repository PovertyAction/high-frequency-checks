/*----------------------------------------*
 |file:    ipacheckconstraints.ado        | 
 |project: high frequency checks          |
 |author:  christopher boyer              |
 |         matthew bombyk                 |
 |         innovations for poverty action |
 |date:    2016-02-13                     |
 *----------------------------------------*/

 // this program checks for hard and soft constraint violations

capture program drop ipacheckconstraints
program ipacheckconstraints, rclass
	di ""
	di "HFC 8 => Checking that values do not exceed soft/hard minimums and maximums..."
	qui {

	syntax varlist, saving(string) id(name) smin(numlist) smax(numlist) enumerator(name)  [hmin(numlist) hmax(numlist) sheetmodify sheetreplace]
	
	version 13.1

	tempfile tmp
	file open myfile using `tmp', text write replace
	file write myfile "id,enumerator,variable,label,value,message" _n 

	local i = 1
	local nviol = 0 
	local nhard = 0
	local nsoft = 0
	ds `varlist'
	foreach var of varlist `r(varlist)' {
		loc minsoft: word `i' of `smin'
		loc minhard: word `i' of `hmin'
		loc maxsoft: word `i' of `smax'
		loc maxhard: word `i' of `hmax'
		local npvar = 0
		
		if `"`minsoft'"' == "" loc minsoft .
		if `"`minhard'"' == "" loc minhard .
		if `"`maxsoft'"' == "" loc maxsoft .
		if `"`maxhard'"' == "" loc maxhard .		

		cap loc varlabb: variable label `var'
		cap loc varlabb = subinstr(`"`varlabb'"',",","-",.)
		forval x = 1/`=_N' {
			loc enum = `enumerator'[`x']
			loc survey = `id'[`x']
			loc varval = `var'[`x']
			
			*Check Hard and Soft minimums
			if `varval' < `minhard' & `minhard' < . {
				loc message `"Value is too small. Hard Min. = `minhard'"'
				file write myfile `"`survey',`enum',`var',`varlabb',`varval',`message'"' _n
				local nviol = `nviol' + 1
				local npvar = `npvar' + 1
				local nhard = `nhard' + 1

			}
			else if `varval' < `minsoft' & `minsoft' < . {
				loc message `"Value is small. Soft Min. = `minsoft'"'
				file write myfile `"`survey',`enum',`var',`varlabb',`varval',`message'"' _n
				local nviol = `nviol' + 1
				local npvar = `npvar' + 1
				local nsoft = `nsoft' + 1
			}
			
			*Check Hard and Soft Maximums
			if `varval' > `maxhard' & `maxhard' < . & `varval' < . {
				loc message `"Value is too high. Hard Max. = `maxhard'"'
				file write myfile `"`survey',`enum',`var',`varlabb',`varval',`message'"' _n
				local nviol = `nviol' + 1
				local npvar = `npvar' + 1
				local nhard = `nhard' + 1
			}
			else if `varval' > `maxsoft' & `maxsoft' < . & `varval' < . {
				loc message `"Value is high. Soft Max. = `maxsoft'"'
				file write myfile `"`survey',`enum',`var',`varlabb',`varval',`message'"' _n
				local nviol = `nviol' + 1
				local npvar = `npvar' + 1
				local nsoft = `nsoft' + 1
			}

		}
		if `npvar' > 0 {
			noisily di "  Variable `var' has `npvar' constraint violations."
		}
		local i = `i' + 1
	}
	file close myfile	
		
	// Output this to Excel:
	preserve
	import delimited using `tmp', clear
	if `=_N' > 0 {
		g notes = ""
		g drop = ""
		g newvalue = ""	
		export excel using `saving' , sheet("8. constraints") `sheetreplace' `sheetmodify' firstrow(variables) nolabel
	}	
	restore
	}
	di ""
	di "  Found `nviol' total constraint violations: `nhard' hard and `nsoft' soft."
	return scalar nviol = `nviol'
	return scalar nhard = `nhard'
	return scalar nsoft = `nsoft'
end
