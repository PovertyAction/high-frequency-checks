*! version 3.0.0 Innovations for Poverty Action 22oct2018

program ipacheckconstraints, rclass
	/* Check that certain numeric variables fall within
	   reasonable hard and soft constraints..

	   Most numeric questions that are asked during an 
	   interview have a logical range of possible values.
	   Entries that exceed these limits could be a sign of
	   misentry or fraud. */
	version 14.1

	#d ;
	syntax varlist, 
		/* soft constraint options */
	    [smin(numlist miss) smax(numlist miss)]
		/* hard constraint options */
	    [hmin(numlist miss) hmax(numlist miss)]
		/* output filename */
	    saving(string) 
	    /* output options */
        id(varname) ENUMerator(varname) SUBMITted(varname) 
		[KEEPvars(string) SCTOdb(string)] 

		/* other options */
		[SHEETMODify SHEETREPlace NOLabel];	
	#d cr

	* test for fatal conditions
	if mi("`smin'`smax'`hmin'`hmax'") {
			di as err "must specify at least one constraint value."
			error 198
	}

	di ""
	di "HFC 8 => Checking that values do not exceed soft/hard minimums and maximums..."

	qui {
	* count nvars
	unab vars : _all
	local nvars : word count `vars'

	* define temporary files 
	tempfile tmp org
	save "`org'"

	* define temporary variable
	tempvar viol
	g `viol' = .

	* define default output variable list
	unab admin : `submitted' `id' `enumerator'
	local meta `"variable label value message"'
	if !missing("`sctodb'") {
		local meta `"`meta' scto_link"'
	}

	* add user-specified keep vars to output list
    local lines : subinstr local keepvars ";" "", all
    local lines : subinstr local lines "." "", all

    local unique : list uniq lines
    local keeplist : list admin | meta
    local keeplist : list keeplist | unique

 	* define loop locals
	local nviol = 0 
	local nhard = 0
	local nsoft = 0
	local i = 1

	* initialize meta data variables
	foreach var in `meta' {
		g `var' = ""
	}
	
	* Create scto_link variable
	if !missing("`sctodb'") {
		local bad_chars `"":" "%" " " "?" "&" "=" "{" "}" "[" "]""'
		local new_chars `""%3A" "%25" "%20" "%3F" "%26" "%3D" "%7B" "%7D" "%5B" "%5D""'
		local url "https://`sctodb'.surveycto.com/view/submission.html?uuid="
		local url_redirect "https://`sctodb'.surveycto.com/officelink.html?url="

		foreach bad_char in `bad_chars' {
			gettoken new_char new_chars : new_chars
			replace scto_link = subinstr(key, "`bad_char'", "`new_char'", .)
		}
		replace scto_link = `"HYPERLINK("`url_redirect'`url'"' + scto_link + `"", "View Submission")"'
	}
	
	* initialize temporary output file
	poke `tmp', var(`keeplist')

	/* loop through varlist and check that values
	   fall within hard and soft constraints */
	foreach var in `varlist' {
		* get constraint values for current variable
		local minsoft: word `i' of `smin'
		local minhard: word `i' of `hmin'
		local maxsoft: word `i' of `smax'
		local maxhard: word `i' of `hmax'
		local npvar = 0
		
		* replace unspecified constraints with Stata missing value
		if `"`minsoft'"' == "" local minsoft .
		if `"`minhard'"' == "" local minhard .
		if `"`maxsoft'"' == "" local maxsoft .
		if `"`maxhard'"' == "" local maxhard .		

		* capture variable label
		local varl : variable label `var'

		* update values for additional variables
		replace variable = "`var'"
		replace label = "`varl'"
		replace value = string(`var')
			
		* generate _hfcokay & _hfcokayvar if they do not exist
		cap confirm var _hfcokay
		if _rc == 111 gen _hfcokay = 0
		cap confirm var _hfcokayvar 
		if _rc == 111 gen _hfcokayvar = ""

		/* =======================
		   = check hard minimums =
		   ======================= */
		replace `viol' = `var' < `minhard' & `minhard' < . & (!_hfcokay & !regexm(_hfcokayvar, "`var'")) 
		replace message = "Value is too small. Hard Min. = `minhard'"

		* count the violations
		count if `viol' == 1
		local nviol = `nviol' + `r(N)'
		local npvar = `npvar' + `r(N)'
		local nhard = `nhard' + `r(N)'

		* append violations to the temporary data set
		saveappend using "`tmp'" if `viol' == 1, ///
			    keep("`keeplist'") sort(`id')

		/* =======================
		   = check hard maximums =
		   ======================= */
		replace `viol' = `var' > `maxhard' & `maxhard' < . & `var' < . & (!_hfcokay & !regexm(_hfcokayvar, "`var'")) 
		replace message = "Value is too high. Hard Max. = `maxhard'"

		* count the violations
		count if `viol' == 1
		local nviol = `nviol' + `r(N)'
		local npvar = `npvar' + `r(N)'
		local nhard = `nhard' + `r(N)'

		* append violations to the temporary data set
		saveappend using "`tmp'" if `viol' == 1, ///
			    keep("`keeplist'") sort(`id')

	    /* =======================
		   = check soft minimums =
		   ======================= */

		replace `viol' = `var' < `minsoft' & `minsoft' < . & (!_hfcokay & !regexm(_hfcokayvar, "`var'"))
		replace message = "Value is too small. Soft Min. = `minsoft'"

		* count the violations
		count if `viol' == 1
		local nviol = `nviol' + `r(N)'
		local npvar = `npvar' + `r(N)'
		local nsoft = `nsoft' + `r(N)'

		* append violations to the temporary data set
		saveappend using "`tmp'" if `viol' == 1, ///
			    keep("`keeplist'") sort(`id')

		/* =======================
		   = check soft maximums =
		   ======================= */

		replace `viol' = `var' > `maxsoft' & `maxsoft' < . & `var' < . & (!_hfcokay & !regexm(_hfcokayvar, "`var'"))
		replace message = "Value is too high. Soft Max. = `maxsoft'"

		* count the violations
		count if `viol' == 1
		local nviol = `nviol' + `r(N)'
		local npvar = `npvar' + `r(N)'
		local nsoft = `nsoft' + `r(N)'

		* append violations to the temporary data set
		saveappend using "`tmp'" if `viol' == 1, ///
			    keep("`keeplist'") sort(`id')

		if `npvar' > 0 {
			nois di "  Variable `var' has `npvar' constraint violations."
		}
		local i = `i' + 1
	}

	* import compiled list of violations
	use "`tmp'", clear

	* if there are no violations
	if `=_N' == 0 {
		set obs 1
	} 


	order `keeplist'
    gsort -`submitted', gen(order)

	format `submitted' %tc
	tempvar bot bottom lines

	bysort variable (`enumerator' order) : gen `lines' = _n
	egen `bot' = max(`lines'), by(variable)
	gen `bottom' = cond(`bot' == `lines', 1, 0)
	
	
	loc colorcols
	foreach var in variable label {
		loc pos : list posof "`var'" in keeplist
		loc colorcols `colorcols' `pos'
	}
	
	* export compiled list to excel
	export excel `keeplist' using "`saving'" ,  ///
		sheet("8. constraints") `sheetreplace' `sheetmodify' ///
		firstrow(variables) `nolabel'
	
	unab keeplist : `keeplist'	
	mata: basic_formatting("`saving'", "8. constraints", tokens("`keeplist'"), tokens("`colorcols'"), `=_N')	

	*export scto links as links
	if !missing("`sctodb'") {
		*nois di c(version)
		unab allvars : _all
		local pos : list posof "scto_link" in allvars
		mata: add_scto_link("`saving'", "8. constraints", "scto_link", `pos')
	}

	* revert to original
	use "`org'", clear
	}
	* display check statistics to output screen
	di ""
	di "  Found `nviol' total constraint violations: `nhard' hard and `nsoft' soft."
	return scalar nviol = `nviol'
	return scalar nhard = `nhard'
	return scalar nsoft = `nsoft'
end

program saveappend
	/* this program appends the data in memory, or a subset 
	   of that data, to a stata file on disk. */
	syntax using/ [if] [in] [, keep(varlist) sort(varlist)]

	marksample touse 
	preserve

	keep if `touse'

	if "`keep'" != "" {
		keep `keep' `touse'
	}

	append using "`using'"

	if "`sort'" != "" {
		sort `sort'
	}

	drop `touse'
	save "`using'", replace

	restore
end

program poke
	syntax [anything], [var(varlist)] [replace] 

	* remove quotes from filename, if present
	local file = `"`=subinstr(`"`anything'"', `"""', "", .)'"'

	* test fatal conditions
	cap assert "`file'" != "" 
	if _rc {
		di as err "must specify valid filename."
		error 100
	}

	preserve 

	if "`var'" != "" {
		keep `var'
		drop if _n > 0
	}
	else {
		drop _all
		g var = 1
		drop var
	}
	* save 
	save "`file'", emptyok `replace'

	restore

end

mata: 
mata clear
void basic_formatting(string scalar filename, string scalar sheet, string matrix vars, string matrix colors, real scalar nrow) 
{

class xl scalar b
real scalar i, ncol
real vector column_widths, varname_widths, bottomrows
real matrix bottom

b = xl()
ncol = length(vars)

b.load_book(filename)
b.set_sheet(sheet)
b.set_mode("open")

b.set_bottom_border(1, (1, ncol), "thin")
b.set_font_bold(1, (1, ncol), "on")
b.set_horizontal_align(1, (1, ncol), "center")

if (length(colors) > 1 & nrow > 2) {	
for (j=1; j<=length(colors); j++) {
	b.set_font((3, nrow), strtoreal(colors[j]), "Calibri", 11, "lightgray")
	}
}


// Add separating bottom lines : figure out which columns to gray out	
bottom = st_data(., st_local("bottom"))
bottomrows = selectindex(bottom :== 1)
column_widths = colmax(strlen(st_sdata(., vars)))	
varname_widths = strlen(vars)

for (i=1; i<=cols(column_widths); i++) {
	if	(column_widths[i] < varname_widths[i]) {
		column_widths[i] = varname_widths[i]
	}

	if (column_widths[i] > 250) {
		column_widths[i] = 250
	}	

	b.set_column_width(i, i, column_widths[i] + 4)
}

if (rows(bottomrows) > 1) {
for (i=1; i<=rows(bottomrows); i++) {
	b.set_bottom_border(bottomrows[i]+1, (1, ncol), "thin")
	if (length(colors) > 1) {
		for (k=1; k<=length(colors); k++) {
			b.set_font(bottomrows[i]+2, strtoreal(colors[k]), "Calibri", 11, "black")
		}
	}
}
}
else b.set_bottom_border(2, (1, ncol), "thin")

b.close_book()

}

void add_scto_link(string scalar filename, string scalar sheetname, string scalar variable, real scalar col)
{
	class xl scalar b
	string matrix links
	real scalar N

	b = xl()
	links = st_sdata(., variable)
	N = length(links) + 1

	b.load_book(filename)
	b.set_sheet(sheetname)
	b.set_mode("open")
	b.put_formula(2, col, links)
	b.set_font((2, N), col, "Calibri", 11, "5 99 193")
	b.set_font_underline((2, N), col, "on")
	b.set_column_width(col, col, 17)
	
	b.close_book()
	}

end

