*! version 4.0.0 11may2022
*! Innovations for Poverty Action 
* ipacodebook: export excel codebook

program define ipacodebook, rclass
    
	#d;
	syntax 	[varlist] 
			using/ 
			[if] [in]
			[, replace] 
			[note(string)]
			;
	#d cr
	
	preserve
	
	* mark sample
	marksample touse, strok
	keep if `touse'
	drop `touse'
	
	qui {
	    
		* check notes option
		* expected format note(#, REPLace|COALesce|LONGer|SHORTer)
	
		if "`note'" ~= "" {
			tokenize "`note'", parse(",")
			cap confirm number `1'
			if _rc == 7 {
				disp as err "`1' found at option note() where number expected"
				ex 7
			} 
			cap assert regexm(lower("`3'"), "^(repl)|^(coal)|^(long)|^(short)")
			if _rc == 9 {
			    disp as err "`3' found were any of the replace, coalesce, longer or shorter expected"
				ex 9
			}
			else {
			    loc note_num `1'
				loc note_priority "`3'"
			}
			
		}
		
		cap frame drop frm_codebook
		cap frame drop frm_choice_list
		#d;
		frames 	create 	frm_codebook 
				str32  	variable 
				strL 	label
				str10   type 
				str32   vallabel 
				double  (number_missing percent_missing number_unique) 
			;
		#d cr

		*** create output ***

		if "`varlist'" ~= "" unab vars: `varlist'
		else unab vars: _all

		* create & post stats for each variable
		foreach var of varlist `vars' {
			
			* count missing values for var
			qui count if missing(`var')
			loc missing_cnt `r(N)'
			
			* count number of unique nonmissing values for var
			qui tab `var'
			loc unique_cnt `r(r)'
			
			loc label 	"`:var lab `var''"
			if "`note'" ~= ""  loc notelab "``var'[note`note_num']'"
			
			if "`note'" == ""	{
			    loc varlab "`label'"
			}
			else if regexm("`note_priority'", "^(repl)") {
				loc varlab "`notelab'"
			}
			else if  regexm("`note_priority'", "^(coal)") {
				if "`label'" ~= "" {
					loc varlab "`label'"
				}
				else {
					loc varlab "`notelab'"
				}
			}
			else if regexm("`note_priority'", "^(long)") {
				if length(`"`label'"') <= length(`"`notelab'"') {
					loc varlab "`notelab'"
				}
				else {
					loc varlab "`label'"
				}
			}
			else if regexm("`note_priority'", "^(short)") {
				if (length(`"`label'"') <= length(`"`notelab'"')) | missing("`notelab'") {
					loc varlab "`label'"
				}
				else {
					loc varlab "`notelab'"
				}
			}
			
			
			* post results to frame
			frames post ///
				frm_codebook (`"`var'"') 			///
						 (`"`varlab'"') 		///
						 ("`:type `var''")		///
						 ("`:val lab `var''")	///
						 (`missing_cnt') 		///
						 (`missing_cnt'/`=_N') 	///
						 (`unique_cnt')

		}

		* export results
		frames frm_codebook {
			
			* count number of variables to check
			loc varscount = wordcount("`vars'")

			* count number of variables that are all missing
			count if percent_missing == 1
			loc allmisscount `r(N)'

			* count number of vars with at least 1 missing variables
			count if percent_missing ~= 1
			loc misscount `r(N)'
			
			* replace unique_cnt  with missing if all missing
			replace number_unique = . if percent_missing == 1
			
			* export & format output
			export excel using "`using'", first(var) sheet("codebook") `replace'
			mata: colwidths("`using'", "codebook")
			mata: colformats("`using'", "codebook", "percent_missing", "percent_d2")
			mata: addlines("`using'", "codebook", (1, `=_N' + 1), "medium")
			
			* save vallels in local
			levelsof vallabel, clean
			loc vallabels "`r(levels)'"
		}
		
		
		* choice_list
		restore, preserve
		
		if "`vallabels'" ~= "" {
		    
			* create frame for choice_list
			#d;
			frames create 	 frm_choice_list
				   str32 	 (choice_label) 
				   strL      (value label)
				   ;
			#d cr	
			
			* order list
			loc vallabels: list sort vallabels
			
		    foreach vallabel in `vallabels' {
			    * get variables using vallabel
				
				ds, has(vallabel `vallabel')
				loc var = word("`vallabel'", 1)
				
				* get values in actual label.
				qui lab list 	`vallabel'
				loc list_min  	`r(min)'
				loc list_max  	`r(max)'
				loc list_miss 	`r(hasemiss)'
					
				* check labels
				if `r(k)' > 2 {
					loc list_vals ""
					forval j = `list_min'/`list_max' {
						if !mi("`:lab `vallabel' `j', strict'") loc list_vals = "`list_vals' `j'"
					}
					
					loc list_vals: list sort list_vals
				}
				else {
					loc list_vals: list list_min | list_max
				}
				
				* check for possible extended missing values
				if `list_miss' {
					foreach letter in `c(alpha)' {
						if !mi("`:lab `vallabel' .`letter''") loc list_vals = "`list_vals' .`letter'"
					}
				}
				
				loc list_vals: list uniq list_vals
				foreach val in `list_vals' {
				    #d;
					frames post 
						   frm_choice_list 
								("`vallabel'") 
								("`val'")
								("`:lab `vallabel' `val''")
						;
					#d cr
				}
			}
			
			* export & format output
			frame frm_choice_list {
				export excel using "`using'", first(var) sheet("value labels")
				
				mata: colwidths("`using'", "value labels")
				mata: addlines("`using'", "value labels", (1, `=_N' + 1), "medium")
			}
			
		}
		
		return scalar N_vars = `varscount'
		return scalar N_allmiss = `allmisscount'
		return scalar N_miss = `misscount'
	}
	
end