*! version 2.0.0 Christopher Boyer 07apr2017

/* =============================================================== 
   ===============================================================
   ============== IPA HIGH FREQUENCY CHECK TEMPLATE  ============= 
   ===============================================================
   =============================================================== */
   
* this line adds standard boilerplate headings
ipadoheader, version(13.0)

/* overview:
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
     11. Check that there are no outliers for unconstrained vars */
	 

/* =============================================================== 
   ================== Import globals from Excel  ================= 
   =============================================================== */

ipacheckimport using "hfc_inputs.xlsx"


/* =============================================================== 
   ================= Replacements and Corrections ================ 
   =============================================================== */

use "${dataset}", clear

* recode don't know/refusal values
ds, has(type numeric)
local numeric `r(varlist)'
if !mi("${mv1}") recode `numeric' (${mv1} = .d)
if !mi("${mv2}") recode `numeric' (${mv2} = .r)
if !mi("${mv3}") recode `numeric' (${mv3} = .n)
	
if !mi("${repfile}") {
	readreplace using "${repfile}", ///
	  id("id") ///
		variable("variable") ///
		value("newvalue") ///
		excel ///
		import(firstrow)
}


/* =============================================================== 
   ==================== Survey Tracking ==========================
   =============================================================== */

 /* <============ Track 1. Summarize completed surveys by date ============> */

      /* the command below creates a summary page for the HFC 
      output showing stats on survey completion by submission 
	  date */
	  
ipatracksummary using "${outfile}", submit(${date}) target(${target}) 

/* <========== Track 2. Track surveys completed against planned ==========> */

      /* the command below creates a table showing the num of 
	  surveys completed, num of surveys planned, and num of 
	  surveys remaining in each given unit (e.g. by region, 
	  district, etc.). It also shows the date of the first
	  survey completed in that unit and the date of the last
	  */
	  
ipatracksurveys using "${outfile}", unit(${geounit}) ///
	id(${id}) submit(${date}) sample("${master}") 

 /* <======== Track 3. Track form versions used by submission date ========> */

      /* the command below creates a table showing the num of 
	  each form version used on each submission date. For the 
	  most recent submission date, if any entries didn't use the
	  latest form version, the id and enumerator is listed below
	  the table */
	  
ipatrackversions ${formversion}, id(${id}) 
	enumerator(${enum}) ///
	submit(${date}) ///
    saving("${outfile}") 
   
   
/* =============================================================== 
   ==================== High Frequency Checks ==================== 
   =============================================================== */
  
  
/* <=========== HFC 1. Check that all interviews were completed ===========> */
ipacheckcomplete ${variable1}, complete(${complete_value1}) ///
  percent(${complete_percent1}) ///
  id(${id}) ///
  enumerator(${enum}) ///
  submit(${date}) ///
  keepvars("${keep1}") ///
  saving("${outfile}") ///
  sctodb("${server}") ///
  sheetreplace ${nolabel}
	

/* <======== HFC 2. Check that there are no duplicate observations ========> */
ipacheckdups ${variable2}, id(${id}) ///
  enumerator(${enum}) ///
  submit(${date}) ///
  keepvars(${keep2}) ///
  saving("${outfile}") ///
  sctodb("${server}") ///
  sheetreplace ${nolabel}
	
	
/* <============== HFC 3. Check that all surveys have consent =============> */
ipacheckconsent ${variable3}, consentvalue(${consent_value3}) ///
  id(${id}) ///
  enumerator(${enum}) ///
  submit(${date}) ///
  keepvars(${keep3}) ///
  saving("${outfile}") ///
  sctodb("${server}") ///
  sheetreplace ${nolabel}


/* <===== HFC 4. Check that critical variables have no missing values =====> */
ipachecknomiss ${variable4}, id(${id}) /// 
  enumerator(${enum}) ///
  submit(${date}) ///
  keepvars(${keep4}) ///
  saving("${outfile}") ///
  sctodb("${server}") ///
  sheetreplace ${nolabel}
	
	
/* <======== HFC 5. Check that follow up record ids match original ========> */
if !mi("${master}") {
	ipacheckfollowup ${variable5} using ${master}, id(${id}) ///
		enumerator(${enum}) ///
		submit(${date}) ///
		saving("${outfile}") ///
		sctodb("${server}") ///
		sheetreplace
}


