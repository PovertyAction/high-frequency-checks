*! version 1.0.0 09dec2020
*! Innovations for Poverty Action
* version 1.0 Ishmail Azindoo Baako & Rosemarie Sandino

/*
This update to bcstats includes work previously done by Chris boyer and the TI network 
at Innovations for Poverty Action. 

bcstats was originally programmed by:
Matt White (Innovations for Poverty Action)			
*/

program ipabcstats, rclass
    
    #d;
    syntax, 																			
    	Surveydata(str) Bcdata(str)
    	id(namelist) 
    	ENUMerator(name) [ENUMTeam(name)] 
    	BACKchecker(name) [BCTeam(name)]
		[t1vars(namelist) t2vars(namelist) t3vars(namelist)] 
	   	[okrange(str) NODIFFNum(numlist) NODIFFStr(string asis)]
	   	[ttest(namelist) signrank(namelist) prtest(namelist) RELiability(namelist) Level(real -1)] 
	   	[showid(str)] 
	   	FILEname(str) [replace]
	   	[KEEPSUrvey(namelist) keepbc(namelist) full] 
	   	[EXCLUDENum(numlist) EXCLUDEStr(str asis) EXCLUDEMISSing LOwer UPper NOSymbol TRim NOLabel]
	   	surveydate(name) bcdate(name)
    ;
	#d cr	

		version 14.2

		* set graphics
		set graphics on

		* save data in memory
		tempfile _originaldata
		qui save "`_originaldata'", emptyok
		
		* check syntax
		* check that at least one variable is specified in t1, t2 or t3
		if "`t1vars'`t2vars'`t3vars'" == "" {
			disp as err "must specify, at minimum, one of options t1vars(), t2vars() or t3vars()"
			ex 198
		}
		
		* check level		
		if `level' ~= -1 & "`ttest'`prtest'" == "" {
			di as err "option level must be specified with option ttest or prtest"
			ex 198
		}
		if `level' == -1 loc level = c(level)
		else {
			if !inrange(`level', 10, 99.99) {
				di as err "level `level' not allowed; level() must be between 10 and 99.99 inclusive"
				ex 198
			}
		}

		* ensure output file is a .xlsx
		loc ext = substr("`filename'", -(strpos(reverse("`filename'"), ".")), .)
		
		if "`ext'" == ".xls" | "`ext'" == ".xlsx" | "`ext'" == "" {

			if "`ext'" == ".xls" {

				noi dis "File must be exported in .xlsx format. Adjusting file extension to .xlsx."
				loc fileroot = substr("`filename'", 1, (strpos("`filename'", ".")) - 1)
				loc filename = "`fileroot'.xlsx"
			}
			if "`ext'" == "" {
				loc filename = "`filename'.xlsx"
			}
		}
		
		else {
			di as err "file type `ext' not allowed. File must be in .xlsx format"
			ex 609 
		}

		* set showid to default of 30% if not specified
		if "`showid'" == "" loc showid "30%"

		* check that specified show id is not greater than 100% if specified in %
		if regexm("`showid'", "%") {
			loc showid = real(subinstr("`showid'", "%", "", .))/100
			loc percent 1
			if `showid' > 1 {
				dis as err "opt showid (`=`showid'*100'%) cannot be higher than 100%. Use a lower percentage or use an absolute number."
				ex 198
			}
		}

		* check that showid coun is not greater than number of variables specified
		else if `showid' > `:word count `t1vars' `t2vars' `t3vars'' {
			dis as err "option showid (`showid') is higher than the highest possible number of comparisons (`: word count `t1vars' `t2vars' `t3vars'')." 
			dis as err "Use a lower number or use a percentage (add '%')."
			ex 198
		}
		
		* check if file exists and replace is specified
		if "`replace'" == "" {
			cap confirm file "`filename'"
			if !_rc {
				dis as err "file `filename' already exists. Specify new filename or use -replace- option."
				ex 602
			}
		}
	
		* check that values in nodiffnum & excludenum are mutually exclusive
		if "`nodiffnum'" ~= "" & "`excludenum'" ~= "" {
			loc nv_all: list nodiffnum | excludenum
			if wordcount(`"`nodiffnum' `excludenum'"') > wordcount("`nv_all'") {
				loc nv_both: list nodiffnum & excludenum
				di as err `"value(s) "`nv_both'" not allowed in both nodiffnum() and excludenum()"'
				ex 198
			}
		}

		loc nodiffnum_list = subinstr(trim(itrim("`nodiffnum'")), " ", ",", .)
		
		* check that values in nodiffstr & excludestr are mutually exclusive
		if `"`nodiffstr'"' ~= "" & `"`excludestr'"' ~= "" {
			loc nd_rest `"`nodiffstr'"'
			loc c = 1
			while `"`nd_rest'"' ~= "" {
				gettoken nd_val nd_rest: nd_rest
				loc ex_rest `"`excludestr'"'
				while `"`ex_rest'"' ~= "" {
					gettoken ex_val ex_rest: ex_rest
					if "`nd_val'" == "`ex_val'" {
						di as err `"value(s) "`ex_val'" not allowed in both nodiffstr() and excludestr()"'
						ex 198
					}
				}

				loc ++c
				if `c' > 6 {
					disp as err "expression too long. You can only specify a maximum of 6 strings with option nodiffstr()"
					ex 130
				}

				loc nodiffstr_list = cond(`c' == 1, "`nd_val'", "`nodiffstr_list'" + ", " + "`nd_val'")
			}
		}
		
		* temp datasets and vars
		tempfile _sdata _bdata _mdata _diffs _cdata _enumdata _enumteamdata _bcerdata _bcerteamdata _checks _bconly _bcavgdata _bcteamavgdata _varstats

		qui {
			* import only relevant variables in survey dataset
			use `id' `t1vars' `t2vars' `t3vars' `enumerator' `enumteam'  ///
				`ttest' `signrank' `prtest' `reliability' `keepsurvey' `surveydate' ///
				using "`surveydata'", clear 


			* get unabbrev list of id
			unab id: `id'

			* check that datsets is unique on id
			isid `id'
			if _rc == 459 {
				disp as err `"variable(s) "`id'" does not uniquely identify the observations in survey data"'
				ex 459
			} 


			* set warning if ID is long
			cap confirm string var `id' 
			if _rc != 0 {
				summ `id'
				if abs(floor(log10(`r(max)'))) + 1 > 20 {
					disp as err "Warning: cannot reversibly convert `id' to string without loss of precision. Consider using a different ID or convert yourself."
					disp as err "Columns widths may not automatically adjust for this variable."
				}
				else if abs(floor(log10(`r(max)'))) + 1 > 8 {
					disp as err "Warning: using large numeric IDs may result in loss of precision. Consider converting to string!"
					disp as err "Columns widths may not automatically adjust for this variable."
				}
			}

			* check that enum and enumteam are numeric
			cap confirm numeric var `enumerator'
			if _rc == 7 {
				disp as err `"Enumerator variable `enumerator' in enumerator() must be a numeric variable."'
				ex 198
			}

			cap confirm numeric var `enumteam'
			if _rc == 7 {
				nois di as error `"Enumerator team variable `enumteam' in enumteam() must be a numeric variable."'
				nois di as error `"enumteam option will not be included in output."'
				loc enumteam ""
			}

			* check that no variable is prefixed with _bc
			cap ds _bc*
			if !_rc {
				disp as err "variable `:word 1 of `r(varlist)'' has illegal prefix _bc in survey data"
				ex 198
			}

			* check survey and bbdates
			foreach opt in surveydate bcdate {
				cap confirm numeric var `opt'
				if _rc == 7 {
					di as err "Variable `opt' in option `opt'() must be a date formatted variable"
					ex 198
				}
			}

			* change string variables if applicable
			if "`t1vars'" ~= "" unab t1vars: `t1vars'
			if "`t2vars'" ~= "" unab t2vars: `t2vars'
			if "`t3vars'" ~= "" unab t3vars: `t3vars'
			unab tvars: `t1vars' `t2vars' `t3vars'
			
			change_str `tvars', `nosymbol' `lower' `upper' `trim'
			
			* check that the same vars listed in keepsurvey are not listed in id, enumteam and enumerator 
			if "`keepsurvey'" ~= "" {
				unab keepsurvey: `keepsurvey'
				foreach var of varlist `keepsurvey' {
					if `:list var in id' {
						disp as err "variable `var' not allowed in both id() and keepsurvey() options"
						ex 198
					}
					if `:list var in enumerator' {
						disp as err "variable `var' not allowed in both enumerator() and keepsurvey() options"
						ex 198
					}
					if `:list var in enumteam' & "`enumteam'" ~= "" {
						disp as err "variable `var' not allowed in both enumteam() and keepsurvey() options"
						ex 198
					}
				}
			}
			
			* parse okrange
			if "`okrange'" ~= "" {
				
				* count the number combinations
				loc comb_cnt = length("`okrange'") -  length(subinstr("`okrange'", "]", "", .))
				loc showokrange = cond("`okrange'" ~= "", "okrange", "")
				loc okrange = subinstr("`okrange'", " ", "", .) 
				while length(subinstr("`okrange'", " ", "", .)) > 0 {
					loc okrcomb = substr("`okrange'", 1, strpos("`okrange'", "]"))
					gettoken okrvar okrcomb: okrcomb, parse([)
					
					* Check that combo has "[", "," and "]" in specified order
					loc okrcomb = subinstr("`okrcomb'", " ", "", .)

					cap assert (strpos("`okrcomb'", "[") > 0) & (strpos("`okrcomb'", ",") > strpos("`okrcomb'", "[")) & (strpos("`okrcomb'", "]") > strpos("`okrcomb'", ","))
					if _rc {
						di as err `"option okrange() incorrectly specified: range "`okrcomb'" not allowed"'
						ex 198
					}
					* check that range was specified
					else if strpos("`okrvar'", ",") > 0 {
						di as err `"option okrange() incorrectly specified; variable list "`okrvar'" not allowed"'
						ex 198
					}
					
					* gen okrmin and okrange
					loc okrmin = substr("`okrcomb'", strpos("`okrcomb'", "[") + 1, strpos("`okrcomb'", ",") - strpos("`okrcomb'", "[") - 1)
					loc okrmax = substr("`okrcomb'", strpos("`okrcomb'", ",") + 1, strpos("`okrcomb'", "]") - strpos("`okrcomb'", ",") - 1)
					
					* check that range specified meets requirement.
					* ie. minumum must be prefixed with "-" and at least minimum or max must be specified
					if "`okrmin'" == "" & "`okrmax'" == "" {
						di as err `"option okrange() incorrectly specified: range "`okrcomb'" not allowed"'
						ex 198
					}
					else if ("`okrmin'" ~= "" & !regexm("`okrmin'", "\-")) | ("`okrmax'" ~= "" & regexm("`okrmax'", "\-")) {
						di as err `"option okrange() incorrectly specified: range "`okrcomb'" not allowed"'
						ex 198
					}

					* substr with 0 if min or max is not specified. Expand to match number of vars if wildcard was used
					unab okrvar: `okrvar'
					loc okc = wordcount("`okrvar'")
					
					loc okrmin = cond("`okrmin'" == "", "0 " * `okc', "`okrmin' " * `okc')
					loc okrmax = cond("`okrmax'" == "", "0 " * `okc', "`okrmax' " * `okc')
					
					* aggregate okrvar, okrmin and okrmax
					loc okrvars = trim(itrim("`okrvars' `okrvar'")) 
					loc okrmins = trim(itrim("`okrmins' `okrmin'"))
					loc okrmaxs = trim(itrim("`okrmaxs' `okrmax'"))
					
					loc okrange = subinstr("`okrange'", "`okrvar'`okrcomb'", "", 1)
					loc okrange = subinstr("`okrange'", ",", "", 1)		
				}
			}
		
			* check that okrange vars are in survey data
			if "`okrvars'" ~= "" {
				cap unab okrvars_list: `okrvars'
				if _rc == 111 {
					foreach item in `okrvars' {
						cap unab check: item
						if _rc == 111 {
							di as err "variable `item' specified in okrange() not found in survey data"
							ex 111
						}
					}
				}
			}

			* check that okrange variables is specified as t1, t2 or t3
			* check the comparison variables
			foreach var of loc rangevars {
				if !`:list var in tvars' {
					di as err "option okrange() incorrectly specified; `var' not type 1, type 2, or type 3 variable"
					ex 198
				}
			}

			* check that stability and reliability test vars are t2 or t3 vars
			* stability checks
			
			if "`ttest'`prtest'`signrank'`reliability'" ~= "" {
				if "`t2vars'`t3vars'" ~= "" {
					unab t2t3vars: `t2vars' `t3vars'
					foreach opt in ttest prtest signrank reliability {
						if "``opt''" ~= "" {
							unab `opt'vars: ``opt''
							foreach var of varlist ``opt'vars' {
								if !`:list var in t2t3vars' {
									di as err "variable `var' in option `opt' must be specified as t2vars() or t2vars() variables"
									ex 198
								}

								* check that variable is numeric
								cap confirm numeric var `var'
								if _rc == 7 {
									di as err "variable `var' in option `opt' must be a numeric variable"
									ex 7
								}								
							}
						}
					}
				}
				else {
					foreach opt in ttest prtest signrank reliability { 
						di as err "option `opt' must be specified with option t2vars() or t3vars() variables"
						ex 198
					}
				}

				* unab check and test vars
				if "`ttest'" ~= "" unab ttest: `ttest'
				if "`prtest'" ~= "" unab prtest: `prtest'
				if "`signrank'" ~= "" unab signrank: `signrank'
				unab checkvars: `ttest' `prtest' `signrank' `reliability'
				loc checkvars: list uniq checkvars

				* check that vars specified in ttest, prtest and signrank are mutualy exclusive
				if wordcount("`ttest' `prtest' `signrank'") > wordcount("`checkvars'") {
					
					loc ttest_prtest: list ttest & prtest
					if wordcount("`ttest_prtest'") > 0 {
						di as err `"variable(s) "`ttest_prtest'" cannot be specified in both ttest and prtest"'
						ex 198
					}

					loc ttest_signrank: list ttest & signrank
					if wordcount("`ttest_signrank'") > 0 {
						di as err `"variable(s) "`ttest_signrank'" cannot be specified in both ttest and signrank"'
						ex 198
					}

					loc prtest_signrank: list prtest & signrank
					if wordcount("`prtest_signrank'") > 0 {
						di as err `"variable(s) "`prtest_signrank'" cannot be specified in both prtest and signrank"'
						ex 198
					}
				}

			}
			
			* unab survey list
			if "`keepsurvey'" 	~= "" unab keepsurvey   :	`keepsurvey'

			save "`_sdata'"

			* create and save data for enumerators
			keep `enumerator'
			bys `enumerator': gen surveys = _N
			bys `enumerator': keep if _n == 1

			save "`_enumdata'"

			* create enumerator team statistics
			if "`enumteam'" ~= "" {
				use "`_sdata'", clear
				keep `enumteam'
				bys `enumteam': gen surveys = _N 
				bys `enumteam': keep if _n == 1
				save "`_enumteamdata'"
			}
			
			
			* import only relevant variables in bcdata
			use `id' `t1vars' `t2vars' `t3vars' `backchecker' `bcteam'  ///
				`ttest' `signrank' `prtest' `reliability' `keepbc' `bcdate'	 	///
				using "`bcdata'", clear

			* check that datsets is unique on id
			isid `id'
			if _rc == 459 {
				disp as err `"variable(s) "`id'" does not uniquely identify the observations in backcheck data"'
				exit 459
			}

			* check that bc and bcteam are numeric
			cap confirm numeric var `backchecker'

			if _rc != 0 {
				disp as err `"Backchecker variable `backchecker' in backchecker() must be a numeric variable."'
				ex 108
			}


			if "`bcteam'" ~= "" {
				cap confirm numeric var `bcteam'

				if _rc != 0 {
					disp as err `"Backchecker team variable `bcteam' in bcteam() must be a numeric variable."'
					disp as err `"enumteam option will not be included in output."'
					loc bcteam ""
				}
			}

			* change str
			change_str `tvars', `nosymbol' `lower' `upper' `trim'

			* expand okrange variables in bc data
			if "`okrvars'" ~= "" {
				cap unab okrvars_list: `okrvars'
				if _rc == 111 {
					foreach item in `okrvars' {
						cap unab check: item
						if _rc == 111 {
							disp as err "variable `item' specified in okrange() not found in backcheck data"
							ex 111
						}
					}
				}
			}
			
			* check that the same vars listed in keepbc are not listed in id, bcteam and backchecker 
			if "`keepbc'" ~= "" {
				unab keepbc: `keepbc'
				foreach var of varlist `keepbc' {
					if `:list var in id' {
						disp as err "variable `var' not allowed in both id() and keepbc() options"
						ex 198
					}
					if `:list var in backchecker' {
						disp as err "variable `var' not allowed in both backchecker() and keepbc() options"
						ex 198
					}
					if `:list var in bcteam' & "`bcteam'" ~= "" {
						disp as err "variable `var' not allowed in both bcteam() and keepbc() options"
						ex 198
					}
				}
			}

			* add _bc prefix to backcheck dataset
			foreach var of varlist `t1vars' `t2vars' `t3vars' `ttest' `signrank' `prtest' `reliability' `keepbc' `bcdate' {
				* check that variables is not prefixed by _bc
				if regexm("`var'", "^(_bc)") {
					disp as error "variable `var' has illegal prefix _bc in backcheck data"
					ex 198
				}
				
				* check that variale length is not greater than 29
				else if `=length("`var'")' > 29 {
					disp as err `"variable `var' is too long. Rename variable"'
					ex 198
				}

				* prefix the backcheck var with _bc
				else {
					cap confirm var `var'
					if !_rc {
						ren `var' _bc`var'
					}

					if `:list var in keepbc' {
						loc bc_keepbc = trim(itrim("`bc_keepbc' _bc`var'"))
					}
				}
			}

			* add prefix to bcdate local
			if "`bcdate'" ~= "" loc bcdate _bc`bcdate'

			save "`_bdata'" 

			* create and save data for backcheckers
			keep `backchecker'
			bys `backchecker': gen backchecks = _N
			bys `backchecker': keep if _n == 1

			save "`_bcerdata'"

			* creare enumerator team statistics
			if "`bcteam'" ~= "" {
				use "`_bdata'", clear
				keep `bcteam'
				bys `bcteam': gen backchecks = _N 
				bys `bcteam': keep if _n == 1
			}
			
			* merge datasets
			use "`_sdata'", clear
			merge 1:1 `id' using "`_bdata'", gen (_mergebc)
			count if _mergebc == 1
			loc survey_only `r(N)'
			count if _mergebc == 2
			loc bc_only `r(N)'
			loc _surveyed `=_N'

			keep if inlist(_mergebc, 2, 3)
			
			loc _backchecked `=_N'
			return scalar bc = `_backchecked'
			return scalar survey = `_surveyed'
			loc pct_bc : piece 1 4 of  "`=(`_backchecked' / `_surveyed')*100'"
			unab admin:	`id' `enumerator' `enumteam' `backchecker' `bcteam' `surveydate' `bcdate'
			save "`_mdata'", replace

			keep if _mergebc == 2
			save "`_bconly'", emptyok

			use "`_mdata'", clear
			keep if _mergebc == 3
			
			* convert dates to %td format
			* check that date is in %td format, else convert
			foreach var of varlist `surveydate' `bcdate' {
				if "`:format `var''" ~= "%td" {
					gen _td`var' = dofc(`var') 
					format %td _td`var'
					drop `var'
					ren _td`var' `var'
				}
			}
			
			* save merged dataset
			save "`_mdata'", replace 
			
			* keep data of number of survey back checked by enumerator and enumteam
			keep `enumerator'
			bys `enumerator': gen backchecks = _N
			bys `enumerator': keep if _n == 1
			merge 1:1 `enumerator' using "`_enumdata'", nogen
			order `enumerator' surveys backchecks
			save "`_enumdata'", replace

			if "`enumteam'" ~= "" {
				use "`_mdata'", clear
				keep `enumteam'
				bys `enumteam': gen backchecks = _N
				bys `enumteam': keep if _n == 1
				merge 1:1 `enumteam' using "`_enumteamdata'", nogen
				order `enumteam' surveys backchecks
				save "`_enumteamdata'", replace
			}
			
			* calculate average days between surveys and back checks bcers
			use "`_mdata'", clear
			keep `backchecker' `surveydate' `bcdate'
			gen days = `bcdate' - `surveydate'
			order `backchecker' days
			collapse (mean) days, by (`backchecker')
			lab var days "average days"
			save "`_bcavgdata'"
			
			* calculate average days between surveys and back checks for bcer teams
			if "`bcteam'" ~= "" {
				use "`_mdata'", clear
				keep `bcteam' `surveydate' `bcdate'
				gen days = `bcdate' - `surveydate'
				order `bcteam' days
				collapse (mean) days, by (`bcteam')
				lab var days "average days"
				save "`_bcteamavgdata'"
			}
			
			* foreach variable compare and save comparison in long format
			clear
			save "`_diffs'", emptyok
			loc i 1
			foreach var in `tvars' {
				use "`_mdata'", clear

				keep `admin' `keepsurvey' `bc_keepbc' `var' _bc`var' `surveydate' `bcdate'
				
				* generate variable to mark type
				gen _vtype = cond(`:list var in t1vars', "type 1", cond(`:list var in t2vars', "type 2", "type 3"))
				
				* Mark variables that need to be compared
				if "`excludemissing'" ~= "" gen _compared = !missing(`var') & !missing(_bc`var') 
				else gen _compared = 1
				
				* apply excludenum: change to "not compared" if values is included in excludenum
				cap confirm numeric var `var' 
				if !_rc {
					if "`excludenum'" ~= "" {
						loc exn_cnt = wordcount("`excludenum'")
						forval x = 1/`exn_cnt' {
							loc exn_val = word("`excludenum'", `x')
							replace _compared = 0 if _bc`var' == `exn_val'
						}
					}
				}

				* apply excludestr: change to "not compared" if values is included in excludestr
				else {
					if `"`excludestr'"' ~= "" {
						local rest `"`excludestr'"'
						while `"`rest'"' ~= "" {
							gettoken exs_val rest: rest
							replace _compared = 0 if _bc`var' == "`exs_val'"
						} 
					}
				}
				
				* generate variable to mark if values are different
				gen _vdiff = `var' ~= _bc`var' if _compared == 1
				
				* For numeric vars: 
				* Check that the variable has an okrange
				* Check that there is at least one difference. 
				* Apply okrange.
				* apply nodiffnum
				
				cap confirm numeric var `var'
				if !_rc {
					* check that the variable has an okrange
					if `:list var in okrvars_list' {
						* check for range combination of var
						forval j = 1/`=wordcount("`okrvars'")' {
							loc okr_item = word("`okrvars'", `j') 
							cap unab okr_item_list: `okr_item'
							
							if !_rc {

								loc min = word("`okrmins'", `j') 
								loc max = word("`okrmaxs'", `j') 
								
								* apply minimum and max okranges. 
								* if relative, apply percentage
								if regexm("`min'", "%$") {
									loc perc = subinstr("`min'", "%", "", .)
									loc perc = abs(float(`perc')/100)
									gen _okmin = cond(`perc' == 0, `var', `var' - (`perc'*`var'))

								}
								else gen _okmin = cond(`min' == 0, `var', `var' + `min')
								
								if regexm("`max'", "%$") {
									loc perc = subinstr("`max'", "%", "", .)
									loc perc = abs(float(`perc')/100)
									gen _okmax = cond(`perc' == 0, `var', `var' + (`perc'*`var'))
								}
								else gen _okmax = cond(`max' == 0, `var', `var' + `max')

								* replace comparison
								replace _vdiff = 0 if _bc`var' >= float(_okmin) & _bc`var' <= float(_okmax) & !missing(_bc`var')
								
								* generate variable to show okrange message
								gen _okrange = "okrange of [`min', `max'] is [" + string(_okmin) + ", " + string(_okmax) + "]" if _compared

								continue, break
							}
						}

					}
					
					* apply nodiff
					if "`nodiffnum'" ~= "" replace _vdiff = 0 if inlist(_bc`var', `nodiffnum_list')

				}
				else {
					* apply nodiff for string variables
					if `"`nodiffstr'"' ~= "" {
						local rest "`nodiffstr_list'"
						while `"`rest'"' ~= "" {
							gettoken nds_val rest: rest, parse(,)
							replace _vdiff = 0 if _bc`var' == "`nds_val'"
						}
					}
				}
				
				* generate variable to hold variable name
				gen _vvar = "`var'"

				* generate variable to hold variable label
				gen _vvlab = "`:var label `var''"

				* generate vars to hold survey and bc values
				cap confirm string var `var'
				if !_rc {
					gen _survey    = `var'
					gen _backcheck = _bc`var' 
				}
				else {
					* use display format
					tostring `var', gen (_survey) usedisplayformat force
					cap decode `var'	, gen (_surveylab)
					if _rc == 182 {
						gen _surveylab = ""
					}

					tostring _bc`var', gen (_backcheck) usedisplayformat force
					cap decode _bc`var'	, gen (_backchecklab)
					if _rc == 182 {
						gen _backchecklab = ""
						replace _surveylab = ""
					}
				}
				
				gen _seq 	= `i'
				loc ++i
				gen _seqid 	= _n 
				
				cap confirm var _okrange, exact
				if !_rc {
					keep `admin' `keepsurvey' `bc_keepbc' _v* _survey* _backcheck* _okrange _seq* _compared `surveydate' `bcdate'
				}
				else keep `admin' `keepsurvey' `bc_keepbc' _v* _survey* _backcheck* _seq* _compared `surveydate' `bcdate'
				
				append using "`_diffs'"
				save "`_diffs'", replace

			}
			
			* rename variables in comparison data
			ren (_vtype _vvar _vvlab _survey _backcheck) ///
				(type variable label survey backcheck)
			
			cap ren (_surveylab _backchecklab) ///
					(surveylabel backchecklabel)
			
			cap ren _okrange okrange
			
			* create days difference variable
			gen _surveyday = `surveydate' 
			gen _bcday 	   = `bcdate'
			
			format _surveyday _bcday %td
			gen days = _bcday - _surveyday
			
			* add average difference between survey and backcheck
			bysort `id' : gen first = _n
			sum days if first == 1
			loc days_diff : piece 1 4 of  "`r(mean)'"
			return scalar avd = `days_diff'

			* export comparison/differences
			gen result = cond(_vdiff == ., "not compared", cond(!_vdiff, "not different", "different"))

			cap gen surveylabel = ""
			cap gen backchecklabel = ""
			cap gen okrange = ""

			foreach name of varlist survey surveylabel backcheck backchecklabel okrange `id' `enumerator' `enumteam' `backchecker' `bcteam' `keepsurvey' {
				lab var `name' "`name'"
			}
			
			order `id' `enumerator' `enumteam' `backchecker' `bcteam' variable label type survey surveylabel ///
			 backcheck backchecklabel result okrange `keepsurvey' `bc_keepbc' `surveydate' `bcdate' days ///
			 _surveyday _vdiff
			
			keep `id' `enumerator' `enumteam' `backchecker' `bcteam' variable label type survey surveylabel ///
			backcheck backchecklabel result okrange `keepsurvey' `bc_keepbc' `surveydate' `bcdate' days ///
			_surveyday _vdiff

			save "`_cdata'"
			
			* Create summary sheet
			encode type, gen(vartype)

			* collapse to surveydate and type
			collapse (count) valcount = _vdiff (sum) _vdiff, by(vartype _surveyday)
			
			keep _surveyday vartype _vdiff valcount 

			* reshape to table	
			reshape wide _vdiff valcount , i(_surveyday) j(vartype)


			*create daily, weekly, or monthly graph
			sum _surveyday
			loc mindate = `r(min)'
			loc maxdate = `r(max)'
			loc count = `r(max)' - `r(min)'

			forval i = 1/3 {
				cap confirm var _vdiff`i'
				if !_rc {
					gen error_rate`i' = round((_vdiff`i'/valcount`i') * 100, 0.01), after(_vdiff`i')
					lab var error_rate`i' "Type `i'"
				}
			}

			tempname rates_time
			mkmat _surveyday _vdiff* valcount*, matrix(`rates_time')
			return matrix rates_time = `rates_time'
			forval i = 1/3 {
				cap drop error_rate`i'
			}

			if `count' <= 30 {
				gen days = _n
				loc unit = "days"
				loc titleunit "Daily"
			}

			else {

				if `count' > 210 {
					loc unit "months"
					loc numberofdays 30
					loc titleunit "Monthly"
				}

				else {
					loc unit "weeks"
					loc numberofdays 7
					loc titleunit "Weekly"
				}
				
				loc units = ceil((`maxdate' - `mindate')/`numberofdays')
				gen `unit' = .
				forval i = 1/`units' {
					replace `unit' = `i' if _surveyday >= `mindate'
					loc mindate = `mindate' + `numberofdays'

				}
	
				collapse (sum) valcount* _vdiff*, by(`unit')
			}

			forval i = 1/3 {
				cap confirm var _vdiff`i'
				if !_rc {
					gen error_rate`i' = round((_vdiff`i'/valcount`i') * 100, 0.01), after(_vdiff`i')
					lab var error_rate`i' "Type `i'"
				}
			}

			egen valcounttotal = rowtotal(valcount?)
			egen _vdifftotal = rowtotal(_vdiff?)
			gen error_rate_total = round((_vdifftotal / valcounttotal) * 100, 0.01)
			lab var error_rate_total "Total" 

			tempname rates_`unit'
			mkmat `unit' error_rate*, matrix(`rates_`unit'')
			return matrix rates_`unit' = `rates_`unit''

			graph drop _all
			graph twoway connected error_rate* `unit', title("Error Rates (`titleunit')") legend(col(4)) ///
				scheme(s1color) name(summary) ytitle("%") lwidth(thin thin thin thick) lpattern(dash dash dash solid)
			
			graph export "`c(tmpdir)'/errorrates.png", width(460) replace name(summary)
			graph close
			drop error_rate*

			reshape long _vdiff valcount, i(`unit') j(vartype)
			collapse (sum) valcount _vdiff, by(vartype)

			set obs 4
			replace vartype = 4 in 4
			lab define vartype 4 "All", add
			foreach var in valcount _vdiff {
				qui sum `var'
				replace `var' = `r(sum)' in 4
			}
			g error_rate = _vdiff / valcount

			gen varcount = ., after(vartype)
			forval i = 1/3 {
				replace varcount = `: word count `t`i'vars'' if _n == `i'
			}

			replace varcount = `: word count `tvars'' in 4

			g empty = "", after(vartype)

			lab var varcount "# variables"
			lab var valcount "# values"
			lab var _vdiff "differences"
			lab var error_rate "Error rate (%)"
			lab var vartype "Type"

			* summary page matrix
			tempname rates
			mkmat varcount valcount _vdiff error_rate, matrix(`rates')
			matrix coln `rates' = "variables" "values" "differences" "error rate" 
			matrix rown `rates' = "type 1" "type 2" "type 3" "total"
			return matrix rates = `rates'
			loc total : piece 1 4 of "`=error_rate[4]'"
			return scalar total_rate = `total'
			export excel using "`filename'", sheet("summary") `replace' first(varlabel) cell(C11)
			loc directory "`c(tmpdir)'"
			mata: add_summary_formatting("`filename'", "summary", "`c(current_date)'")
			
			return scalar bc_only = `bc_only'
			
			loc idcount `:word count `id''
			loc enumcount `:word count `enumerator' `enumteam''
			loc bcer `:word count `backchecker' `bcteam''
			loc keeps `: word count `keepsurvey''
			loc keepb `:word count `keepbc''

			* export bc only IDs
			if `bc_only' > 0 {
				use "`_bconly'", clear
				keep if _mergebc == 2
				keep `id' `backchecker' `bcteam' _bc*
				ds _bc*
				loc bcexportvars
				foreach var in `r(varlist)' {
					loc stub = substr("`var'", 4, .)
					ren `var' `stub'
					loc bcexportvars `bcexportvars' `stub'
				}
				
				loc bcdatevar = subinstr("`bcdate'", "_bc", "", .)
				* apply nolabel option
				apply_nolab `id' `backchecker' `bcteam' `bcexportvars', `nolabel' keepvarlab 
				sort `id' `backchecker' `bcteam' `bcexportvars'
				order `id' `backchecker' `bcteam' `bcdatevar'
				export excel `id' `backchecker' `bcteam' `bcdatevar' using "`filename'", sheet("backcheck only", modify) first(var) cell(B3)  `nolabel'
				mata: format_bconlyids("`filename'", "backcheck only")
			}
			
			* create showid
			use "`_cdata'", clear

		 	bysort `id' : egen _iddifferences = total(_vdiff)
		 	lab var _iddifferences "differences"
	 		bysort `id' : gen _idcount = _N
	 		lab var _idcount "# compared"
	 		bysort `id' : gen count = _n
	 		gen _iderror_rate = _iddifferences / _idcount
	 		lab var _iderror_rate "% different"	

	 		sum _idcount
	 		loc idmin = `r(min)'
	 		loc idmax = `r(max)'
			loc idcount `:word count `id''
			loc enumcount `:word count `enumerator' `enumteam''
			loc bcer `:word count `backchecker' `bcteam''
			loc keeps `: word count `keepsurvey''
			loc keepb `:word count `keepbc''

		 		if "`percent'" == "1" keep if _iderror_rate > `showid' & count == 1
		 		else keep if _iddifferences > `showid' & count == 1
		 		loc showidcount `=_N'
		 		return scalar showid = `showidcount'
		 		if `showidcount' > 0 {
		 			gsort -_iderror_rate
		 			keep `id' `enumerator' `enumteam' `backchecker' `bcteam' _iddifferences _idcount _iderror_rate
					
					* apply nolabel option
					apply_nolab `id' `enumerator' `enumteam' `backchecker' `bcteam', `nolabel' keepvarlab
				
		 			export excel `id' `enumerator' `enumteam' `backchecker' `bcteam' _iddifferences _idcount _iderror_rate ///
		 			using "`filename'", sheet("IDs") firstrow(varl) cell(B3)
		 			mata: format_showids("`filename'", "IDs")
					gen _a = "", before(`=word("`id'", 1)')
					mata: adjust_column_width("`filename'", "IDs")
		 		}
		
			if `showid' > `idmin' & `showid' < `idmax' {
				disp as err "opt showid (`showid') is higher than the number of comparisons for at least one observation (`idmin')." 
				disp as err "Use a lower number to include all observations or use a percentage (add '%'). "
			}

	 		use "`_cdata'", clear
			if "`full'" == "" keep if _vdiff == 1
			save "`_cdata'", replace

			lab var `surveydate' "`surveydate'"
			loc lab = substr("`bcdate'", 4, .)
			lab var `bcdate' "`lab'"
			
			loc exp_vars "`id' `enumerator' `enumteam' `backchecker' `bcteam' variable label type survey surveylabel backcheck backchecklabel result `showokrange' `surveydate' `bcdate' days `keepsurvey'"

			order `exp_vars' `bc_keepbc'
			export excel `exp_vars' using "`filename'", sheet("comparison") first(varl) cell(B4) `nolabel'

			if "`bc_keepbc'" ~= "" {
				
				unab exp_vars: `exp_vars' 
				loc range_cnt = wordcount("`exp_vars'")

				mata: st_local("alphavar", invtokens(numtobase26(`=`range_cnt'+2')))

				keep `bc_keepbc'
				ren _bc* *
		
				export excel using "`filename'", sheet("comparison", modify) first(var) cell(`alphavar'4)
			}

			use "`_cdata'", clear
			order `id' `enumerator' `enumteam' `backchecker' `bcteam' variable label type survey surveylabel backcheck backchecklabel result `surveydate' `bcdate' days `keepsurvey' `bc_keepbc'
			gen _a = "", before(`=word("`id'", 1)')
			unab id: `id'
			
			* apply nolabel option
			apply_nolab `enumerator' `enumteam' `backchecker' `bcteam' `bcteam' `keepsurvey' `bc_keepbc', `nolabel' keepvarlab
			

			loc okr = cond("`showokrange'" == "okrange", 1, 0)
			loc t1 = cond("`t1vars'" ~= "", 1, 0)
			loc t2 = cond("`t2vars'" ~= "", 1, 0)
			loc t3 = cond("`t3vars'" ~= "", 1, 0)
						
			order _a `id' `enumerator' `enumteam' `backchecker' `bcteam' variable label type survey surveylabel backcheck backchecklabel result `showokrange' `surveydate' `bcdate' days `keepsurvey' `bc_keepbc'
			keep _a `id' `enumerator' `enumteam' `backchecker' `bcteam' variable label type survey surveylabel backcheck backchecklabel result `showokrange' `surveydate' `bcdate' days `keepsurvey' `bc_keepbc'
			mata: format_comparison("`filename'", "comparison")
			mata: adjust_column_width("`filename'", "comparison")
			
			* create and export enumerator and bcer statistics
			create_stats using "`_diffs'", enum(`enumerator') enumdata("`_enumdata'") type(_vtype) compared(_compared) different(_vdiff) enumlabel(enumerator)  `nolabel'
			
			* sort data based on error rates
			loc esortvars ""
			forval i = 1/3 {
				cap confirm var error_rate`i'
				if !_rc {
					loc esortvars "`esortvars' -error_rate`i'"
				}
			}

			gsort `esortvars'
			
			export excel using "`filename'", sheet("enumerator stats", replace) first(varl) cell(B3) `nolabel'
			
			forval i = 3(-1)1 {
				cap confirm var error_rate`i'
				if !_rc {
					mkmat `enumerator' error_rate`i', matrix(enum`i')
					return matrix enum`i' = enum`i' 
				}
			}

			mkmat `enumerator' error_rate, matrix(enum)
			return matrix enum = enum
			
			replace backcheck_percent = round(backcheck_percent * 100, 0.01)
			mkmat `enumerator' backcheck_percent, matrix(enum_bc)
			matrix coln enum_bc = `enumerator' "bc_pct"
			return matrix enum_bc = enum_bc
			
			* apply nolabel 
			gen _a = "", before(`enumerator')
			apply_nolab `enumerator', `nolabel' keepvarlab
			mata: format_enumstats("`filename'", "enumerator stats", "`enumerator'", 0)
		
			if "`enumteam'" ~= "" {
				create_stats using "`_diffs'", enum(`enumteam') enumdata("`_enumteamdata'") type(_vtype) compared(_compared) different(_vdiff) enumlabel(enum team) `nolabel'
				* sort data based on error rates
				loc esortvars "-error_rate"
				forval i = 1/3 {
					cap confirm var error_rate`i'
					if !_rc {
						loc esortvars "`esortvars' -error_rate`i'"
					}
				}
				gsort `esortvars'
				export excel using "`filename'", sheet("enumerator team stats", replace) first(varl) cell(B3) `nolabel'
				
				forval i = 3(-1)1 {
					cap confirm var error_rate`i'
					if !_rc {
						mkmat `enumteam' error_rate`i', matrix(enumteam`i')
						return matrix enumteam`i' = enumteam`i'
					}
				}

				mkmat `enumteam' error_rate, matrix(enumteam)
				return matrix enumteam = enumteam
				
				replace backcheck_percent = round(backcheck_percent * 100, 0.01)
				mkmat `enumteam' backcheck_percent, matrix(enumteam_bc)
				return matrix enumteam_bc = enumteam_bc
				
				gen _a = "", before(`enumteam')
				apply_nolab `enumteam', `nolabel' keepvarlab
				mata: format_enumstats("`filename'", "enumerator team stats", "`enumteam'", 0)
			}
			
			create_stats using "`_diffs'", bc enum(`backchecker') enumdata("`_bcerdata'") type(_vtype) compared(_compared) different(_vdiff) enumlabel(backchecker) `nolabel'
			merge 1:1 `backchecker' using "`_bcavgdata'", nogen
			order days, after(backchecks)

			* sort data based on error rates
			loc esortvars "-error_rate"
			forval i = 1/3 {
				cap confirm var error_rate`i'
				if !_rc {
					loc esortvars "`esortvars' -error_rate`i'"
				}
			}
			gsort `esortvars'
			export excel using "`filename'", sheet("backchecker stats", replace) first(varl) cell(B3) `nolabel'

			forval i = 3(-1)1 {
				cap confirm var error_rate`i'
				if !_rc {
					mkmat `backchecker' error_rate`i', matrix(backchecker`i')
					return matrix backchecker`i' = backchecker`i' 
				}
			}

			mkmat `backchecker' error_rate, matrix(backchecker)
			return matrix backchecker = backchecker
			
			ren days average_days
			mkmat `backchecker' average_days, matrix(backchecker_avd)
			return matrix backchecker_avd = backchecker_avd
			
			gen _a = ""
			apply_nolab `backchecker', `nolabel' keepvarlab
			mata: format_enumstats("`filename'", "backchecker stats", "`backchecker'", 1)

			if "`bcteam'" ~= "" {
				create_stats using "`_diffs'", bc enum(`backchecker') enumdata("`_bcerteamdata'") type(_vtype) compared(_compared) different(_vdiff) enumlabel(bc team) `nolabel'
				merge 1:1 `bcteam' using "`_bcteamavgdata'", nogen
				order days, after(backchecks)
				* sort data based on error rates
				loc esortvars "-error_rate"
				forval i = 1/3 {
					cap confirm var error_rate`i'
					if !_rc {
						loc esortvars "`esortvars' -error_rate`i'"
					}
				}
				gsort `esortvars'
				export excel using "`filename'", sheet("backchecker team stats", replace) first(varl) cell(B3)

				forval i = 3(-1)1 {
					cap confirm var error_rate`i'
					if !_rc {
						mkmat `bcteam' error_rate`i', matrix(bcteam)
						return matrix bcteam`i' = bcteam`i'
					}
				}

				mkmat `bcteam' error_rate, matrix(bcteam)
				return matrix bcteam = bcteam
				
				ren days average_days
				mkmat `bcteam' average_days, matrix(bcteam_avd)
				return matrix bcteam_avd = bcteam_avd
				
				gen _a = ""
				apply_nolab `bcteam', `nolabel' keepvarlab
				mata: format_enumstats("`filename'", "backchecker team stats", "`bcteam'", 1)
			}


			* Create stats for variables
			cap postclose postchecks
			postfile postchecks str32(variable) str80(label) str10(type) int(diffs total) ///
				double(error_rate)	double(surveymean bcmean differences) str10(test) ///
				double(pvalue srv ratio) ///
				using "`_checks'", replace

			use "`_diffs'", clear
			keep _vvar _vvlab _vtype _compared _vdiff _survey _backcheck
			destring _survey _backcheck, force replace

			foreach var in `tvars' {
				loc type = cond(`:list var in t1vars', "type 1", cond(`:list var in t2vars', "type 2", "type 3"))
				count if _vdiff == 1 & _vvar == "`var'"
				loc diff `r(N)'
				count if _compared & _vvar == "`var'"
				loc total `r(N)'
				levelsof _vvlab if _vvar == "`var'", loc (label) clean

				if `:list var in ttest' | `:list var in prtest' | `:list var in signrank' | `:list var in reliability' {
					qui su _survey if _compared & _vvar == "`var'"
					loc surveymean = round(`r(mean)', 0.01)
					qui su _backcheck if _compared & _vvar == "`var'"
					loc bcmean = round(`r(mean)', 0.01)
					loc differences = round(`surveymean' - `bcmean', 0.01) 
				}
				
				if `:list var in reliability' {

					gen _reldiff = _survey - _backcheck if _compared & _vvar == "`var'"
					su _reldiff if _compared & _vvar == "`var'"
					loc srv = r(sd)^2 / 2
					drop _reldiff

					* Calculate the variance of the back check variable.
					* We're using the back check variable instead of the survey variable,
					* thinking that the back check data is probably more reliable.
					su _backcheck if _compared & _vvar == "`var'"
					loc variance = r(sd)^2

					loc ratio = 1 - `srv' / `variance'
				}
				else {
					loc srv   -222
					loc ratio -222
				}

				if `:list var in ttest' {
					ttest _survey == _backcheck if _compared & _vvar == "`var'", level(`level')
					loc test 			"ttest"
					loc pvalue 			`r(p)'
				}
				else if `:list var in prtest' {
					
					prtest _survey == _backcheck if _compared & _vvar == "`var'", level(`level')
					loc test 			"prtest"
					loc pvalue 			`r(p)'
				}
				else if `:list var in signrank' {

					signrank _survey = _backcheck if _compared & _vvar == "`var'"
					loc test 			"signrank"
					loc pvalue 			`r(p_2)'
				}
				else {
					loc surveymean  -222
					loc bcmean 		-222
					loc differences -222
					loc test 		""
					loc pvalue 		-222
				}

				post postchecks ("`var'") ("`label'") ("`type'") (`diff') (`total') ///
						(round((`diff'/`total'), 0.01)) (`surveymean') (`bcmean') (`differences') ("`test'") ///
						(`pvalue') (`srv') (`ratio')

			}

			postclose postchecks
			use "`_checks'", clear
			mvdecode surveymean bcmean differences pvalue srv ratio, mv(-222 = .)
			lab var surveymean 	"survey mean"
			lab var bcmean 		"backcheck mean"
			lab var test 		"test type"

			order test, before(surveymean)

			if "`ttest'`prtest'`signrank'" == "" {
				drop surveymean bcmean differences pvalue test
			}  
			if "`reliability'" == "" {
				drop srv ratio
			}

			export excel using "`filename'", sheet("variable stats") first(varl) cell(B3)
			gen _a = "", before(variable)
			loc mt = cond("`ttest'`prtest'`signrank'" ~= "", 1, 0)
			loc rlb = cond("`reliability'" ~= "", 1, 0)
			noi mata: format_varstats("`filename'", "variable stats", `mt', `rlb')
			
			* save enumerator statistics
			save "`_varstats'", replace

			* get return values for variable stats
			* error_rates for type 1, type 2, type 3 and all
			forval i = 3(-1)0 {
				if `i' == 0 use variable type error_rate using "`_varstats'", clear
				else use variable type error_rate if type == "type `i'" using "`_varstats'", clear
				drop type
				if `=_N' > 0 {
					gen _id = 1
					ren error_rate V_
					reshape wide V_, i(_id) j(variable) str
					ren V_* *
					drop _id
					mkmat _all, matrix(matname)
					if `i' == 0 return matrix var = matname, copy
					else return matrix var`i' = matname, copy
				}	
			} 
			
			* error_rate for ttest prtest signrank and reliability
			if "`ttest'`prtest'`signrank'`reliability'" ~= "" {
				foreach test in ttest prtest signrank reliability {
					foreach i of numlist 3 2 0 {
						if `i' == 0 use variable type test pvalue if test == "`test'" using "`_varstats'", clear
						else use variable type test pvalue if test == "`test'" & type == "type `i'" using "`_varstats'", clear
						if `=_N' > 0 {
							drop type test
							gen _id = 1
							ren pvalue V_
							reshape wide V_, i(_id) j(variable) str
							ren V_* *
							drop _id
							mkmat _all, matrix(matname)
							if `i' == 0 return matrix `test' matname, copy
							else return matrix `test'`i' matname, copy
						}
					}
				}
			}
		}	

	use "`_originaldata'", clear

end

* program to apply nolabel option
program define apply_nolab 
	
	syntax varlist[, NOLabel keepvarlab] 
	
	ds `varlist', has(vallab)
	if "`nolabel'" == "nolabel" & !missing("`r(varlist)'") _strip_labels `r(varlist)'
	else { 
		foreach var in `r(varlist)'	{
			decode `var', gen(_newvar)
			order _newvar, after(`var')
			drop `var'
			ren _newvar `var'
			if "`keepvarlab'" ~= "" lab var `var' "`var'"	 
		}
	}
end

* program to remove symbols, trim and change cases of string values
program define change_str
	syntax varlist [, NOSymbol trim upper lower]

	ds `varlist', has(type string)
	if `:word count `r(varlist)'' > 0 {
		foreach var of varlist `r(varlist)' {
			cap confirm string var `var' 
			if !_rc {
				* remove symbols
				if "`nosymbol'" ~= "" {
					foreach i of numlist 33/47 58/64 91/96 123/126 {
						replace `var' = subinstr(`var', char(`i'), " ", .)
					}
				}

				* change case to lower
				if "`lower'`upper'" ~= "" {
					if "`lower'" ~= "" & "`upper'" ~= "" {
						disp as err "options lower and upper are mutually exclusive"
						ex 198
					}
					else if "`lower'" ~= "" replace `var' = lower(`var')
					else replace `var' = upper(`var')
				}

				* trim string variables
				if "`trim'" ~= "" replace `var' = trim(itrim(ustrltrim(`var')))
			}
		}
	}

