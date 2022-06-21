********************************************************************************
** 	TITLE	: 3_prep.do
**
**	PURPOSE	: Prepare Back Check Data for BCSTATS
**				
**	AUTHOR	: 
**
**	DATE	: 
********************************************************************************

**# import data
*------------------------------------------------------------------------------*

	use "$rawbc", clear
	
	* recode extended missing values

	if "$dk_num" ~= "" {
		loc dk_num = trim(itrim(subinstr("$dk_num", ",", " ", .)))
		ds, has(type numeric)
		recode `r(varlist)' (`dk_num' = .d)
	}
	
	if "$ref_num" ~= "" {
		loc ref_num = trim(itrim(subinstr("$ref_num", ",", " ", .)))
		ds, has(type numeric)
		recode `r(varlist)' (`ref_num' = .r)
	}
	
**# drop unwanted variables
*------------------------------------------------------------------------------*

	* NB: Edit this section to include variables as needed

	#d;
	drop deviceid 
		 subscriberid 
		 simid 
		 devicephonenum 
		 username
		 ;
	#d cr
	
**# destring numeric variables
*------------------------------------------------------------------------------*

	* NB: Edit this section to include variables as needed

	#d;
	destring ${duration}
			 ${bcer}		 
			 , 
			 replace
		 ;
	#d cr
	
**# check key variable
	* check that key variable contains no missing values
	* check that key variable has no duplicates
*------------------------------------------------------------------------------*
	
	qui {
		count if missing($key)
		if `r(N)' > 0 {
			disp as err "KEY variable should never be missing. Variable $key has `r(N)' missing values"
			exit 459
		}
		else {

			cap isid $key
			if _rc == 459 {
				preserve
				keep $key
				duplicates tag $key, gen (_dup)
				gen row = _n
				sort $key row
				disp as err "variable $key does not uniquely identify the observations"
				noi list row $key if _dup, abbreviate(32) noobs sepby($key)
				exit 459
			}
		}
	}
	
**# Generate Short-Key variable
	* Generate short key variable. ie. last 12 chars of the SurveyCTO key
	* check that short key variable has no duplicates
*------------------------------------------------------------------------------*
	qui {
		gen skey = substr(${key}, -12, .)
		count if missing(skey)
		if `r(N)' > 0 {
			disp as err "skey variable should never be missing. Variable skey has `r(N)' missing values"
			exit 459
		}
		else {

			cap isid skey
			if _rc == 459 {
				preserve
				keep skey
				duplicates tag skey, gen (_dup)
				gen row = _n
				sort skey row
				disp as err "variable skey does not uniquely identify the observations"
				noi list row skey if _dup, abbreviate(32) noobs sepby(skey)
				exit 459
			}
		}
	}
	
**# check date variables
	* check that surveycto auto generated date variables have no missing values
	* check that surveycto auto generated date variables show values before 
		* Jan 1, 2016
*------------------------------------------------------------------------------*
	
	* NB: Edit this section to include other date & datetime variables as needed
	
	qui {
		foreach var of varlist starttime endtime submissiondate {
			count if missing(`var')
			if `r(N)' > 0 {
				disp as err "Variable `var' has `r(N)' missing values"
				exit 459
			}
			else {
				cap assert year(dofc(`var')) >= 2016
				if _rc == 9 {
					preserve
					keep $key `var'
					gen row = _n
					disp as err "variable `var' has dates before 2016. Check that date variable are properly imported"
					noi list row $key `var' if year(dofc(`var')) < 2016, abbreviate(32) noobs sepby($key)
					exit 459
				}
			}
		}
	}
	

**# generate datevars from surveycto default datetime vars
*------------------------------------------------------------------------------*

	gen startdate 	= dofc(starttime)
	gen enddate		= dofc(endtime)
	gen subdate 	= dofc(submissiondate)
	
	format %td startdate enddate subdate
	
**# Drop observations with date before jan 2026
*------------------------------------------------------------------------------*

	* NB: Edit this section to change the date as needed

	drop if startdate <= date("01jan2016", "DMY")
	
**# save prepped back check data
*------------------------------------------------------------------------------*

	save "$preppedbc", replace
	
**# Generate Master Data for Back Check
*------------------------------------------------------------------------------*
	
	* Import checked survey data
	use "$checkedsurvey", clear
	
	* keep only observations selected for back checks
	keep if bc_sel_yn == 1
	
	* keep relevant variables for Master Data
	
	#d;
	keep	 ${key}
			 ${id}
			 a_district_id
			 a_district
			 a_kg_id
			 a_kg
			 a_community
			 a_pl_hhh_fn
			 a_pl_hhh_gnd
			 a_pl_pgv_fn
			 a_pl_hhh_gnd
			 a_pl_ch_fn
			 a_pl_ch_gnd
			 a_pl_ch_age
		 ;
	#d cr
	
	* export master data
	
	export excel using "${masterbc}", first(var) replace