/* <============= HFC 6. Check skip patterns and survey logic =============> */
ipacheckskip ${variable6}, assert(${assert6}) ///
  condition(${if_condition6}) ///
  id(${id}) ///
  enumerator(${enum}) ///
  submit(${date}) ///
  keepvars(${keep6}) ///
  saving("${outfile}") ///
  sctodb("${server}") ///
  sheetreplace ${nolabel}
		 
		 
/* <======== HFC 7. Check that no variable has all missing values =========> */
ipacheckallmiss ${variable7}, id(${id}) ///
  enumerator(${enum}) ///
  saving("${outfile}") ///
  sheetreplace ${nolabel}


/* <=============== HFC 8. Check for hard/soft constraints ================> */
ipacheckconstraints ${variable8}, smin(${soft_min8}) ///
  smax(${soft_max8}) ///
  id(${id}) ///
  enumerator(${enum}) ///
  submit(${date}) ///
  keepvars(${keep8}) ///
  saving("${outfile}") ///
  sctodb("${server}") ///
  sheetreplace ${nolabel}
		 

/* <================== HFC 9. Check specify other values ==================> */
ipacheckspecify ${specify_variable9}, ///
  othervars(${other_variable9}) ///
  id(${id}) ///
  enumerator(${enum}) ///
  submit(${date}) ///
  keepvars(${keep9}) ///
  saving("${outfile}") ///
  sctodb("${server}") ///
  sheetreplace ${nolabel}

	
/* <========== HFC 10. Check that dates fall within survey range ==========> */
ipacheckdates ${startdate10} ${enddate10}, surveystart(${surveystart10}) ///
  id(${id}) ///
  enumerator(${enum}) ///
  submit(${date}) ///
  keepvars(${keep10}) ///
  saving("${outfile}") ///
  sctodb("${server}") ///
  sheetreplace ${nolabel}
		 

/* <============= HFC 11. Check for outliers in unconstrained =============> */
ipacheckoutliers ${variable11}, id(${id}) ///
  enumerator(${enum}) ///
  submit(${date}) ///
  multiplier(${multiplier11}) ///
  keepvars(${keep11}) ///
  ignore(${ignore11}) ///
  saving("${outfile}") ///
  sctodb("${server}") ///
  sheetreplace ${nolabel} ${sd}

  
/* ===============================================================
   ================= Create Enumerator Dashboard =================
   =============================================================== */

ipacheckenum ${enum} using "${enumdb}", ///
   dkrfvars(${dkrf_variable12}) ///
   missvars(${missing_variable12}) ///
   durvars(${duration_variable12}) ///
   exclude(${exclude_variable12}) ///
   subdate(${submission_date12})

   
/* ===============================================================
   ================== Create Research Dashboard ==================
   =============================================================== */

   /* in this section we'll use the -table1- command to 
      build one and two way summaries of key variables.
	  this can be useful for communicating data summaries
	  with PIs. 
	  
	  NOTE: -ssc install table1- if not installed. */
	  
#d ;
table1,  
    saving("${researchdb}", replace)
	plusminus
	test
	format(%4.2f)
    vars(gender cat \
	     age contn \ 
		 edustatus cat \
		 eduattain cat \
		 employmt cat \
         relationship cat \
         childnum contn );
#d cr


/* ===============================================================
   =============== User Checks Programming Template ==============
   =============================================================== */

   /* we ENCOURAGE you to use this section to add additional 
      data quality checks that are more specific to your data 
      collection activities. we include several examples below to 
      give you an sense of the possibilities and to show you how
      to integrate the results of your custom checks in the 
	  standard Excel output. */

* Example 1 
* Check if GPS coordinates are within shapefile bounds (ssc install gpsbound)

/*
local shapefile "shapefiles/Ward.shp"

preserve
gpsbound using `shapefile', ///
  lat(gpsLatitude)          ///
  long(gpsLongitude)        ///
  keepusing(ward)
  
assert ward_clean == ward 
if _rc {
  keep SubmissionDate id enumid gpsLatitude gpsLongitude ward ward_clean
  keep if ward_clean != ward
  export excel using "${outfile}", sheet("12. GPS bounds") firstrow(vars) sheetreplace
}
restore

*/
