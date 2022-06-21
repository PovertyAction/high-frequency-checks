********************************************************************************
** 	TITLE	: 00_master.do
**	PURPOSE	: Master do file
**  PROJECT	:		
**	AUTHOR	: 
**	DATE	: 
********************************************************************************

**# setup Stata
*------------------------------------------------------------------------------*
	
	cls
	clear 			all
	macro drop 		_all
	version 		17
	set min_memory 	1g
	set maxvar 		32767
	set more 		off
	
	set seed 		87235
	set sortseed 	98237

**# setup working directory
*------------------------------------------------------------------------------*
	
	if "$cwd" ~= "" cd "$cwd"
	else global cwd "`c(pwd)'" 
	
**# Survey 1
*------------------------------------------------------------------------------*

	do "2_dofiles/1_globals.do"													// globals do-file
	* do "2_dofiles/2_import_wbnp_hhs_2021.do"									// import do-file
	do "2_dofiles/3_prepsurvey.do"												// prep survey do-file
	do "2_dofiles/4_checksurvey.do"												// check survey do-file
	do "2_dofiles/5_prepbc.do"													// prep back check do-file
	do "2_dofiles/6_checkbc.do"													// check survey do-file
	
** END **