


*Welcome to the IPA High Frequency Checks Template!

*Please fill in the following information:

	cd "C:\Users\mbombyk.IPA\Box Sync\Workspace (Matt Bombyk)\Resources_Developing\HFC guide and templates & exercise"
	glo survey_id KEY // unique ID for each survey
	glo enum_id enumeratorid // unique name or ID for each enumerator
	glo raw_data "SHPS tracking/SHPS Tracking Survey_v1-3_combined_2014-06-09.dta" // raw data file
	glo error_fixes // readreplace file
	glo hfc_metadata "New HFC templates\HFC Input Template_DRAFT_2016-01-11.xlsx" // HFC metadata file


********************************************************************************
*Step 1: load metadata, fix known errors, and standardize coding
********************************************************************************
	*Always run this first
	include "New HFC templates/Process metadata.do"	// This is based on a standard template file.
	*include fixerrorsandrecode.do // This relies largely on readreplace


********************************************************************************
*Step 3: Standard Daily high-frequency checks
********************************************************************************
	*This can be run at any time after step 1
	include "New HFC templates/Daily checks.do"
	
	
	
	
	
	
	
	
	
	
/*
	*****************************************
	TO ADD LATER
	
*/
	

********************************************************************************
*Step 4: Additional Daily high-frequency checks
********************************************************************************
	*This can be run at any time after step 1


	
********************************************************************************
*Step 5: Enumerator dashboard
********************************************************************************
	*This can be run at any time after step 1



********************************************************************************
*Step 6: Experimental integrity dashboard
********************************************************************************
	*This can be run at any time after step 1

