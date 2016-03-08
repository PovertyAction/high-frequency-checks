/*----------------------------------------*
 |file:    master_check.do                | 
 |project: high frequency checks          |
 |author:  christopher boyer              |
 |         matthew bombyk                 |
 |         innovations for poverty action |
 |date:    2016-02-13                     |
 *----------------------------------------*/

// this line adds standard boilerplate headings
ipadoheader, version(13.0)
use "data/survey_data.dta", clear
 
/*
 overview:
   this file contains the following data quality checks...
     1. Check that all interviews were completed
     2. Check that there are no duplicate observations
     3. Check that all surveys have consent
     4. Check that certain critical variables have no missing values
     5. Check that follow up record ids match original
     6. Check skip patterns and survey logic
     7. Check that no variable has all missing values
     8. Check hard/soft constraints
     9. Check specify other vars for items that can be included
     10. Check that date values fall within survey range
     11. Check that there are no outliers for unconstrained vars
*/

// dtanotes

// local definitions (EDIT THESE)
local infile     "hfc_inputs.xlsx"
local outfile    "hfc_outputs.xlsx"
local repfile    "hfc_replacements.xlsx"
local enumdb     "hfc_enumerators.xlsx"
local researchdb "hfc_research.xlsx"
*local master     "master_tracking_list.dta"
local id         "id"
local enum       "enumid"


/* =============================================================== 
   ================== Pre-process Import Data  =================== 
   =============================================================== */
