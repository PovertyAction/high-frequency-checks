********************************************************************************
** 	TITLE	: 3_nomiss_sample.do
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
		loc logic_keep	"key hhid a_kg a_community a_enum_name a_pl_hhh_fn a_pl_hhh_gnd"
		loc logic_outp 	"logic_check.xlsx"


* DUPLICATE THE BELOW CODE FOR AS MANY LOGIC CHECKS AS REQUIRED		
		
**# Check and export
* Check that e_hhh_howlong (How long have you lived in the community) is not missing 
* if the answer to e_hhh_native (Are you a native of this community) is "No"
*------------------------------------------------------------------------------*
	
	use "`dataset'", clear
	
	* count the number of violations
	count if missing(e_hhh_howlong) & e_hhh_native == 0
	if `r(N)' > 0 {
		
		* keep only observations with violations
		keep if missing(e_hhh_howlong) & e_hhh_native == 0
		
		* keep relevant variables (This is useful for automatic column width adjustment)
		keep `logic_keep' e_hhh_howlong e_hhh_native 
		
		* order variables
		order `logic_keep'
		
		* adjust sheetname if neccesary
		export excel using "`logic_outp'", replace first(var) sheet("e_hhh_howlong")
			
		* format sheet (adjust sheetname if neccesary)
		mata: colwidths("`logic_outp'", "e_hhh_howlong")
	}
	
	use "`dataset'", clear
	