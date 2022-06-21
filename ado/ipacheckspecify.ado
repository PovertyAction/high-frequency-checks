*! version 4.0.0 11may2022
*! Innovations for Poverty Action
*! ipacheckspecify: This program collates and list other specify values.

program ipacheckspecify, rclass sortpreserve
	

	version 17

	#d ;
	syntax 	using/,
			[SHeet(string)]
			id(varname)
			ENUMerator(varname)
			date(varname)
	    	OUTFile(string) 
			[outsheet1(string)]
			[outsheet2(string)]
			[SHEETMODify SHEETREPlace] 
			[NOLabel]
		;	
	#d cr

	qui {
	    
		preserve
		
		tempfile tmf_choices
		
		* set default insheet
		if "`sheet'" == "" loc sheet "other specify"
		
		* check that output sheet is specified. If not assume "other specify"
		if "`outsheet1'" == "" loc outsheet1 "other specify"
		if "`outsheet2'" == "" loc outsheet2 "other specify (choices)"
		
		* create frame for choice_list
		cap frame drop frm_choice_list
		#d;
		frames create 	 frm_choice_list
			   str32 	 (variable vartype choice_label) 
			   str80     (value label)
			   double    (frequency percentage)
			   ;
		#d cr	
		
		* get inputs from inputs sheet if using is specified	
		import excel using "`using'", sheet("`sheet'") first clear allstr case(l)
		drop if missing(child) & missing(parent)
		levelsof keepvars, loc(keep) clean

		* get child and parent vars
		keep child parent
		keep if !missing(child) | !missing(parent)

		* save number of pairs to check
		loc osp_N `=_N'

		*** check for missing child or parent ***
		count if mi(child) | mi(parent)
		if `r(N)' > 0 {
			disp as err "missing child or parent in input sheet"
			gen row = _n + 1

			noi list if mi(child) | mi(parent)
			ex 198
		}
		
		* save input data into frame and import survey data
		cap frame drop frm_inputs
		frame copy default frm_inputs
			
		* change to main data
		restore, preserve
	
		* expand keep
		if "`keep'" == "" unab keep: `keep'

		* For each pair, check that # of children and parents match after expansion
		forval i = 1/`osp_N' {

			* save and expand locals
			frame frm_inputs: loc child = child[`i']
			unab child : `child'
			
			frame frm_inputs: loc parent = parent[`i']
			unab parent: `parent'

			if wordcount("`child'") ~= wordcount("`parent'") {
				disp as err "number of vars specified in child (`child') does not" , ///
							"does not match the number of vars specified in parent", ///
							"(`parent') on row `=`i'+1'"
				ex 198
			}

			* save full child and parent varlist in local
			loc unab_child  "`unab_child' `child'"
			loc unab_parent "`unab_parent' `parent'"
		}
		
		frame drop frm_inputs
	
		* keep only variables that are needed for check
		keep `id' `enumerator' `date' `keep' `unab_child' `unab_parent'
		
		loc child_cnt = wordcount("`unab_child'")

		forval i = 1/`child_cnt' {
			
			* get child and parent vars
			loc p_var = word("`unab_parent'", `i')
			loc c_var = word("`unab_child'", `i')
			
			* check that child variable has values. If not skip current iteration
			qui count if !missing(`c_var')
			if `r(N)' == 0 {
				drop `p_var' `c_var'
				continue
			}

			* reset list_vals to empty
			loc list_vals ""

			* get levels of parent var.
			* This is to account for values with missing label codes
			
			qui levelsof `p_var', loc (vals) clean
			loc vals: list uniq vals
			
			* get parent label
			loc p_var_vallab "`:val lab `p_var''"

			if !mi("`p_var_vallab'") {
				* get values in actual label.
				qui lab list 		`p_var_vallab'
					loc list_min  	`r(min)'
					loc list_max  	`r(max)'
					loc list_miss 	`r(hasemiss)'

				* check labels
				if `r(k)' > 2 {
					loc list_vals ""
					forval j = `list_min'/`list_max' {
						if !mi("`:lab `p_var_vallab' `j', strict'") loc list_vals = "`list_vals' `j'"
					}
				}
				else {
					loc list_vals: list list_min | list_max
				}

				* check for possible extended missing values
				if `list_miss' {
					foreach letter in `c(alpha)' {
						count if `p_var' == .`letter'
						if `r(N)' > 0 loc list_vals = "`list_vals' `i'"
					}
				}

				loc list_vals: list vals | list_vals
				loc list_vals: list uniq list_vals

			}

			if mi("`list_vals'") loc list_vals "`vals'"

			cap confirm string var `p_var'
			if !_rc {
				loc p_var_type "str"
			}
			else loc p_var_type "num"
			
			foreach val in `list_vals' {
		
				if "`p_var_type'" == "str" {
					
					qui count if regexm("_" + subinstr(`p_var', " ", "_", .) + "_", "_`val'_")
					loc val_cnt `r(N)'

					loc val_lab ""
					
				}
				else {
					qui count if `p_var' == `val'
					loc val_cnt `r(N)'
					
					if !mi("`p_var_vallab'") {
						loc val_lab "`:lab `p_var_vallab' `val''"
					}
					else loc val_lab ""

				}
		
				qui count if !missing(`p_var')
				loc nm_cnt `r(N)'
			
				#d;
				frames post frm_choice_list 
							("`p_var'") 
							("`:type `p_var''")
							("`p_var_vallab'")
							("`val'")
							("`val_lab'") 
							(`val_cnt')
							(`=`val_cnt'/`nm_cnt'')
					;
				#d cr
				
			}

			* save meta information
			loc p_var_name`i' 	"`p_var'"
			loc p_var_lab`i' 	"`:var lab `p_var''"
			loc c_var_name`i' 	"`c_var'"
			loc c_var_lab`i' 	"`:var lab `c_var''"

			* change vars to string vars
			cap confirm numeric var `p_var'
			if !_rc {
			    gen parent_value`i' = string(`p_var'), after(`p_var')
			}
			else ren `p_var' parent_value`i'
			
			cap confirm numeric var `c_var'
			if !_rc {
			    gen child_value`i' = string(`c_var'), after(`c_var')
			}
			else ren `c_var' child_value`i'
		}
		
		* drop rows that contain no osp
		egen noosp = rownonmiss(child*), strok
		drop if !noosp
		drop noosp
		
		if `c(N)' > 0 {
		    gen reshape_id = _n
			reshape long parent_value child_value, i(reshape_id) j(index)

			keep if !missing(child_value)

			gen parent_label = "", before(parent_value)
			gen parent 		 = "", before(parent_label)
			gen child_label  = "", before(child_value)
			gen child 		 = "", before(child_label)

			forval i = 1/`child_cnt' {
				replace parent 			= "`p_var_name`i''" if index == `i'
				replace parent_label 	= "`p_var_lab`i''" if index == `i'
				replace child 			= "`c_var_name`i''" if index == `i'
				replace child_label 	= "`c_var_lab`i''" if index == `i'
			}

			sort parent child child_value `date'

			drop reshape_id index

			compress
			
			ipagettd `date'
		
			keep 	`enumerator' `keep' `date' `id'  parent parent_label parent_value child child_label child_value
			order 	`enumerator' `date' `keep' `id' parent parent_label parent_value child child_label child_value 

			foreach var of varlist _all {
				lab var `var' ""
			}
			
			label var parent 		"parent variable"
			label var parent_label 	"parent label"
			label var parent_value 	"parent value"
			label var child 		"child variable"
			label var child_label 	"child label"
			label var child_value 	"child value"
			
			if "`keep'" ~= "" ipalabels `keep', `nolabel'
			ipalabels `id' `enumerator', `nolabel'
			export excel using "`outfile'", sheet("`outsheet1'") first(varl) `sheetreplace' `sheetmodify'
			mata: colwidths("`outfile'", "`outsheet1'")
			mata: colformats("`outfile'", "`outsheet1'", "`date'", "date_d_mon_yy")
			mata: setheader("`outfile'", "`outsheet1'")
			
			tab child
			loc var_cnt `r(r)'
			
			frames frm_choice_list {

				gsort variable value
				foreach var of varlist _all {
					lab var `var' ""
				}
			
				label var vartype 		"variable type"
				label var choice_label 	"choice list"

				export excel using "`outfile'", sheet("`outsheet2'") first(varl) `sheetreplace' `sheetmodify'

				mata: colwidths("`outfile'", "`outsheet2'")
				mata: colformats("`outfile'", "`outsheet2'", "percentage", "percent_d2")	
				mata: setheader("`outfile'", "`outsheet2'")
				
				* get row numbers for seperator line
				cap frame drop frm_subset
				frame put variable value, into(frm_subset)
				frame frm_subset {
				    bys variable (value): gen _dp_index = _n
					bys variable (value): gen _dp_count = _N
					gen _dp_row = _n + 1
					keep if _dp_index == _dp_count
					mata: rows = st_data(., st_varindex("_dp_row"))
				}
				frame drop frm_subset
				mata: addlines("`outfile'", "`outsheet2'", rows, "thin")
			}
			
			frame drop frm_choice_list
			
			noi disp "Found {cmd:`c(N)'} total specified values in `var_cnt' variables."
		}
		else {
		    loc var_cnt 0
			
			noi disp "Found {cmd:0} other specify values."
		}

		return local N_specify 		= `c(N)'
		return local N_vars 		= `var_cnt'
		return local parentvarlist 	= "`unab_parent'"
		return local childvarlist	= "`unab_child'"
	}

end
