/*----------------------------------------*
 |file:    test.do                        | 
 |project: high frequency checks          |
 |author:  christopher boyer              |
 |         innovations for poverty action |
 |date:    2017-04-12                     |
 *----------------------------------------*/

* this line adds standard boilerplate headings
ipadoheader, version(13.0)
set trace off


/* =================================================
   ==================== Check 1 ==================== 
   ================================================= */

cd "check01"

* Test 1
use check01_test01, clear
ipacheckimport using "check01_test01_in.xlsx"
ipacheckcomplete ${variable1}, complete(${complete_value1}) ///
    id(id) ///
    enumerator(enum) ///
    submit(var3) ///
    saving("check01_test01_out.xlsx") ///
    sheetreplace

* Test 2
use check01_test02, clear
ipacheckimport using "check01_test02_in.xlsx"
ipacheckcomplete ${variable1}, complete(${complete_value1}) ///
    id(id) ///
    enumerator(enum) ///
	submit(var3) ///
    saving("check01_test02_out.xlsx") ///
    sheetreplace

* Test 3
use check01_test03, clear
ipacheckimport using "check01_test03_in.xlsx"
ipacheckcomplete ${variable1}, complete(${complete_value1}) ///
    id(id) ///
    enumerator(enum) ///
	submit(var3) ///
	keepvars(var1 var2) ///
    saving("check01_test03_out.xlsx") ///
    sheetreplace
	
* Test 3
use check01_test03, clear
ipacheckimport using "check01_test03_in.xlsx"
ipacheckcomplete ${variable1}, complete(${complete_value1}) ///
    id(id) ///
    enumerator(enum) ///
	submit(var3) ///
	keepvars(var1 var2) ///
    saving("check01_test03_out.xlsx") ///
    sheetreplace
	
* Test 4
use check01_test04, clear
ipacheckimport using "check01_test04_in.xlsx"
ipacheckcomplete ${variable1}, complete(${complete_value1}) ///
    percent(${complete_percent1}) ///
    id(id) ///
	submit(var3) ///
    enumerator(enum) ///
	keepvars(var1 var2) ///
    saving("check01_test04_out.xlsx") ///
    sheetreplace
	
* Test 5
use check01_test05, clear
ipacheckimport using "check01_test05_in.xlsx"
ipacheckcomplete ${variable1}, complete(${complete_value1}) ///
    id(id) ///
    enumerator(enum) ///
    submit(var3) ///
    saving("check01_test05_out.xlsx") ///
    sheetreplace ///
	sctodb("test")

/* =================================================
   ==================== Check 2 ==================== 
   ================================================= */

cd "../check02"

* Test 1
use check02_test01, clear
ipacheckimport using "check02_test01_in.xlsx"
ipacheckdups ${variable2}, ///
    id(id) ///
    enumerator(enum) ///
	submit(var3) ///
    saving("check02_test01_out.xlsx") ///
    sheetreplace

* Test 2
use check02_test02, clear
ipacheckimport using "check02_test02_in.xlsx"
ipacheckdups ${variable2}, ///
    id(id) ///
    enumerator(enum) ///
	submit(var3) ///
    saving("check02_test02_out.xlsx") ///
    sheetreplace

* Test 3
use check02_test03, clear
ipacheckimport using "check02_test03_in.xlsx"
ipacheckdups ${variable2}, uniquevars(${other_unique2}) ///
    id(id) ///
    enumerator(enum) ///
	submit(var3) ///
    saving("check02_test03_out.xlsx") ///
    sheetreplace

* Test 4
use check02_test04, clear
ipacheckimport using "check02_test04_in.xlsx"
ipacheckdups ${variable2}, uniquevars(${other_unique2}) ///
    id(id) ///
    enumerator(enum) ///
	submit(var3) ///
    saving("check02_test04_out.xlsx") ///
    sheetreplace

