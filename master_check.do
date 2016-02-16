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
use "test.dta", clear

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
local outfile "hfc_output.xlsx"


/* =============================================================== 
   ================== Import locals from Excel  ================== 
   =============================================================== */
ipacheckimport using "hfc_inputs.xlsx"
local = r()
local = r()

/* =============================================================== 
   ================= Replacements and Corrections ================ 
   =============================================================== */
readreplace using "hfc_replacements.xlsx", id() variable() value() excel import(firstrow sheet())
readreplace using "hfc_replacements.xlsx", id() variable() value() excel import(firstrow sheet())
readreplace using "hfc_replacements.xlsx", id() variable() value() excel import(firstrow sheet())
readreplace using "hfc_replacements.xlsx", id() variable() value() excel import(firstrow sheet())
readreplace using "hfc_replacements.xlsx", id() variable() value() excel import(firstrow sheet())
readreplace using "hfc_replacements.xlsx", id() variable() value() excel import(firstrow sheet())
readreplace using "hfc_replacements.xlsx", id() variable() value() excel import(firstrow sheet())
readreplace using "hfc_replacements.xlsx", id() variable() value() excel import(firstrow sheet())
readreplace using "hfc_replacements.xlsx", id() variable() value() excel import(firstrow sheet())


/* =============================================================== 
   ==================== High Frequency Checks ==================== 
   =============================================================== */


/* <=========== HFC 1. Check that all interviews were completed ===========> */
ipacheckcomplete var, val() saving(`outfile') enumerator(`enum')

/* <======== HFC 2. Check that there are no duplicate observations ========> */
ipacheckdups id, saving(`outfile') enumerator(`enum')

/* <============== HFC 3. Check that all surveys have consent =============> */
ipacheckconsent var, saving(`outfile') enumerator(`enum')

/* <===== HFC 4. Check that critical variables have no missing values =====> */
ipachecknomiss var, saving(`outfile') enumerator(`enum')

/* <======== HFC 5. Check that follow up record ids match original ========> */
ipacheckfollowup var, saving(`outfile') enumerator()

/* <====== HFC 6. Check that no variable has only one distinct value ======> */
ipacheckdistinct var, saving(`outfile') enumerator()

/* <======== HFC 7. Check that no variable has all missing values =========> */
ipacheckallmiss var, saving(`outfile')

/* <============= HFC 8. Check for outliers/soft constraints ==============> */
ipacheckconstraints var, saving(`outfile') enumerator()

/* <================== HFC 9. Check specify other values ==================> */
ipacheckspecify var, saving(`outfile') enumerator()

/* <========== HFC 10. Check that dates fall within survey range ==========> */
ipacheckdates var, saving(`outfile') enumerator()

/* <============= HFC 11. Check for outliers/soft constraints =============> */
ipacheckoutliers var, saving(`outfile') enumerator()

/* <============= HFC 12. Check survey and section durations ==============> */
ipacheckduration var, saving(`outfile') enumerator()


/* ===============================================================
   =============== User Checks Programming Template ==============
   =============================================================== */


/* ===============================================================
   ================= High Frequency Check Report =================
   =============================================================== */
