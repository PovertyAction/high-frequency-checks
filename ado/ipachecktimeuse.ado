*! version 4.0.0 11may2022
*! Innovations for Poverty Action
* ipachecktimeuse: Import and analyse text audit data for active times

program ipachecktimeuse, rclass sortpreserve
	
	#d;
	syntax varname, 
			ENUMerator(varname) 
			STARTtime(varname)
			TEXTAUDITdata(string)
			OUTFile(string)
			[SHEETMODify SHEETREPlace]
			[NOlabel]
		;
	#d cr
		
	qui {
	    
		*** preserve data ***
		preserve

		* tempfiles
		tempfile tmf_main_data tmf_ta_data tmf_ta tmf_ta_group_stats
		tempfile tmf_timeuse 
		
		* check  : format timeevar in %tc, %tC format
		if lower("`:format `starttime''") ~= "%tc"	{
			disp as err "`starttime' is not a datetime variable"
			exit 181
		}
		
		* check that media & textauditdata are mutually exclusive & that at least one is specified
		if "`media'`textauditdata'" == "" {
		    disp as err "must specify either media() or textauditdata() option"
			ex 198
		}
		else if "`media'" ~= "" & "`textauditdata'" ~= "" {
		     disp as err "options media() and are mutually exclusive"
			 ex 198
		}	
		
		* keep only relevant variables and observations
		keep `varlist' `enumerator' `starttime'
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
				keep fieldname formtime `varlist' `starttime' `enumerator'
				ren (formtime) (firstappeared)
				destring firstappeared, replace
			}
			else {
				keep fieldname firstappeared `varlist' `starttime' `enumerator'
				ren (firstappeared) (firstappeared)
				destring firstappeared, replace
				gen tt = firstappeared
				replace firstappeared = firstappeared * 1000
			}
			
			* gen group & field from field name
			gen groupname = substr(fieldname, 1, length(fieldname) - strpos(reverse(fieldname), "/")) if regexm(fieldname, "/")
			replace fieldname = substr(fieldname, -(strpos(reverse(fieldname), "/")) + 1, .)
		
			save "`tmf_ta'", replace
		
			* generate actual time for firstappeared
			gen double time = `starttime' + firstappeared
			gen hour 		= hh(time)
			format %tc time
			gen date = dofc(`starttime')
			format %td date
		
			duplicates drop `varlist' hour, force
		
			save "`tmf_ta'", replace
		
			*** timeuse by date ***
			
			keep date hour
			gen weight = 1
			collapse (sum) hh = weight, by(date hour)
			
			reshape wide hh, i(date) j(hour)
			
			forval i = 0/23 {
				cap confirm var hh`i'
				if _rc == 111 {
						gen hh`i' = 0
				}
			}

			recode hh* (0 = .)
			order hh*, sequential after(date)
			
			export excel date using "`outfile'", sheet("timeuse by date") cell(B4) `sheetreplace' `sheetmodify'
			mata: format_timeuse("`outfile'", "timeuse by date", "Active survey hours by `starttime'", 1)

			*** timeuse by enumerator ***
			use "`tmf_ta'", clear
			
			keep hour `enumerator'
			gen weight = 1
			collapse (sum) hh = weight, by(`enumerator' hour)
			
			reshape wide hh, i(`enumerator') j(hour)
			
			forval i = 0/23 {
				cap confirm var hh`i'
				if _rc == 111 {
						gen hh`i' = 0
				}
			}

			recode hh* (0 = .)
			order hh*, sequential after(`enumerator')
			ipalabels `enumerator', `nolabel'
			export excel `enumerator' using "`outfile'", sheet("timeuse by enumerator") cell(B4) `sheetreplace' `sheetmodify'
			mata: format_timeuse("`outfile'", "timeuse by enumerator", "Active survey hours by enumerator", 0)
		}
	} 

end 





		
				
