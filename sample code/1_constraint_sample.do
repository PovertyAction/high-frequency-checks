********************************************************************************
** 	TITLE	: 1_constraint_sample.do
**
**	PURPOSE	: Sample code for constraint checks in your DMS
**				
**	AUTHOR	: Ishmail Azindoo Baako
**
**	DATE	: 19aug2022
********************************************************************************

**# Single Variable
*------------------------------------------------------------------------------*

	use "D:\Files\Git\high-frequency-checks\data/household_survey", clear
	
	* check that values are outside range
	cap assert inrange(f_hr_age_r1, 18, 80) if !missing(f_hr_age_r1)
	if _rc == 9 {
		
		preserve
		keep if !inrange(f_hr_age_r1, 18, 80) & !missing(f_hr_age_r1)
		keep hhid a_kg a_community a_enum_id a_enum_name a_team_id a_team_name  ///
			 a_pl_hhh_fn a_pl_pgv_fn a_pl_ch_fn f_hr_age_r1
		
		* export violations
		#d;
			export excel using "constraint violations.xlsx", 
					sheet("f_hr_age_r1") 
					first(var)
					replace 
			;
		#d cr
		
		* format sheet
		mata: colwidths("constraint violations.xlsx", "f_hr_age_r1")
		
	}
	
