*! version 2.0.1 ChristopherBoyer 25apr2017
*! version 1.0.0 Caton brewster 10nov2016

program ipatrackversions, rclass
	/* Create a sheet that shows the survey versions used for each day of surveying. 
	For the most recent day of surveying, if there are surveys that have been submitted
	using the wrong version, list the enumerator ID, respondent ID, etc. for those observations
	to facilitate finding that enumerator and ensuring they upload the latest version of the 
	survey */
	
	

	* define inputs
	version 13

	#delimit ;
	syntax varname,  //varname is the form version variable - must be num. 
		/* specify uid for the survey, enumerator id */
	    id(varname) ENUMerator(varname) 
		/* list of other vars to keep */
		[KEEPvars(varlist)] 
		/* specify date var, i.e. submission date var */
		submit(varname numeric)
		/* output filename */
		saving(string) 
		;	
	#delimit cr

	
	di ""
	di "Compiling information on survey form versions by submission date..."

	qui {
	
	* test for fatal conditions

	* non-numeric input
	cap confirm numeric var `varlist'
	if _rc {
		di as err "Variable used for form version (`varlist') not numeric."
		di as err "Must be numeric and ordinal for the program to work correctly."
		error 101
	}
	
	* missing values of submission date
	count if `submit' == . 
	if `r(N)' > 0 {
		di as err `"There are missing values of `submit'. Drop these observations before continuing."'
		error 101
	}

	
	tempfile org tmp
	save `org'

	* initialize tempvars  
	tempvar wrong_form submit_td

	* convert `header_submit' to %td format if needed	
	foreach letter in d c C b w m q h y {
		ds `submit', has(format %t`letter'*)
		if !mi("`r(varlist)'") {
			g `submit_td' = dof`letter'(`submit')
		}
	}

	* confirm variable exists
	cap confirm var `submit_td'
    if _rc {
        di as err "The submission date variable, `submit', is not in an acceptable format."
        di as err "Must be %td, %tc, %tC, %tb, %tw, %tm, %tq, %th, or %ty."
        error 101
    } 
	
	tab `submit_td' `varlist', matcell(X) matrow(rows) matcol(cols)
	local N = r(N)
	local r = r(r) + 1
	local c = r(c) + 1

	if mi("`N'") {
		di as err `"No observations in cross-tab of `submit' and `varlist' - check your data"'
		error 122
	}

	save `tmp'

	clear
	set obs `r'
	forval i = 1/`c' {
		g var`i' = .
		label variable var`i' " "

		if `i' == 1 {
    		format var`i' %tdCCYY/NN/DD  
		} 
		else {
			format var`i' %12.0g
		}
	}

	mata: tab_to_dta("rows", "cols", "X")

	label variable var1 "Submission Date"
	label variable var2 "Form Versions"
 
 	export excel using "`saving'", ///
	    sheet("T3. form versions") sheetreplace firstrow(varl) date("%tdCCYY/NN/DD")

	use `tmp', clear

	* save most recent submission date
	sum `submit_td'
	local max_date = r(max)

	* save most recent form version
	sum `varlist'
	local max_version = r(max)

	local str_max_date: disp %tdCCYY/NN/DD `max_date'
	local str_max_date = trim("`str_max_date'")
	
 	local export_str = "List of submissions using outdated form version on `str_max_date'."
	mata: export_excel_string(`r' + 5, 1, "`export_str'", "`saving'")

	* determine which submissions used wrong form on most recent date
	g `wrong_form' = `submit_td' == `max_date' & !inlist(`varlist', ., `max_version')

	count if `wrong_form'
	local num_wrong_form = r(N)

 	keep if `wrong_form'
 	keep `submit' `id' `enumerator' `keepvars' 
 	order `submit' `id' `enumerator' `keepvars'
 	
	* export header 
	local row = `r' + 6
	if _N > 0 {
		export excel `submit' `enumerator' `id' `keepvars'  using "`saving'", ///
			sheet("T3. form versions") sheetmodify cell(A`row') firstrow(var)
	}

	local perc_wrong_form: disp %12.2f `num_wrong_form' * 100 / `N'
	local perc_wrong_form = trim("`perc_wrong_form'")

	use `org', clear

	}
	
	di "  Most recent submission date was `str_max_date'."
	di "  `num_wrong_form' (`perc_wrong_form'%) survey(s) completed with an outdated form version on `str_max_date'"

end

mata: 
// explain what this function does
void tab_to_dta(string scalar rowname, string scalar colname, string scalar matname)
{
	real matrix rows, cols, X

	rows = st_matrix(rowname)
	cols = st_matrix(colname)
	X = st_matrix(matname)

	X = (. \ rows), (cols \ X)

	st_store(., ., X)
}

void export_excel_string(real scalar row, real scalar column, string scalar str, string scalar filename)
{
	class xl scalar b
	
	b = xl()

	b.load_book(filename)
	b.set_sheet("T3. form versions")
	b.put_string(row, column, str)
	b.close_book()
}

end

