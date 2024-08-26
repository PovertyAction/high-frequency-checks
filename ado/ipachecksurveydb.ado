*! version 4.1.0 08apr2024
*! Innovations for Poverty Action
* ipachecksurveydb: Outputs general survey statistics

program ipachecksurveydb, rclass
	
	version 17

	#d;
	syntax 	,
        	[by(varlist max = 2)]
        	date(varname)
        	[PERiod(string)]
        	ENUMerator(varname)
        	[CONSent(string)]
        	[DONTKnow(string)]
			[REFuse(string)]
			[OTHERspecify(varlist)]
        	[DURation(varname)]
        	FORMVersion(varname)
        	OUTFile(string)
			[SHEETREPlace SHEETMODify]
			[NOLABel]
		;	
	#d cr

	qui {
	    
		preserve

		* tempvars
		tempvar tmv_subdate tmv_consent_yn
		tempvar tmv_obs tmv_enum tmv_formversion tmv_days tmv_dur tmv_miss tmv_dk tmv_ref tmv_other

		* tempfiles
		tempfile tmf_main_data tmf_datecal
		
		* save number of obs and vars in local
		
		loc obs_count 	= c(N)
		loc vars_count 	= c(k)
		
		
		* get list of all vars
		unab allvars: _all
		
		* check missing
		egen `tmv_miss' = rowmiss(_all)
		
		* create dummies scalars for options
		loc _cons 	= "`consent'" 	~= ""
		loc _dk 	= "`dontknow'" 	~= ""
		loc _ref 	= "`refuse'" 	~= ""
		loc _other 	= "`otherspecify'" ~= ""
		loc _dur 	= "`duration'" 	~= ""
		
		* check for dk, ref. Generate dummies if not specified

		if `_dk' {
			token `"`dontknow'"', parse(,)
				
			* check numeric number
			if "`1'" ~= "" {
				cap confirm integer number `1'
				if _rc == 7 {
					cap assert regexm("`1'", "^[\.][a-z]$")
					if _rc == 9 {
						disp as err "`1' found where integer is expected in option dontknow()"
						exit 198
					}
				}
			}
			ipaanycount _all, generate(`tmv_dk') numval(`1') strval("`3'")
		}
		else gen `tmv_dk' = 0
		if `_ref' {
			token `"`refuse'"', parse(,)
			
			* check numeric number
			if "`1'" ~= "" {
				cap confirm integer number `1'
				if _rc == 7 {
					cap assert regexm("`1'", "^[\.][a-z]$")
					if _rc == 9 {
						disp as err "`1' found where integer is expected in option refuse()"
						exit 198
					}
				}
			}

			ipaanycount _all, generate(`tmv_ref') numval(`1') strval("`3'")
		}
		else gen `tmv_ref' = 0
	
		if `_other' {
			unab othervars: `otherspecify'
			loc other_count = wordcount("`otherspecify'")
			egen `tmv_other' = rownonmiss(`otherspecify'), strok
		}
		else {
			gen `tmv_other' = 0
			loc other_count 0
		}
		
		ipagettd `date'
		
		* save main dateset
		save "`tmf_main_data'"
	
		* period: period(auto | daily | weekly | monthly) 
		* check : check options in period
		if "`period'" ~= "" & !inlist("`period'", "auto", "daily", "weekly", "monthly") {
			disp as err `"option period incorrectly specified. Expecting auto, daily, weekly or monthly."'
			ex 198
		}
		else if "`period'" == "" loc period "auto"
		if "`period'" == "auto" {
		    su `date'
			loc min_date `r(min)'
			loc max_date `r(max)'
			loc days = `max_date' - `min_date'
			loc period = cond(`days' <= 40,  "daily", ///
						 cond(`days' <= 280, "weekly", ///
											 "monthly"))
		}

		* duration: check that duration is a numeric var
		if `_dur' {
		    cap confirm numeric var `duration'
		    if _rc == 7 {
			    disp as err "variable `duration' found at option duration() where numeric variable is expected"
				ex 7
			} 
			else {
				gen `tmv_dur' = `duration'
			}
		}
		else gen `tmv_dur' = 0

		* consent: consent(consent, 1) or consent(consent, 1 2 3)
		if `_cons' {	
			
			* check  : check that consent variable is numeric and values is a numlist
			token "`consent'", parse(,)
			* check variable specified
			cap unab consent_var	: `1'
			if _rc == 102 {
				disp as err `"no variables specified for consent() option"'
				ex 198
			}
			else if _rc == 111 {
				disp as err `"variable `1' specifed in consent() option not found"'
				ex 111
			}
			else {
				
				* check that consent var is numeric
				cap confirm numeric var `consent_var'
				if _rc == 7 {
					disp as err `"variable `consent_var' specifed in consent() option is not numeric"'
					ex 7
				}
			
				macro shift
				loc consent_vals = subinstr(trim(itrim("`*'")), ",", "", 1)
				if missing("`consent_vals'") {
					disp as err `"no values specified with consent() option."' ///
								`"expected format is consent(varname, varlist)."' 
					ex 198
				}
				gen `tmv_consent_yn' = 0
				foreach val of numlist `consent_vals' {
					replace `tmv_consent_yn' = 1 if `consent_var' == `val'
				}
			}
		}
		else {
			gen `tmv_consent_yn' = 0
		}
				
		*** summary sheet ***
		
		cap frames drop frm_summary
		#d;
		frames 	create 	frm_summary 
				str10  	blank1 
				str80 	description
				str32   values 
			;
		#d cr
		
		* create additional statistics
		
		count if `date' == today()
		loc today = `r(N)'												// total submissions from today
		count if week(`date') == week(today()) & 	///
			year(`date') == year(today())
		loc week = `r(N)'												// total submissions for current calendar week
		count if month(`date') == month(today()) & 	///
			year(`date') == year(today())
		loc month = `r(N)'												// total submissions for current calendar month
		su `tmv_consent_yn'
		loc consent_rate `r(mean)'										// consent rate
		mata: st_numscalar("sum", colsum(st_data(., "`tmv_miss'")))
		loc miss_rate = scalar(sum)/(`obs_count' * `vars_count')		// missing rate
		mata: st_numscalar("sum", colsum(st_data(., "`tmv_dk'")))
		loc dontknow_rate = scalar(sum)/(`obs_count' * `vars_count') 	// dontknow rate
		mata: st_numscalar("sum", colsum(st_data(., "`tmv_ref'")))
		loc refuse_rate = scalar(sum)/(`obs_count' * `vars_count')		// refuse rate
		mata: st_numscalar("sum", colsum(st_data(., "`tmv_other'")))
		loc other_rate = scalar(sum)/(`obs_count' * `other_count')		// refuse rate
		
		* get unique, non miss and all var count
		
		loc uniq_count 		0
		loc nomiss_count 	0
		loc allmiss_count 	0
		foreach var of varlist `allvars' {
						
			cap assert missing(`var')
			if !_rc {
				loc ++allmiss_count
			}
			else {
				cap assert !missing(`var')
				if !_rc {
					loc ++nomiss_count
					
					cap isid `var'
					if !_rc {
						loc ++uniq_count
					}
				}
			}
		}
		
		* duration
		su `duration', detail
		loc dur_min 	= `r(min)'
		loc dur_mean 	= `r(mean)'
		loc dur_med  	= `r(p50)'
		loc dur_max 	= `r(max)'
		
		* other details
		tab `enumerator'
		loc enum_count 		  = `r(r)'
		tab `formversion'
		loc formversion_count = `r(r)'
		su `date'
		loc firstdate 		  = string(`r(min)', "%td")
		loc lastdate  		  = string(`r(max)', "%td")
		tab `date'
		loc days_count 		  =	`r(r)'
		

		frames frm_summary {
		 
			set obs 32
			replace description = "Survey Dashboard" 				in 1 
			replace description = "`c(current_date)'" 				in 2
			replace description = "submissions" 					in 3
			replace description = "today" 							in 4
			replace values 		= "`today'" 						in 4
			replace description = "this week" 						in 5
			replace values 		= "`week'" 							in 5
			replace description = "this_month" 						in 6
			replace values 		= "`month'" 						in 6
			replace description = "all" 							in 7
			replace values 		= "`obs_count'"						in 7
			replace description = "consent" 						in 8
			replace description = "consent rate" 					in 9
			replace values 		= "`consent_rate'"					in 9
			replace description = "missingness" 					in 10
			replace description = "% of missing values" 			in 11
			replace values 		= "`miss_rate'" 					in 11
			replace description = "% of don't know value" 			in 12
			replace values 		= "`dontknow_rate'" 				in 12
			replace description = "% of refuse to answer value" 	in 13
			replace values 		= "`refuse_rate'"					in 13
			replace description = "other specify" 					in 14
			replace description = "# of other specify variables"    in 15
			replace values		= "`other_count'" 					in 15
			replace description	= "% of other specify values"		in 16
			replace values		= "`other_rate'" 					in 16
			replace description = "variables" 						in 17
			replace description = "# with only unique values" 		in 18
			replace values 		= "`uniq_count'" 					in 18
			replace description = "# with no missing values" 		in 19
			replace values 		= "`nomiss_count'" 					in 19
			replace description = "# with all missing values" 		in 20
			replace values 		= "`allmiss_count'"					in 20
			replace description = "total number" 					in 21
			replace values 		= "`vars_count'" 					in 21
			replace description = "duration" 						in 22
			replace description = "minimum" 						in 23
			replace values 		= "`dur_min'" 						in 23
			replace description = "mean" 							in 24
			replace values 		= "`dur_mean'" 						in 24
			replace description = "median" 							in 25
			replace values 		= "`dur_med'" 						in 25
			replace description = "maximum" 						in 26
			replace values 		= "`dur_max'" 						in 26
			replace description = "other details" 					in 27
			replace description = "# of enumerators" 				in 28
			replace values 		= "`enum_count'" 					in 28
			replace description = "# of form versions" 				in 29
			replace values 		= "`formversion_count'"				in 29
			replace description = "first date of survey" 			in 30
			replace values 		= "" 								in 30
			replace description = "last date of survey" 			in 31
			replace values 		= "" 								in 31
			replace description = "# of days" 						in 32	
			replace values 		= "`days_count'" 					in 32
			
			destring values, replace
			
			* export partially completed sheet. This is to hold the position of the sheet 
			if "`replace'" ~= "" cap rm "`outfile'"
			export excel using "`outfile'", replace sheet("summary")
			mata: format_sdb_summary("`outfile'", "summary", `_cons', `_dk', `_ref', `_other', `_dur', "`firstdate'", "`lastdate'")	
		}
		
		frame drop frm_summary
		
		*** Summary (by group) ***
		if "`by'" ~= "" {
		    
			save "`tmf_main_data'", replace
		    
			* generate vars to keep track of uniq number of forms, enums days in each group
			
			gen `tmv_enum' 			= 0
			gen `tmv_formversion' 	= 0
			gen `tmv_days'			= 0
			
			cap confirm string var `by'
			if !_rc {
			    levelsof `by', loc (groups)
				foreach group in `groups' {
					tab `enumerator' 						if `by' == "`group'"
					replace `tmv_enum' 			= `r(r)' 	if `by' == "`group'"
					tab `formversion' 						if `by' == "`group'"
					replace `tmv_formversion' 	= `r(r)' 	if `by' == "`group'"
					tab `date'							if `by' == "`group'"
					replace `tmv_days' 			= `r(r)' 	if `by' == "`group'"
				}
			}
			else {
			    levelsof `by', loc (groups) clean
				foreach group in `groups' {
					tab `enumerator' 						if `by' == `group'
					replace `tmv_enum' 			= `r(r)' 	if `by' == `group'
					tab `formversion' 						if `by' == `group'
					replace `tmv_formversion' 	= `r(r)' 	if `by' == `group'
					tab `date'							if `by' == `group'
					replace `tmv_days' 			= `r(r)' 	if `by' == `group'
				}
			}
			
			gen `tmv_obs' = 1
			#d;
			collapse (count) 	submissions 	= `tmv_obs'
					 (mean)  	consent_rate 	= `tmv_consent_yn'
					 (sum)   	missing_rate   	= `tmv_miss'
					 (sum)   	dontknow_rate  	= `tmv_dk'
					 (sum)	 	refuse_rate		= `tmv_ref'
					 (sum)		other_rate 		= `tmv_other'
					 (min)	 	duration_min   	= `tmv_dur'
					 (mean)	 	duration_mean   = `tmv_dur'
					 (median) 	duration_median = `tmv_dur'
					 (max)	 	duration_max   	= `tmv_dur'
					 (first) 	enumerators 	= `tmv_enum'
					 (first) 	formversion 	= `tmv_formversion'
					 (min)   	firstdate 		= `date'
					 (max)   	lastdate		= `date'
					 (first) 	days 			= `tmv_days'
					 ,
					 by(`by')
				;
			#d cr
			
			* convert missing_rate to actual rates
			replace missing_rate 	= missing_rate/(submissions * `vars_count')
			replace dontknow_rate 	= dontknow_rate/(submissions * `vars_count')
			replace refuse_rate 	= refuse_rate/(submissions * `vars_count')
			replace other_rate 		= other_rate/(submissions * `other_count')
			
			*label variables
			lab var submissions 	"# of submissions"
			lab var consent_rate 	"% of consent"
			lab var missing_rate   	"% missing"
			lab var dontknow_rate  	"% dont know"
			lab var refuse_rate		"% refuse"
			lab var other_rate		"% other"
			lab var duration_min   	"min duration"
			lab var duration_mean   "mean duration"
			lab var duration_median "median duration"
			lab var duration_max   	"max duration"
			lab var enumerators 	"# of enumerators"
			lab var formversion 	"# of form versions"
			lab var firstdate 		"first date"
			lab var lastdate		"last date"
			lab var days 			"# of days"
			
			* drop consent, dk, ref, other, duration
			if !`_cons' 	drop consent_rate
			if !`_dk' 		drop dontknow_rate
			if !`_ref' 		drop refuse_rate
			if !`_other'	drop other_rate
			if !`_dur' 		drop duration_*

			ipalabels `by', `nolabel'
			export excel using "`outfile'", first(varl) sheet("summary (grouped)")
			ipacolwidth using "`outfile'", sheet("summary (grouped)")
			iparowformat using "`outfile'", sheet("summary (grouped)") type(header)

			if `_cons' 	ipacolformat using "`outfile'", sheet("summary (grouped)") vars(consent_rate missing_rate) format("percent_d2")
			if `_dk' 	ipacolformat using "`outfile'", sheet("summary (grouped)") vars(dontknow_rate) format("percent_d2")
			if `_ref' 	ipacolformat using "`outfile'", sheet("summary (grouped)") vars(refuse_rate) format("percent_d2")
			if `_other' ipacolformat using "`outfile'", sheet("summary (grouped)") vars(other_rate) format("percent_d2")
			if `_dur'   ipacolformat using "`outfile'", sheet("summary (grouped)") vars(duration_min duration_mean duration_median duration_max) format("number_sep")
						ipacolformat using "`outfile'", sheet("summary (grouped)") vars(enumerators formversion days) format("number_sep")
						ipacolformat using "`outfile'", sheet("summary (grouped)") vars(firstdate lastdate) format("date_d_mon_yy")
					
		}
		
		*** productivity ***
		
		* generate a calendar dataset
		use "`tmf_main_data'", clear
		ipagetcal `date', clear
		
		merge 1:m `date' using "`tmf_main_data'", keepusing(`date' `by') gen(datematch)
		gen weight = cond(datematch == 3, 1, 0)
		drop datematch
		
		* save data
		save "`tmf_datecal'"
		
		if "`period'" == "daily" {
		    collapse (sum) submissions = weight, by(`date')
			gen day = _n
			order day `date' submissions
		}
		else if "`period'" == "weekly" {
		    collapse (min) startdate = `date' (max) enddate = `date' (sum) submissions = weight, by(year week)
			replace week = _n
			order 	week startdate enddate submissions
			keep 	week startdate enddate submissions
		}
		else {
		    collapse (min) startdate = `date' (max) enddate = `date' (sum) submissions = weight, by(year month)
			replace month = _n
			order 	month startdate enddate submissions
			keep 	month startdate enddate submissions
		}
		
		export excel using "`outfile'", first(var) sheet("`period' productivity")
		ipacolwidth using "`outfile'", sheet("`period' productivity")
		iparowformat using "`outfile'", sheet("`period' productivity") type(header)
		if "`period'" == "daily" {
			ipacolformat using "`outfile'", sheet("`period' productivity") vars(day submissions) format("number_sep")
			ipacolformat using "`outfile'", sheet("`period' productivity") vars(`date') format("date_d_mon_yy")
		}
		else if "`period'" == "weekly" {
			ipacolformat using "`outfile'", sheet("`period' productivity") vars(week submissions) format("number_sep")
			ipacolformat using "`outfile'", sheet("`period' productivity") vars(startdate enddate) format("date_d_mon_yy")
		}
		else {
			ipacolformat using "`outfile'", sheet("`period' productivity") vars(month submissions) format("number_sep")
			ipacolformat using "`outfile'", sheet("`period' productivity") vars(startdate enddate) format("date_d_mon_yy")
		}
		
		*** productivity by group ***
		if "`by'" ~= "" {
			use "`tmf_datecal'", clear
			
			if "`period'" == "daily" {
				collapse (sum) submissions = weight, by(`by' `date')
				ren `date' jvar
			}
			else if "`period'" == "weekly" {
				collapse (sum) submissions = weight, by(`by' year week)
				sort week
				egen jvar = group(year week)
			}
			else {
				collapse `date' (sum) submissions = weight, by(`by' year month)
				sort month
				egen jvar = group(year month)
			}
			
			ren submissions vv_
			keep vv_ `by' jvar
			reshape wide vv_, i(`by') j(jvar)
			recode vv_* (. = 0)
			
			egen submissions = rowtotal(vv_*)
			order submissions, after(`by')
			drop if submissions == 0
			
			* add a total row
			loc add = `=_N' + 1
			set obs `add'
			
			foreach var of varlist vv_* {
					
				loc vdate = substr("`var'", 4, .)
				
				if "`period'" == "daily" {
					loc lab "`:disp %td  `vdate''"
					lab var `var' "`lab'"
				}
				else if "`period'" == "weekly" 	lab var `var' "week `vdate'"
				else 							lab var `var' "month `vdate'"
				
				mata: st_numscalar("sum", colsum(st_data(., "`var'")))
				replace `var' = scalar(sum) in `add'
			}
			
			mata: st_numscalar("sum", colsum(st_data(., "submissions")))
			replace submissions = scalar(sum) in `add'
			ipalabels `by', `nolabel'
			export excel using "`outfile'", first(varl) sheet("`period' productivity (grouped)")
			ipacolwidth using "`outfile'", sheet("`period' productivity (grouped)")
			iparowformat using "`outfile'", sheet("`period' productivity (grouped)") type(header)
			ds, has(type numeric)
			ipacolformat using "`outfile'", sheet("`period' productivity (grouped)") vars(`r(varlist)') format("number_sep")
			iparowformat using "`outfile'", sheet("`period' productivity (grouped)") type(total)

		}
	}
	
end

mata:
mata clear

void format_sdb_summary(string scalar file, string scalar sheet, real scalar consent, real scalar dontknow, real scalar refuse, real scalar other, real scalar duration, string scalar firstdate, string scalar lastdate) 
{
	real scalar i
	class xl scalar b
	b = xl()
	b.load_book(file)
	b.set_sheet(sheet)
	b.set_mode("open")
	
	b.set_column_width(1, 1, 2)
	b.set_column_width(2, 2, 42)
	b.set_column_width(3, 3, 16)
	
	b.set_border((1, st_nobs()), (2, 3), "thin")
	b.set_bottom_border((1, 1), (2, 3), "medium")
		
	b.set_horizontal_align((1, st_nobs()), (3, 3), "center")
	b.set_font_bold((1, st_nobs()), (2, 2), "on")
	b.set_font_bold((2, 2), (2, 2), "off")
	b.set_font_italic((2, 2), (2, 2), "on")
	b.set_font_italic((1, st_nobs()), (3, 3), "on")
	
	b.set_sheet_merge(sheet, (1, 1), (2, 3))
	b.set_horizontal_align((1, 1), (2, 3), "center")
	b.set_sheet_merge(sheet, (2, 2), (2, 3))
	b.set_horizontal_align((2, 2), (2, 3), "center")
	b.set_sheet_merge(sheet, (3, 3), (2, 3))
	b.set_horizontal_align((3, 3), (2, 3), "center")
	b.set_fill_pattern((3, 3), (2, 3), "solid", "255 192 0")
	b.set_number_format((4, 7), (3, 3), "number_sep")


	b.set_sheet_merge(sheet, (8, 8), (2, 3))
	b.set_horizontal_align((8, 8), (2, 3), "center")
	b.set_fill_pattern((8, 8), (2, 3), "solid", "255 192 0")
	
	b.set_number_format((9, 9), (3, 3), "percent_d2")
	
	if (consent == 0) {
		b.put_string(9, 3, "-")
	}
	
	b.set_sheet_merge(sheet, (10, 10), (2, 3))
	b.set_horizontal_align((10, 10), (2, 3), "center")
	b.set_fill_pattern((10, 10), (2, 3), "solid", "255 192 0")
	
	if (dontknow == 0) {
		b.put_string(12, 3, "-")
	}
	
	if (refuse == 0) {
		b.put_string(13, 3, "-")
	}
	
	b.set_number_format((11, 13), (3, 3), "percent_d2")
	
	b.set_sheet_merge(sheet, (14, 14), (2, 3))
	b.set_horizontal_align((14, 14), (2, 3), "center")
	b.set_fill_pattern((14, 14), (2, 3), "solid", "255 192 0")
	
	if (other == 0) {
		b.put_string(15, 3, "-")
		b.put_string(16, 3, "-")
	}
	
	b.set_number_format((15, 15), (3, 3), "number_sep")
	b.set_number_format((16, 16), (3, 3), "percent_d2")
	
	b.set_sheet_merge(sheet, (17, 17), (2, 3))
	b.set_horizontal_align((17, 17), (2, 3), "center")
	b.set_fill_pattern((17, 17), (2, 3), "solid", "255 192 0")
	b.set_number_format((18, 21), (3, 3), "number_sep")
		
	b.set_sheet_merge(sheet, (22, 22), (2, 3))
	b.set_horizontal_align((22, 22), (2, 3), "center")
	b.set_fill_pattern((22, 22), (2, 3), "solid", "255 192 0")
	b.set_number_format((23, 26), (3, 3), "number_sep")
	
	if (duration == 0) {
		b.put_string(23, 3, "-")
		b.put_string(24, 3, "-")
		b.put_string(25, 3, "-")
		b.put_string(26, 3, "-")
	}

	b.set_sheet_merge(sheet, (27, 27), (2, 3))
	b.set_horizontal_align((27, 27), (2, 3), "center")
	b.set_fill_pattern((27, 27), (2, 3), "solid", "255 192 0")
	b.set_number_format((28, 29), (3, 3), "number_sep")
	b.set_number_format((32, 32), (3, 3), "number_sep")
	
	
	b.put_string(30, 3, firstdate)
	b.put_string(31, 3, lastdate)
	
	b.close_book()

}
end
