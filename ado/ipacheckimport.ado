*! version 1.1.0 Christopher Boyer 22feb2017
*! version 1.0.1 Kelsey Larson 08jan2017
*! version 1.0.0 Christopher Boyer 04may2016

program ipacheckimport, rclass
	/* This program imports high frequency check inputs
	   as Stata globals from an excel spreadsheet. The 
	   checks are based on IPA's minimum checks for 
	   data quality assurance */
	version 13

	syntax using/
	
	di ""
	di "Reading `using'..."

	qui {
		preserve
	
		tempvar tmp
		tempfile tmpsheet

		local sheets =                  ///
			`""0. setup""' +            ///
			`""1. incomplete""' +       ///
			`""2. duplicates""' +       ///
			`""3. consent""' +          ///
			`""4. no miss""' +          ///
			`""5. follow up""' +        ///
			`""6. logic""' +            ///
			`""7. all miss""'  +        ///
			`""8. constraints""' +      ///
			`""9. specify""' +          ///
			`""10. dates""' +           ///
			`""11. outliers""'  +       ///
			`""12. field comments""' +  ///
			`""13. text audit""' 	 +  ///
			`""enumdb""'  +             ///
			`""research oneway""' +     ///
			`""research twoway""' +     ///
			`""backchecks""'
		
		* store number of sheets
		local wc: word count `sheets'

	    foreach sheet in `sheets' {
	    	* display sheet name to be read
			nois di `"`sheet'"'

	    	* read the data from the input file
	    	cap import excel using "`using'", sheet(`"`sheet'"') firstrow clear

			* return error if unable to read sheet
			if _rc {
				di as err "Input sheet `sheet' not found"
				error 198
			}

	    	* collect the headers
	    	unab colnames: _all

	    	* get current sheet number, decrement by 1 to match sheet #s
	    	local n : list posof `"`sheet'"' in sheets	
	    	local --n
					
	    	* drop missing and/or incomplete rows
			local col1 : word 1 of `colnames'
	    	drop if mi(`col1')

	    	* count number of rows
			local rows = _N

			* add a temporary variable to check for matching boxes
			g `tmp' = _n
			save `tmpsheet', replace

			* the set up sheet is different from all others
			if `"`sheet'"' == "0. setup" {
				* define lists of entry boxes and matching globals to be defined
				*<!> TO ADD => replacements file, master tracking list, tracking globals
				local boxes =                                 ///
					`""Survey Dataset""' 	 				+ ///
					`""Back Check Dataset""' 				+ ///
					`""Master Tracking Dataset \(opt\.\)""' + ///
					`""HFC \& BC Input file""' 				+ ///
					`""Corrections Workbook \(opt\.\)""' 		+ ///
					`""Corrections WorkSheet \(opt\.\)""' 	+ ///
					`""HFC Output File""' 					+ ///
					`""HFC Enumerator File""' 				+ ///
					`""Progress Report Output \(opt\.\)""'  + ///
					`""Back Check Comparison Output \(opt\.\)""' 	+ ///
					`""HFC Research File""' 						+ ///
					`""Replacements Log \(opt\.\)""' 	+ ///
					`""Submission Date""' 				+ ///
					`""Survey ID""' 					+ ///
					`""Enumerator ID""' 				+ ///
					`""Enumerator Team ID""' 			+ ///
					`""Back Checker ID""' 				+ ///
					`""Back Checker Team ID""' 			+ ///
					`""Form Version""' 					+ ///
					`""Missing Value \(\.d\)""' 		+ ///
					`""Missing Value \(\.r\)""' 		+ ///
					`""Missing Value \(\.n\) \(opt\.\)""' 	+ ///
					`""Statify Progress Report By""' 		+ ///
				    `""Variables to keep in Master Data""' 	+ ///
				    `""Variables to keep in Survey Data \(opt\.\)""' 	+ ///
				    `""Save Descrepancy As \(opt\.\)""' 				+ ///
				    `""Target Completion Rate \(opt\.\)""' 				+ ///
				    `""Use Variable Names as Headers \(opt\.\)""' 		+ ///
				    `""Use Values for Factors \(opt\.\)""' 				+ ///
				    `""ID in Master Tracking Data \(opt\.\)""' 			+ ///
				    `""Statistics to include in Enum DB""' 				+ ///
				    `""Statistic Variables for Enum DB""' 				+ ///
					`""Use SD for Outliers \(opt\.\)""' 				+ ///
					`""Use Label for Factors \(opt\.\)""' 				+ ///
					`""Show Unique IDs \(opt\.\)""' 					+ ///
				    `""Show All Discrepancies \(opt\.\)""' 				+ ///
				    `""Include All Comparisons \(opt\.\)""' 			+ ///
				    `""Do not Use Value labels for Factors \(opt\.\)""' + ///
				    `""Replace Back Check Comparison File \(opt\.\)""' 	+ ///
				    `""Save Discrepancy in Stata Format""' 		+ ///
				    `""Exclude BC Responses that Equal""' 		+ ///
				    `""Convert All Strings to Lower""' 			+ ///
				    `""Convert All Strings to Upper""' 			+ ///
				    `""Replace Symbols with Spaces""' 			+ ///
				    `""Remove Leading and Trailing Blanks""' 	+ ///
			        `""Server Name""' 							+ ///
				    `""Username""'								+ ///
					`""Progress Report""' 	+ ///
					`""1. incomplete""' 	+ ///
					`""2. duplicates""' 	+ ///
					`""3. consent""' 		+ ///
					`""4. no miss""' 		+ ///
					`""5. follow up""' 		+ ///
					`""6. logic""' 			+ ///
					`""7. all miss""' 		+ ///
					`""8. constraints""' 	+ ///
					`""9. specify""' 		+ ///
					`""10. dates""' 		+ ///
					`""11. outliers""' 		+ ///
					`""12. field comments""' 	+ ///
					`""13. text audits""' 		+ ///
					`""enumdb""' 				+ ///
					`""research oneway""' 		+ ///
					`""research twoway""' 		+ ///
					`""backcheck""'


				local globals   ///
					sdataset    ///
					bdataset	///
					master		///
					infile      ///
					repfile     ///
					repsheet    ///
					outfile     ///
					enumdb      ///
					progreport	///
					bcfile		///
					researchdb  ///
					replog		///
					date        ///
					id          ///
					enum        ///
					enumteam	///
					bcer		///
					bcerteam	///
					formversion ///
					mv1         ///
					mv2         ///
					mv3         ///
					psortby	 	///
					pkeepmaster ///
					pkeepsurvey ///
					psave		///
					ptarget		///
					pvariable	///
					plabel		///
					pmid		///
					stats		///
					statvars	///
					sd          ///
					nolabel		///
					bcshowrate	///
					bcshowall	///
					bcfull		///
					bcnolabel	///
					bcreplace	///
					bcsave		///
					bcexclude	///
					bclower		///
					bcupper		///
					bcnosymbols ///
					bctrim		///
					server		///
					username	///
					run_progreport 		 ///
					run_incomplete		 ///
					run_duplicates		 ///
					run_consent			 ///
					run_no_miss			 ///
					run_follow_up		 ///
					run_logic			 ///
					run_all_miss		 ///
					run_constraints		 ///
					run_specify			 ///
					run_dates	 		 ///
					run_outliers	 	 ///
					run_field_comments   ///
					run_text_audits		 ///
					run_enumdb			 ///
					run_research_oneway  ///
					run_research_twoway  ///
					run_backcheck


				* count the number of entry boxes
				local nboxes : word count `boxes'

				* loop through boxes and define the matching global 
				forval i = 1/`nboxes' {
					if `i' <= 56 {
						loc strCol "DataManagementSystem"
						loc valCol "B"
					}
					else {
						loc strCol "C"
						loc valCol "D"
					}
					gettoken global globals : globals
					gettoken box boxes : boxes
					summarize `tmp' if regexm(`strCol', `"`box'"'), meanonly
					local value = `valCol'[r(max)]
					mata: st_global("`global'", "")
					mata: st_global("`global'", `"`value'"')
				}
			}
			
			else {

				* expand wild cards in variable list
				if inlist(`n', 1, 3, 8, 11, 13, 15) & `rows' > 0 {
	    			mata: rv = st_sdata(., "variable")
	    			mata: nrv = ""
	    			mata: copies = .
	    			use "${sdataset}", clear
	    			forval i = 1/`rows' {
	    				mata: st_local("vlist", rv[`i'])
						unab vlist : `vlist'
						loc length : list sizeof vlist
						loc j = `i'
						foreach inner in `vlist' {
							mata: nrv = (`j' == 1 ? "`inner'" : nrv \ "`inner'")
							loc `++j'
						}
						mata: copies = (`i' == 1 ? `length' : copies \ `length')
	    			}
	    			use `tmpsheet', clear
	    			mata: st_store(., st_addvar("float", "copies"), copies)
	    			expand copies
	    			sort `tmp'
	    			recast strL variable
	    			mata: st_sstore(., "variable", nrv)
	    			local rows = _N
		    	}

		    	* create variable string for research summary command
				if inlist(`"`sheet'"', "research oneway", "research twoway") & `rows' > 0 {
					g variablestr = variable + " " + type + " \ "
					replace variablestr = variable + " " + type if _n == _N
					local colnames `"`colnames' "variablestr""'
				}

				if !inlist(`"`sheet'"', "backchecks") {

					* loop through columns
			    	foreach col in `colnames' {

			    		* initialize Stata global
						mata: st_global("`col'`n'", "")

						* loop through rows
			    		forval i = 1/`rows' {
		    				* append entries to global list
		    				mata: st_global("`col'`n'", `"${`col'`n'} `=`col'[`i']'"')

			    			* if the keep_variable column
			    			if inlist("`col'", "keep", "assert", "if_condition") {
			    				* add a semi-colon signifying the end of the line
			    				mata: st_global("`col'`n'", `"${`col'`n'}; "')
			    			}
							
							* if the variable column for the skip check, or variable or other_unique for duplicate check
							if ("`col'" == "variable" & `n' == 6) | (inlist("`col'", "variable", "other_unique") & `n' == 2) {
			    				* add a semi-colon signifying the end of the line
			    				mata: st_global("`col'`n'", `"${`col'`n'}; "')
							}
			    		}
			    	}
		    	}
				if inlist(`"`sheet'"', "backchecks") {
					if `rows' > 0 {
						* okrange global
						g okrangestr = variable + " [" + trim(okrange_min) + "," + trim(okrange_max) +  "], "
						replace okrangestr = variable + " [" + trim(okrange_min) + "," + trim(okrange_max) + "]" if _n == _N
					}

					* initialize Stata global
					mata: st_global("type1_`n'", "")
					mata: st_global("type2_`n'", "")
					mata: st_global("type3_`n'", "")
					mata: st_global("ttest`n'", "")
					mata: st_global("reliability`n'", "")
					mata: st_global("okrangestr`n'", "")
					mata: st_global("keepbc`n'", "")
					mata: st_global("keepsurvey`n'", "")
					mata: st_global("exclude`n'", "")

					forval i = 1/`rows' {
						if type[`i'] == 1 {
							mata: st_global("type1_`n'", `"${type1_`n'} `=variable[`i']'"')
						}
						else if type[`i'] == 2 {
							mata: st_global("type2_`n'", `"${type2_`n'} `=variable[`i']'"')
						}
						else if type[`i'] == 3 {
							mata: st_global("type3_`n'", `"${type3_`n'} `=variable[`i']'"')
						}
						else {
							di as error "Invalid type entry in back check sheet. Must be 1, 2, or 3."
							exit 198
						}

						if ttest[`i'] != "" {
							mata: st_global("ttest`n'", `"${ttest`n'} `=variable[`i']'"')
						}
						
						if reliability[`i'] != "" {
							mata: st_global("reliability`n'", `"${reliability`n'} `=variable[`i']'"')
						}

						if okrange_min[`i'] != "" & okrange_max[`i'] != "" {
							mata: st_global("okrangestr`n'", `"${okrangestr`n'} `=okrangestr[`i']'"')
						}
					}

				}
		    }
		}
	    restore
	}

end
