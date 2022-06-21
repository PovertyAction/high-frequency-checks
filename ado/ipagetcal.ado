*! version 4.0.0 11may2022
*! Innovations for Poverty Action
* ipagetcal: Generate date calendar data

program define ipagetcal, rclass

	syntax varname, clear
	
	* temp var
	tempvar tmv_date
	
	qui {
		ipagettd `varlist'	
		
		* check start and enddate
		su `varlist'
		loc startdate = `r(min)'
		loc enddate = `r(max)'
		
		loc days = `enddate' - `startdate'
		
		clear
		set obs `=`days'+1' 
		gen index = _n
		gen `varlist' 	= `startdate' + index - 1
		format %td `varlist'
		gen week 		= week(`varlist') 
		gen month 		= month(`varlist') 
		gen year 		= year(`varlist') 
	}
	
	return local N_days = `c(N)'
end