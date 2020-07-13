*! version 3.0.0 Innovations for Poverty Action 22oct2018

program ipacheckresearch, rclass
	/* This program creates oneway and twoway summaries 
	   of important research variables and exports them 
	   as a separate excel file. */
	version 13

	#d ;
	syntax using/ , VARiables(string) 
	    [by(varname)]
	    [format(string)]
	    [missing]
		[replace];
	#d cr

	if mi("`format'") {
		local format "%9.2f"
	}

	preserve
	tempfile oway tway org

	if mi("`by'") {
		* calculate one-way summaries
		table1, vars("`variables'") clear onecol format(`format') plusminus `missing'
		qui save "`oway'"
	}
	else {
		* calculate two-way summaries
		table1, vars("`variables'") by(`by') clear onecol format(`format') plusminus `missing'
		qui save "`tway'"
	}

	local sheets oneway twoway
	local i = 0

	foreach file in "`oway'" "`tway'" {
		local ++i
		local sheet : word `i' of `sheets'

		cap confirm file `file'
		if !_rc {
			if !mi("`replace'") & `i' == 1  local opt replace
			use "`file'", clear
			export excel using "`using'", sheet("`sheet'") `opt' sheetreplace
		}
	}

	restore
	
end

program define table1
	version 12
	syntax [if] [in] [fweight], ///
		[by(varname)]		/// optional grouping variable
		vars(string)		/// varname vartype [varformat], vars delimited by \
		[ONEcol]			/// only use 1 column to report categorical vars
		[Format(string)]	/// default format for contn / conts variables
		[plusminus]			/// report contn vars as mean ± sd instead of mean (sd)
		[percent]			/// report categorical vars just as % (no N)
		[MISsing]			/// don't exclude missing values
		[pdp(integer 3)]	/// max number of decimal places in p-value
		[test]				/// include column specifying which test was used
		[SAVing(string asis)]	/// optional Excel file to save output		
		[clear]				// keep the resulting table in memory
		
	marksample touse

	* table will be stored in temporary file called resultstable
	tempfile resultstable
	* order of rows in table
	local sortorder=1

	* group variable in numeric format
	tempvar groupnum
	if "`by'"=="" {
		gen byte `groupnum'=1 // 1 placeholder group
	}
	else {
		capture confirm numeric variable `by'
		if !_rc qui clonevar `groupnum'=`by'
		else qui encode `by', gen(`groupnum')
	}
	
	* determine number of groups and issue error if <2
	qui levelsof `groupnum' if `touse', local(levels)
	local groupcount: word count `levels'
	if `groupcount'<2 & "`by'"!="" {
		di in re "by() variable must have at least 2 levels"
		error 498
	}
	
	* group variable needed for some calculations so becomes placeholder if
	* not specified by user
	if "`by'"=="" local group `groupnum'

	* N
	preserve
	qui keep if `touse'
	qui drop if missing(`by')
	contract `groupnum' [`weight'`exp']
	gen factor="N"
	gen factor_sep="N" // for subsequent neat output
	qui gen n=string(_freq)
	qui drop _freq
	qui reshape wide n, i(factor) j(`groupnum')
	rename n* `groupnum'*
	gen sort1=`sortorder++'
	qui save "`resultstable'", replace
	restore

	* step through the variables
	gettoken arg rest : vars, parse("\")
	while `"`arg'"' != "" {
		if `"`arg'"' != "\" {
			local varname   : word 1 of `arg'
			local vartype   : word 2 of `arg'
			local varformat : word 3 of `arg'

			* check that input is valid
			* does variable exist?
			confirm variable `varname'
			qui count if !mi(`varname')
			
			if `r(N)' == 0 {
				dis as err "The variable `varname' has no values. This will not be included in the output file."
			}
			
			else {
			* is vartype supported?
			if !inlist("`vartype'", "contn", "conts", "cat", "cate", "bin", "bine") {
				di in re "-`varname' `vartype'- not allowed in vars() option"
				di in re "Variables must be classified as contn, conts, cat, cate, bin or bine"
				error 498
			}
			
			* obtain variable label, or just varname if variable has no label
			local varlab: variable label `varname'
			if "`varlab'"=="" local varlab `varname'
	
			* continuous, normally distributed variable
			if "`vartype'"=="contn" {
				preserve
				qui keep if `touse'
				qui drop if missing(`by')
				
				* significance test
				if `groupcount'>1 {
					qui anova `varname' `groupnum' [`weight'`exp']
					local p=1-F(e(df_m), e(df_r), e(F))
				}

				* default format is specified in the format option, 
				* or if that's blank, it's just the variable's display format
				if "`varformat'"=="" {
					if "`format'"=="" local varformat: format `varname'
					else local varformat `format'
				}
				
				* collapse to table1 format
				collapse (mean) mean=`varname' (sd) sd=`varname' ///
					[`weight'`exp'], by(`groupnum')
				if "`plusminus'"=="plusminus" {
					qui gen mean_sd=string(mean, "`varformat'") + ///
						" ± " + string(sd, "`varformat'")
				}
				else {
					qui gen mean_sd=string(mean, "`varformat'") + ///
						" (" + string(sd, "`varformat'") + ")"
				}
				if "`plusminus'"=="plusminus" gen factor="`varlab', mean ± SD"
				else gen factor="`varlab', mean (SD)"
				qui clonevar factor_sep=factor
				keep factor* `groupnum' mean_sd
				qui reshape wide mean_sd, i(factor) j(`groupnum')
				rename mean_sd* `groupnum'*
				
				* add p-value, test and sort variable, then save
				if `groupcount'>1 qui gen p=`p'
				if "`test'"=="test" & `groupcount'>1 {
					if `groupcount'==2 gen test="Two sample t test"
					else gen test="ANOVA"
				}
				gen sort1=`sortorder++'
				qui append using "`resultstable'"
				qui save "`resultstable'", replace
				restore
			}
			
			* continuous, skewed variable
			if "`vartype'"=="conts" {
				preserve
				qui keep if `touse'
				qui drop if missing(`groupnum')

				* need to expand by frequency weight since ranksum & kwallis
				* don't allow frequency weights
				if "`weight'"=="fweight" qui expand `exp'
				
				* significance tests
				if `groupcount'>1 {
					if `groupcount'==2 {
						* rank-sum for 2 groups
						qui ranksum `varname', by(`groupnum')
						local p=2*normal(-abs(r(z)))
					}
					else {
						* Kruskal-Wallis for >2 groups
						qui kwallis `varname', by(`groupnum')
						local p=chi2tail(r(df), r(chi2_adj))
					}
				}
				
				* display format
				if "`varformat'"=="" {
					if "`format'"=="" local varformat: format `varname'
					else local varformat `format'
				}

				* collapse to table1 format
				collapse (p50) p50=`varname' (p25) p25=`varname' ///
					(p75) p75=`varname', by(`groupnum')
				qui gen median_iqr=string(p50, "`varformat'") + ///
					" (" + string(p25, "`varformat'") + ///
					", " + string(p75, "`varformat'") + ")"
				gen factor="`varlab', median (IQR)"
				qui clonevar factor_sep=factor
				keep factor* `groupnum' median_iqr
				qui reshape wide median_iqr, i(factor) j(`groupnum')
				rename median_iqr* `groupnum'*

				* add p-value, test and sort variable, then save
				if `groupcount'>1 qui gen p=`p'
				if "`test'"=="test" & `groupcount'>1 {
					if `groupcount'==2 gen test="Wilcoxon rank-sum"
					else gen test="Kruskal-Wallis"
				}
				gen sort1=`sortorder++'
				qui append using "`resultstable'"
				qui save "`resultstable'", replace
				restore
			}
			
			* categorical variable
			if "`vartype'"=="cat" | "`vartype'"=="cate" {
				preserve
				qui keep if `touse'
				qui drop if missing(`groupnum')
				if "`missing'"!="missing" qui drop if missing(`varname')

				* categories should be numeric
				tempvar varnum
				capture confirm numeric variable `varname'
				if !_rc qui clonevar `varnum'=`varname'
				else qui encode `varname', gen(`varnum')
				
				* significance test
				if `groupcount'>1 {
					if "`vartype'"=="cat" {
						qui tab `varnum' `groupnum' [`weight'`exp'], chi2
						local p=r(p)
					}
					else {
						qui tab `varnum' `groupnum' [`weight'`exp'], exact
						local p=r(p_exact)
					}				
				}
				
				* collapse to table1 format
				qui contract `varnum' `groupnum' [`weight'`exp'], zero
				qui egen tot=total(_freq), by(`groupnum')
				
				* default format is 0 decimal places if <100 cases, otherwise 1 dp
				* (for categorical variables, format is for % not the frequency)
				if "`varformat'"=="" {
					sum tot, meanonly
					if r(max)<100 local varformat "%1.0f"
					else local varformat "%2.1f"
				}

				* finish restructuring to table1 format
				qui gen perc=string(100*_freq/tot, "`varformat'")
				qui replace perc="<1" if _freq!=0 & real(perc)==0
				
				if "`percent'"=="percent" qui gen n_perc=perc + "%"
				else qui gen n_perc=string(_freq) + " (" + perc + "%)"
				
				drop _freq tot perc
				qui reshape wide n_perc, i(`varnum') j(`groupnum')
				rename n_perc* `groupnum'*
				
				* add factor and level variables, unless onecol option specified
				* in which case just add factor variable (with levels included)
				if "`onecol'"=="" {
					qui gen factor="`varlab'" if _n==1
					qui gen factor_sep="`varlab'" // allows neat sepby
					qui gen level=""
					qui levelsof `varnum', local(levels)
					foreach level of local levels {
						qui replace level="`: label (`varnum') `level''" ///
							if `varnum'==`level'
					}
				}
				else {
					* add new observation to contain name of variable and
					* p-value
					qui set obs `=_N + 1'
					tempvar reorder
					qui gen `reorder'=1 in L
					sort `reorder' `varnum'
					drop `reorder'
					
					qui gen factor="`varlab'" if _n==1
					qui gen factor_sep="`varlab'" // allows neat sepby
					qui levelsof `varnum', local(levels)
					foreach level of local levels {
						qui replace factor="   `: label (`varnum') `level''" ///
							if `varnum'==`level'
					}					
				}

				* add p-value, test and sort variables, then save
				if `groupcount'>1 qui gen p=`p' if _n==1
				if "`test'"=="test" & `groupcount'>1 {
					if "`vartype'"=="cat" qui gen test="Pearson's chi-squared" if _n==1
					else qui gen test="Fisher's exact" if _n==1
				}
				gen sort1=`sortorder++'
				qui gen sort2=_n
				qui drop `varnum'
				qui append using "`resultstable'"
				qui save "`resultstable'", replace
				restore
			}
	
			* binary variable
			if "`vartype'"=="bin" | "`vartype'"=="bine" {
				preserve
				qui keep if `touse'
				qui drop if missing(`groupnum') | missing(`varname')

				* categories should be numeric 0/1	
				capture assert `varname'==0 | `varname'==1
				if _rc {
					di in red "bin variable `varname' must be 0 (negative) or 1 (positive)"
					exit 198
				}
					
				* significance test
				if "`vartype'"=="bin" {
					qui tab `varname' `groupnum' [`weight'`exp'], chi2
					local p=r(p)
				}
				else {
					qui tab `varname' `groupnum' [`weight'`exp'], exact
					local p=r(p_exact)
				}				
				
				* collapse to table1 format
				qui contract `varname' `groupnum' [`weight'`exp'], zero
				qui egen tot=total(_freq), by(`groupnum')
				
				* default format is 0 decimal places if <100 cases, otherwise 1 dp
				* (for categorical variables, format is for % not the frequency)
				if "`varformat'"=="" {
					sum tot, meanonly
					if r(max)<100 local varformat "%1.0f"
					else local varformat "%2.1f"
				}

				* finish restructuring to table1 format
				qui keep if `varname'==1
				qui gen perc=string(100*_freq/tot, "`varformat'")
				qui replace perc="<1" if _freq!=0 & real(perc)==0
				
				if "`percent'"=="percent" qui gen n_perc=perc + "%"
				else qui gen n_perc=string(_freq) + " (" + perc + "%)"
				
				drop _freq tot perc
				qui reshape wide n_perc, i(`varname') j(`groupnum')
				qui drop `varname'
				qui gen factor="`varlab'" if _n==1
				qui clonevar factor_sep=factor
				rename n_perc* `groupnum'*

				* add p-value, test and sort variables, then save
				if `groupcount'>1 qui gen p=`p'
				if "`test'"=="test" & `groupcount'>1 {
					if "`vartype'"=="bin" qui gen test="Pearson's chi-squared"
					else qui gen test="Fisher's exact"
				}
				gen sort1=`sortorder++'
				qui append using "`resultstable'"
				qui save "`resultstable'", replace
				restore
			}			
		}
  }
		gettoken arg rest : rest, parse("\")
 
   }
	
	* get value labels for group if available
	local vallab: value label `groupnum'
	if "`vallab'"!="" {
		tempfile labels
		qui label save `vallab' using "`labels'"
	}

	* levels of group variable, for subsequent labelling
	qui levelsof `groupnum' if `touse', local(levels)

	* load results table
	preserve
	qui use "`resultstable'", clear
	
	* restore value labels if available
	capture do `labels'
	
	* label each group variable
	foreach level of local levels {
		if "`vallab'"=="" {
			lab var `groupnum'`level' "`by' = `level'"
		}
		else {
			local lab: label `vallab' `level'
			lab var `groupnum'`level' "`lab'"
		}
	}

	* label other variables
	lab var factor "Factor"
	capture lab var level "Level"
	capture lab var test "Test"
	if `groupcount'==1 lab var `groupnum'1 "Value"
	
	* format p-values
	if `groupcount'>1 {
		qui gen pvalue=string(p, "%3.2f") if !missing(p)
		qui replace pvalue=string(p, "%`=`pdp'+1'.`pdp'f") if p<0.10
		local pmin=10^-`pdp'
		qui replace pvalue="<" + string(`pmin', "%`=`pdp'+1'.`pdp'f") if p<`pmin'
		lab var pvalue "p-value"
	}

	* create a row containing variable labels - for nicer output
	qui count
	local newN=r(N) + 1
	qui set obs `newN'
	qui desc, varlist
	foreach var of varlist `r(varlist)' {
		capture replace `var'="`: var lab `var''" in `newN'
	}
	qui replace sort1=0 in `newN'
	
	* clean up variables in preparation for display
	order factor `groupnum'*
	capture order factor `by'* pvalue // won't have p-value if no group var
	capture order test, after(pvalue) // won't have test if no group var
	capture order level, after(factor) // won't have level if no cat vars
	
	* sort rows and drop unneeded variables
	sort sort*
	drop sort*
	capture drop p
	
	* left-justify the strings apart from p-value
	qui desc, varlist
	foreach var in `r(varlist)' {
		format `var' %-`=substr("`: format `var''", 2, .)'
	}
	capture format %`=`pdp'+3's pvalue

	* rename placeholder group variable if by() option not used
	* otherwise rename group variables using the specified group var (only
	*   important if using the "clear" option)
	if `groupcount'==1 rename `groupnum'1 value
	else rename `groupnum'* `by'*
	
	* finally, display the table itself
	qui ds factor_sep, not
	list `r(varlist)', sepby(factor_sep) noobs noheader table
	drop factor_sep
	
	* if -saving- was specified then we'll save the table as an Excel spreadsheet
	if `"`saving'"'!="" export excel using "`saving'", `replace'

	* restore original data unless told not to
	if "`clear'"=="clear" restore, not
	else restore
end