* Test 5
use check02_test05, clear
ipacheckimport using "check02_test05_in.xlsx"
ipacheckdups ${variable2}, uniquevars(${other_unique2}) ///
    id(id) ///
    enumerator(enum) ///
	submit(var3) ///
	keepvars(${keep_variable2}) ///
    saving("check02_test05_out.xlsx") ///
    sheetreplace

* Test 6
use check02_test06, clear
ipacheckimport using "check02_test06_in.xlsx"
ipacheckdups ${variable2}, uniquevars(${other_unique2}) ///
    id(id) ///
    enumerator(enum) ///
	submit(var3) ///
	keepvars(${keep_variable2}) ///
    saving("check02_test06_out.xlsx") ///
    sheetreplace
	
* Test 7
use check02_test07, clear
ipacheckimport using "check02_test07_in.xlsx"
ipacheckdups ${variable2}, uniquevars(${other_unique2}) ///
    id(id) ///
    enumerator(enum) ///
	submit(var3) ///
	keepvars(${keep_variable2}) ///
    saving("check02_test07_out.xlsx") ///
    sheetreplace

* Test 8
use check02_test08, clear
ipacheckimport using "check02_test08_in.xlsx"
ipacheckdups ${variable2}, uniquevars(${other_unique2}) ///
    id(id) ///
    enumerator(enum) ///
	submit(var3) ///
	keepvars(${keep_variable2}) ///
    saving("check02_test08_out.xlsx") ///
    sheetreplace 
	
* Test 9
use check02_test09, clear
ipacheckimport using "check02_test09_in.xlsx"
ipacheckdups ${variable2}, ///
    id(id) ///
    enumerator(enum) ///
	submit(var3) ///
    saving("check02_test09_out.xlsx") ///
    sheetreplace ///
	sctodb("test")
	
/* =================================================
   ==================== Check 3 ==================== 
   ================================================= */

cd "../check03"

* Test 1
use check03_test01, clear
ipacheckimport using "check03_test01_in.xlsx"
ipacheckconsent ${variable3}, consentvalue(${consent_value3}) ///
    id(id) ///
    enumerator(enum) ///
	submit(var3) ///
    saving("check03_test01_out.xlsx") ///
    sheetreplace

* Test 2
use check03_test02, clear
ipacheckimport using "check03_test02_in.xlsx"
ipacheckconsent ${variable3}, consentvalue(${consent_value3}) ///
    id(id) ///
    enumerator(enum) ///
	submit(var3) ///
    saving("check03_test02_out.xlsx") ///
    sheetreplace

* Test 3
use check03_test03, clear
ipacheckimport using "check03_test03_in.xlsx"
ipacheckconsent ${variable3}, consentvalue(${consent_value3}) ///
    id(id) ///
    enumerator(enum) ///
	submit(var3) ///
	keepvars(var1 var2) ///
    saving("check03_test03_out.xlsx") ///
    sheetreplace
	
* Test 4
use check03_test04, clear
ipacheckimport using "check03_test04_in.xlsx"
ipacheckconsent ${variable3}, consentvalue(${consent_value3}) ///
    id(id) ///
    enumerator(enum) ///
	submit(var3) ///
    saving("check03_test04_out.xlsx") ///
    sheetreplace ///
	sctodb("test")
	
* Test 5
use check03_test05, clear
ipacheckimport using "check03_test05_in.xlsx"
ipacheckconsent ${variable3}, consentvalue(${consent_value3}) ///
    id(id) ///
    enumerator(enum) ///
	submit(var3) ///
    saving("check03_test05_out.xlsx") ///
    sheetreplace ///
	sctodb("test")

	
/* =================================================
   ==================== Check 4 ==================== 
   ================================================= */

cd "../check04"

* Test 1
use check04_test01, clear
ipacheckimport using "check04_test01_in.xlsx"
ipachecknomiss ${variable4}, ///
    id(id) ///
    enumerator(enum) ///
	submit(var3) ///
    saving("check04_test01_out.xlsx") ///
    sheetreplace

