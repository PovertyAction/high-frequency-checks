*! version 4.0.0 11may2022
*! Innovations for Poverty Action
* ipacheckids: Outputs duplicates in survey id

program ipacheckids, rclass
	
	#d;
	syntax varname, 
			ENUMerator(varname) 
			date(varname) 
			key(varname) 
			OUTFile(string) 
			[OUTSHeet(string)]
			[DUPFile(string)]
			[SAve(string)]
			[keep(varlist)]
			[SHEETMODify SHEETREPlace]
			[NOLabel replace]
			[force]
		;
	#d cr
		
	qui {
	    	
		preserve
	
		tempvar tmv_serial tmv_index tmv_min tmv_max tmv_dups
		tempvar tmv_compared tmv_diffs tmv_perc_diffs
		
		* save a de-duplicated dataset
		if "`save'" ~= "" {
			if "`force'" ~= "" {
				duplicates drop `varlist', force
				save "`save'", replace
			
				restore, preserve
			}
			else {
				disp as err "force option required with save() option"
				ex 198
			}
		    
		}
 		
		ipagettd `date'
		
		* set default outsheet
		if "`outsheet'" == "" loc outsheet "id duplicates"

		* create dataset of duplicate outputs
		duplicates tag `varlist', gen(`tmv_dups')
		keep if `tmv_dups'

		if `c(N)' == 0 noi display "There are no duplicates of `varlist' in the data." 
		else {
			keep if `tmv_dups'
			drop `tmv_dups'

			* save duplicates dta
			if "`dupfile'" ~= "" save "`dupfile'", replace
			
			bysort `varlist' (`date') : gen `tmv_serial' = _n

			ds `varlist' `date' `key' `tmv_serial', not 
			loc compvars `r(varlist)'
			gen `tmv_compared' = `:word count `compvars''

			* use this value to find the first row for each ID
			gen `tmv_index' = _n 
			bysort `varlist' : egen `tmv_min' = min(`tmv_index')
			gen `tmv_max' = cond(`tmv_index' == `tmv_min', ., `tmv_index')
			
			* compare values for all vars except admin vars
			gen `tmv_diffs' = 0	
			forval j = 2/`c(N)' { 
				loc minval = `tmv_min'[`j']
				loc maxval = `tmv_max'[`j']

				foreach var of varlist `compvars' { 
				
					replace `tmv_diffs' = `tmv_diffs' + 1 if `var'[`minval'] != `var'[`maxval'] & _n == `maxval'
				}
			}

			gen `tmv_perc_diffs' 	= `tmv_diffs' / `tmv_compared'
			recode `tmv_diffs' `tmv_perc_diffs' (0 = .)
			replace `tmv_compared' = . if missing(`tmv_diffs')

			foreach var of varlist * {
				lab var `var' ""
			}

			lab var `tmv_diffs' 		"# different"
			lab var `tmv_compared' 		"# compared"
			lab var `tmv_perc_diffs' 	"% different"
			lab var `tmv_serial' 		"serial"
			
			* export data 
			keep  `enumerator' `keep' `tmv_serial' `date' `key' `varlist' `tmv_compared' `tmv_diffs' `tmv_perc_diffs'
			order `enumerator' `keep' `tmv_serial' `date' `key' `varlist' `tmv_compared' `tmv_diffs' `tmv_perc_diffs'
			
			if "`keep'" ~= "" ipalabels `keep', `nolabel'
			ipalabels `id' `key' `enumerator', `nolabel'
			
			export excel using "`outfile'", first(varl) sheet("`outsheet'") `sheetreplace' `sheetmodify'
			mata: colwidths("`outfile'", "`outsheet'")
			mata: colformats("`outfile'", "`outsheet'", "`tmv_perc_diffs'", "percent_d2")	
			mata: colformats("`outfile'", "`outsheet'", ("`tmv_diffs'", "`tmv_compared'"), "number_sep")
			mata: colformats("`outfile'", "`outsheet'", "`date'", "date_d_mon_yy")	
			mata: setheader("`outfile'", "`outsheet'")
			
			* get row numbers for seperator line
			cap frame drop frm_subset
			frame put `varlist' `tmv_serial', into(frm_subset)
			frame frm_subset {
			    bys `varlist' (`tmv_serial'): gen _dp_count = _N
				gen _dp_row = _n + 1
				keep if `tmv_serial' == _dp_count
				mata: rows = st_data(., st_varindex("_dp_row"))
			}
			frame drop frm_subset
			mata: addlines("`outfile'", "`outsheet'", rows, "thin")

		}

		tab `varlist'
		if `c(N)' > 0 noi disp "Found {cmd:`c(N)'} duplicates observations in `r(r)' duplicate pairs."
		
		return local N_dups = `c(N)'
		return local N_pairs = `r(r)'
		
	} 

end 