qui {
	// generate start and end dates from SCTO values
	g startdate = dofc(starttime)
	g enddate = dofc(endtime)
	format %td startdate enddate

	// recode don't know/refusal values
	ds, has(type numeric)
	local numeric `r(varlist)'
	recode `numeric' (999 = .d)
	recode `numeric' (998 = .r)
	recode `numeric' (888 = .n)
	
	// get the current date
	local today = date(c(current_date), "DMY")
	local today_f : di %tdnn/dd/YY `today'
	
	// get total number of interviews
	local n = _N
}

/* =============================================================== 
   ================== Import locals from Excel  ================== 
   =============================================================== */

ipacheckimport using "`infile'"

/* =============================================================== 
   ================= Replacements and Corrections ================ 
   =============================================================== */
/* 
merge 1:1 `id' using "hfc_replacements.xlsx", keepusing(drop)
drop if drop == "y" | drop == "yes"
drop drop
*/
readreplace using "hfc_replacements.xlsx", ///
    id("id") ///
	variable("variable") ///
	value("newvalue") ///
	excel ///
	import(firstrow)


/* =============================================================== 
   ==================== High Frequency Checks ==================== 
   =============================================================== */

putexcel A1=("HFC Summary Report") ///
         A2=("Report Date") B2=("`today_f'") ///
		 A3=("Total Interviews") B3=("`n'") ///
		 using `outfile', sheet("0. summary") replace

/* <=========== HFC 1. Check that all interviews were completed ===========> */
ipacheckcomplete ${variable1}, complete(${complete_value1}) ///
    id(`id') ///
    enumerator(`enum') ///
    saving(`outfile') ///
    sheetreplace
	
putexcel A4=("HFC 1") A5=("number of incompletes") B5=("`r(nincomplete)'") using `outfile', ///
    sheet("0. summary") modify

/* <======== HFC 2. Check that there are no duplicate observations ========> */
ipacheckdups ${variable2}, enumerator(`enum') ///
    saving(`outfile') ///
    sheetreplace

putexcel A6=("HFC 2") A7=("number of duplicates") B7=("`r(ndups1)'") using `outfile', ///
    sheet("0. summary") modify
	
/* <============== HFC 3. Check that all surveys have consent =============> */
ipacheckconsent ${variable3}, consentvalue(${consent_value3}) ///
    id(`id') ///
    enumerator(`enum') ///
    saving(`outfile') ///
    sheetreplace

putexcel A8=("HFC 3") A9=("number without consent") B9 =("`r(noconsent)'") using `outfile', ///
    sheet("0. summary") modify

/* <===== HFC 4. Check that critical variables have no missing values =====> */
ipachecknomiss ${variable4}, id(`id') /// 
    enumerator(`enum') ///
    saving(`outfile') ///
    sheetreplace
		
putexcel A10=("HFC 4") ///
         A11=("number of variables with a miss.") ///
		 A12=("number of missing values") ///
		 B11=("`r(missvar)'") ///
		 B12=("`r(nmiss)'") ///
		 using `outfile', sheet("0. summary") modify
	
/* <======== HFC 5. Check that follow up record ids match original ========> */
/*ipacheckfollowup using `master', id(`id') ///
    enumerator(`enum') ///
    saving(`outfile') ///
    sheetreplace*/

/* <====== HFC 6. Check that no variable has only one distinct value ======> */
ipacheckskip ${variable6}, assert(${assert6}) ///
    condition(${if_condition6}) ///
	id(`id') ///
	enumerator(`enum') ///
	saving(`outfile') 

putexcel A15=("HFC 6") ///
         A16=("number of skip pattern and logic violations.") ///
		 B16=("`r(nviol)'") ///
		 using `outfile', sheet("0. summary") modify
		 
/* <======== HFC 7. Check that no variable has all missing values =========> */
ipacheckallmiss, id(`id') ///
    enumerator(`enum') ///
    saving(`outfile') ///
    sheetmodify

putexcel A17=("HFC 7") A18=("number of all missing variables") B18 =("`r(nallmiss)'") using `outfile', ///
    sheet("0. summary") modify

/* <=============== HFC 8. Check for hard/soft constraints ================> */
ipacheckconstraints ${variable8}, smin(${soft_min8}) ///
    smax(${soft_max8}) ///
    id(`id') ///
    enumerator(`enum') ///
    saving(`outfile') ///
    sheetreplace

putexcel A19=("HFC 8") ///
         A20=("number of soft constraint violations.") ///
		 A21=("number of hard constraint violations.") ///
		 B20=("`r(nsoft)'") ///
		 B21=("`r(nhard)'") ///
		 using `outfile', sheet("0. summary") modify

/* <================== HFC 9. Check specify other values ==================> */
ipacheckspecify ${specify_variable9}, id(`id') ///
    enumerator(`enum') ///
    saving(`outfile') ///
    sheetreplace

putexcel A22=("HFC 9") A23=("number of times other specified") B23 =("`r(nspecify)'") using `outfile', ///
    sheet("0. summary") modify
	
/* <========== HFC 10. Check that dates fall within survey range ==========> */
ipacheckdates ${startdate10} ${enddate10}, surveystart(${surveystart10}) ///
    id(`id') ///
    enumerator(`enum') ///
    saving(`outfile') ///
    sheetreplace

putexcel A24=("HFC 10") ///
         A25=("number of missing start or end dates.") ///
         A26=("number with unequal start/end dates.") ///
		 A27=("number of dates before survey start.") ///
		 A28=("number with start after current date.") ///
		 B25=("`r(missing)'") ///
		 B26=("`r(diff_end)'") ///
		 B27=("`r(diff_start)'") ///
		 B28=("`r(diff_today)'") ///
		 using `outfile', sheet("0. summary") modify

/* <============= HFC 11. Check for outliers in unconstrained =============> */
ipacheckoutliers ${variable11}, id(`id') ///
                                enumerator(`enum') ///
                                iqrmulti(${iqr_multiplier11}) ///
                                saving(`outfile') ///
                                sheetreplace

putexcel A29=("HFC 11") A30=("number of potential outliers") B30 =("`r(noutliers)'") using `outfile', ///
    sheet("0. summary") modify

/* ===============================================================
   =============== User Checks Programming Template ==============
   =============================================================== */


/* ===============================================================
   ================= Create Enumerator Dashboard =================
   =============================================================== */

ipacheckenum `enum' using "hfc_enumerators.xlsx", ///
   dkrfvars(${dkrf_variable12}) ///
   missvars(${missing_variable12}) ///
   durvars(${duration_variable12}) ///
   exclude(${exclude_variable12}) ///
   subdate(${submission_date12})

/* ===============================================================
   ================== Create Research Dashboard ==================
   =============================================================== */

   /* coming soon! */
