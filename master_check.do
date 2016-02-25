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
use "data/maximum_diva_cleaned.dta", clear
 
/*
 overview:
   this file contains the following data quality checks...
     1. Check that all interviews were completed
     2. Check that there are no duplicate observations
     3. Check that all surveys have consent
     4. Check that certain critical variables have no missing values
     5. Check that follow up record ids match original
     6. Check that no variable has only one distinct value
     7. Check that no variable has all missing values
     8. Check hard/soft constraints
     9. Check specify other vars for items that can be included
     10. Check that date values fall within survey range
     11. Check that there are no outliers for unconstrained vars
     12. Check that survey and section durations fall within limits
*/

// dtanotes

// local definitions
local infile  "hfc_inputs.xlsx"
local outfile "hfc_outputs.xlsx"
local repfile "hfc_replacements.xlsx"
local id "qnum"
local enum "surnum"
local startdate "startdate"


/* =============================================================== 
   ================== Import locals from Excel  ================== 
   =============================================================== */

ipacheckimport using "hfc_inputs.xlsx"

/* =============================================================== 
   ================= Replacements and Corrections ================ 
   =============================================================== */

*readreplace using "hfc_replacements.xlsx", id("id") variable("variable") value("newvalue") excel


/* =============================================================== 
   ==================== High Frequency Checks ==================== 
   =============================================================== */

/* <=========== HFC 1. Check that all interviews were completed ===========> */
ipacheckcomplete ${variable1}, ivalue(${incomplete_value1}) ///
    id(`id') ///
    enumerator(`enum') ///
    saving(`outfile') ///
    sheetreplace
                               

/* <======== HFC 2. Check that there are no duplicate observations ========> */
ipacheckdups ${variable2}, enumerator(`enum') ///
    saving(`outfile') ///
    sheetreplace

/* <============== HFC 3. Check that all surveys have consent =============> */
ipacheckconsent ${variable3}, consentvalue(${consent_value3}) ///
    id(`id') ///
    enumerator(`enum') ///
    saving(`outfile') ///
    sheetreplace

/* <===== HFC 4. Check that critical variables have no missing values =====> */
ipachecknomiss ${variable4}, id(`id') /// 
    enumerator(`enum') ///
    saving(`outfile') ///
    sheetreplace

/* <======== HFC 5. Check that follow up record ids match original ========> */
/*ipacheckfollowup using "master_tracking_list.dta", id(`id') ///
    enumerator(`enum') ///
    saving(`outfile') ///
    sheetreplace*/

/* <====== HFC 6. Check that no variable has only one distinct value ======> */
*ipacheckskip var, saving(`outfile') enumerator(`enum')

/* <======== HFC 7. Check that no variable has all missing values =========> */
ipacheckallmiss, id(`id') ///
    enumerator(`enum') ///
    saving(`outfile') ///
    sheetmodify

/* <=============== HFC 8. Check for hard/soft constraints ================> */
ipacheckconstraints ${variable8}, smin(${soft_min8}) ///
    smax(${soft_max8}) ///
    id(`id') ///
    enumerator(`enum') ///
    saving(`outfile') ///
    sheetreplace

/* <================== HFC 9. Check specify other values ==================> */
ipacheckspecify ${specify_variable9}, id(`id') ///
    enumerator(`enum') ///
    saving(`outfile') ///
    sheetreplace

/* <========== HFC 10. Check that dates fall within survey range ==========> */
ipacheckdates ${startdate10} ${enddate10}, surveystart(${surveystart10}) ///
    id(`id') ///
    enumerator(`enum') ///
    enumarea(ward_clean) ///
    days(7) ///
    saving(`outfile') ///
    sheetreplace

/* <============= HFC 11. Check for outliers in unconstrained =============> */
*ipacheckoutliers var, saving(`outfile') enumerator(`enum')

/* <============= HFC 12. Check survey and section durations ==============> */
*ipacheckduration var, saving(`outfile') enumerator(`enum')


/* ===============================================================
   =============== User Checks Programming Template ==============
   =============================================================== */



/* ===============================================================
   ================= High Frequency Check Report =================
   =============================================================== */
