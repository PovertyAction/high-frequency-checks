*! version 2.0.0 Christopher Boyer 07apr2017

/* =============================================================== 
   ===============================================================
   ============== IPA HIGH FREQUENCY CHECK TEMPLATE  ============= 
   ===============================================================
   =============================================================== */
   
* this line adds standard boilerplate headings
ipadoheader, version(13.0)
	 

/* =============================================================== 
   ================== Import globals from Excel  ================= 
   =============================================================== */

ipacheckimport using "hfc_inputs.xlsm"


/* =============================================================== 
   ================= Replacements and Corrections ================ 
   =============================================================== */

use "${sdataset}", clear

* recode don't know/refusal values
ds, has(type numeric)
local numeric `r(varlist)'
if !mi("${mv1}") recode `numeric' (${mv1} = .d)
if !mi("${mv2}") recode `numeric' (${mv2} = .r)
if !mi("${mv3}") recode `numeric' (${mv3} = .n)
	
if !mi("${repfile}") {
	ipacheckreadreplace using "${repfile}", ///
    id("${id}") ///
		variable("variable") ///
		value("value") ///
		newvalue("newvalue") ///
		action("action") ///
		comments("comments") ///
		sheet("${repsheet}") ///
		logusing("${replog}") 
}


/* =============================================================== 
   ==================== Survey Tracking ==========================
   =============================================================== */


/* <============ Track 1. Summarize completed surveys by date ============> */

if ${run_progreport} {	  
ipatracksummary using "${progreport}", ///
  submit(${date}) ///
  target(${ptarget}) 
}


/* <========== Track 2. Track surveys completed against planned ==========> */

if ${run_progreport} {    	  
progreport, ///
    master("${master}") /// 
    survey("${sdataset}") /// 
    id(${id}) /// 
    sortby(${psortby}) /// 
    keepmaster(${pkeepmaster}) /// 
    filename("${progreport}") /// 
    target(${ptarget}) ///
    ${pvariable} ///
    ${plabel} ///
    workbooks
}

 /* <======== Track 3. Track form versions used by submission date ========> */

if ${run_progreport} {    	  
ipatrackversions ${progreport}, 
  id(${id}) ///
	enumerator(${enum}) ///
	submit(${date}) ///
  saving("${progreport}") 

}   
   

/* =============================================================== 
   ==================== High Frequency Checks ==================== 
   =============================================================== */
  
  
/* <=========== HFC 1. Check that all interviews were completed ===========> */
if ${run_incomplete} {
  ipacheckcomplete ${variable1}, ///
    complete(${complete_value1}) ///
    percent(${complete_percent1}) ///
    id(${id}) ///
    enumerator(${enum}) ///
    submit(${date}) ///
    keepvars("${keep1}") ///
    saving("${outfile}") ///
    sctodb("${server}") ///
    sheetreplace ${nolabel}
}	


/* <======== HFC 2. Check that there are no duplicate observations ========> */
if ${run_duplicates} {
  ipacheckdups ${variable2}, ///
    id(${id}) ///
    enumerator(${enum}) ///
    submit(${date}) ///
    keepvars(${keep2}) ///
    saving("${outfile}") ///
    sctodb("${server}") ///
    sheetreplace ${nolabel}
}	

	
/* <============== HFC 3. Check that all surveys have consent =============> */
if ${run_consent} { 
  ipacheckconsent ${variable3}, ///
    consentvalue(${consent_value3}) ///
    id(${id}) ///
    enumerator(${enum}) ///
    submit(${date}) ///
    keepvars(${keep3}) ///
    saving("${outfile}") ///
    sctodb("${server}") ///
    sheetreplace ${nolabel}
}


/* <===== HFC 4. Check that critical variables have no missing values =====> */
if ${run_no_miss} {
  ipachecknomiss ${variable4}, ///
    id(${id}) /// 
    enumerator(${enum}) ///
    submit(${date}) ///
    keepvars(${keep4}) ///
    saving("${outfile}") ///
    sctodb("${server}") ///
    sheetreplace ${nolabel}
}
	

/* <======== HFC 5. Check that follow up record ids match original ========> */
if ${run_follow_up} {
	ipacheckfollowup ${variable5} using ${master}, ///
    id(${id}) ///
		enumerator(${enum}) ///
		submit(${date}) ///
		saving("${outfile}") ///
		sctodb("${server}") ///
		sheetreplace
}


