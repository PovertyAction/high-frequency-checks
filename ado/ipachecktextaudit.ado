*! version 3.0.0 Innovations for Poverty Action 30oct2018

* Stata program for merging and summarise text audit data from surveycto
* This program draws heavily from Nathan Barker and Chris Boyer's work on tamerge

prog define ipachecktextaudit, rclass
	syntax varname  using/, saving(string)					///
							MEDia(string) 					///
							ENUMerator(varname)				///
							[KEEPvars(string)				///
							PREfix(name)					///
							STATS(name min = 1 max = 9)		///
							dta(string)]	

	* written in version 15
	* requires version 14.1
	version 14.1				
	
	qui {
		* add extension to using file
		if !regexm("`saving'", "\.xlsx|\.xls") loc saving "`saving'.xlsx"
		
		* clean keepvars
		loc keep = trim(itrim(subinstr("`keep'", ";", "", .)))

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
		
		* get prefix. Use dfault prefix ta_ if no prefix is specified
		if 		"`prefix'" ~= "" loc pre "`prefix'"
		else 	loc pre "ta_"

	
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
		
		save "`master'", replace
		
		* keep only data with text audits
		drop if missing(`varlist')
		save "`tadata'", emptyok
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
			save "`tadata_long'", emptyok
			
			* miss_count will track number of ta files that could not be found in file
			loc misscount 0
			forval i = 1/`tacount' {
				cap import delim using "`media'/`taf_`i''", clear
				if !_rc {
					gen 	`varlist' = "media\\`taf_`i''"
					append	using "`tadata_long'"
					save 	"`tadata_long'", replace
				}
				else if _rc == 601 loc ++misscount
				
			}

			* Compare the number of missing ta files to the number of files expected
			* STOP: If all files are missing from folder	
			if `misscount' == `tacount' {
				noi disp as err "{p}All " as res `misscount' " of " as res `tacount' ///
					" media files not found in folder `media'. Please specify the correct media folder{p_end}"
				ex 601
			}
			else {
				* SHOW WARNING: If some ta files are missing
				if `misscount' > 0 {
					noi disp as err "{p} " as res `misscount' " of " `tacount' ///
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

				collapse (sum) ta_ (first) groupname, by(fieldname `varlist')
				
				* merge in enumerator and other data
				loc keeplist: list keepvars - enumerator

       loc keeplist = ustrtrim(subinstr(subinstr("`keeplist'", ";", "", .), ".", "", .)) 

				merge m:1 `varlist' using "`tadata'", keepusing(`enumerator' `keeplist') ///
					assert(match) nogen
				order `enumerator' `keeplist' fieldname `pre' `varlist'
				
				* save dataset
				if "`dta'" ~= "" save "`dta'", replace
				
				* save long data in long format
				save "`tadata_long'", replace
				
				* PREPARE GROUP DATA
				* import input data from input survey
				import excel using "`using'", sheet("13. text audit") first case(lower) allstr clear
				drop if missing(group_name)
				if `=_N' > 0 {
					* Check that for each variable specified a group name is also specified
					* Check that group names are uniques
					isid group_name
					* prefix exclude vars
					replace exclude_variable = "`pre'" + exclude_variable
					* keep count of the number of groups
					loc groupcount `=_N'
					* save group names and excluded vars in locals
					forval i = 1/`groupcount' {
						loc gn_`i' = group_name[`i']
						loc ev_`i' = exclude_variable[`i']
					}
					
					* re-import dataset and form group data
					use "`tadata_long'", clear
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
				save "`tadata_wide'"
				
				* sum variables into groups
				loc keepgroups ""
				forval i = 1/`groupcount' {
					egen tg_`gn_`i'' = rowtotal(`gn_`i'_vars')
					loc keepgroups "`keepgroups' tg_`gn_`i''" 
				}
				
				* save group data in wide format
				keep `enumerator' `keeplist' `keepgroups' `varlist'
				save "`tagroup_wide'", replace
				
				* save group data in long format
				reshape long tg_, i(`varlist') j(groupname) str
				save "`tagroup_long'"
				
				* Define Statistics
				if "`stats'" == "" loc stats "count mean median sd min max"
				else loc stats "count `stats'"
				
				* export statistics on durations per field(fields)
				* export field stats for vars
				use "`tadata_long'", clear
				
				collapse_long `pre', stats(`stats') by(fieldname)
				replace fieldname = subinstr(fieldname, "`pre'", "", 1)
				* export field stats for groups
				export excel using "`saving'", sheet(fields) first(var) cell(A2) replace

				mata: add_formatting("`saving'", "fields", "FIELD DURATION SUMMARIES (in seconds)", 1)
				
				* export summary statistics by group
				if `groupcount' > 0 {
					use "`tagroup_long'", clear
					collapse_long tg_, stats(`stats') by(groupname)
					replace groupname = subinstr(groupname, "tg_", "", 1)
					* export field stats for groups
					export excel using "`saving'", sheet(groups) sheetmodify first(var) cell(A2)
					* format headers for stata 14 and later version

					mata: add_formatting("`saving'", "groups", "GROUP DURATION SUMMARIES", 1)
				}

				* Export average time in seconds by enumerator(enumerator-fields)
				use "`tadata_wide'", clear
				
				if "`keeplist'" ~= "" collapse (first) `keeplist' (mean) `pre'*, by(`enumerator')
				else collapse (mean) `pre'*, by(`enumerator')
				order `pre'*, last
				foreach var of varlist `pre'* {
					replace `var' = round(`var')
				}
				
				* export field stats for groups
				export excel using "`saving'", sheet(enumerators-fields) sheetmodify first(var) cell(A2)

				loc startcount = wordcount("`enumerator' `keeplist'") + 1
				mata: add_formatting("`saving'", "enumerators-fields", "FIELD DURATION SUMMARIES BY ENUMERATOR (in seconds)", `startcount')

				* Export average time in seconds by group(group-fields)
				use "`tagroup_wide'", clear
				
				if "`keeplist'" ~= "" collapse (first) `keeplist' (mean) tg_*, by(`enumerator')
				else collapse (mean) tg_*, by(`enumerator')
				order tg_*, last
				foreach var of varlist tg_* {
					replace `var' = round(`var')
				}
				
				* export field stats for groups
				export excel using "`saving'", sheet(enumerators-groups) sheetmodify first(var) cell(A2)

				loc startcount = wordcount("`enumerator' `keeplist'") + 1
				mata: add_formatting("`saving'", "enumerators-groups", "GROUP DURATION SUMMARIES BY ENUMERATOR (in seconds)", `startcount')

			}
		}
		else {
			nois disp "{red:No text Audit Data Recorded}"
		}
    
		use "`master'", clear

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


mata:
mata clear

void add_formatting(string scalar filename, string scalar sheetname, string scalar header, real scalar start)
{

	class xl scalar b
	real scalar column_width, columns, ncols, nrows, i, colmaxval

	ncols = st_nvar()
	nrows = st_nobs() + 2

	b = xl()

	b.load_book(filename)
	b.set_sheet(sheetname)
	b.set_mode("open")

	b.set_top_border(1, (1, ncols), "thick")
	b.set_bottom_border((1,2), (1, ncols), "thick")
	b.set_sheet_merge(sheetname, (1, 1), (start, ncols))
	if (start > 1) {
		b.set_horizontal_align(1, (start, ncols), "left")
		b.set_left_border((1, nrows), start, "thick")
	}
	else {
		b.set_horizontal_align(1, (start, ncols), "merge")
	}
	b.put_string(1, start, header) 

	b.set_font_bold((1,2), (1,ncols), "on")

	b.set_right_border((1,nrows), ncols, "thick")
	b.set_bottom_border(nrows, (1,ncols), "thick")

	for (i = 1;i <= ncols;i ++) {
		namelen = strlen(st_varname(i))
		if (st_isnumvar(i)) {
			colmaxval = colmax(st_data(., i))
			if (colmaxval == 0) {
				collen = 0
			}
			else {
				collen = log(colmax(st_data(., i)))
			}
		}
		else {
			collen = colmax(strlen(st_sdata(., i)))
		}
		if (namelen > collen) {
			column_width = namelen + 1
		}
		else {
			column_width = collen + 1
		}
		if (column_width > 101) {
			column_width = 101
		}	
		b.set_column_width(i, i, column_width)
	}	

	b.close_book()
}
end



