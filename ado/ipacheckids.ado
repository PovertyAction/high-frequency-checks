*! version 3.0.0 Innovations for Poverty Action 22oct2018

program ipacheckids
	syntax varname [using/], ///
		ENUMerator(varname)  ///
		[NOLabel]			 ///
		[VARiable]			 ///
		[force]				 ///
		[save(string)]
version 14.1

if mi("`using'") {
	loc using = "hfc_duplicates.xlsx"
}	

if mi("`variable'") {
	loc variable varl
}

if "`force'" == "" & "`save'" != "" {
	dis as error "option {bf:save} not allowed"
	dis as error "{col 5}option {bf:save} requires you also specify option {bf:force}, which changes the existing dataset."
	error 198
}

qui {

noi di "Searching for duplicates in `varlist'..."

marksample touse, strok novarlist

tempfile survey_dta
save `survey_dta'

keep if `touse'

sort `varlist' submissiondate key
cap confirm string variable `varlist' 
if _rc {
	summ `varlist'
	if abs(floor(log10(`r(max)'))) + 1 > 20 {
		nois di as error "Error: cannot reversibly convert `id' to string without loss of precision. Consider using a different ID or convert yourself."
		error 198
	}
	else if abs(floor(log10(`r(max)'))) + 1 > 8 {
		nois di as error "Warning: using large numeric IDs may result in loss of precision. Consider converting to string!"
	}
	tostring `varlist', replace force format("%20.0g")
}
duplicates tag `varlist', gen(dup)
count if dup

if `r(N)' > 0 {
	tempvar prctdiff vardiff bot differences total sortavg
	gen `prctdiff' = .
	lab var `prctdiff' "Percent Difference"
	gen `vardiff' = .
	gen `differences' = .
	lab var `differences' "Differences"
	gen `total' = .
	lab var `total' "Total Compared"

	qui ds `varlist' key `prctdiff' `vardiff', not
	local cfvars `r(varlist)' 
	drop if dup < 1	
	levelsof `varlist', local(ids)
	bysort `varlist' : gen n = _n
	loc j 1
	foreach id in `ids' {

		preserve
			keep if `varlist' == "`id'" 
			keep if _n == 1 			
			tempfile first
			save "`first'"
		restore

		local pairdiff
		count if `varlist' == "`id'" 
		forval i = 2/`r(N)' {

			preserve
				keep if `varlist' == "`id'" 
				keep if _n == `i' 
				cfout `cfvars' using "`first'", id(`varlist')
				loc different`i' = `r(discrep)'
				loc total`i' = `r(N)'
				local prctdiff`i' = `r(discrep)' / `r(N)'
				local loc`i' `r(alldiff)'
			restore

			replace `prctdiff' = `prctdiff`i'' if n == `i' & `varlist' == "`id'" 
			replace `differences' = `different`i'' if n == `i' & `varlist' == "`id'"
			replace `total' = `total`i'' if n == `i' & `varlist' == "`id'"
			local pairdiff `pairdiff' `loc`i''
		}
		
		local vardiffs `vardiffs' `pairdiff' 
		local pairdiff`j' : list uniq pairdiff
		loc ++j

	}
	
by `varlist' : egen `sortavg' = mean(`prctdiff')

recode `prctdiff' (.=-999)
sort `sortavg' `prctdiff'
recode `prctdiff' (-999=.)

	export excel `varlist' `enumerator' key `differences' `total' `prctdiff' using "`using'" if dup, ///
	sheet("Diffs") firstrow(varl) replace missing(".")

	
** need to loop through and place them with a space between each other
* need to count how many are in each, add two (one for vars, one for space)

loc start 1
loc count 1

loc id_ordered
forval i = 1/`=_N' {
	levelsof `varlist' if _n == `i'
	loc id : word 1 of `r(levels)'
	loc id_ordered `id_ordered' `id'
}

loc id_ordered : list uniq id_ordered

levelsof `varlist', loc(original)

foreach id in `id_ordered' {
	loc count : list posof "`id'" in original
	export excel `varlist' key `pairdiff`count'' using "`using'" if dup > 0 & `varlist' == "`id'", ///
	sheet("Raw") firstrow(`variable') sheetmodify `nolabel' cell(A`start')
	
		
	count if `varlist' == "`id'"
	loc counter `r(N)'
	loc end = `start' + `counter'
	loc column : word count `varlist' key `pairdiff`count''
	mata: borders("`using'", "Raw", `start', `column', `counter')
	
	loc start = `start' + `counter' + 2
	loc ++count
	
	}

	* I need to find the number of rows and columns in the raw file to adjust column widths
*use end as nrow, use last word count pairdiff`count-1'
	
	mata: col_widths("`using'", "Raw", `end', `=`:word count `pairdiff`=`count'-1'''+2')



**********Formatting***********************
	 // adding lines, bolding, and adjusting column widths
	sort `varlist' key
	keep `varlist' key dup

	by `varlist' : gen lines = _n
	egen `bot' = max(lines), by(`varlist')
	gen bottom = cond(`bot' == lines, 1, 0)

	*add separating lines

	mata: make_lines("`using'", "Diffs", 6, `=`=_N'+1')

	use `survey_dta', clear

	noi di "`:word count `ids'' duplicate groups placed in `using'." 

	if "`force'" == "force" {
		duplicates drop `varlist', force
		noi di "One from each group is randomly kept in this dataset."
		if "`save'" != "" {
		save "`save'", replace
		}
	}
	else noi di "All duplicates are kept. To randomly drop them, use -force- option." 
	
	}
	else noi di "No duplicates found for `varlist'!"
} // qui bracket