* Test 2
use check04_test02, clear
ipacheckimport using "check04_test02_in.xlsx"
ipachecknomiss ${variable4}, ///
    id(id) ///
    enumerator(enum) ///
	submit(var3) ///
    saving("check04_test02_out.xlsx") ///
    sheetreplace
	
* Test 3
use check04_test03, clear
ipacheckimport using "check04_test03_in.xlsx"
ipachecknomiss ${variable4}, ///
    id(id) ///
    enumerator(enum) ///
	submit(var3) ///
	keepvars(${keep_variable4}) ///
    saving("check04_test03_out.xlsx") ///
    sheetreplace
	
* Test 4
use check04_test04, clear
ipacheckimport using "check04_test01_in.xlsx"
ipachecknomiss ${variable4}, ///
    id(id) ///
    enumerator(enum) ///
	submit(var3) ///
    saving("check04_test04_out.xlsx") ///
    sheetreplace ///
	sctodb("test")
	
/* =================================================
   ==================== Check 5 ==================== 
   ================================================= */

cd "../check05"

* Test 1
use check05_test01, clear
ipacheckimport using "check05_test01_in.xlsx"
ipacheckfollowup ${variable5} using "check05_test01_master.dta", ///
	id(id) ///
    enumerator(enum) ///
	submit(var3) ///
    saving("check05_test01_out.xlsx") ///
    sheetreplace
	
* Test 2
use check05_test02, clear
ipacheckimport using "check05_test02_in.xlsx"
ipacheckfollowup ${variable5} using "check05_test02_master.dta", ///
	id(id) ///
    enumerator(enum) ///
	submit(var3) ///
    saving("check05_test02_out.xlsx") ///
    sheetreplace

* Test 3
use check05_test03, clear
ipacheckimport using "check05_test03_in.xlsx"
ipacheckfollowup ${variable5} using "check05_test03_master.dta", ///
	id(id) ///
    enumerator(enum) ///
	submit(var3) ///
	keepvars(${keep_variable5}) ///
    saving("check05_test03_out.xlsx") ///
    sheetreplace
	
* Test 4
use check05_test04, clear
ipacheckimport using "check05_test04_in.xlsx"
ipacheckfollowup ${variable5} using "check05_test04_master.dta", ///
	id(id) ///
    enumerator(enum) ///
	submit(var4) ///
	keepvars(${keep_variable5}) ///
	keepmaster(${keep_master5}) ///
    saving("check05_test04_out.xlsx") ///
    sheetreplace

* Test 5
use check05_test05, clear
ipacheckimport using "check05_test05_in.xlsx"
ipacheckfollowup ${variable5} using "check05_test05_master.dta", ///
	id(id) ///
    enumerator(enum) ///
	submit(var3) ///
    saving("check05_test05_out.xlsx") ///
    sheetreplace ///
	sctodb("test")
	
/* =================================================
   ==================== Check 6 ==================== 
   ================================================= */

cd "../check06"

* Test 1
use check06_test01, clear
ipacheckimport using "check06_test01_in.xlsx"
ipacheckskip ${variable6}, ///
	assert(${assert6}) ///
	condition(${if_condition6}) ///
	keepvars(${keep_variable6}) ///
	id(id) ///
    enumerator(enum) ///
	submit(var3) ///
    saving("check06_test01_out.xlsx") ///
    sheetreplace
	
* Test 2
use check06_test02, clear
ipacheckimport using "check06_test02_in.xlsx"
ipacheckskip ${variable6}, ///
	assert(${assert6}) ///
	condition(${if_condition6}) ///
	keepvars(${keep_variable6}) ///
	id(id) ///
    enumerator(enum) ///
	submit(var3) ///
    saving("check06_test02_out.xlsx") ///
    sheetreplace

	* Test 3
