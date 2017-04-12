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

		local sheets =              ///
			`""0. setup""' +        ///
			`""1. incomplete""' +   ///
			`""2. duplicates""' +   ///
			`""3. consent""' +      ///
			`""4. no miss""' +      ///
			`""5. follow up""' +    ///
			`""6. skip""' +         ///
			`""7. all miss""'  +    ///
			`""8. constraints""' +  ///
			`""9. specify""' +      ///
			`""10. dates""' +       ///
			`""11. outliers""'  +   ///
			`""enumdb""'  +         ///
			`""researchdb""' 
		
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
					
	    	* drop missing and/or incomplete rows
			local col1 : word 1 of `colnames'
	    	drop if mi(`col1')
			
	    	* get current sheet number, decrement by 1 to match sheet #s
	    	local n : list posof `"`sheet'"' in sheets	
	    	local --n

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
					`""Stata Dataset""' +                     ///
					`""HFC Input File""' +                    ///
					`""HFC Output File""' +                   ///
					`""HFC Enumerator File""' +               ///
					`""HFC Research File""' +                 ///
					`""Replacements File \(opt\.\)""' +       ///
					`""Master Tracking Dataset \(opt\.\)""' + ///
					`""Submission Date""' +                   ///
					`""Survey ID""' +                         ///
					`""Enumerator ID""' +                     ///
					`""Form Version""' +                      ///
					`""Geographic Cluster""' +                ///
					`""Target Sample Size""' +                ///
					`""SurveyCTO Server""' +                  ///
					`""Missing Value \(\.d\)""' +             ///
					`""Missing Value \(\.r\)""' +             ///
					`""Missing Value \(\.n\)""' +             ///
					`""Use SD for Outliers""' +               ///
					`""Use label for Factors""' 

				local globals   ///
					dataset     ///
					infile      ///
					outfile     ///
					enumdb      ///
					researchdb  ///
					repfile     ///
					master      ///
					date        ///
					id          ///
					enum        ///
					formversion ///
					geounit     ///
					target      ///
					server      ///
					mv1         ///
					mv2         ///
					mv3         ///
					sd          ///
					nolabel

				* count the number of entry boxes
				local nboxes : word count `boxes'

				* loop through boxes and define the matching global 
				forval i = 1/`nboxes' {
					gettoken global globals : globals
					gettoken box boxes : boxes
					summarize `tmp' if regexm(HighFrequencyChecks, `"`box'"'), meanonly
					local value = B[r(max)]
					mata: st_global("`global'", "")
					mata: st_global("`global'", `"`value'"')
				}
			}
			else {
				* loop through columns
		    	foreach col in `colnames' {

		    		if inlist("`col'", "variable") & inlist(`n', 1, 3, 8, 11) & `rows' > 0 {
		    			mata: rv = st_sdata(., "variable")
		    			mata: nrv = ""
		    			mata: copies = .
		    			use "${dataset}", clear
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
		    			mata: st_sstore(., "variable", nrv)
		    			local rows = _N
		    		}

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
		}
	    restore
	}

end