end 

mata:
mata clear

void make_lines(string scalar filename, string scalar sheet, real scalar N, real scalar nrow)
{

	class xl scalar b

	b = xl()
	
	b.load_book(filename)
	b.set_sheet(sheet)
	b.set_mode("open")
	
	
	bottom = st_data(., "bottom")
	bottomrows = selectindex(bottom :== 1)
	for (i=1; i<=rows(bottomrows); i++) {
		b.set_bottom_border(bottomrows[i]+1, (1, N), "thick")
	}
	
	b.set_bottom_border(1, (1,N), "thick")
	b.set_font_bold(1, (1,N), "on")

	
	//adjust col widths
	cols = b.get_string((1,nrow), (1,N))
	column_widths = colmax(strlen(cols))

	for (j=1; j<=N; j++) {
		b.set_column_width(j, j, column_widths[j]+2)		
	}
	
	if (sheet == "Raw") b.set_right_border((1, nrow), 2, "thick")
	else {
		b.set_right_border((1, nrow), N, "thick")
		b.set_number_format((2, nrow), N, "percent_d2")
		b.set_horizontal_align((1, nrow), (1, N), "center")
	}
	
	b.close_book()
}

void borders(string scalar filename, string scalar sheet, real scalar row, real scalar column, real scalar counter)
{

	class xl scalar b
	
	b = xl()
	
	b.load_book(filename)
	b.set_sheet(sheet)
	b.set_mode("open")
	
	b.set_font_bold(row, (1, column), "on")
	b.set_left_border(row, 1, "thick")
	b.set_top_border((row, row+1), (1,column), "thick")
	b.set_bottom_border(row + counter, (1, column), "thick")
	
	b.close_book()
	
	}


void col_widths(string scalar filename, string scalar sheet, real scalar nrow, real scalar ncol)
{
	class xl scalar b
	string matrix cols
	real matrix column_widths
	b = xl()
	
	b.load_book(filename)
	b.set_sheet(sheet)
	b.set_mode("open")
	
	//adjust col widths
	cols = b.get_string((1, nrow), (1, ncol))
	column_widths = colmax(strlen(cols))

	for (j=1; j<=ncol; j++) {
		b.set_column_width(j, j, column_widths[j]+2)		
	}

	b.close_book()
	} 


end


