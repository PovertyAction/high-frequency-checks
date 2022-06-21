*! version 4.0.0 11may2022
*! Innovations for Poverty Action
* ipachecktextaudit: Import and analyse text audit data

program ipachecktextaudit, rclass
	
	#d;
	syntax varname, 
			ENUMerator(varname) 
			TEXTAUDITdata(string)
			OUTFile(string)
			[stats(name min = 1 max = 9)]
			[SHEETMODify SHEETREPlace]
			[NOLABel]
		;
	#d cr
		
	qui {
	    
		preserve

		tempvar tmv_index tmv_row tmv_fmt

		tempfile tmf_main_data tmf_ta_data tmf_ta tmf_ta_group_stats
		
		* if stats are specified, check that is in the allowed list of stats
		loc all_stats "count mean max min sd iqr p25 p50 p75"
		if "`stats'" ~= "" {
			loc stats = subinstr("`stats'", "median", "p50", .)
			loc viol: list stats - all_stats
			if "`viol'" ~= "" {
				loc all_stats = subinstr("`all_stats'", "p50", "p50 (median)", 1)
				nois disp as err "{p}" as res "`viol'" as txt " invalid statistic. " ///
					"Allowed stats include " as res "`all_stats' {p_end}" 
				ex 198
			}
		}
		else loc stats "`all_stats'"
		
		* keep only relevant variables and observations
		keep `varlist' `enumerator'
		
		keep if !missing(`varlist')
		loc obs_cnt 	= `c(N)'
		
		if `c(N)' > 0 {
			
			* extract id from media file
			* check if data was downloaded from browser or api | from desktop
			cap assert regexm(`varlist', "^https")
			if !_rc {
			    * browser or API 
			    replace `varlist' = substr(`varlist', strpos(`varlist', "uuid:") + 5, ///
							strpos(`varlist', "&e=") - strpos(`varlist', "uuid:") - 5)
				replace `varlist' = "TA_" + `varlist'
			}
			else if regexm(`varlist', "^media") {
			    * surveycto desktop
			    replace `varlist' = substr(`varlist', strpos(`varlist', "media\") + 6, ///
							strpos(`varlist', ".csv") - strpos(`varlist', "media\") - 6)
			}
			
			isid `varlist'
			merge 1:m `varlist' using "`textauditdata'", nogen keep(match)
			
			if `obs_cnt' == 0 {
				disp as err "Data in `textauditdata' does not match current dataset on id variable `varlist'"
				ex 198
			}
			
			* keep only needed variables 
			cap confirm var devicetime 
			if !_rc {
				keep fieldname durationms `varlist' `enumerator'
				ren (durationms) (duration)
			}
			else {
				keep fieldname totalduration `varlist' `enumerator'
				ren (totalduration) (duration)
			}
			
			* gen group & field from field name
			gen groupname = substr(fieldname, 1, length(fieldname) - strpos(reverse(fieldname), "/")) if regexm(fieldname, "/")
			replace fieldname = substr(fieldname, -(strpos(reverse(fieldname), "/")) + 1, .)
			
			destring duration, replace
			
			* drop negative duration. Unrealiable data caused by time travel in SurveyCTO app
			replace duration = . if duration <= 0
	
			save "`tmf_ta'", replace
			
			*** FIELD STATS ***
		
			collapse (count) count 	= duration ///
					 (min)	 min 	= duration  ///
					 (max)	 max	= duration  ///
					 (mean)  mean	= duration 	///
					 (sd)	 sd     = duration  ///
					 (iqr) 	 iqr	= duration  ///
					 (p25) 	 p25 	= duration  ///
					 (p50)	 p50 	= duration  ///
					 (p75) 	 p75 	= duration, by(fieldname)
					 
			foreach stat of loc all_stats {
				if !`:list stat in stats' drop `stat'
			}
					 
			export excel using "`outfile'", sheet("field stats") first(var) replace
			mata: colwidths("`outfile'", "field stats")
			mata: setheader("`outfile'", "field stats")
			
			foreach stat of loc all_stats {
				if `:list stat in stats' {
					if inlist("`stat'", "count", "min", "max") mata: colformats("`outfile'", "field stats", "`stat'", "number_sep")
					else mata: colformats("`outfile'", "field stats", "`stat'", "number_d2")
				}
			}
			
			*** FIELD AVERAGE BY ENUMERATOR ***
			
			use "`tmf_ta'", clear
		
			collapse (mean)  ta_	= duration, by(fieldname `enumerator')
			cap frame drop frm_subset
			frame put fieldname, into(frm_subset)
			frame frm_subset {
			    duplicates drop fieldname, force
				gen varindex = _n
				loc varcount `c(N)'
			}
			frlink m:1 fieldname, frame(frm_subset)
			frget varindex = varindex, from(frm_subset)
			drop fieldname frm_subset
			reshape wide ta_, i(`enumerator') j(varindex) 
			* adjust varname lengths so that col widths will be properly adjusted
			forval i = 1/`varcount' {
				frame frm_subset: loc var = fieldname[`i']
				loc newname = "ta_`i'_" + ("0" * (length("`var'") - length("ta_`i'") - 1))
				lab var ta_`i' "`var'" 
				ren ta_`i'  `newname'
			}
			
			frame drop frm_subset
					
			lab var `enumerator' "`enumerator'"
			ipalabels `enumerator', `nolabel'
			
			export excel using "`outfile'", sheet("field average by enumerator") first(varl)
			mata: colwidths("`outfile'", "field average by enumerator")
			mata: setheader("`outfile'", "field average by enumerator")
			* mata: colformats("`outfile'", "field average by enumerator", st_varname(2..st_nvar()), "number_sep_d2")		
			
			*** GROUP STATS ***
			
			use "`tmf_ta'", clear
			count if !missing(groupname)
			if `r(N)' > 0 {
				
				* remove instance numbers and "/" & [*] from groups 
				replace groupname = subinstr(groupname, "/", " ", .)
				loc cont 1
				
				while `cont' == 1 {
					replace groupname = regexr(groupname, "\[[0-9]+\]", " ")
					count if regexm(groupname, "\[")
					if !`r(N)' loc cont 0
				}
				
				levelsof groupname, loc (groups) clean
				loc groups: list uniq groups
				
				loc i 1
				foreach group of loc groups {
					use "`tmf_ta'", clear
					keep if regexm(groupname, "`group'\[")
					gen group = "`group'"
					if `c(N)' > 0 {
						collapse (count) count 	= duration 	///
								 (min)	 min 	= duration  ///
								 (max)	 max	= duration  ///
								 (mean)  mean	= duration 	///
								 (sd)	 sd     = duration  ///
								 (iqr) 	 iqr	= duration  ///
								 (p25) 	 p25 	= duration  ///
								 (p50)	 p50 	= duration  ///
								 (p75) 	 p75 	= duration, by(group)
								 
						 if `i' == 1 save "`tmf_ta_group_stats'"
						 else {
							append using "`tmf_ta_group_stats'"
							save "`tmf_ta_group_stats'", replace
						 } 
					}
					loc ++i
				}
				
				foreach stat of loc all_stats {
					if !`:list stat in stats' drop `stat'
				}
				
				sort group
				
				foreach stat of loc all_stats {
					if !`:list stat in stats' drop `stat'
				}
				
				export excel using "`outfile'", sheet("group stats") first(var)
				mata: colwidths("`outfile'", "group stats")
				mata: setheader("`outfile'", "group stats")
				
				foreach stat of loc all_stats {
					if `:list stat in stats' {
						if inlist("`stat'", "count", "min", "max") {
							mata: colformats("`outfile'", "group stats", "`stat'", "number_sep")
						}
						else {
							mata: colformats("`outfile'", "group stats", "`stat'", "number_d2")
						}
					}
				}
				
				*** GROUP AVERAGE BY ENUMERATOR ***
				use "`tmf_ta'", clear
				
				loc i 1
				foreach group of loc groups {
					use "`tmf_ta'", clear
					keep if regexm(groupname, "`group'\[")
					gen group = "`group'"
					if `c(N)' > 0 {
						collapse (mean)  ta_	= duration, by(group `enumerator')
						 if `i' == 1 save "`tmf_ta_group_stats'", replace
						 else {
							append using "`tmf_ta_group_stats'"
							save "`tmf_ta_group_stats'", replace
						 } 
					}
					loc ++i
				}
				
				frame put group, into(frm_subset)
				frame frm_subset {
					duplicates drop group, force
					gen groupindex = _n
					loc groupcount `c(N)'
				}
				frlink m:1 group, frame(frm_subset)
				frget groupindex = groupindex, from(frm_subset)
				drop group frm_subset
				reshape wide ta_, i(`enumerator') j(groupindex) 
				* adjust varname lengths so that col widths will be properly adjusted
				forval i = 1/`groupcount' {
					frame frm_subset: loc group = group[`i']
					loc newname = "ta_`i'_" + ("0" * (length("`group'") - length("ta_`i'") - 1))
					lab var ta_`i' "`group'" 
					ren ta_`i'  `newname'
				}
						
				lab var `enumerator' "`enumerator'"
				ipalabels `enumerator', `nolabel'
				export excel using "`outfile'", sheet("group average by enumerator") first(varl)
				mata: colwidths("`outfile'", "group average by enumerator")
				mata: setheader("`outfile'", "group average by enumerator")
				* mata: colformats("`outfile'", "group average by enumerator", st_varname(2..st_nvar()), "number_d2")
			}
		}
		
	} 

end 