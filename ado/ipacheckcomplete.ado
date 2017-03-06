*! version 1.0.1 Christopher Boyer 04may2016

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
        id(varname) ENUMerator(varname) SUBMITted(varname) 
		[KEEPvars(string) SCTOdb(string)] 

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
	unab admin : `submitted' `id' `enumerator'
	local meta `"variable label value message"'
	if !missing("`sctodb'") {
		local meta `"`meta' scto_link"'
	}
	
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
	
	* Create scto_link variable
	if !missing("`sctodb'") {
		replace scto_link = subinstr(key, ":", "%3A", 1)
		replace scto_link = `"=HYPERLINK("https://`sctodb'.surveycto.com/view/submission.html?uuid="' + scto_link + `"", "View Submission")"'
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
		count if `nonmiss' < `percent' / 100
		local nonmissviol = `r(N)'	
		
		* append violation list to output file
		saveappend using `tmp' if `nonmiss' < `percent' / 100 , ///
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
		sheet("1. incomplete") `sheetreplace' `sheetmodify' ///
		firstrow(variables) `nolabel'

	*export scto links as links
	if !missing("`sctodb'") {
		putexcel set "`saving'", sheet("1. incomplete") modify
		ds
		loc allvars `r(varlist)'
		loc linkpos: list posof "scto_link" in allvars
		loc alphabet `c(ALPHA)'
		local col: word `linkpos' of `alphabet'
		count
		forval x = 1 / `r(N)' {
			loc row = `x' + 1
			loc formula = scto_link[`x']
			loc putlist `"`putlist' `col'`row' = formula(`"`formula'"')"'
		}
		putexcel `putlist'
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
