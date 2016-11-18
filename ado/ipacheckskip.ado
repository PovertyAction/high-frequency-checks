*! version 1.0.0 Christopher Boyer 04may2016

program ipacheckskip, rclass
	/* This program checks skip patterns and logical constraints */
	version 13

	#d ;
	syntax varlist, 
		/* soft constraint options */
	    ASSert(string) [CONDition(string)]
		/* output filename */
	    saving(string) 
	    /* output options */
        id(varname) ENUMerator(varname) [KEEPvars(string)] 
		/* other options */
		[SHEETMODify SHEETREPlace NOLabel];	
	#d cr

	di ""
	di "HFC 6 => Checking skip patterns and survey logic..."
	qui {

	* count nvars
	unab vars : _all
	local nvars : word count `vars'

	* define temporary files 
	tempfile tmp org
	save `org'

	* define temporary variable
	tempvar test
	g `test' = .

	* define default output variable list
	unab admin : `id' `enumerator'
	local meta `"variable label value message"'

	* add user-specified keep vars to output list
    local lines : subinstr local keepvars ";" "", all
    local lines : subinstr local lines "." "", all

    local unique : list uniq lines
    local keeplist : list admin | meta
    local keeplist : list keeplist | unique

    * set locals
	local i = 1
	local nviol = 0

	* initialize meta data variables
	foreach var in `meta' {
		g `var' = ""
	}

	* initialize temporary output file
	touch `tmp', var(`keeplist')

	* loop through varlist and test assertions
	foreach var in `varlist' {
		gettoken cond1 assert : assert, p(";")
		gettoken cond2 condition : condition, p(";")
		local assert : subinstr local assert ";" ""
		local condition : subinstr local condition ";" ""

		replace `test' = .
		replace message = ""

		if "`cond2'" == ";" {
			cap assert `cond1'
			if _rc {
				replace `test' = `cond1'
				replace message = `"Assertion "`cond1'" is invalid "'
			}
		} 
		else {
			cap assert `cond1' if `cond2'
			if _rc {
				replace `test' = `cond1' if `cond2'
				replace message = `"Assertion "`cond1' if `cond2'" is invalid "'
			}
		}

		* count the invalid assertions
		count if `test' == 0
		local viol = `r(N)'
		local nviol = `nviol' + `viol'

		* capture variable label
		local varl : variable label `var'

		* update values of meta data variables
		replace variable = "`var'"
		replace label = "`varl'"
		cap confirm numeric variable `var' 
		if !_rc {
			replace value = string(`var')
		}
		else {
			replace value = `var'
		}

		* append violations to the temporary data set
		saveappend using `tmp' if `test' == 0, ///
			keep("`keeplist'")
	}

	* import compiled list of violations
	use `tmp', clear

	* if there are no violations
	if `=_N' == 0 {
		set obs 1
	} 

	* create additional meta data for tracking
	g notes = ""
	g drop = ""
	g newvalue = ""	

	order `keeplist' notes drop newvalue

	* export compiled list to excel
	export excel using "`saving'" ,  ///
		sheet("6. skip") `sheetreplace' `sheetmodify' ///
		firstrow(variables) `nolabel'

	* revert to original
	use `org', clear

	}
	di ""
	di "  Found `nviol' total skip pattern and survey logic violations."
	return scalar nviol = `nviol'
end

program saveappend
	/* this program appends the data in memory, or a subset 
	   of that data, to a stata file on disk. */
	syntax using/ [if] [in] [, keep(varlist) sort(varlist)]

	marksample touse 
	preserve

	keep if `touse'

	if "`keep'" != "" {
		keep `keep' `touse'
	}

	append using `using'

	if "`sort'" != "" {
		sort `sort'
	}

	drop `touse'
	save `using', replace

	restore
end

program touch
	syntax [anything], [var(varlist)] [replace] 

	* remove quotes from filename, if present
	local file = `"`=subinstr(`"`anything'"', `"""', "", .)'"'

	* test fatal conditions
	cap assert "`file'" != "" 
	if _rc {
		di as err "must specify valid filename."
		error 100
	}

	preserve 

	if "`var'" != "" {
		keep `var'
		drop if _n > 0
	}
	else {
		drop _all
		g var = 1
		drop var
	}
	* save 
	save "`file'", emptyok `replace'

	restore

end
