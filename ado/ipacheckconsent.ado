*! version 2.0.1 Christopher Boyer 26jul2017

program ipacheckconsent, rclass
	/* Check that all interviews have consent.

	   IPA best practice is generally to include one or more
	   questions at that asks the enumerator to document 
	   the consent of the interviewee. This check verifies 
	   that all surveys have appropriate consent values for
	   all consent variables. 
	   
	   version 2.0.1: includes formatting for stata 14 and above
	   */
	
	* version 15

	#d ;
	syntax varlist, 
		/* consent options */
	    CONSENTvalue(numlist) 
		/* output filename */
	    saving(string) 
	    /* condition option */
	    [CONDition(string)]
	    /* output options */
        id(varname) ENUMerator(varname) SUBMITted(varname) 
		[KEEPvars(string)] 

		/* other options */
		[SHEETMODify SHEETREPlace NOLabel];	
	#d cr

	* test for fatal conditions

	* display header text
	di ""
	di "HFC 3 => Checking that all interviews have consent..."

	qui {
		* count nvars
		unab vars : _all
		local nvars : word count `vars'

		* define temporary files 
		tempfile tmp org
		save `org'

		* define temporary variable
		tempvar consent
		g `consent' = .

		* define default output variable list
		unab admin : `submitted' `id' `enumerator'
		local meta `"variable label value message"'

		* add user-specified keep vars to output list
		local lines : subinstr local keepvars ";" "", all
		local lines : subinstr local lines "." "", all

		local unique : list uniq lines
		local keeplist : list admin | meta
		local keeplist : list keeplist | unique

		* define loop locals
		local numnoconsent = 0
		local i = 1

		* initialize meta data variables
		foreach var in `meta' {
			g `var' = ""
		}
		
		* initialize temporary output file
		poke `tmp', var(`keeplist')

		* loop through varlist and capture the number of unconsented surveys 
		foreach var in `varlist' {
			local val : word `i' of `consentvalue'
			gettoken cond condition : condition, p(";")
			local condition : subinstr local condition ";" ""

			if "`cond'" != "" {
				local condstr "if `cond'"
			}
			else {
				local condsrt ""
			}

			* check if there are any violations
			cap assert `var' == `val' `condstr'
			if _rc {
				* create temp marker variable
				replace `consent' = `var' == `val' `condstr'

				* count the unconsented
				count if `consent' == 0
				local num = `r(N)'

				* capture variable label
				local varl : variable label `var'

				* update values for additional variables
				replace variable = "`var'"
				replace label = "`varl'"
				replace value = string(`var') if `consent' == 0
				replace message = "Interview does not have valid consent."

				* append violations to the temporary data set
				saveappend using `tmp' if `consent' == 0, ///
					keep("`keeplist'") sort(`id')
			}
			else {
				* if all consented, set the number of no consent to zero
				local num = 0
			}
			* update the total number of no consents
			local numnoconsent = `numnoconsent' + `num'
			local i = `i' + 1
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
			sheet("3. consent") `sheetreplace' `sheetmodify' ///
			firstrow(variables) `nolabel'
			
		* Add text formatting to headers
		if `c(version)' >= 14 {
			d, s
			loc endcol = char(65 + `r(k)' - 1)
			
			putexcel set "`saving'", sheet("3. consent") modify
			putexcel A1:`endcol'1, bold border(bottom)
		}

			
		* revert to original 
		use `org', clear
	}

	* display stats and return
	di "  Found `numnoconsent' interviews with no consent."
	return scalar noconsent = `numnoconsent'
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
