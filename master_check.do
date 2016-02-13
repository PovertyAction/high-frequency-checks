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
use "filename.dta", clear

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
     8. Check for outliers/soft constraints
     9. Check specify others for items that can be included
     10. Check that date values fall within survey range
*/

/* =============================================================== 
   ================== Import locals from Excel  ================== 
   =============================================================== */
ipacheckimport using file

/* =============================================================== 
   ================= Replacements and Corrections ================ 
   =============================================================== */
readreplace
readreplace


/* =============================================================== 
   ==================== High Frequency Checks ==================== 
   =============================================================== */


/* <============== HFC 1. Check that all interviews were completed =============> */
ipacheckcomplete var, val() saving() enumerator()

/* <============== HFC 2. Check that there are no duplicate observations =============> */
ipacheckdups id, saving() enumerator()

/* <============== HFC 3. Check that all surveys have consent =============> */
ipacheckconsent var, saving() enumerator()

/* <============== HFC 4. Check that critical variables have no missing values =============> */
ipachecknomiss var, saving() enumerator()

/* <============== HFC 5. Check that follow up record ids match original =============> */
ipacheckfollowup var, saving() enumerator()

/* <============== HFC 6. Check that no variable has only one distinct value =============> */
ipacheckdistinct var, saving() enumerator()

/* <============== HFC 7. Check that no variable has all missing values =============> */
ipacheckallmiss var, saving()

/* <============== HFC 8. Check for outliers/soft constraints =============> */
ipacheckoutliers var, saving() enumerator()

/* <============== HFC 9. Check specify other values for misscodes/recategorization =============> */
ipacheckspecify var, saving() enumerator()

/* <============== HFC 10. Check that date values fall within survey range =============> */
ipacheckdates var, saving() enumerator()


/* ===============================================================
   =============== User Checks Programming Template ==============
   =============================================================== */