/* <============= HFC 6. Check skip patterns and survey logic =============> */
if ${run_logic} {
  ipachecklogic ${variable6}, ///
    assert(${assert6}) ///
    condition(${if_condition6}) ///
    id(${id}) ///
    enumerator(${enum}) ///
    submit(${date}) ///
    keepvars(${keep6}) ///
    saving("${outfile}") ///
    sctodb("${server}") ///
    sheetreplace ${nolabel}
}

		 
/* <======== HFC 7. Check that no variable has all missing values =========> */
if ${run_all_miss} {
  ipacheckallmiss ${variable7}, ///
    id(${id}) ///
    enumerator(${enum}) ///
    saving("${outfile}") ///
    sheetreplace ${nolabel}
}


/* <=============== HFC 8. Check for hard/soft constraints ================> */
if ${run_constraints} {
  ipacheckconstraints ${variable8}, ///
    smin(${soft_min8}) ///
    smax(${soft_max8}) ///
    id(${id}) ///
    enumerator(${enum}) ///
    submit(${date}) ///
    keepvars(${keep8}) ///
    saving("${outfile}") ///
    sctodb("${server}") ///
    sheetreplace ${nolabel}
}


/* <================== HFC 9. Check specify other values ==================> */
if ${run_specify} {
  ipacheckspecify ${child9}, ///
    parentvars(${parent9}) ///
    id(${id}) ///
    enumerator(${enum}) ///
    submit(${date}) ///
    keepvars(${keep9}) ///
    saving("${outfile}") ///
    sctodb("${server}") ///
    sheetreplace ${nolabel}
}

	
/* <========== HFC 10. Check that dates fall within survey range ==========> */
if ${run_dates} {
  ipacheckdates ${startdate10} ${enddate10}, ///
    surveystart(${surveystart10}) ///
    id(${id}) ///
    enumerator(${enum}) ///
    submit(${date}) ///
    keepvars(${keep10}) ///
    saving("${outfile}") ///
    sctodb("${server}") ///
    sheetreplace ${nolabel}
}


/* <============= HFC 11. Check for outliers in unconstrained =============> */
if ${run_outliers} {
  ipacheckoutliers ${variable11}, id(${id}) ///
    enumerator(${enum}) ///
    submit(${date}) ///
    multiplier(${multiplier11}) ///
    keepvars(${keep11}) ///
    ignore(${ignore11}) ///
    saving("${outfile}") ///
    sctodb("${server}") ///
    sheetreplace ${nolabel} ${sd}
}


/* <============= HFC 12. Check for and output field comments =============> */
if ${run_field_comments} {
  ipacheckcomment ${fieldcomments}, id(${id}) ///
    media(${sctomedia}) ///
    enumerator(${enum}) ///
    submit(${date}) ///
    keepvars(${keep12}) ///
    saving("${outfile}") ///
    sheetreplace ${nolabel}
}


/* <=============== HFC 13. Output summaries for text audits ==============> */
if ${run_text_audits} {
  ipachecktextaudit ${textaudit} using "${textauditdb}",  ///
    media("${sctomedia}") ///
    enumerator(${enum}) ///
    keepvars(${keep15})
}


/* ===============================================================
   ================= Create Enumerator Dashboard =================
   =============================================================== */

if ${run_enumdb} {
  ipacheckenum ${enum} using "${enumdb}", ///
     dkrfvars(${dkrf_variable14}) ///
     missvars(${missing_variable14}) ///
     durvars(${duration_variable14}) ///
     othervars(${other_variable14}) ///
     statvars(${stats_variable14}) ///
     exclude(${exclude_variable14}) ///
     subdate(${submission_date14}) ///
     ${stats}
}
 

/* ===============================================================
   ================== Create Research Dashboard ==================
   =============================================================== */

* tabulate one-way summaries of important research variables
if ${run_research_oneway} {
  ipacheckresearch using "${researchdb}", ///
    variables(${variablestr15})
}

* tabulate two-way summaries of important research variables
if ${run_research_twoway} {
  ipacheckresearch using "${researchdb}", ///
    variables(${variablestr16}) by(${by16}) 
}
   
   
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
