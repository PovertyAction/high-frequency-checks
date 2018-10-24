*! version 3.0.0 Innovations for Poverty Action 22oct2018

* Stata program for merging and outputting field comments
prog define ipacheckcomment, rclass
	#d;
	syntax varname, MEDia(string) 
					saving(string) 
					id(varname) 
					ENUMerator(varname) 
					SUBMITted(varname) 
					[KEEPvars(string) 
					SHEETMODify SHEETREPlace NOLabel]
		;	
	#d cr	
	
	qui {
		* clean keepvars
		loc keepvars = trim(itrim(subinstr("`keepvars'", ";", "", .)))

		* temporary files
		tempfile 	master commdata commdata_long
		
		save `master', replace
		
		* keep only data with text audits
		drop if missing(`varlist')
		save `commdata', emptyok
		loc commcount `=_N'
	
		if `commcount' > 0 {
			* check that data is unique on field comment var
			isid `varlist'
			
			* loop through and save the name of each comment file name in a local
			forval i = 1/`commcount' {
				loc comm_`i' = subinstr(`varlist'[`i'], "media\", "", 1) 
			}
			
			* Loop through scto media folder and import comm csvs one at a time 
			* appending them to the prevously imported dataset
			clear
			save `commdata_long', emptyok
			
			* misscount will track number of ta files that could not be found in file
			loc misscount 0
			forval i = 1/`commcount' {
				cap import delim using "`media'/`comm_`i''", clear varnames(1)
				if !_rc {
					gen 	`varlist' = "media\\`comm_`i''"
					append	using `commdata_long'
					save 	`commdata_long', replace
				}
				else if _rc == 601 loc ++misscount
				
			}
			
			* drop observations with missing comments
			drop if missing(comment) 
			save 	`commdata_long', replace
			
			* Compares the number of missing ta files to the number of files expected
			* STOP: If all files are missing from folder	
			if `misscount' == `commcount' {
				noi disp as err "{p}All " as res "`misscount'" as txt " of " as res "`commcount'" ///
					as txt " media files not found in folder `media'. Please specify the correct media folder{p_end}"
				ex 601
			}
			else {
				* SHOW WARNING: If some ta files are missing
				if `misscount' > 0 {
					noi disp as err "{p}" as res "`miss_ta'" as txt " of " `tacount' ///
						" media files not found in folder `media'. Please specify the correct media folder{p_end}"
				}
			
				
			}
			
			* clean variable names
			* rename fieldname to groupname and generate fieldname var
			rename 	fieldname 	groupname
			egen 	fieldname = ends(groupname), last punc(/)
			drop 	groupname
			
			* Merge in additional variables from dataset
			loc keeplist: list enumerator | keepvars
			merge m:1 `varlist' using `commdata', keepusing(`id' `submitted' `keeplist') ///
					assert(match master) keep(match) nogen
			* format submissiondate
			gen 	`submitted'_fmt = dofc(`submitted') 
			format %td `submitted'_fmt
			drop 	`submitted'
			ren 	`submitted'_fmt `submitted'
			
			* drop comm var and sort
			drop 	`varlist'
			order 	`submitted' `id' `keeplist' fieldname comment
			gsort -`submitted'
			
			* export data
			export excel using "`saving'", first(var) ///
				sheet("12. field comments") `sheetmodify' `sheetreplace'
				
			* format output for stata 14.0 and above
			if `c(version)' >= 14.0 {
				d, s
				alphacol `r(k)'
				loc endcol "`r(alphacol)'"
				putexcel set "`saving'", sheet("12. field comments") modify
				putexcel A1:`endcol'1, bold border(bottom)
			}
			
			return local comments = `=_N'
		}
		
		else {
			nois disp "{red:No text comments recorded}"
			return local comments = 0
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

