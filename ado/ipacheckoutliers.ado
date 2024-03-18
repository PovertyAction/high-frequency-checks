*! version 4.0.6 18mar2024
*! Innovations for Poverty Action
* ipacheckoutliers: Flag outliers in numeric variables

program ipacheckoutliers, rclass
	
	
	version 17

	#d;
	syntax 	using/,
			[SHeet(string)]
        	OUTFile(string)
        	[OUTSheet(string)]  
			id(varname) 
        	ENUMerator(varname) 
        	date(varname) 
			[SHEETMODify SHEETREPlace] 
			[NOLABel]
		;	
	#d cr

	qui {
	    
		preserve

		tempvar tmv_flag tmv_dups
		
		* set default insheet values
		if "`sheet'" == "" loc sheet "outliers"
		
		* set default outsheet values
		if "`outsheet'" == "" loc outsheet "outliers"

		* import input data	
		import excel using "`using'", clear sheet("`sheet'") first case(l) allstr

		* check for duplicates in variable comlumn
		drop if missing(variable)
		cap isid variable
		if _rc == 459 {
			duplicates tag variable, gen (`tmv_dups')
			di as err "Duplicates found in inputs sheet:"
			noi list variable by method multiplier combine if dups
			exit 459 
		}
		
		* check and insert optionally needed required columns
		foreach var in by method multiplier combine keep {
			cap confirm var `var'
			if _rc == 111 {
				gen `var' = ""
			}
		}

		* save variables, by and keep vars locals
		levelsof variable, loc (vars) clean
		levelsof by, loc (byvars) clean
		levelsof keep, loc(keep) clean

		* keep only relevant vars
		keep variable by method multiplier combine

		* include default values method and multiplier
			* if no method is supplied, assume iqr
			* if no multiplier is supplied, assume 1.5 for iqr & 3 for SD

		replace method = "iqr" if missing(method)
		replace multiplier = cond(method == "iqr" & missing(multiplier), "1.5", ///
							 cond(method == "sd" & missing(multiplier), "3", multiplier))

		destring multiplier, replace 

		* check that all multpliers are numeric
		cap confirm numeric var multiplier
		if _rc == 7 {
			disp as err "Multiplier contains non-numeric variables"
			destring multiplier, force gen(`tmv_flag')
			gen row = _n, before(variable)
			noi list row variable method multiplier if mi(`tmv_flag'), abbreviate(32) noobs
			ex 198
		}

		loc cnt `=_N'

		* copy inputs into data frame
		cap frame drop frm_inputs
		frames put * , into(frm_inputs)

		restore, preserve 
		
		cap confirm var _hfcokay
		if !_rc {
		    cap confirm var _hfcokayvar 
			if !_rc {
			    loc checkok 1
				cap frame drop frm_hfcokay
				frames put `id' _hfcokay _hfcokayvar if _hfcokay == 1, into(frm_hfcokay)
			}
			else loc checkok 0
		}
		else {
		    loc checkok 0
		}

		* expand and replace vars in input sheet
		forval i = 1/`cnt' {

			frames frm_inputs: loc vars`i' = variable[`i']
			unab vars`i': `vars`i''
			frames frm_inputs: replace variable = "`vars`i''" in `i'

			* check that the variable specified is not also a keep var
			if "`keep'" ~= "" {
				loc viol: list vars`i' in keep
				if `viol' {
					disp as err "Variables in varlist and keep are mutually exclusive. `vars`i'' is in both"
					ex 198
				}
			}
		}


		* rename and reshape outlier vars
		unab vars: `vars'
		loc vars: list uniq vars
		loc i 1
		foreach var of varlist `vars' {
			* check that variable is numeric
			cap confirm numeric var `var'
			if _rc == 7 {
				disp as err "Variable `var' must be a numeric variable"
				ex 7
			}

			ren `var' ovvalue_`i'
			gen ovname_`i' = "`var'" if !missing(ovvalue_`i')
			gen ovlabel_`i' = "`:var lab ovvalue_`i''" if !missing(ovvalue_`i'), after(ovvalue_`i')
			loc ++i
		}
		
		* keep only relevant variables
		keep `id' `enumerator' `date' `keep' `byvars' ovvalue_* ovname_* ovlabel_*

		gen reshape_id = _n

		reshape long ovvalue_ ovname_ ovlabel_, i(reshape_id) j(index)
		ren (ovvalue_ ovname_ ovlabel_) (value variable varlabel)

		drop if missing(value)
		drop reshape_id index

		* gen placeholders for important vars
		loc statvars "value_count value_min value_max value_mean value_median value_sd p25 p75 iqr"
		foreach var of newlist `statvars' {
			gen `var' = .
		}

		gen byvar 		= ""
		gen method 		= ""
		gen multiplier 	= .
		gen combine 	= variable
		gen combine_ind = 0
		
		* calculate outliers
		forval i = 1/`cnt' {
			frames frm_inputs {
				loc vars`i' 		= variable[`i']
				loc by`i' 			= by[`i']
				loc method`i' 		= method[`i']
				loc multiplier`i' 	= multiplier[`i']
				loc combine`i' 		= combine[`i'] 
			}

			* check if vars are combined
			if lower("`combine`i''") == "yes" {
				foreach var in `vars`i'' {
					replace combine = "`vars`i''" if variable == "`var'"
					replace combine_ind = 1 if variable == "`var'"
				}
				
				if "`by`i''" ~= "" 	loc by_syntax "bys `by`i'':"
				else 				loc by_syntax ""
					
				`by_syntax' egen vcount  = count(value)   if combine == "`vars`i''"
				`by_syntax' egen vmin 	  = min(value) 	  if combine == "`vars`i''"
				`by_syntax' egen vmax 	  = max(value) 	  if combine == "`vars`i''"
				`by_syntax' egen vmean   = mean(value)    if combine == "`vars`i''"
				`by_syntax' egen vmedian = median(value)  if combine == "`vars`i''"
				`by_syntax' egen vsd     = sd(value)      if combine == "`vars`i''"
				`by_syntax' egen vp25 	  = pctile(value) if combine == "`vars`i''", p(25)
				`by_syntax' egen vp75 	  = pctile(value) if combine == "`vars`i''", p(75)
				`by_syntax' egen viqr 	  = iqr(value)    if combine == "`vars`i''"

				replace value_count 	  = vcount 		  if combine == "`vars`i''"
				replace value_min 		  = vmin 		  if combine == "`vars`i''"
				replace value_max 		  = vmax 		  if combine == "`vars`i''"
				replace value_mean 		  = vmean 		  if combine == "`vars`i''"
				replace value_median 	  = vmedian 	  if combine == "`vars`i''"
				replace value_sd 	  	  = vsd 	  	  if combine == "`vars`i''"
				replace p25 			  = vp25       	  if combine == "`vars`i''"
				replace p75 			  = vp75 		  if combine == "`vars`i''"
				replace iqr 			  = viqr 		  if combine == "`vars`i''"

				replace byvar 		= "`by`i''" 		if combine == "`vars`i''" 
				replace method 		= "`method`i''"		if combine == "`vars`i''"
				replace multiplier 	= `multiplier`i''   if combine == "`vars`i''"

				drop vcount vmin vmax vmean vmedian vsd vp25 vp75 viqr
			}
			else {
				foreach var in `vars`i'' {
					if "`by`i''" ~= "" 	loc by_syntax "bys `by`i'':"
					else 				loc by_syntax ""
					
					`by_syntax' egen vcount  = count(value)  if variable == "`var'"
					`by_syntax' egen vmin 	  = min(value) 	  if variable == "`var'"
					`by_syntax' egen vmax 	  = max(value) 	  if variable == "`var'"
					`by_syntax' egen vmean   = mean(value)   if variable == "`var'"
					`by_syntax' egen vmedian = median(value) if variable == "`var'"
					`by_syntax' egen vsd     = sd(value)     if variable == "`var'"
					`by_syntax' egen vp25 	  = pctile(value) if variable == "`var'", p(25)
					`by_syntax' egen vp75 	  = pctile(value) if variable == "`var'", p(75)
					`by_syntax' egen viqr 	  = iqr(value)    if variable == "`var'"

					replace value_count 	  = vcount 		  if variable == "`var'"
					replace value_min 		  = vmin 		  if variable == "`var'"
					replace value_max 		  = vmax 		  if variable == "`var'"
					replace value_mean 		  = vmean 		  if variable == "`var'"
					replace value_median 	  = vmedian 	  if variable == "`var'"
					replace value_sd 	  	  = vsd 	  	  if variable == "`var'"
					replace p25 			  = vp25       	  if variable == "`var'"
					replace p75 			  = vp75 		  if variable == "`var'"
					replace iqr 			  = viqr 		  if variable == "`var'"

					replace byvar 		= "`by`i''" 		  if variable == "`var'" 
					replace method 		= "`method`i''"		  if variable == "`var'"
					replace multiplier 	= `multiplier`i''     if variable == "`var'"

					drop vcount vmin vmax vmean vmedian vsd vp25 vp75 viqr
				}
			}
		}

		* clean up and rename combine variables
		replace combine = "" if !combine_ind
		drop 	combine_ind

		gen range_min = cond(method == "iqr", p25 - (1.5 * iqr), value_mean - (multiplier * value_sd))
		gen range_max = cond(method == "iqr", p75 + (1.5 * iqr), value_mean + (multiplier * value_sd)) 
		
		keep if !inrange(value, range_min, range_max)
		
		* drop if already marked as ok
		if `checkok' {
		    frame frm_hfcokay: loc okaycnt `c(N)'
			forval i = 1/`okaycnt' {
			    loc vars = _frval(frm_hfcokay, _hfcokayvar, `i')
			    drop if `id' == _frval(frm_hfcokay, `id', `i') & regexm("`vars'", variable)
			}
		}
		
		if `c(N)' > 0 {

			ipagettd `date'
			
			gen method_value = cond(method == "iqr", iqr, value_sd)
			gen range = "Range for " + string(multiplier, "%15.2f") + " * " + method + ///
						"(" + string(method_value, "%15.2f") + "): " + ///
						string(range_min, "%15.2f") + " to " + string(range_max, "%15.2f")
						
			foreach var of varlist _all {
				lab var `var' "`var'"
			}
			
			lab var varlabel 		"label"
			lab var value_count 	"count"
			lab var value_sd 		"sd"
			lab var value_mean 		"mean"
			lab var value_min 		"min"
			lab var value_max 		"max"
			
			keep 	`enumerator' `keep' `date' `id'  variable varlabel ///
					byvar `byvars' combine value value_count value_min value_mean value_max range 

			order 	`enumerator' `keep' `date' `id'  variable varlabel ///
					byvar `byvars' combine value value_count value_min value_mean value_max range 
					
			if "`keep'" ~= "" ipalabels `keep', `nolabel'
			ipalabels `id' `enumerator', `nolabel'
			export excel using "`outfile'", first(varl) sheet("`outsheet'") `sheetreplace'

			cap mata: colwidths("`outfile'", "`outsheet'")
			cap mata: colformats("`outfile'", "`outsheet'", ("value", "value_min", "value_mean", "value_max"), "number_sep_d2")	
			cap mata: colformats("`outfile'", "`outsheet'", ("`date'"), "date_d_mon_yy")
			cap mata: setheader("`outfile'", "`outsheet'")
			
			tab variable
			loc var_cnt `r(r)'
			
			* display number of outliers flagged
			noi disp "Found {cmd:`c(N)'} outliers in `var_cnt' variable(s)."
		}
		else {
		    loc var_cnt 0
			noi disp "Found {cmd:0} outliers."
		}
		
		return local N_outliers = `c(N)'
		return local N_vars = `var_cnt'
	}
	
end
