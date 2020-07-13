*! version 3.0.0 Innovations for Poverty Action 22oct2018

program ipatrackversions, rclass 
	/* Create a sheet that shows the survey versions used for each day of surveying. 
	For the most recent day of surveying, if there are surveys that have been submitted
	using the wrong version, list the enumerator ID, respondent ID, etc. for those observations
	to facilitate finding that enumerator and ensuring they upload the latest version of the 
	survey */

	* define inputs
	version 14.1

	#delimit ;
	syntax varname,  //varname is the form version variable - must be num. 
		/* specify uid for the survey, enumerator id */
	    id(varname) ENUMerator(varname) [starttime(varname) endtime(varname)] //added starttime and endtime
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
	save "`org'"

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
	
	if mi("`starttime'") {
		loc starttime starttime
	}

	if mi("`endtime'") {
		loc endtime endtime
	}
	
	tab `submit_td' `varlist', matcell(X) matrow(rows) matcol(cols)
	local N = r(N)
	local r = r(r) + 1
	local c = r(c) + 1

	if mi("`N'") {
		di as err `"No observations in cross-tab of `submit' and `varlist' - check your data"'
		error 122
	}
	
	di ""
	di "Compiling information on survey form versions by submission date..."

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
	save "`org'"

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

	save "`tmp'"

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

	g newsub = string(var1, "%td"), before(var1)
	drop var1
	label variable newsub "Submission Date"
	label variable var2 "Form Versions"
 
 	export excel using "`saving'", ///
	    sheet("Version Control") sheetreplace firstrow(varl) missing("") //This is for the versions table
		
	mata: v_formatting("`saving'", "Version Control", 1, `c', 1, `r') 
	
	use "`tmp'", clear

	* save most recent submission date
	sum `submit_td'
	local max_date = r(max)

	* save most recent form version
	sum `varlist'
	local max_version = r(max)

	local str_max_date: disp %tdCCYY/NN/DD `max_date'
	local str_max_date = trim("`str_max_date'")
	
	* determine which submissions used wrong form on most recent date
	g `wrong_form' = `submit_td' == `max_date' & !inlist(`varlist', ., `max_version')

	count if `wrong_form'
	local num_wrong_form = r(N)

 	keep if `wrong_form'
 	keep `submit' `id' `enumerator' `starttime' `endtime' `keepvars' //added starttime and endtime
 	order `submit' `id' `enumerator' `starttime' `endtime' `keepvars'
 	
	* export header 
	loc columns `:word count `submit' `enumerator' `id' `starttime' `endtime' `keepvars''
	*local col = char(`c' + 66)
	mata: st_local("col", invtokens(numtobase26(`c' + 2)))
	if _N > 0 {
		export excel `submit' `enumerator' `id' `starttime' `endtime' `keepvars'  using "`saving'", /// this is for the outdated versions
			sheet("Version Control") sheetmodify cell(`col'2) firstrow(var) missing("") //added starttime and endtime
	
		mata: v_formatting("`saving'", "Version Control", `=`c' + 2', `= `columns' + `c' + 1', 1, `=`=_N' + 1' )  
	}
	
	use "`org'", clear

	} // qui bracket
	
	di "  Most recent submission date was `str_max_date'."
	di "  `num_wrong_form' (`perc_wrong_form'%) survey(s) completed with an outdated form version on `str_max_date'"

end

mata: 

void v_formatting(string scalar filename, string scalar sheet, real scalar startcol, real scalar column, real scalar startrow, real scalar row)
{
	class xl scalar b
	real vector lastrow
	
	b = xl()

	b.load_book(filename)
	b.set_sheet(sheet)
	b.set_mode("open")

	b.set_left_border((1, row + 1), startcol, "thick")
	b.set_top_border(1, (startcol, column), "thick")
	b.set_left_border((1, row + 1), column + 1, "thick")
	b.set_bottom_border((1, 2), (startcol, column), "thick")
	b.set_bottom_border(row + 1, (startcol, column), "thick")
	
	b.set_font_bold((1,2), (startcol, column), "on")
	b.set_font_bold((3, row + 1), startcol, "on")
	if (column == 2) {
		b.set_horizontal_align(1, 2, "merge")	
	} 
	else b.set_horizontal_align( 1, (startcol + 1, column), "merge")
	
	
	if (startcol == 1) {
		b.set_column_width(startcol, column, 16)
		b.set_left_border((1, 2), startcol + 1, "thick")
		b.set_horizontal_align((1, row + 1), (startcol, column), "center")
		
		
		if (column == 2) {
			lastrow = b.get_number(row+1, 2)
		}
		else {
			lastrow = b.get_number(row+1, (startcol + 1, column))
		}
		
		
		for (i=1; i<=length(lastrow)-1; i++) {
			if (lastrow[i] != 0) {
			b.set_fill_pattern(row+1, i+1, "solid", "pink")
			}
		}
		
	}
	else {
	b.put_string(1, startcol, "List of submissions using outdated form version on " + st_local("str_max_date") + ".")

	output = b.get_string((2, row+1), (startcol, column))
	lengths = colmax(strlen(output))
	x=0
	for (i=1; i <=cols(lengths); i++) {
		b.set_column_width(startcol + x, startcol + x, lengths[i] + 2)
	x++
	}
	b.set_horizontal_align((2, row+1), (startcol, column), "center")
	}
	
	b.close_book()
}

void tab_to_dta(string scalar rowname, string scalar colname, string scalar matname)
{
	real matrix rows, cols, X

	rows = st_matrix(rowname)
	cols = st_matrix(colname)
	X = st_matrix(matname)

	X = (. \ rows), (cols \ X)

	st_store(., ., X)
}


end
