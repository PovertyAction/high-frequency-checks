*! version 4.0.0 11may2022
*! Innovations for Poverty Action
* ipacheckenumdb: Outputs survey statistics by enumerator

program ipacheckenumdb, rclass sortpreserve
	
	version 17

	#d;
	syntax 	[using/],
			[SHEETname(string)]
        	DATE(varname)
        	[PERiod(string)]
        	ENUMerator(varname)
			[TEAM(varname)]
        	[CONSent(string)]
        	[DONTKnow(string)]
			[REFuse(string)]
			[OTHERspecify(varlist)]
        	[DURation(varname)]
        	FORMVersion(varname)
        	OUTFile(string)
			[SHEETREPlace SHEETMODify]
			[NOLabel]
		;	
	#d cr

	qui {
	    
		preserve

		tempvar tmv_subdate tmv_consent_yn tmv_team tmv_enum
		tempvar tmv_obs tmv_enum tmv_formversion tmv_days tmv_dur tmv_miss tmv_dk tmv_ref tmv_other 

		tempfile tmf_main_data tmf_datecal tmf_varcodes
		
		* save number of obs and vars in local
		
		loc obs_count 	= c(N)
		loc vars_count 	= c(k)
		
		* get list of all vars
		unab allvars: _all
		
		* check missing
		egen `tmv_miss' = rowmiss(_all)
		
		* create dummies scalars for options
		loc _cons 	= "`consent'" 	~= ""
		loc _dk 	= "`dontknow'" 	~= ""
		loc _ref 	= "`refuse'" 	~= ""
		loc _other 	= "`otherspecify'" ~= ""
		loc _dur 	= "`duration'" 	~= ""
		loc _team 	= "`team'"		~= ""
		
		* check for dk, ref. Generate dummies if not specified
		
		if `_dk' {
			token `"`dontknow'"', parse(,)
				
			* check numeric number
			if "`1'" ~= "" {
				cap confirm integer number `1'
				if _rc == 7 {
					cap assert regexm("`1'", "^[\.][a-z]$")
					if _rc == 9 {
						disp as err "`1' found where integer is expected in option dontknow()"
						exit 198
					}
				}
			}
			ipaanycount _all, generate(`tmv_dk') numval(`1') strval("`3'")
		}
		else gen `tmv_dk' = 0
		if `_ref' {
			token `"`refuse'"', parse(,)
			* check numeric number
			if "`1'" ~= "" {
				cap confirm integer number `1'
				if _rc == 7 {
					cap assert regexm("`1'", "^[\.][a-z]$")
					if _rc == 9 {
						disp as err "`1' found where integer is expected in option refuse()"
						exit 198
					}
				}
			}
			ipaanycount _all, generate(`tmv_ref') numval(`1') strval("`3'")
		}
		else gen `tmv_ref' = 0

		if `_other' {
			unab otherspecify: `otherspecify'
			loc other_count = wordcount("`otherspecify'")
			egen `tmv_other' = rownonmiss(`otherspecify'), strok
		}
		else {
			gen `tmv_other' = 0
			loc other_count 0
		}
		
		* team: team()
		if `_team' {
			gen `tmv_team' 	= `team' 
		}
		else gen `tmv_team' = ""
		
		ipagettd `date'
	
		* period: period(auto | daily | weekly | monthly) 
		* check : check options in period
		if "`period'" ~= "" & !inlist("`period'", "auto", "daily", "weekly", "monthly") {
			disp as err `"option period incorrectly specified. Expecting auto, daily, weekly or monthly."'
			ex 198
		}
		else if "`period'" == "" loc period "auto"
		if "`period'" == "auto" {
		    su `date'
			loc min_date `r(min)'
			loc max_date `r(max)'
			loc days = `max_date' - `min_date'
			loc period = cond(`days' <= 40,  "daily", ///
						 cond(`days' <= 280, "weekly", ///
											 "monthly"))
		}

		* duration: check that duration is a numeric var
		if `_dur' {
		    cap confirm numeric var `duration'
		    if _rc == 7 {
			    disp as err "variable `duration' found at option duration() where numeric variable is expected"
				ex 7
			} 
			else {
				gen `tmv_dur' = `duration'
			}
		}
		else gen `tmv_dur' = 0

		* consent: consent(consent, 1) or consent(consent, 1 2 3)
		if `_cons' {	
			* check  : check that consent variable is numeric and values is a numlist
			token "`consent'", parse(,)
			* check variable specified
			cap unab consent_var	: `1'
			if _rc == 102 {
				disp as err `"no variables specified for consent() option"'
				ex 198
			}
			else if _rc == 111 {
				disp as err `"variable `1' specifed in consent() option not found"'
				ex 111
			}
			else {
				macro shift
				loc consent_vals = subinstr(trim(itrim("`*'")), ",", "", 1)
				if missing("`consent_vals'") {
					disp as err `"no values specified with consent() option."' ///
								`"expected format is consent(varname, varlist)."' 
					ex 198
				}
				gen `tmv_consent_yn' = 0
				foreach val of numlist `consent_vals' {
					replace `tmv_consent_yn' = 1 if `consent_var' == `val'
				}
			}
		}
		else {
			gen `tmv_consent_yn' = 0
		}
		
		* save main dataset
		save "`tmf_main_data'", replace
				
		*** Summary (by enumerator) ***
		
		* generate vars to keep track of uniq number of forms, enums days in each group
		
		gen `tmv_formversion' 	= 0
		gen `tmv_days'			= 0
		
		cap confirm string var `enumerator'
		if !_rc {
			levelsof `enumerator', loc (enums)
			foreach enum in `enums' {
				tab `formversion' 						if `enumerator' == "`enum'"
				replace `tmv_formversion' 	= `r(r)' 	if `enumerator' == "`enum'"
				tab `date'								if `enumerator' == "`enum'"
				replace `tmv_days' 			= `r(r)' 	if `enumerator' == "`enum'"
			}
		}
		else {
			levelsof `enumerator', loc (enums) clean
			foreach enum in `enums' {
				tab `formversion' 						if `enumerator' == `enum'
				replace `tmv_formversion' 	= `r(r)' 	if `enumerator' == `enum'
				tab `date'								if `enumerator' == `enum'
				replace `tmv_days' 			= `r(r)' 	if `enumerator' == `enum'
			}
		}
		
		gen `tmv_obs' = 1
		
		#d;
		collapse (first)    team 			= `tmv_team'
				 (count) 	submissions 	= `tmv_obs'
				 (mean)  	consent_rate 	= `tmv_consent_yn'
				 (sum)   	missing_rate   	= `tmv_miss'
				 (sum)   	dontknow_rate  	= `tmv_dk'
				 (sum)	 	refuse_rate		= `tmv_ref'
				 (sum)		other_rate 		= `tmv_other'
				 (min)	 	duration_min   	= `tmv_dur'
				 (mean)	 	duration_mean   = `tmv_dur'
				 (median) 	duration_median = `tmv_dur'
				 (max)	 	duration_max   	= `tmv_dur'
				 (first) 	formversion 	= `tmv_formversion'
				 (min)   	firstdate 		= `date'
				 (max)   	lastdate		= `date'
				 (first) 	days 			= `tmv_days'
				 ,
				 by(`enumerator')
			;
		#d cr
		
		* convert missing_rate to actual rates
		
		replace missing_rate 	= missing_rate/(submissions * `vars_count')
		replace dontknow_rate 	= dontknow_rate/(submissions * `vars_count')
		replace refuse_rate 	= refuse_rate/(submissions * `vars_count')
		replace other_rate 		= other_rate/(submissions * `other_count')
	
		*label variables
		lab var team 			"team"
		lab var submissions 	"# of submissions"
		lab var consent_rate 	"% of consent"
		lab var missing_rate   	"% missing"
		lab var dontknow_rate  	"% dont know"
		lab var refuse_rate		"% refuse"
		lab var other_rate		"% other"
		lab var duration_min   	"min duration"
		lab var duration_mean   "mean duration"
		lab var duration_median "median duration"
		lab var duration_max   	"max duration"
		lab var formversion 	"# of form versions"
		lab var firstdate 		"first date"
		lab var lastdate		"last date"
		lab var days 			"# of days"
		
		* drop consent, dk, ref, other, duration
		if !`_team'		drop team
		if !`_cons' 	drop consent_rate
		if !`_dk' 		drop dontknow_rate
		if !`_ref' 		drop refuse_rate
		if !`_other'	drop other_rate
		if !`_dur' 		drop duration_*

		ipalabels `enumerator', `nolabel'
		export excel using "`outfile'", first(varl) sheet("summary") `sheetreplace' `sheetmodify'
		mata: colwidths("`outfile'", "summary")
		mata: setheader("`outfile'", "summary")
		if `_cons' 	mata: colformats("`outfile'", "summary", ("consent_rate", "missing_rate"), "percent_d2")
		if `_dk' 	mata: colformats("`outfile'", "summary", ("dontknow_rate"), "percent_d2")
		if `_ref' 	mata: colformats("`outfile'", "summary", ("refuse_rate"), "percent_d2")
		if `_other' mata: colformats("`outfile'", "summary", ("other_rate"), "percent_d2")
		if `_dur'   mata: colformats("`outfile'", "summary", ("duration_min", "duration_mean", "duration_median", "duration_max"), "number_sep")
					mata: colformats("`outfile'", "summary", ("formversion", "days"), "number_sep")
					mata: colformats("`outfile'", "summary", ("firstdate", "lastdate"), "date_d_mon_yy")					
					
		*** Summary (by team) ***
		
		if `_team' {
		    
			use "`tmf_main_data'", clear
			
			* generate vars to keep track of uniq number of forms, enums days in each team
			
			gen `tmv_formversion' 	= 0
			gen `tmv_days'			= 0
			gen `tmv_enum'			= 0
	
			cap confirm string var `team'
			if !_rc {
				levelsof `team', loc (teams)
				foreach t in `teams' {
					tab `formversion' 						if `team' == "`t'"
					replace `tmv_formversion' 	= `r(r)' 	if `team' == "`t'"
					tab `date'							if `team' == "`t'"
					replace `tmv_days' 			= `r(r)' 	if `team' == "`t'"
					tab `enumerator'						if `team' == "`t'"
					replace `tmv_enum'			= `r(r)'	if `team' == "`t'" 
				}
			}
			else {
				levelsof `team', loc (teams) clean
				foreach t in `teams' {
					tab `formversion' 						if `team' == `t'
					replace `tmv_formversion' 	= `r(r)' 	if `team' == `t'
					tab `date'							if `team' == `t'
					replace `tmv_days' 			= `r(r)' 	if `team' == `t'
					tab `enumerator'						if `team' == `t'
					replace `tmv_enum'			= `r(r)'	if `team' == `t' 
				}
			}

			gen `tmv_obs' = 1
			
			#d;
			collapse (first)    enumerators     = `tmv_enum'
					 (count) 	submissions 	= `tmv_obs'
					 (mean)  	consent_rate 	= `tmv_consent_yn'
					 (sum)   	missing_rate   	= `tmv_miss'
					 (sum)   	dontknow_rate  	= `tmv_dk'
					 (sum)	 	refuse_rate		= `tmv_ref'
					 (sum)		other_rate 		= `tmv_other'
					 (min)	 	duration_min   	= `tmv_dur'
					 (mean)	 	duration_mean   = `tmv_dur'
					 (median) 	duration_median = `tmv_dur'
					 (max)	 	duration_max   	= `tmv_dur'
					 (first) 	formversion 	= `tmv_formversion'
					 (min)   	firstdate 		= `date'
					 (max)   	lastdate		= `date'
					 (first) 	days 			= `tmv_days'
					 ,
					 by(`team')
				;
			#d cr
			
			* convert missing_rate to actual rates
			
			replace missing_rate 	= missing_rate/(submissions * `vars_count')
			replace dontknow_rate 	= dontknow_rate/(submissions * `vars_count')
			replace refuse_rate 	= refuse_rate/(submissions * `vars_count')
			replace other_rate 		= other_rate/(submissions * `other_count')
			
			*label variables
			lab var enumerators     "# of enums"
			lab var `team' 			"team"
			lab var submissions 	"# of submissions"
			lab var consent_rate 	"% of consent"
			lab var missing_rate   	"% missing"
			lab var dontknow_rate  	"% dont know"
			lab var refuse_rate		"% refuse"
			lab var other_rate		"% other"
			lab var duration_min   	"min duration"
			lab var duration_mean   "mean duration"
			lab var duration_median "median duration"
			lab var duration_max   	"max duration"
			lab var formversion 	"# of form versions"
			lab var firstdate 		"first date"
			lab var lastdate		"last date"
			lab var days 			"# of days"
			
			* drop consent, dk, ref, other, duration
			if !`_cons' 	drop consent_rate
			if !`_dk' 		drop dontknow_rate
			if !`_ref' 		drop refuse_rate
			if !`_other'	drop other_rate
			if !`_dur' 		drop duration_*

			ipalabels `team', `nolabel'
			export excel using "`outfile'", first(varl) sheet("summary (team)") `sheetreplace' `sheetmodify'
			mata: colwidths("`outfile'", "summary (team)")
			mata: setheader("`outfile'", "summary (team)")
			if `_cons' 	mata: colformats("`outfile'", "summary (team)", ("consent_rate", "missing_rate"), "percent_d2")
			if `_dk' 	mata: colformats("`outfile'", "summary (team)", ("dontknow_rate"), "percent_d2")
			if `_ref' 	mata: colformats("`outfile'", "summary (team)", ("refuse_rate"), "percent_d2")
			if `_other' mata: colformats("`outfile'", "summary (team)", ("other_rate"), "percent_d2")
			if `_dur'   mata: colformats("`outfile'", "summary (team)", ("duration_min", "duration_mean", "duration_median", "duration_max"), "number_sep")
						mata: colformats("`outfile'", "summary (team)", ("enumerators", "formversion", "days"), "number_sep")
						mata: colformats("`outfile'", "summary (team)", ("firstdate", "lastdate"), "date_d_mon_yy")
		
		}
		
		*** productivity ***
		
		* generate a calendar dataset
		use "`tmf_main_data'", clear
		ipagetcal `date', clear
		
		merge 1:m `date' using "`tmf_main_data'", keepusing(`date' `enumerator' `team') gen(datematch)
		gen weight = cond(datematch == 3, 1, 0)
		drop datematch
		
		* save data
		save "`tmf_datecal'"
			
		if "`period'" == "daily" {
			collapse (sum) submissions = weight, by(`enumerator' `date')
			ren `date' jvar
		}
		else if "`period'" == "weekly" {
			collapse (sum) submissions = weight, by(`enumerator' year week)
			sort week
			egen jvar = group(year week)
		}
		else {
			collapse `date' (sum) submissions = weight, by(`enumerator' year month)
			sort month
			egen jvar = group(year month)
		}
		
		ren submissions vv_
		keep vv_ `enumerator' jvar
		reshape wide vv_, i(`enumerator') j(jvar)
		recode vv_* (. = 0)
		
		egen submissions = rowtotal(vv_*)
		order submissions, after(`enumerator')
		drop if submissions == 0
		
		* add a total row
		loc add = `=_N' + 1
		set obs `add'
		
		tostring `enumerator', replace format(%15.0f)
		
		replace `enumerator' = "Total" in `add'
		
		foreach var of varlist vv_* {
				
			loc date = substr("`var'", 4, .)
			
			if "`period'" == "daily" {
				loc lab "`:disp %td  `date''"
				lab var `var' "`lab'"
			}
			else if "`period'" == "weekly" 	lab var `var' "week `date'"
			else 							lab var `var' "month `date'"
			
			mata: st_numscalar("sum", colsum(st_data(., "`var'")))
			replace `var' = scalar(sum) in `add'
		}
	
		mata: st_numscalar("sum", colsum(st_data(., "submissions")))
		replace submissions = scalar(sum) in `add'
		
		ipalabels `enumerator', `nolabel'
		export excel using "`outfile'", first(varl) sheet("`period' productivity") `sheetreplace' `sheetmodify'
		mata: colwidths("`outfile'", "`period' productivity")
		mata: setheader("`outfile'", "`period' productivity")
		mata: colformats("`outfile'", "`period' productivity", st_varname(2..st_nvar()), "number_sep")
		mata: settotal("`outfile'", "`period' productivity")
		*** productivity by team ***
		
		if `_team' {
		    
			use "`tmf_datecal'", clear
		
			if "`period'" == "daily" {
				collapse (sum) submissions = weight, by(`team' `date')
				ren `date' jvar
			}
			else if "`period'" == "weekly" {
				collapse (sum) submissions = weight, by(`team' year week)
				sort week
				egen jvar = group(year week)
			}
			else {
				collapse `date' (sum) submissions = weight, by(`team' year month)
				sort month
				egen jvar = group(year month)
			}
			
			ren submissions vv_
			keep vv_ `team' jvar
			reshape wide vv_, i(`team') j(jvar)
			recode vv_* (. = 0)
			
			egen submissions = rowtotal(vv_*)
			order submissions, after(`team')
			drop if submissions == 0
			
			* add a total row
			loc add = `=_N' + 1
			set obs `add'
			
			* replace `team' = "Total" in `add'
			
			foreach var of varlist vv_* {
					
				loc date = substr("`var'", 4, .)
				
				if "`period'" == "daily" {
					loc lab "`:disp %td  `date''"
					lab var `var' "`lab'"
				}
				else if "`period'" == "weekly" 	lab var `var' "week `date'"
				else 							lab var `var' "month `date'"
				
				mata: st_numscalar("sum", colsum(st_data(., "`var'")))
				replace `var' = scalar(sum) in `add'
			}
		
			mata: st_numscalar("sum", colsum(st_data(., "submissions")))
			replace submissions = scalar(sum) in `add'
			
			ipalabels `team', `nolabel'
			export excel using "`outfile'", first(varl) sheet("`period' productivity (team)") `sheetreplace' `sheetmodify'
			mata: colwidths("`outfile'", "`period' productivity (team)")
			mata: setheader("`outfile'", "`period' productivity (team)")
			mata: colformats("`outfile'", "`period' productivity (team)", st_varname(2..st_nvar()), "number_sep")
			mata: settotal("`outfile'", "`period' productivity (team)")
		}
		
		*** Variable Stats by enumerator ***
		
		if "`using'" ~= "" {
			* if sheetname is missing assume "enumstats"
			if "`sheetname'" == "" loc sheetname "enumstats"		
			
			* import enumstats input sheet
			import excel using "`using'", sheet("`sheetname'") clear first allstr
			
			keep variable min mean show_mean_as media max sd combine
			keep if !missing(variable)
			
			count if !missing(variable)
			if `r(N)' == 0 {
				disp as err "variable column is required in `sheetname'"
				ex 198
			}
			
			* check that all rows have at least one stats specification
			egen syntax_check = rowmiss(min mean median sd max)
			
			count if syntax_check == 5
			if `r(N)' > 0 {
				disp as err "missing stats specification for `r(N)' rows"
				gen row = _n + 1
				noi list if syntax_check == 5
				ex 198
			}
						
			drop syntax_check
			
			* set default value for show_mean_as to number_sep
			replace show_mean_as = cond(lower(show_mean_as) == "percentage", "percent_d2", "number_sep_d2")
			replace show_mean_as = "" if missing(mean)
			loc statsvar_count = c(N)
			
			* gen an input label
			gen input_lab = variable
			
			* save input data into a frame
			cap frame drop frm_enumstats
			frames copy default frm_enumstats
			
			levelsof variable, loc (statvars) clean
			
			use `enumerator' `statvars' using "`tmf_main_data'", replace
			
			* expand and replace vars in input sheet
			forval i = 1/`statsvar_count' {

				frames frm_enumstats: loc vars`i' = variable[`i']
				unab vars`i': `vars`i''
				frames frm_enumstats: replace variable = "`vars`i''" in `i'
			}
			
			* rename and reshape outlier vars
			loc i 1
			foreach var of varlist `statvars' {
				* check that variable is numeric
				cap confirm numeric var `var'
				if _rc == 7 {
					disp as err "Variable `var' must be a numeric variable"
					ex 7
				}

				ren `var' ovvalue_`i'
				gen ovname_`i' = "`var'" if !missing(ovvalue_`i')
				loc ++i
			}
			
			gen reshape_id = _n

			reshape long ovvalue_ ovname_, i(reshape_id) j(index)
			ren (ovvalue_ ovname_) (value variable)
			
			drop if missing(value)
			drop reshape_id index

			* gen placeholders for important vars
			loc statvars "count min mean median sd max"
			foreach var of newlist `statvars' {
				gen value_`var' = .
			}
			
			gen combine 	= variable
			gen combine_ind = 0
			gen input_lab 	= ""
			
			* calculate outliers
			forval i = 1/`statsvar_count' {
				
				frames frm_enumstats {
					loc vars`i' 		= variable[`i']
					loc min`i'			= min[`i']
					loc mean`i'			= mean[`i']
					loc median`i'		= median[`i']
					loc sd`i'			= sd[`i']
					loc max`i'			= max[`i']
					loc combine`i' 		= combine[`i'] 
					loc input_lab`i'	= input_lab[`i']
				}
			
				* check if vars are combined
				if lower("`combine`i''") == "yes" {
					foreach var in `vars`i'' {
						replace combine = "`vars`i''" 			if variable == "`var'"
						replace combine_ind = 1 				if variable == "`var'"
						replace input_lab = "`input_lab`i''"	if variable == "`var'"
					}
					
					bys `enumerator': egen vcount   = count(value)  if combine == "`vars`i''"
					bys `enumerator': egen vmin 	  = min(value) 	  if combine == "`vars`i''"
					bys `enumerator': egen vmean    = mean(value)   if combine == "`vars`i''"
					bys `enumerator': egen vmedian  = median(value) if combine == "`vars`i''"
					bys `enumerator': egen vsd  	  = sd(value) 	  if combine == "`vars`i''"
					bys `enumerator': egen vmax 	  = max(value) 	  if combine == "`vars`i''"
					
					replace value_count 	= vcount 	  if combine == "`vars`i''"
					replace value_min 		= vmin 		  if combine == "`vars`i''"
					replace value_mean 		= vmean 	  if combine == "`vars`i''"
					replace value_median 	= vmedian 	  if combine == "`vars`i''"
					replace value_sd 	  	= vmedian 	  if combine == "`vars`i''"
					replace value_max 		= vmax 		  if combine == "`vars`i''"
					
					drop vcount vmin vmax vmean vmedian vsd
					
				}
				else {
					foreach var in `vars`i'' {
						
						replace input_lab = "`input_lab`i''"	if variable == "`var'"
						
						bys `enumerator': egen vcount   = count(value)  if variable == "`var'"
						bys `enumerator': egen vmin 	  = min(value) 	  if variable == "`var'"
						bys `enumerator': egen vmean    = mean(value)   if variable == "`var'"
						bys `enumerator': egen vmedian  = median(value) if variable == "`var'"
						bys `enumerator': egen vsd  	  = sd(value) 	  if variable == "`var'"
						bys `enumerator': egen vmax 	  = max(value) 	  if variable == "`var'"
					
						replace value_count 	= vcount 	  if variable == "`var'"
						replace value_min 		= vmin 		  if variable == "`var'"
						replace value_mean 		= vmean 	  if variable == "`var'"
						replace value_median 	= vmedian 	  if variable == "`var'"
						replace value_sd 	  	= vmedian 	  if variable == "`var'"
						replace value_max 		= vmax 		  if variable == "`var'"

						drop vcount vmin vmax vmean vmedian vsd
					}
				}
			}
			
			frames frm_enumstats: save "`tmf_varcodes'"
			
			merge m:1 input_lab using "`tmf_varcodes'", nogen keep(match)	
			replace input_lab = variable if !combine_ind
			duplicates drop `enumerator' input_lab, force
			
			encode input_lab, gen (index)
			su index
			loc index_count `r(max)'
			
			forval i = 1/`index_count' {
				loc lab`i' "`:lab index `i''"
			}
			
			cap frame drop frm_enumstats
			frame copy default frm_enumstats, replace
			
			keep `enumerator' value_count value_min value_mean value_median value_sd value_max index			
			reshape wide value_count value_min value_mean value_median value_sd value_max, i(`enumerator') j(index)
			
			recode value_count* (. = 0)
			
			frames frm_enumstats {
				duplicates drop input_lab, force
				sort index
				loc varcount = c(N)
				mata: labs = st_sdata(., "input_lab")
				
				count if show_mean_as == "percent_d2"
				if `r(N)' > 0 {
					gen row = _n 
					levelsof row if show_mean_as == "percent_d2", loc (rows) clean sep("\")
					mata: percentcols = st_sdata((`rows'), "input_lab")
					drop row
				}
				else mata: percentcols = ("")

			}
			
			forval i = 1/`varcount' {
				foreach stat in count min mean median sd max {
					if "`stat'" == "count" {
						lab var value_count`i' "count"
					}
					else {
						frames frm_enumstats: loc keepstat = `stat'[`i']
						if lower("`keepstat'") ~= "yes" drop value_`stat'`i'
						else lab var value_`stat'`i' "`stat'"
					}
				}				
			}
			
			frames drop frm_enumstats
			
			ipalabels `enumerator', `nolabel'
			export excel using "`outfile'", first(varl) sheet("enumstats") cell(A2) `sheetreplace' `sheetmodify'
			mata: colwidths("`outfile'", "enumstats")
			mata: format_edb_stats("`outfile'", "enumstats", labs, percentcols)
		}
	}
	
end