end

* create_stats: program to aggregate and create stats for enum and bcer
program define create_stats, rclass
	syntax using/, enum(name) type(name) enumdata(string) compared(name) different(name) enumlabel(string) [bc nolabel] 

	use `using', clear

	collapse (sum) compared = `compared' differences = `different', by (`enum' `type')
	replace `type' = trim(itrim(subinstr(`type', "type ", "", 1)))
	reshape wide compared differences, i(`enum') j(`type') str

	merge 1:1 `enum' using `enumdata', nogen keep(master match)

	if "`bc'" == "" {
		order `enum' surveys backchecks
		* generate back check percentage and backcheck error rates
		gen backcheck_percent = backchecks/surveys, after(backchecks)
		label var backcheck_percent "% backchecked"
	}
	else order `enum' backchecks

	* generate percentages for each type
	forval i = 1/3 {
		cap confirm var compared`i'
		if !_rc {
			gen error_rate`i' = differences`i'/compared`i', after(differences`i')
			label var compared`i' "# compared"
			label var differences`i' "# different"
			label var error_rate`i' "% different"

			loc type`i' 1
		}
		else loc type`i' 0
	}

	* generate aggregated values
	egen compared = rowtotal(compared*)
	label var compared "# compared"
	egen differences = rowtotal(differences*)
	label var differences "# different"
	gen error_rate = differences/compared
	label var error_rate "% different"
	label var `enum' "`enumlabel'"

	* change enumerator var to string labels if nolabel is not specified
	if "`nolabel'" ~= "" {
		decode `enum', gen (`enum'_new)
		order `enum'_new, after(`enum')
		drop `enum'
		ren `enum'_new `enum'
	}
	
	ds `enum', not
	recode `r(varlist)' (. = 0) // recode missing/no comparisons to 0

	return local type1 = `type1'
	return local type2 = `type2'
	return local type3 = `type3'

end


* format_comparison: formats comparison sheet
* format_enumstats: formats enumerator statistics sheet
* adjust_column_width: adjust column width of excel workbook using datset in memory
mata:
mata clear

void format_enumstats(string scalar filename, string scalar sheetname, string scalar enumvar, real scalar bc)
{

	class xl scalar b
	real scalar column_width, columns, ncols, nrows, i, colmaxval, current_col

	ncols = st_nvar()
	nrows = st_nobs() + 2

	b = xl()

	b.load_book(filename)
	b.set_sheet(sheetname)
	b.set_mode("open")

	b.set_top_border(3, (2, ncols), "medium")
	b.set_bottom_border(3, (2, ncols), "medium")
	b.set_bottom_border(nrows + 1, (2, ncols), "medium")
	b.set_left_border((3, nrows + 1), 2, "medium")
	b.set_right_border((3, nrows + 1), 2, "medium")
	b.set_right_border((3, nrows + 1), ncols, "medium")
	b.set_column_width(1, 1, 1)
	b.set_row_height(1, 1, 10)

	collen = colmax(strlen(st_sdata(., enumvar)))
	if (collen > 12) {
		b.set_column_width(2, 2, collen)
	}
	else {
		b.set_column_width(2, 2, 12)
	}

	b.set_column_width(3, ncols, 14)
	b.set_horizontal_align((3, nrows + 1), (3, ncols), "center")
	
	if (bc == 1) {
		current_col = 4
		b.set_number_format((4, nrows + 1), 4, "number_d2")
		b.set_border(2, (5, ncols), "medium")
	}	
	else {
		current_col = 5
		b.set_number_format((4, nrows + 1), 5, "percent_d2")
		b.set_border(2, (6, ncols), "medium")
	}

	b.set_right_border((3, nrows + 1), current_col, "medium")
	
	for (i = 1; i <= 3; i++) {
		if (st_local("t" + strofreal(i)) == "1") {
			current_col = current_col + 3
			b.set_right_border((3, nrows + 1), current_col, "medium")
			b.set_number_format((4, nrows + 1), current_col, "percent_d2")
			b.set_sheet_merge(sheetname, (2, 2), (current_col - 2, current_col))
			b.put_string(2, current_col -2, "type " + strofreal(i))
		}
	}

	b.set_right_border((3, nrows + 1), ncols, "medium")
	b.set_number_format((4, nrows + 1), ncols, "percent_d2")
	b.set_sheet_merge(sheetname, (2, 2), (ncols - 2, ncols))
	b.put_string(2, ncols - 2, "all")

	b.set_horizontal_align(2, (5, ncols), "center")
	b.set_font_bold((2, 3), (2, ncols), "on")

	b.close_book()
}

void adjust_column_width(string scalar filename, string scalar sheetname)
{

	class xl scalar b
	real scalar column_width, columns, ncols, nrows, i, colmaxval

	ncols = st_nvar()
	nrows = st_nobs() + 4

	b = xl()

	b.load_book(filename)
	b.set_sheet(sheetname)
	b.set_mode("open")

	for (i = 1;i <= ncols;i ++) {
		
		if (st_varname(i) == "days") {
			namelen = 12
		}
		
		else {
			namelen = strlen(st_varname(i))
		}
		
		if (st_varname(i) == st_local("surveydate") | st_varname(i) == st_local("bcdate") | st_varname(i) == "starttime" | st_varname(i) == "endtime" | st_varname(i) == "submissiondate" | st_varname(i) == "_bcstarttime" | st_varname(i) == "_bcendtime" | st_varname(i) == "_bcsubmissiondate") {
			namelen = 16
		} 

		
		collen = colmax(strlen(st_sdata(., i)))
		
		if (namelen > collen) {
			column_width = namelen + 3
		}
		else {
			column_width = collen + 3
		}
		
		if (column_width > 101) {
			column_width = 101
			b.set_text_wrap((1, nrows), i, "on")
		}	
		if (i==1) {
			column_width = 1
		}
		
		b.set_column_width(i, i, column_width)

	}

		b.close_book()

}

void add_summary_formatting(string scalar filename, string scalar sheetname, string scalar date) 
{

	class xl scalar b
	numeric scalar border
	string scalar graphdir

	b = xl()
	
	b.load_book(filename)
	b.set_sheet(sheetname)
	b.set_mode("open")
	b.set_sheet_gridlines(sheetname, "off")

	b.put_string(2, 3, "Back Check Analysis")
	b.put_string(4, 3, "Average Days between Survey and Backcheck: " + st_local("days_diff") ) 

	b.put_string(6, 3, "Date: ")
	b.put_string(6, 5, date)

	b.put_string(7, 3, "Backcheck Rate: ")
	b.put_string(7, 5, st_local("_backchecked") + " / " + st_local("_surveyed") + " (" + st_local("pct_bc") + "%)")

	b.put_string(8, 3, "Survey Data:")
	b.put_string(8, 5, st_local("surveydata"))

	b.put_string(9, 3, "Backcheck Data:")
	b.put_string(9, 5, st_local("bcdata"))

	b.set_font(2, 3, "Calibri", 18)
	b.set_font_bold((2, 9), 3, "on")
	b.set_font_italic((6, 9), 4, "on")
	b.set_column_width(1, 2, 2)
	b.set_column_width(9, 9, 2)
	b.set_column_width(4, 5, 5)
	b.set_column_width(5, 8, 12)


	b.set_horizontal_align((11, 15), (3, 8), "center")
	b.set_number_format((12, 15), 8, "percent_d2")

	b.set_sheet_merge(sheetname, (2, 2), (3, 8))
	b.set_sheet_merge(sheetname, (4, 4), (3, 8))


	for (i = 6; i<=15; i++) {
		b.set_sheet_merge(sheetname, (i, i), (3, 4))		
	}
	
	b.set_horizontal_align((6, 9), 3, "left")
	b.set_font_bold((11, 15), 3, "on")
	b.set_font_bold(11, (5, 8), "on")
	b.set_horizontal_align((2, 4), 3, "center")
	
	border = 16
	if (strtoreal(st_local("count")) > 1) {
		graphdir = st_local("directory") + "errorrates.png"
		b.put_picture(18, 3, graphdir)
		border = 38
	}

	b.set_bottom_border(border, (2, 9), "thin")
	b.set_left_border((2, border), 2, "thin")
	b.set_right_border((2, border), 9, "thin")
	b.set_top_border(2, (2, 9), "thin")
	
	b.close_book()
}



void format_comparison(string scalar filename, string scalar sheetname)
{

	class xl scalar b
	real scalar idpos, enumpos, bcerpos, varpos, spos, bcpos, respos, datepos, keepspos, keepbcpos, lastcol
	real matrix positions 

	b = xl()

	b.load_book(filename)
	b.set_sheet(sheetname)
	b.set_mode("open")
	
	nrows = st_nobs() + 4
	ncols = st_nvar()
	idpos = 1 + strtoreal(st_local("idcount"))
	enumpos = idpos + strtoreal(st_local("enumcount"))
	bcerpos = enumpos + strtoreal(st_local("bcer"))
	varpos = bcerpos + 3
	spos = varpos + 2
	bcpos = spos + 2
	respos = bcpos + 1
	okrpos = respos + strtoreal(st_local("okr")) 
	datepos = okrpos + 3
	keepspos = datepos + strtoreal(st_local("keeps"))
	keepbcpos = keepspos + strtoreal(st_local("keepb"))


	positions = (idpos\enumpos\bcerpos\varpos\spos\bcpos\respos\okrpos\datepos\keepspos\keepbcpos)
	
	if (nrows < 3000) {
		
		b.set_right_border((4, nrows), 1, "medium")

		for (i = 1; i<=11; i++) {
			b.set_right_border((4, nrows), positions[i], "medium")
		}
	}
	
	b.set_sheet_merge(sheetname, (2, 2), (okrpos + 1, okrpos + 3))

	if (strtoreal(st_local("keeps")) > 0) {

		b.set_sheet_merge(sheetname, (3, 3), (datepos + 1, keepspos))
		b.put_string(3, datepos + 1, "Keep in Survey")
	}
	
	if (strtoreal(st_local("keepb")) > 0) {
		b.set_sheet_merge(sheetname, (3, 3), (keepspos + 1, keepbcpos))
		b.put_string(3, keepspos + 1, "Keep in Backcheck")

	}

	if (nrows < 3000) {
		b.set_top_border((4, 5), (2, keepbcpos), "medium")
		b.set_bottom_border(nrows, (2, keepbcpos), "medium")
		

		lastcol = datepos
		if (strtoreal(st_local("keeps")) > 0) {

			lastcol = keepbcpos

		}
		b.set_border(3, (okrpos + 1, lastcol), "medium")
	}
	else {
		
		b.set_bottom_border(4, (2, ncols), "medium")
		
	}

	b.set_horizontal_align((2, 3), (okrpos + 1, keepbcpos), "center")
	b.set_font_bold((2,4), (2, keepbcpos), "on")

	b.put_string(3, okrpos + 1, "Survey")
	b.put_string(3, okrpos + 2, "Backcheck")
	b.put_string(3, okrpos + 3, "Difference")
	b.put_string(2, okrpos + 1, "Dates")

	b.set_row_height(1, 1, 10)

	b.close_book()

}



void format_showids (string scalar filename, string scalar sheetname) {
	class xl scalar b 
	real scalar nrows, nvars

	b = xl()
	nrows = st_nobs() + 3
	nvars = strtoreal(st_local("idcount")) + strtoreal(st_local("enumcount")) + strtoreal(st_local("bcer")) + 4
	b.load_book(filename)
	b.set_sheet(sheetname)
	b.set_mode("open")
	
	b.set_right_border((3, nrows), 1, "medium")
	b.set_right_border((3, nrows), nvars - 3, "medium")
	b.set_right_border((3, nrows), nvars, "medium")
	b.set_top_border((3, 4), (2, nvars), "medium")
	b.set_bottom_border(nrows, (2, nvars), "medium")
	b.set_number_format((4, nrows), nvars, "percent_d2")

	b.set_column_width(nvars - 2, nvars, 10)
	b.set_column_width(1, 1, 1)

	for(i = 1; i <= nvars - 4; i++) {
		collen = colmax(strlen(st_sdata(., i)))
		namelen = strlen(st_varname(i))
		if (namelen > collen) {
			collen = namelen
		}

		b.set_column_width(i + 1, i + 1, collen)
	}
	b.set_horizontal_align((3, nrows), (5, nvars), "center")
	b.set_row_height(1, 1, 10)

	b.close_book()

}

void format_varstats (string scalar filename, string scalar sheetname, real scalar mt, rlb) {

	class xl scalar b 
	real scalar nrows, nvars

	nrows = st_nobs() + 3
	ncols = st_nvar()

	b = xl()
	b.load_book(filename)
	b.set_sheet(sheetname)
	b.set_mode("open")

	if (mt == 1) {
		testpos = 12
		b.set_column_width(8, 8, 10)
		b.set_column_width(9, 9, 11)
		b.set_column_width(10, 10, 14)
		b.set_column_width(11, 12, 10)
		b.set_sheet_merge(sheetname, (2, 2), (8, 12))
		b.set_horizontal_align(2, (8, 12), "center")
		b.put_string(2, 8, "mean comparison test")
		b.set_number_format((3, nrows), (8, 12), "number_d2")
	}
	else {
		testpos = 7
	}

	if (rlb == 1) {
		rlbpos = testpos + 2
		b.set_column_width(testpos, rlbpos, 10)
		b.set_sheet_merge(sheetname, (2, 2), (testpos + 1, ncols))
		b.set_horizontal_align(2, (testpos + 1, ncols), "center")
		b.put_string(2, testpos + 1, "reliability test")
		b.set_number_format((3, nrows), (testpos + 1, ncols), "number_d2")
	}

	positions = (1\4\7\testpos\ncols)

	for (i = 1; i<=5; i++) {
		b.set_right_border((3, nrows), positions[i], "medium")
	}

	b.set_top_border(3, (2, ncols), "medium")
	b.set_bottom_border(3, (2, ncols), "medium")
	b.set_bottom_border(nrows, (2, ncols), "medium")

	b.set_font_bold((2, 3), (2, ncols), "on")

	b.set_row_height(1, 1, 10)
	b.set_column_width(1, 1, 1)
	
	collen = colmax(strlen(st_sdata(., 2)))
	namelen = strlen(st_varname(2))
	if (namelen > collen) {
		collen = namelen
	}
	b.set_column_width(2, 2, collen)

	collen = colmax(strlen(st_sdata(., 3)))
	namelen = strlen(st_varname(3))
	if (namelen > collen) {
		collen = namelen
	}
	b.set_column_width(3, 3, collen)

	b.set_column_width(4, 7, 10)

	b.set_number_format((3, nrows), 7, "percent_d2")
	b.set_horizontal_align((4, nrows), (5, ncols), "center")

	b.close_book()
}

void format_bconlyids (string scalar filename, string scalar sheetname) {
	class xl scalar b 
	real scalar nrows, nvars


	b = xl()
	nrows = st_nobs() + 3
	nvars = strtoreal(st_local("bcer")) + strtoreal(st_local("idcount")) + 1
	b.load_book(filename)
	b.set_sheet(sheetname)
	b.set_mode("open")

	b.set_right_border((3, nrows), 1, "medium")
	//b.set_right_border((3, nrows), nvars - 3, "medium")
	b.set_right_border((3, nrows), nvars+1, "medium")
	b.set_top_border((3, 4), (2, nvars+1), "medium")
	b.set_bottom_border(nrows, (2, nvars+1), "medium")
	
	//b.set_column_width(nvars - 2, nvars, 10)
	b.set_column_width(1, 1, 1)

	for(i = 1; i <= nvars; i++) {
		collen = colmax(strlen(st_sdata(., i)))

		if (st_varname(i) == st_local("surveydate") | st_varname(i) == st_local("bcdate") | st_varname(i) == "starttime" | st_varname(i) == "endtime" | st_varname(i) == "submissiondate") {
			namelen = 16
		} 
		else namelen = strlen(st_varname(i))

		if (namelen > collen) {
			collen = namelen
		}



		b.set_column_width(i+1, i+1, collen)
	}


	b.set_horizontal_align((3, nrows), (2, nvars+1), "center")
	b.set_row_height(1, 1, 10)
	b.set_column_width(1, 1, 1)

	b.close_book()

}



end
