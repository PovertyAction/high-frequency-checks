*! version 4.1.0 08apr2024
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

				cap confirm var formtimems 
				if !_rc {
					ren formtimems formtime
				}

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

mata:
mata clear

void format_timeuse(string scalar file, string scalar sheet, string scalar title, real scalar fmtdate) 
{

	class xl scalar b	
	b = xl()
	b.load_book(file)
	b.set_sheet(sheet)
	b.set_mode("open")
	
	real scalar min, max, colormax, i, j, value, fmtid, colwidth
	real scalar red, green, blue
	real scalar max_r, max_g, max_b
	real scalar min_r, min_g, min_b 
	
	string scalar time_lab, rgb
	
	colwidth = max(strlen(st_sdata(. , 1)))
	if (colwidth == 0) {
		colwidth = 10
		if (fmtdate) {
			b.set_number_format((4, st_nobs() + 4), (2, 2), "date_d_mon_yy")
		}
	}
	
	b.set_sheet_gridlines(sheet, "off")
	b.set_column_width(2, 2, colwidth + 3)
	b.set_column_width(3, 26, 3)
	
	for (i = 0;i <= 23; i++) {
		if (i == 0) {
			time_lab = "Midnight"
		}
		else if (i >= 0 & i <= 11) {
			time_lab = strofreal(i) + " AM"
		}
		else if (i == 12) {
			time_lab = "12 Noon"
		}
		else {
			time_lab = strofreal(i - 12) + " PM"
		}
		b.put_string(st_nobs() + 5, i + 3, time_lab)
		
	}
	
	fmtid = b.add_fmtid()
	b.set_fmtid((st_nobs() + 5, st_nobs() + 5), (3, 26), fmtid)
	b.fmtid_set_text_rotate(fmtid, 90)
	b.fmtid_set_vertical_align(fmtid, "top")
	
	min = min(colmin(st_data(. , st_varname(2..st_nvar()))))
	max = max(colmax(st_data(. , st_varname(2..st_nvar()))))
	
	max_r = 209
	max_g = 200
	max_b = 162
	min_r = 11
	min_g = 59
	min_b = 79
	
	if (max > 20) {
		colormax = 20
	}
	else {
		colormax = max
	}
		
	for (i = 1; i <= 24; i++) {
		for (j = 1; j <= st_nobs(); j++) {
			
			value = st_data(j, i + 1)
			
			if (value ~= .) {
				
				red = max_r - floor(((value/max) * (max_r - min_r)))
				green = max_g - floor(((value/max) * (max_g - min_g)))
				blue = max_b- floor(((value/max) * (max_b - min_b)))
				
				rgb = strofreal(red) + " " + strofreal(green) + " " + strofreal(blue)
				
				b.set_fill_pattern((j + 3, j + 3), (i + 2, i + 2), "solid", rgb)
			}
		}
	}
	
	b.put_string(4, 28, "Scale")
	b.put_number(6, 29, min)
	
	for (i = 1; i <= colormax; i ++) {
	    
	    red = max_r - floor(((i/colormax) * (max_r - min_r)))
		green = max_g - floor(((i/colormax) * (max_g - min_g)))
		blue = max_b- floor(((i/colormax) * (max_b - min_b)))
		
		rgb = strofreal(red) + " " + strofreal(green) + " " + strofreal(blue)
		
		b.set_fill_pattern((5 + i, 5 + i), (28, 28), "solid", rgb)

	}
	
	b.put_number(5 + colormax, 29, max)
	
	b.set_column_width(28, 29, 5)
	
	b.put_string(2, 3, title)
	b.set_sheet_merge(sheet, (2, 2), (3, 27))
	b.set_horizontal_align((2, 2), (3, 27), "center")
	b.set_font_bold((2, 2), (3, 27), "on")
	b.set_font_italic((2, 2), (3, 27), "on")
	
	b.close_book()
}
end
