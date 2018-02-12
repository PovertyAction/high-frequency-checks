*! version 1.0.0 Ishmail Azindoo Baako 26jul2017

* Stata program for merging and analyzing text audit data from surveycto
* This program draws heavily from Nathan Barker and Chris Boyer's work on tamerge

prog define ipachecktextaudit, rclass
	syntax varname  using/, MEDia(string) 					///
							ENUMerator(varname)				///
							[KEEP(string)					///
							PREfix(name)					///
							STATS(name min = 1 max = 9)		///
							save(string)]					
	
	qui {
		* add extension to using file
		if !regexm("`using'", "\.xlsx|\.xls") loc using "`using'.xlsx"
		
		* clean keepvars
		loc keep = trim(itrim(subinstr("`keep'", ";", "", .)))
		noi disp "`keep'"

		* if stats are specified, check that is in the allowed list of stats
		loc all_stats "count mean max min sd iqr p25 p50 p75"
		if "`stats'" ~= "" {
			loc stats = subinstr("`stats'", "median", "p50", .)
			loc viol: list stats - all_stats
			if "`stats'" ~= "" {
				loc all_stats = subinstr("`all_str'", "p50", "p50 (median)", 1)
				nois disp as err "{p} `stats' invalid statistic. " ///
					"Allowed stats inlcude `all_stats'" 
				ex 198
			}
		}
	
		* temporary files
		#d;
		tempfile 	master	 			// Original dataset
					tadata 				// Observations with audits only
					tadata_long 		// Merged text audit data in long format
					tadata_wide			// Merged text audit data in wide format
					tagroup_long		// Long format of group data
					tagroup_wide		// Wide format of group data
			;
		#d cr
		
		save `master', replace
		
		* get prefix. Use dfault prefix ta_ if no prefix is specified
		if 		"`prefix'" ~= "" loc pre "`prefix'"
		else 	loc pre "ta_"

		* keep only data with text audits
		drop if missing(`varlist')
		save `tadata', emptyok
		loc tacount `=_N'
	
		if `tacount' > 0 {
			* check that data is unique on text_audit
			isid `varlist'
			
			* loop through and save the name of each audit file in a local
			forval i = 1/`tacount' {
				loc taf_`i' = subinstr(`varlist'[`i'], "media\", "", 1) 
			}
			
			* Loop through scto media folder and import ta csvs on at a time 
			* appending them to the prevously imported dataset
			clear
			save `tadata_long', emptyok
			
			* miss_count will track number of ta files that could not be found in file
			loc miss_count 0
			forval i = 1/`tacount' {
				cap import delim using "`media'/`taf_`i''", clear
				if !_rc {
					gen 	text_audit = "media\\`taf_`i''"
					append	using `tadata_long'
					save 	`tadata_long', replace
				}
				else if _rc == 601 loc ++miss_count
				
			}

			* Compares the number of missing ta files to the number of files expected
			* STOP: If all files are missing from folder	
			if `miss_count' == `tacount' {
				noi disp as err "{p}All " as res `miss_ta' " of " as res `tacount' ///
					" media files not found in folder `media'. Please specify the correct media folder{p_end}"
				ex 601
			}
			else {
				* SHOW WARNING: If some ta files are missing
				if `miss_count' > 0 {
					noi disp as err "{p} " as res `miss_ta' " of " `tacount' ///
						" media files not found in folder `media'. Please specify the correct media folder{p_end}"
				}
			
				* PREPARE FILES: Prepare dataset and save long and wide format version
				* rename fieldname to groupname and generate fieldname var
				rename 	fieldname 	groupname
				egen 	fieldname = ends(groupname), last punc(/)

				* remove fieldname from group name and prefix groupname with "/"
				gen 	fieldfilter = "/" + fieldname
				replace groupname 	= "/" + subinstr(groupname, fieldfilter, "", .) 
				replace groupname 	= "" if !regexm(groupname, "\[")
				
				* rename duration variable to prefix
				ren (totaldurationseconds) (`pre')
				
				* drop unneeded variables
				drop fieldfilter firstappearedsecondsintosurvey
				
				* include prefix in variable names
				replace fieldname = "`pre'" + fieldname
				
				* merge in enumerator and other data
				loc keeplist: list keep - enumerator
				merge m:1 `varlist' using `tadata', keepusing(`enumerator' `keeplist') ///
					assert(match) nogen
				order `enumerator' `keeplist' fieldname `pre' `varlist'
				
				* save dataset
				if "`save'" ~= "" save "`save'", replace
				
				* save long data in long format
				save `tadata_long', replace
				
				* PREPARE GROUP DATA
				* import input data from input survey
				import excel using "${infile}", sheet("text audit") first case(lower) allstr clear
				drop if missing(group_name)
				if `=_N' > 0 {
					* Check that for each variable specified a group name is also specified
					* Check that group names are uniques
					isid group_name
					* prefix exclude vars
					replace exclude_variable = "ta_" + exclude_variable
					* keep count of the number of groups
					loc groupcount `=_N'
					* save group names and excluded vars in locals
					forval i = 1/`groupcount' {
						loc gn_`i' = group_name[`i']
						loc ev_`i' = exclude_variable[`i']
					}
					
					* re-import dataset and form group data
					use `tadata_long', clear
					* save variables list for each group removing exclude_variable vars when needed
					
					forval i = 1/`groupcount' {
						* get variable names for the group
						levelsof fieldname if regexm(groupname, "/`gn_`i''\["), loc (gn_`i'_vars) clean
						loc gn_`i'_vars: list gn_`i'_vars - ev_`i'
					}
				}
								
				* drop group_name and reshape data to wide format
				drop groupname
				replace fieldname = subinstr(fieldname, "`pre'", "", 1)
				reshape wide `pre', i(`varlist') j(fieldname) str
				order `enumerator' `keeplist'
				
				* save wide format of dataset
				save `tadata_wide'
				
				* sum variables into groups
				loc keepgroups ""
				forval i = 1/`groupcount' {
					egen tg_`gn_`i'' = rowtotal(`gn_`i'_vars')
					loc keepgroups "`keepgroups' tg_`gn_`i''" 
				}
				
				* save group data in wide format
				keep `enumerator' `keeplist' `keepgroups' `varlist'
				save `tagroup_wide', replace
				
				* save group data in long format
				reshape long tg_, i(`varlist') j(groupname) str
				save `tagroup_long'
				
				* Define Statistics
				if "`stats'" == "" loc stats "count mean median sd min max"
				else loc stats "count `stats'"
				
				* export statistics on durations per field(fields)
				* export field stats for vars
				use `tadata_long', clear
				
				collapse_long `pre', stats(`stats') by(fieldname)
				replace fieldname = subinstr(fieldname, "`pre'", "", 1)
				* export field stats for groups
				export excel using "`using'", sheet(fields) sheetmodify first(var) cell(A2)
				* format headers for stata 14 and later version
				putexcel set "`using'", sheet(fields) modify
				d, s
				loc col = char(64 + `r(k)')
				if `c(version)' >= 14.0 {
					putexcel B1:`col'1 = "SUMMARIES OF DURATION(IN SECONDS) BY FIELD", ///
						bold merge hcenter border(bottom, double)
					putexcel A2:`col'2, bold border(bottom)
				}
				else {
					putexcel B1 = "SUMMARIES OF DURATION(IN SECONDS) BY FIELD"
				}
			
				* export summary statistics by group
				if `groupcount' > 0 {
					use `tagroup_long', clear
					collapse_long tg_, stats(`stats') by(groupname)
					replace groupname = subinstr(groupname, "tg_", "", 1)
					* export field stats for groups
					export excel using "`using'", sheet(groups) sheetmodify first(var) cell(A2)
					* format headers for stata 14 and later version
					putexcel set "`using'", sheet(groups) modify
					d, s
					loc col = char(64 + `r(k)')
					if `c(version)' >= 14.0 {
						putexcel B1:`col'1 = "SUMMARIES OF DURATION(IN SECONDS) BY GROUP", ///
							bold merge hcenter border(bottom, double)
						putexcel A2:`col'2, bold border(bottom)
					}
					else {
						putexcel B1 = "SUMMARIES OF DURATION(IN SECONDS) BY GROUP"
					}
				}

				* Export average time in seconds by enumerator(enumerator-fields)
				use `tadata_wide', clear
				
				if "`keeplist'" ~= "" collapse (first) `keeplist' (mean) `pre'*, by(`enumerator')
				else collapse (mean) `pre'*, by(`enumerator')
				order `pre'*, last
				foreach var of varlist `pre'* {
					replace `var' = round(`var')
				}
				
				* export field stats for groups
				export excel using "`using'", sheet(enumerators-fields) sheetmodify first(var) cell(A2)
				putexcel set "`using'", sheet(enumerators-fields) modify
				loc col = wordcount("`enumerator' `keeplist'") + 1
				alphacol `col'
				loc startcol "`r(alphacol)'"
				d, s
				alphacol `r(k)'
				loc endcol "`r(alphacol)'"
				* format headers for stata 14 and later version
				if `c(version)' >= 14.0 {
					putexcel `startcol'1:`endcol'1 = "AVERAGE DURATION(IN SECONDS) PER FIELD BY ENUMERATOR", ///
						bold merge border(bottom, double)
					putexcel A2:`endcol'2, bold border(bottom)
				}
				else {
					putexcel `startcol'1 = "AVERAGE DURATION(IN SECONDS) PER FIELD BY ENUMERATOR"
				}
				
				* Export average time in seconds by group(group-fields)
				use `tagroup_wide', clear
				
				if "`keeplist'" ~= "" collapse (first) `keeplist' (mean) tg_*, by(`enumerator')
				else collapse (mean) tg_*, by(`enumerator')
				order tg_*, last
				foreach var of varlist tg_* {
					replace `var' = round(`var')
				}
				
				* export field stats for groups
				export excel using "`using'", sheet(enumerators-groups) sheetmodify first(var) cell(A2)
				putexcel set "`using'", sheet(enumerators-groups) modify
				loc col = wordcount("`enumerator' `keeplist'") + 1
				alphacol `col'
				loc startcol "`r(alphacol)'"
				d, s
				alphacol `r(k)'
				loc endcol "`r(alphacol)'"
				* format headers for stata 14 and later version
				if `c(version)' >= 14.0 {
					putexcel `startcol'1:`endcol'1 = "AVERAGE DURATION(IN SECONDS) PER GROUP BY ENUMERATOR", ///
						bold merge border(bottom, double)
					putexcel A2:`endcol'2, bold border(bottom)
				}
				else {
					putexcel `startcol'1 = "AVERAGE DURATION(IN SECONDS) PER GROUP BY ENUMERATOR"
				}


			}
		}
		else {
			nois disp "{red:No text Audit Data Recorded}"
			use `master', clear
		}
	}
end

* Chris Boyer's alphacol 
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

program collapse_long
	syntax varname, stats(name min = 1 max = 9) by(varlist)
	
	#d;
	collapse	(count)	count	= `varlist' 
				(mean) 	mean	= `varlist' 
				(max)	max		= `varlist'
				(min)	min		= `varlist'
				(sd)	sd		= `varlist'
				(iqr)	iqr		= `varlist'
				(p25)	p25		= `varlist'
				(p50)	median	= `varlist'
				(p75)	p75		= `varlist'
				, by(`by')
		;
	#d cr	
	
	* determine vars to drop
	loc all_stats "count mean max min sd iqr p25 median p75"
	loc drop_vars: list all_stats - stats
	if "`drop_vars'" ~= "" drop `drop_vars'
	order `stats', last
	foreach var in `stats' {
		replace `var' = round(`var')
	}
end
