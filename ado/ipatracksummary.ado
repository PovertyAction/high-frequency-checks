*! version 2.0.0 Christopher Boyer/Caton Brewster 18mar2017

program ipatracksummary, rclass
    /* Add a summary sheet to the output excel file detailing
       progress towards survey targets.
	   
	   Version 2 update: now looks at stats by submission date
	   instead of by date the HFCs are run. No longer does 
	   number of check violations.
	  */
  version 13

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
	tempvar formatted_submit cum_freq perc_targ cum_perc_targ
	
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

	* generate output
	preserve
	
	table `formatted_submit', replace
	rename table1 freq 
	
	gen `cum_freq' = sum(freq)
	gen `perc_targ' = 100 * (freq / `target')
	format `perc_targ' %9.2f 
	gen `cum_perc_targ' = sum(`perc_targ') 
	format `cum_perc_targ' %9.2f 

	export excel using "`using'", sheet("T1. summary") datestring("%tdCCYY/NN/DD") sheetreplace cell(A3) 
		
	restore
	
	* write the headers
    headers using "`using'"

}
  
end

program headers, rclass
    /* this program writes the column headers
       to the output worksheet. */

    syntax using/, 

    * set the output sheet
    putexcel set "`using'", sheet("T1. summary") modify

	* today's date
	local today = date(c(current_date), "DMY")
	local today_f : di %tdCCYY/NN/DD `today'
	
	* date header
	putexcel A1 = ("Summary as of `today_f'")
	
    * write the column headers
    putexcel A2=("Submission Date") ///
      B2=("Frequency") ///
      C2=("Cumulative Frequency") ///
      D2=("Percent Target") ///
      E2=("Cumulative Percent Target")
end

