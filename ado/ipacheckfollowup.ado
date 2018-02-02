*! version 2.0.1 Christopher Boyer 26jul2017

program ipacheckfollowup, rclass
	/*  This program checks the values of id variables in memory against 
	    a master tracking list from a prior survey or census. 
		
		version 2.0.1: Includes some text formatting for stata 14 and above
		*/
	
	* version 15

	#d ;
	syntax varlist using/, 
		/* output filename */
	    saving(string) 
	    /* output options */
        id(varname) ENUMerator(varname) SUBMITted(varname) 
		[KEEPVars(string) KEEPMaster(string)] 
		/* other options */
		[SHEETMODify SHEETREPlace NOLabel];	
	#d cr

	* test for fatal conditions
	cap which cfout
	if _rc {
		di as err "SSC package {cmd:cfout} required"
		di as err "to install, type {cmd:ssc install cfout}"
		ex 198
	}

	di ""
	di "HFC 5 => Checking that follow up variables match master tracking sheet..."

	qui {

		* count nvars
		unab vars : _all
		local nvars : word count `vars'

		* define temporary files 
		tempfile tmp org
		save `org'

		* define temporary variable
		tempvar viol
		g `viol' = .

		* define default output variable list
		unab admin : `submitted' `id' `enumerator'
		local meta `"variable label current_value tracking_value message"'

		* add user-specified keep vars to output list
		local lines : subinstr local keepvars ";" "", all
		local lines : subinstr local lines "." "", all

		local unique : list uniq lines
		local keeplist : list admin | unique
		local master "`using'"

		* initialize meta data variables
		foreach var in `meta' {
			g `var' = ""
		}
		
		* initialize temporary output file
		poke `tmp', var(`keeplist')

		/* Check that a survey matches other records for its unique ID.
		   Example: For each ID, check that the name in the baseline data matches
		   the one in the master tracking list. */

		cfout `varlist' using "`master'", ///
			id(`id') ///
			saving(`tmp', ///
				variable("variable") ///
				masterval("current_value") ///
				usingval("tracking_value") ///
				keepmaster("`keeplist' message") ///
				keepusing(`keepmaster') ///
				properties(varlabel("label")) ///
				replace ) ///
			lower nopunct  

		* record returned values
		local ncomp = `r(N)'
		local ndiscrep = `r(discrep)'
		local nonlym = `r(Nonlym)'
		local nonlyu = `r(Nonlyu)'

		* import compiled list of violations
		use `tmp', clear

		replace message = "Current value does not match master."
		* if there are no violations
		if `=_N' == 0 {
			set obs 1
			replace message = ""
		} 

		* create additional meta data for tracking
		g notes = ""
		g drop = ""
		g newvalue = ""	

		order `meta' `keeplist' `keepmaster' notes drop newvalue
		gsort -`submitted'
		
		* export compiled list to excel
		export excel using "`saving'" ,  ///
			sheet("5. follow up") `sheetreplace' `sheetmodify' ///
			firstrow(variables) `nolabel'
			
		* Format headers
		if `c(version)' >= 14.0 {
			d, s
			loc endcol = char(65 + `r(k)' - 1)
				
			putexcel set "`saving'", sheet("5. follow up") modify
			putexcel A1:`endcol'1, bold border(bottom)
		}

		* revert to original
		use `org', clear
	}
	
	* display check statistics to output screen
	di "  Compared master and using on `ncomp' values."
	di "  Found `ndiscrep' discrepancies."
	di "  Found `nonlym' ids only in current data set."
	di "  Found `nonlyu' ids only in the master tracking sheet."
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
