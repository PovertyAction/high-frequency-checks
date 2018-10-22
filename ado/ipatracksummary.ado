*! version 3.0.0 Innovations for Poverty Action 22oct2018

program ipatracksummary, rclass
    /* Add a summary sheet to the output excel file detailing
       progress towards survey targets.
	   
	   Version 2 update: now looks at stats by submission date
	   instead of by date the HFCs are run. No longer does 
	   number of check violations.
	  */
  version 14.1

  #d ;
  syntax using/, 
    /* target number of surveys */ 
    TARGet(integer) 
    /* submission date */ 
	submit(varname numeric) 
	;
  #d cr

qui {

	* test for fatal conditions
	count if `submit' == . 
	if `r(N)' > 0 {
		di as err `"Missing values of `submit' are not allowed. Please correct this before running ipatracksurveys."'
		error 101
		}

	* tempvars
	tempvar formatted_submit cum_freq perc_targ cum_perc_targ final_submit
	
	* convert submit to %td format if needed	
	foreach letter in d c C b w m q h y {
		ds `submit', has(format %t`letter'*)
		if !mi("`r(varlist)'") {
			gen `formatted_submit' = dof`letter'(`submit')
		}
	}
	cap confirm var `formatted_submit' 
	if _rc {
		di as err "The submission date variable, `submit', is not in an acceptable format."
		di as err "Must be %td, %tc, %tC, %tb, %tw, %tm, %tq, %th, or %ty."
		error 101
	}
	format `formatted_submit' %tdCCYY/NN/DD	
	local d $S_DATE
	
	* generate output
	preserve
	
	table `formatted_submit', replace
	rename table1 freq 
	
	gen `cum_freq' = sum(freq)
	gen `perc_targ' = freq / `target'
	format `perc_targ' %9.2f 
	gen `cum_perc_targ' = sum(`perc_targ') 
	format `cum_perc_targ' %9.2f 	
	gen `final_submit' = string(`formatted_submit', "%td"), before(`formatted_submit')

	lab var `final_submit' "Submission Date"
	lab var freq "Frequency"
	lab var `cum_freq' "Cumulative Frequency"
	lab var `perc_targ' "Percent Target"
	lab var `cum_perc_targ' "Cumulative Percent Target"

	drop `formatted_submit'
	tab freq
	loc N = `r(N)' + 2
	export excel using "`using'", sheet("Summary") datestring("%tdCCYY/NN/DD") replace cell(I2) first(varl)
	mata: add_formatting("`using'", `N')	
	restore

}
  
end

mata:
mata clear

void add_formatting(string scalar filename, real scalar N)
{

	class xl scalar b
	string scalar date

	b = xl()

	b.load_book(filename)
	b.set_sheet("Summary")
	b.set_mode("open")
	date = st_local("d")

	b.set_top_border(1, (9,13), "thick")
	b.set_bottom_border((1, 2), (9,13), "thick")
	b.set_bottom_border((N), (9,13), "thick")

	b.set_font_bold((1,2), (9,13), "on")
	b.set_horizontal_align((1,N), (9,13), "center")
	
	b.set_left_border((1,N), 9, "thick")
	b.set_left_border((1,N), 14, "thick")
	b.set_horizontal_align(1, (9,13), "merge")

	b.put_string(1, 9, "Summary by Day: " + date) 

	//add number formatting
	b.set_number_format((2,N), (12, 13), "percent_d2")
	
	
	//add col widths
	table_labels = b.get_string(2, (9, 13))
	column_widths = strlen(table_labels)
	j = 9
	for (i=1; i <= cols(column_widths); i++) {
		b.set_column_width(j, j, column_widths[i]+2)
		j++
	}
	
	b.close_book()
}
end
