*! version 4.0.0 11may2022
*! Innovations for Poverty Action
* ipacheckcomments: Collate & export field comments

program ipacheckcomments, rclass
	
	#d;
	syntax varname, 
			ENUMerator(varname) 
			COMMENTSdata(string)
			OUTFile(string)
			[OUTSheet(string)]
			[KEEPvars(varlist)]
			[SHEETMODify SHEETREPlace]
			[NOLABel]
		;
	#d cr
		
	qui {
	   
		preserve
		
		tempvar tmv_comment tmv_field

		tempfile tmf_main_data tmf_comm
		
		* set outsheet
		if "`outsheet'" == "" loc outsheet "field comments"
		
		* keep only relevant variables and observations
		keep `varlist' `enumerator' `keepvars'
		keep if !missing(`varlist')
		
		loc obs_cnt `c(N)' 
		
		if `obs_cnt' > 0 {
			
			* extract id from media file
			* check if data was downloaded from browser or api | from desktop
			cap assert regexm(`varlist', "^https")
			if !_rc {
				* browser or API 
				replace `varlist' = substr(`varlist', strpos(`varlist', "uuid:") + 5, ///
							strpos(`varlist', "&e=") - strpos(`varlist', "uuid:") - 5)
				replace `varlist' = "Comments-" + `varlist'
			}
			else if regexm(`varlist', "^media") {
				* surveycto desktop
				replace `varlist' = substr(`varlist', strpos(`varlist', "media\") + 6, ///
							strpos(`varlist', ".csv") - strpos(`varlist', "media\") - 6)
			}

			cap confirm var comment
			if !_rc {
				ren comment __commentkeep
			}
			
			isid `varlist'
			merge 1:m `varlist' using "`commentsdata'", keep(match) nogen
			
			gen `tmv_comment' = comment
			drop comment 
			
			cap confirm var __commentkeep
			if !_rc {
				ren __commentkeep comment
			}
			
			if `obs_cnt' == 0 {
				disp as err "Data in `commentsdata' does not match current dataset on id variable `varlist'"
				ex 198
			}
			
			* get field name
			egen `tmv_field' = ends(fieldname), last punct("/")
			keep `enumerator' `keepvars' `tmv_comment' `tmv_field'
			order `enumerator' `keepvars' `tmv_field' `tmv_comment'
			
			lab var `tmv_comment' "comment"
			lab var `tmv_field' "field"
			
			sort `enumerator' `tmv_field'
			keep `enumerator' `keepvars' `tmv_field' `tmv_comment'
			order `enumerator' `keepvars' `tmv_field' `tmv_comment'
			
			drop if missing(`tmv_comment')
			
			if "`keepvars'" ~= "" ipalabels `keepvars', `nolabel'
 			ipalabels `enumerator', `nolabel'
			export excel using "`outfile'", sheet("`outsheet'") first(varl) `sheetreplace' `sheetmodify'
			mata: colwidths("`outfile'", "`outsheet'")
			mata: setheader("`outfile'", "`outsheet'")
			
			noi disp "Found {cmd:`c(N)'} comments."
		}
		else {
		 
			noi disp "Found {cmd:0} Comments in `varlist'."
		}

		return local N_comments = `c(N)'

	} 

end 