use check06_test03, clear
ipacheckimport using "check06_test03_in.xlsx"
ipacheckskip ${variable6}, ///
	assert(`"${assert6}"') ///
	condition(`"${if_condition6}"') ///
	keepvars(${keep_variable6}) ///
	id(id) ///
    enumerator(enum) ///
    submit(var3) ///
    saving("check06_test03_out.xlsx") ///
    sheetreplace
	
	/* Test 4
use check06_test04, clear
ipacheckimport using "check06_test04_in.xlsx"
ipacheckskip ${variable6}, ///
	assert(${assert6}) ///
	condition(${if_condition6}) ///
	keepvars(${keep_variable6}) ///
	id(id) ///
    enumerator(enum) ///
    submit(var3) ///
    saving("check06_test04_out.xlsx") ///
    sheetreplace*/
	
	* Test 5
use check06_test05, clear
ipacheckimport using "check06_test05_in.xlsx"
ipacheckskip ${variable6}, ///
	assert(`"${assert6}"') ///
	condition(`"${if_condition6}"') ///
	keepvars(${keep_variable6}) ///
	id(id) ///
    enumerator(enum) ///
    submit(var3) ///
    saving("check06_test05_out.xlsx") ///
    sheetreplace

* Test 6
use check06_test06, clear
ipacheckimport using "check06_test06_in.xlsx"
ipacheckskip ${variable6}, ///
	assert(${assert6}) ///
	condition(${if_condition6}) ///
	keepvars(${keep_variable6}) ///
	id(id) ///
    enumerator(enum) ///
	submit(var3) ///
    saving("check06_test06_out.xlsx") ///
    sheetreplace ///
	sctodb("test")
	
/* =================================================
   ==================== Check 7 ==================== 
   ================================================= */
   
cd "../check07"

* Test 1
use check07_test01, clear
ipacheckimport using "check07_test01_in.xlsx"
ipacheckallmiss ${variable7}, ///
    id(id) ///
    enumerator(enum) ///
    saving("check07_test01_out.xlsx") ///
    sheetreplace

* Test 2
use check07_test02, clear
ipacheckimport using "check07_test02_in.xlsx"
ipacheckallmiss ${variable7}, ///
    id(id) ///
    enumerator(enum) ///
    saving("check07_test02_out.xlsx") ///
    sheetreplace
   
   
/* =================================================
   ==================== Check 8 ==================== 
   ================================================= */
   
cd "../check08"

* Test 1
use check08_test01, clear
ipacheckimport using "check08_test01_in.xlsx"
ipacheckconstraints ${variable8}, smin(${soft_min8}) ///
    smax(${soft_max8}) ///
	hmin(${hard_min8}) ///
	hmax(${hard_max8}) ///
    id(id) ///
    enumerator(enum) ///
    submit(var3) ///
    saving("check08_test01_out.xlsx") ///
    sheetreplace

* Test 2
use check08_test02, clear
ipacheckimport using "check08_test02_in.xlsx"
ipacheckconstraints ${variable8}, smin(${soft_min8}) ///
    smax(${soft_max8}) ///
	hmin(${hard_min8}) ///
	hmax(${hard_max8}) ///
    id(id) ///
    enumerator(enum) ///
    submit(var3) ///
    saving("check08_test02_out.xlsx") ///
    sheetreplace

* Test 3
use check08_test03, clear
ipacheckimport using "check08_test03_in.xlsx"
ipacheckconstraints ${variable8}, smin(${soft_min8}) ///
    smax(${soft_max8}) ///
	hmin(${hard_min8}) ///
	hmax(${hard_max8}) ///
    id(id) ///
    enumerator(enum) ///
    submit(var3) ///
	keepvars("${keep_variable8}") ///
    saving("check08_test03_out.xlsx") ///
    sheetreplace
	
* Test 4
use check08_test04, clear
ipacheckimport using "check08_test04_in.xlsx"
ipacheckconstraints ${variable8}, smin(${soft_min8}) ///
    smax(${soft_max8}) ///
	hmin(${hard_min8}) ///
	hmax(${hard_max8}) ///
    id(id) ///
    enumerator(enum) ///
    submit(var3) ///
    saving("check08_test04_out.xlsx") ///
    sheetreplace ///
	sctodb("test")
	
* Test 5
use check08_test05, clear
ipacheckimport using "check08_test05_in.xlsx"
ipacheckconstraints ${variable8}, smin(${soft_min8}) ///
    smax(${soft_max8}) ///
	hmin(${hard_min8}) ///
	hmax(${hard_max8}) ///
    id(id) ///
    enumerator(enum) ///
    submit(var3) ///
    saving("check08_test05_out.xlsx") ///
    sheetreplace ///
	sctodb("test")
	
/* =================================================
   ==================== Check 9 ==================== 
   ================================================= */

cd "../check09"

* Test 1
use check09_test01, clear
ipacheckimport using "check09_test01_in.xlsx"
ipacheckspecify ${child9}, ///
	parentvars(${parent9}) ///
    id(id) ///
    enumerator(enum) ///
    submit(submissiondate) ///
    saving("check09_test01_out.xlsx") ///
    sheetreplace

* Test 2
use check09_test02, clear
ipacheckimport using "check09_test02_in.xlsx"
ipacheckspecify ${child9}, ///
	parentvars(${parent9}) ///
    id(id) ///
    enumerator(enum) ///
    submit(submissiondate) ///
    saving("check09_test02_out.xlsx") ///
    sheetreplace ///
	sctodb("test")

* Test 3
use check09_test03, clear
ipacheckimport using "check09_test03_in.xlsx"
ipacheckspecify ${child9}, ///
	parentvars(${parent9}) ///
    id(id) ///
    enumerator(enum) ///
    submit(submissiondate) ///
    saving("check09_test03_out.xlsx") ///
    sheetreplace ///
	sctodb("test")

/* =================================================
   =================== Check 10 ==================== 
   ================================================= */

cd "../check10"

* Test 1
use check10_test01, clear
ipacheckimport using "check10_test01_in.xlsx"
ipacheckdates ${startdate10} ${enddate10}, surveystart(${surveystart10}) ///
    id(id) ///
    enumerator(enum) ///
    submit(var3) ///
    saving("check10_test01_out.xlsx") ///
    sheetreplace

* Test 2
use check10_test02, clear
ipacheckimport using "check10_test02_in.xlsx"
ipacheckdates ${startdate10} ${enddate10}, surveystart(${surveystart10}) ///
    id(id) ///
    enumerator(enum) ///
    submit(var3) ///
    saving("check10_test02_out.xlsx") ///
    sheetreplace

* Test 3
use check10_test03, clear
ipacheckimport using "check10_test03_in.xlsx"
ipacheckdates ${startdate10} ${enddate10}, surveystart(${surveystart10}) ///
    id(id) ///
    enumerator(enum) ///
    submit(var3) ///
	enumarea(${enumarea10}) ///
	days(${days10}) ///
    saving("check10_test03_out.xlsx") ///
    sheetreplace

* Test 4
use check10_test04, clear
ipacheckimport using "check10_test04_in.xlsx"
ipacheckdates ${startdate10} ${enddate10}, surveystart(${surveystart10}) ///
    id(id) ///
    enumerator(enum) ///
    submit(var3) ///
	enumarea(${enumarea10}) ///
	keepvars(${keep_variable10}) ///
	days(${days10}) ///
    saving("check10_test04_out.xlsx") ///
    sheetreplace

* Test 5
use check10_test05, clear
ipacheckimport using "check10_test05_in.xlsx"
ipacheckdates ${startdate10} ${enddate10}, surveystart(${surveystart10}) ///
    id(id) ///
    enumerator(enum) ///
    submit(var3) ///
    saving("check10_test05_out.xlsx") ///
    sheetreplace ///
	sctodb("test")
	
* Test 6
use check10_test06, clear
ipacheckimport using "check10_test06_in.xlsx"
ipacheckdates ${startdate10} ${enddate10}, surveystart(${surveystart10}) ///
    id(id) ///
    enumerator(enum) ///
    submit(var3) ///
    saving("check10_test06_out.xlsx") ///
    sheetreplace ///
	sctodb("test")
	
	
/* =================================================
   =================== Check 11 ==================== 
   ================================================= */

cd "../check11"

* Test 1
use check11_test01, clear
ipacheckimport using "check11_test01_in.xlsx"
ipacheckoutliers ${variable11}, id(id) ///
    enumerator(enum) ///
    submit(var3) ///
    multiplier(${multiplier11}) ///
    saving("check11_test01_out.xlsx") ///
    sheetreplace

* Test 2
use check11_test02, clear
ipacheckimport using "check11_test02_in.xlsx"
ipacheckoutliers ${variable11}, id(id) ///
    enumerator(enum) ///
    submit(var3) ///
    multiplier(${multiplier11}) ///
    saving("check11_test02_out.xlsx") ///
    sheetreplace
	
* Test 3
use check11_test03, clear
ipacheckimport using "check11_test03_in.xlsx"
ipacheckoutliers ${variable11}, id(id) ///
    enumerator(enum) ///
    submit(var3) ///
    multiplier(${multiplier11}) ///
    saving("check11_test03_out.xlsx") ///
    sheetreplace sd
	
* Test 4
use check11_test04, clear
ipacheckimport using "check11_test04_in.xlsx"
ipacheckoutliers ${variable11}, id(id) ///
    enumerator(enum) ///
    submit(var3) ///
	keepvars(${keep_variable11}) ///
    multiplier(${multiplier11}) ///
    saving("check11_test04_out.xlsx") ///
    sheetreplace sd
	
* Test 5
use check11_test05, clear
ipacheckimport using "check11_test05_in.xlsx"
di "${ignore11}"
ipacheckoutliers ${variable11}, id(id) ///
    enumerator(enum) ///
    submit(var3) ///
	keepvars(${keep_variable11}) ///
    multiplier(${multiplier11}) ///
	ignore(${ignore11}) ///
    saving("check11_test05_out.xlsx") ///
    sheetreplace sd

* Test 6
use check11_test06, clear
ipacheckimport using "check11_test06_in.xlsx"
ipacheckoutliers ${variable11}, id(id) ///
    enumerator(enum) ///
    submit(var3) ///
    multiplier(${multiplier11}) ///
    saving("check11_test06_out.xlsx") ///
    sheetreplace ///
	sctodb("test")
	
* Test 7
use check11_test07, clear
ipacheckimport using "check11_test07_in.xlsx"
di "${ignore11}"
ipacheckoutliers ${variable11}, id(id) ///
    enumerator(enum) ///
    submit(var3) ///
	keepvars(${keep_variable11}) ///
    multiplier(${multiplier11}) ///
	ignore(${ignore11}) ///
    saving("check11_test07_out.xlsx") ///
    sheetreplace sd
	
	
/* =================================================
   ============== Track 1 - Summary ================
   ================================================= */
   
cd "../track01"

* Test 1
use track01_test01, clear
local target = 100
local outfile "track01_test01_out.xlsx"
ipatracksummary using "`outfile'", ///
submit(submissiondate) target(`target') 

* Test 2
use track01_test02, clear
local target = 100
local outfile "track01_test02_out.xlsx"
ipatracksummary using "`outfile'", ///
submit(submissiondate) target(`target') 

* Test 3
use track01_test03, clear
local target = 100
local outfile "track01_test03_out.xlsx"
ipatracksummary using "`outfile'", ///
submit(submissiondate) target(`target') 


/* =================================================
   =========== Track 3 - Form Versions =============
   ================================================= */
   
cd "../track03"

* Test 1 (normal)
use track03_test01, clear
local outfile "track03_test01_out.xlsx"
ipatrackversions form_version, id(id) ///
	enumerator(enum) ///
	submit(submissiondate) ///
    saving("`outfile'") 

* Test 2 (sub date missing)
use track03_test02, clear
local outfile "track03_test02_out.xlsx"
rcof ipatrackversions form_version, id(id) ///
	enumerator(enum) ///
	submit(submissiondate) ///
    saving("`outfile'") == 101 

/* Test 3
use track03_test03, clear
local outfile "track03_test03_out.xlsx"
rcof ipatrackversions form_version, id(id) ///
	enumerator(enum) ///
	submit(submissiondate) ///
    saving("`outfile'") == 122*/    

* Test 4
use track03_test04, clear
local outfile "track03_test04_out.xlsx"
rcof ipatrackversions form_version, id(id) ///
	enumerator(enum) ///
	submit(submissiondate) ///
    saving("`outfile'") == 101 

/* =================================================
   =========== Track 2 - Track Surveys =============
   ================================================= */
   
cd "../track02"

* Test 1
use track02_test01, clear
local outfile "track02_test01_out.xlsx"
ipatracksurveys using "`outfile'", unit(region) ///
	id(id) submit(submissiondate) ///
	sample("track02_test01_sample.xlsx")

* Test 2
use track02_test02, clear
local outfile "track02_test02_out.xlsx" 
ipatracksurveys using "`outfile'", unit(region) ///
	id(id) submit(submissiondate) ///
	s_id(sample_id) s_unit(sample_region) ///
	sample("track02_test02_sample.xlsx")

* Test 3
use track02_test03, clear
local outfile "track02_test03_out.xlsx"
ipatracksurveys using "`outfile'", unit(region) ///
	id(id) submit(submissiondate) ///
	sample("track02_test03_sample.xlsx")

* Test 4
use track02_test04, clear
local outfile "track02_test04_out.xlsx"
ipatracksurveys using "`outfile'", unit(region) ///
	id(id) submit(submissiondate) ///
	sample("track02_test04_sample.xlsx") 

* Test 5 
use track02_test05, clear
local outfile "track02_test05_out.xlsx"
rcof ipatracksurveys using "`outfile'", unit(region) ///
	id(id) submit(submissiondate) ///
	s_id(fake_id) ///	
	sample("track02_test05_sample.xlsx") == 111

* Test 6
use track02_test06, clear
local outfile "track02_test06_out.xlsx"
ipatracksurveys using "`outfile'", unit(region) ///
	id(id) submit(submissiondate) ///
	sample("track02_test06_sample.xlsx")


/* =================================================
   =================== Enumerator ================== 
   ================================================= */
   
cd "../enumerator"
* Test 1
use enumerator_test01, clear
ipacheckimport using "enumerator_test01_in.xlsx"
ipacheckenum enumid using "enumerator_test01_out.xlsx", ///
   dkrfvars(${dkrf_variable12}) ///
   missvars(${missing_variable12}) ///
   subdate(${submission_date12}) ///
   days(2000)

   
/* =================================================
   ==================== Research =================== 
   ================================================= */
   
cd "../research"

* Test 1
use survey_data, clear
ipacheckimport using "research_inputs.xlsx"
ipacheckresearch using "research_test01_out.xlsx", ///
   variables(${variablestr13})
   
* Test 2
use survey_data, clear
ipacheckimport using "research_inputs.xlsx"
ipacheckresearch using "research_test02_out.xlsx", ///
   variables(${variablestr14}) by(${by14})
   
/* =================================================
   ================== Readreplace ================== 
   ================================================= */

cd "../readreplace"
*Test 1
use readreplace_test01, clear
ipacheckreadreplace using "readreplace_test01_corr.xlsm", ///
	id(id) ///
	variable(variable) ///
	value(value) ///
	newvalue(newvalue) ///
    action(action) ///
    comments(comments) ///
    sheet(replacements) ///
    logusing("replog.txt")
   
/* =================================================
   ==================== Master ===================== 
   ================================================= */
/*  
cd "../master"

* Test 1
do "master_test01.do"
