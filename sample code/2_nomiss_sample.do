********************************************************************************
** 	TITLE	: 2_nomiss_sample.do
**
**	PURPOSE	: Sample code for flagging missing values in Survey data
**				
**	AUTHOR	: Ishmail Azindoo Baako
**
**	DATE	: 29aug2022
********************************************************************************

**# Setup
*------------------------------------------------------------------------------*

	* tempfiles
	
		tempfile miss_data fulldata
	
	* Variables to checks
	
		loc dataset 	"D:\Files\Git\high-frequency-checks\data/household_survey"
		loc nomiss_vars "duration l_hd_earn_first"
		loc nomiss_keep "key hhid a_kg a_community a_enum_name a_pl_hhh_fn a_pl_hhh_gnd"
		loc nomiss_outp	"nomiss.xlsx"
	

**# Compile missing values
*------------------------------------------------------------------------------*
	
	clear 
	save "`miss_data'", emptyok replace
	
	use `nomiss_vars' `nomiss_keep' using "`dataset'", clear
	save "`fulldata'", replace
	
	foreach var of varlist `nomiss_vars' {
		
		use "`fulldata'", clear
		
		cap confirm string var `var'
			
		if _rc == 7 {
			keep if `var' == .
		}
		else keep if missing(`var')
		
		if `=_N' > 0 {
			gen variable 	= "`var'"
			gen label 		= "`:var lab `var''"
			keep `nomiss_keep' variable label
			
			append using "`miss_data'"
							
			save "`miss_data'", replace

		}
	}
	
**# Export data
*------------------------------------------------------------------------------*
	
	order `nomiss_keep' variable label
	
	
	* export violations
	export excel using "`nomiss_outp'", sheet("nomiss") first(var) replace 
	
	* format sheet
	mata: colwidths("`nomiss_outp'", "nomiss")
