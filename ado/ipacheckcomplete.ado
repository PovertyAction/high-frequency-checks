*! version 1.0.0 Christopher Boyer 04may2016

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
	   that have fewer nonmissing responses than the minimum. */
	version 13

	#d ;
	syntax varlist, 
		/* completeness options */
	    COMPlete(numlist) [Percent(real 0)]
		/* output filename */
	    saving(string) 
	    /* output options */
        id(varname) ENUMerator(varname) [KEEPvars(string)] 
		/* other options */
		[SHEETMODify SHEETREPlace NOLabel];	
	#d cr

	* test for fatal conditions
	if `percent' != 0 {
		cap assert `percent' > 0 & `percent' <= 100
		if _rc {
			di as err "percent value must be between 0 and 100."
			error 198
		} 
	}

	* display header text
	di ""
	di "HFC 1 => Checking that all interviews are complete..."

	qui {

	* count nvars
	unab vars : _all
	local nvars : word count `vars'

	* define temporary files 
	tempfile tmp org
	save `org'

	* define temporary variable
	tempvar comp nonmiss
	g `comp' = .

	* define default output variable list
	local admin "`id' `enumerator'"
	local meta `"variable label value message"'

	* add user-specified keep vars to output list
    local lines : subinstr local keepvars ";" "", all
    local lines : subinstr local lines "." "", all

    local unique : list uniq lines
    local keeplist : list admin | unique
    local keeplist : list keeplist | meta

 	* define loop locals
	local nincomplete = 0
	local i = 1

	* initialize meta data variables
	foreach var in `meta' {
		g `var' = ""
	}

	* initialize temporary output file
	touch `tmp', var(`keeplist')

	* loop through varlist and capture the number of incomplete surveys 
	foreach var in `varlist' {
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

	
	if `percent' > 0 {
		* check nonmissing percentage
		egen `nonmiss' = rownonmiss(`vars'), strok
		replace `nonmiss' = `nonmiss'/`nvars'

		* update values for additional variables
		replace variable = ""
		replace label = ""
		replace value = ""
		replace message = "Interview is " + string(`nonmiss'*100, "%2.0f") + ///
		    "% complete (max is " + string(`percent', "%2.0f") + "%)."

		* store number of violations in local 
		count if `nonmiss' < `percent'/100
		local nonmissviol = `r(N)'	
		
		* append violation list to output file
		saveappend using `tmp' if `nonmiss' < `percent'/100 , ///
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

	* export compiled list to excel
	export excel using `saving' ,  ///
		sheet("1. incomplete") `sheetreplace' `sheetmodify' ///
		firstrow(variables) `nolabel'

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
