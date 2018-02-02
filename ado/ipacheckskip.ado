*! version 2.0.1 Christopher Boyer 26jul2017

program ipacheckskip, rclass
	/* This program checks skip patterns and logical constraints 
	 
	 version 2.0.1: includes formatting for stata 14 and above
	*/
	
	* version 15

	#d;
	syntax anything, 
		/* soft constraint options */
	    ASSert(string) [CONDition(string)]
		/* output filename */
	    saving(string) 
	    /* output options */
        id(varname) ENUMerator(varname) SUBMITted(varname) 
		[KEEPvars(string)] 

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
		
		* break down the varlist into sets of variables
		local testnum = 0
		local varnum = 1
		while strpos("`anything'", ";") > 0  {
			local ++testnum
			gettoken varlist`testnum' anything : anything, p(";")
			local anything : subinstr loc anything ";" ""
			
			*find maximum number of variables listed in a test
			local new_words: word count `varlist`testnum''
			if `new_words' > `varnum'{
				local varnum = `new_words'
			}
		}

		* define default output variable list
		unab admin : `submitted' `id' `enumerator'
		forval x = 1 / `varnum' {
			local meta `meta' variable_`x' label_`x'
		}
		local meta `"`meta' message"'

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
		poke `tmp', var(`keeplist')

		* loop through varlist and test assertions
		forval x = 1 / `testnum' {
			local varlist `varlist`x''
			gettoken cond1 assert : assert, p(";")
			gettoken cond2 condition : condition, p(";")
			local assert : subinstr local assert ";" ""
			local condition : subinstr local condition ";" ""

			replace `test' = .
			replace message = ""
			forval a = 1 / `varnum' {
				replace variable_`a' = ""
				replace label_`a' = ""
			}

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
			local n = 1
			foreach var in `varlist' {
				local varl_`n' : variable label `var'
				local ++n
			}

			* update values of meta data variables
			local n = 1
			foreach var in `varlist' {
				replace label_`n' = "`varl_`n''"
				cap confirm numeric variable `var' 
				if !_rc {
					replace variable_`n' = "`var' = " + string(`var')
				}
				else {
					replace variable_`n' = "`var' = " + `var'
				}
				local ++n
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
		gsort -`submitted'

		* export compiled list to excel
		export excel using "`saving'" ,  ///
			sheet("6. skip") `sheetreplace' `sheetmodify' ///
			firstrow(variables) `nolabel'
			
		* Format to headers
		if `c(version)' >= 14.0 {
			d, s
			loc endcol = char(65 + `r(k)' - 1)
				
			putexcel set "`saving'", sheet("6. skip") modify
			putexcel A1:`endcol'1, bold border(bottom)
		}
		
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

program poke
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

program alphacol, rclass
	syntax anything(name = num id = "number")

	local col = ""

	while `num' > 0 {
		local let = mod(`num'-1, 26)
		local col = char(`let' + 65) + "`col'"
		local num = floor((`num' - `let') / 26)
	}

	return local alphacol = "`col'"
end
