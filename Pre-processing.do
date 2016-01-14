

*Pre-processing of survey data

*This do-file defines certain key variables necessary for performing the
*minimum set of High-Frequency Checks required by IPA. 

	set more off
	use "$raw_data" , clear

********************************************************************************
*Define Survey Completion Variable
	gen survey_completion = !mi(endtime)








********************************************************************************












	tempfile preproc_data
	save `preproc_data'
	
	
	
	
	
	
	