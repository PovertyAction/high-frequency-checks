*! version 2.1.0 Ishmail Azindoo Baako, 02feb2018
*! version 2.0.1 Christopher Boyer 26jul2017

program ipacheckcomplete, rclass
	/* Check that all interviews were completed. 

	   IPA best practice is generally to include a question at
	   the end of a survey that asks the enumerator to document 
	   the completness of the interview. This command checks that 
	   all survey values of the completeness variable are equal
	   to the "completed" option. Incomplete surveys are listed 
	   in the output.
	   
	   Optionally, users can also specify a minimum nonmissing 
	   response threshold and this check will output the surveys
	   that have fewer nonmissing responses than the minimum. 
			
	   version 2.0.2 :
			- Optional complete variable. Most surveys in SCTO do not have
			  a complete var because incomplete forms cannot be submitted 
			- Flag outliers in missing percentages using iqr if percentage is not specified
			- Included an if_condition so that completeness will only be checked
			  for observations that meet condition. For instance, if the observation has valid consent
	   */
	
	* version 15

	#d ;
	syntax, [COMPVars(varlist) 
		/* completeness options */
	    COMPlete(numlist) Percent(real 0) condition(string)]
		/* output filename */
	    saving(string) 
	    /* output options */
        id(varname) ENUMerator(varname) SUBMITted(varname) 
		[KEEPvars(string)] 

		/* other options */
		[SHEETMODify SHEETREPlace NOLabel];	
	#d cr
	
	qui {
		* test for fatal conditions
		if `percent' != 0 {
			cap assert `percent' > 1 & `percent' <= 100
			if _rc {
				di as err "percent value must be between 1 and 100."
				error 198
			} 
		}
		
		loc if_condition = subinstr("if `condition'", ";", "", .)

		* display header text
		di ""
		di "HFC 1 => Checking that all interviews are complete..."

		* count nvars
		unab vars : _all
		local nvars : word count `vars'

		* define temporary files 
		tempfile tmp org
		save `org'

		* define temporary variable
		tempvar comp nonmiss iqr_outlier
		g `comp' = .

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
		local nincomplete = 0
		local i = 1

		* initialize meta data variables
		foreach var in `meta' {
			g `var' = ""
		}
		
		* initialize temporary output file
		poke `tmp', var(`keeplist')
		
		* loop through varlist and capture the number of incomplete surveys 
		* check that varlist was provided
		if "`compvars'" ~= "" {
			foreach var in `compvars' {
				local val : word `i' of `complete'

				* check if there are any violations
				cap assert `var' == `val'
				if _rc {
					* create temp marker variable
					replace `comp' = `var' == `val'

					* count the incomplete
					count if `comp' == 0
					local num = `r(N)'

					local varl : variable label `var'

					* update values for additional variables
					replace variable = "`var'"
					replace label = "`varl'"
					replace value = string(`var') if `comp' == 0
					replace message = "Interview is marked as incomplete."

					* append violations to the temporary data set
					saveappend using `tmp' if `comp' == 0, ///
						keep("`keeplist'") sort(`id')
				}
				else {
					* if all complete, set the number of incomplete to zero
					local num = 0
				}
				* update the total number of incomplete 
				local nincomplete = `nincomplete' + `num'
				local i = `i' + 1
			}
		}
		
		* check nonmissing percentage
		egen `nonmiss' = rownonmiss(`vars'), strok
		replace `nonmiss' = `nonmiss'/`nvars'
	
		* Change Percent to IQR Outlier minimum value if percent was not specified
		* (q1 - 1.5(iqr))
		if `percent' == 0 {
			summ `nonmiss' `if_condition', detail
			loc iqr	= `r(p75)' - `r(p25)'
			loc percent 	= `r(p25)' - (1.5 * `iqr')
			if `percent' < 0 loc percent 0
			else loc percent = `percent' * 100
		}
		
		* update values for additional variables
		replace variable = ""
		replace label = ""
		replace value = ""
		replace message = "Interview is " + string(`nonmiss'*100, "%2.0f") + ///
				"% complete (min is " + string(`percent', "%2.0f") + "%)."
		
		* store number of violations in local 
		count if `nonmiss' < `percent' / 100
		local nonmissviol = `r(N)'	
		* append violation list to output file
		saveappend using `tmp' if `nonmiss' < `percent' / 100 , ///
			keep("`keeplist'") 

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
		if "`compvars'" == "" gsort -`submitted'
		else gsort -variable -`submitted'

		* export compiled list to excel
		export excel using "`saving'" ,  ///
			sheet("1. incomplete") `sheetreplace' `sheetmodify' ///
			firstrow(variables) `nolabel'
			
		* Add text formatting to headers
		if `c(version)' >= 14 {
			d, s
			loc endcol = char(65 + `r(k)' - 1)
			
			putexcel set "`saving'", sheet("1. incomplete") modify
			putexcel A1:`endcol'1, bold border(bottom)
		}

		* revert to original
		use `org', clear
	}

	* display stats and return 
	di "  Found `nincomplete' total incomplete interviews."
	return scalar nincomplete = `nincomplete'
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
