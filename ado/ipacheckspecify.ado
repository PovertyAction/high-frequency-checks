*! version 3.0.0 Innovations for Poverty Action 22oct2018

program ipacheckspecify, rclass
	/* This program checks for recodes of specify other variables 
	   by listing all other values specified. */
	version 14.1

	#d ;
	syntax varlist, 
		/* parent variables */
		PARENTvars(varlist)
		/* output filename */
	    saving(string) 
	    /* output options */
        id(varname) ENUMerator(varname) SUBMITted(varname) 
		[KEEPvars(string) SCTOdb(string)] 

		/* other options */
		[SHEETMODify SHEETREPlace NOLabel];	
	#d cr	

	di ""
	di "HFC 9 => Checking specify other variables for misscodes and new categories..."
	qui {

	* count nvars
	unab vars : _all
	local nvars : word count `vars'

	* define temporary files 
	tempfile tmp org
	save "`org'"

	* define temporary variable
	tempvar specified
	g `specified' = .

	* define default output variable list
	unab admin : `submitted' `id' `enumerator' 
	local meta `"parent parent_label parent_value child child_label child_value choices"'
	if !missing("`sctodb'") {
		local meta `"`meta' scto_link"'
	}

	* add user-specified keep vars to output list
    local lines : subinstr local keepvars ";" "", all
    local lines : subinstr local lines "." "", all

    local unique : list uniq lines
    local keeplist : list admin | meta
    local keeplist : list keeplist | unique

    * initialize local counters
	local nother = 0
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

	/* idea - could add check here for additional specify other variables
	   not included in the input file */

	* loop through other specify variables in varlist and find nonmissing values
	foreach var in `varlist' {
		* get current other variable
		local parent : word `i' of `parentvars'

		cap confirm string variable `var'
		if _rc {
			cap tostring `var', replace
			replace `var' = "" if `var' == "."
		}		

		cap confirm string variable `var'

		if !_rc {
			replace `specified' = `var' != ""

			* count the number of specified other values
			count if `specified' == 1
			local n = `r(N)'
			local nother = `nother' + `n'

			* capture variable label
			local pvarl : variable label `parent'
			local cvarl : variable label `var'

			* capture choices 
			getlabel `parent'
			local vall = "`r(label)'"

			* update values of meta data variables
			replace parent = "`parent'"
			replace parent_label = "`pvarl'"
			replace child = "`var'"
			replace child_label = "`cvarl'"
			replace child_value = `var'
			replace choices = "`vall'"

	 		cap confirm numeric variable `parent'
	 		if !_rc {
	 			replace parent_value = string(`parent')
	 		}

			* append violations to the temporary data set
			saveappend using "`tmp'" if `specified' == 1, ///
				keep("`keeplist'")

			noisily di "  Variable {cmd:`var'} has {cmd:`n'} other values specified."

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

	bysort parent : gen `lines' = _n
	egen `bot' = max(`lines'), by(parent)
	gen `bottom' = cond(`bot' == `lines', 1, 0)
	
	loc colorcols
	foreach var in parent parent_label parent_value child child_label choices  {
		loc pos : list posof "`var'" in keeplist
		loc colorcols `colorcols' `pos'
	}
	
	* export compiled list to excel
		
	export excel `keeplist' using "`saving'" ,  ///
		sheet("9. specify") `sheetreplace' `sheetmodify' ///
		firstrow(variables) `nolabel'

	unab keeplist : `keeplist'
	mata: basic_formatting("`saving'", "9. specify", tokens("`keeplist'"), tokens("`colorcols'"), `=_N')	

	
	*export scto links as links
	if !missing("`sctodb'") {
		unab allvars : _all
		local pos : list posof "scto_link" in allvars
		mata: add_scto_link("`saving'", "9. specify", "scto_link", `pos')
	}
	
	* revert to original
	use "`org'", clear
	
	} //qui bracket
	di ""
	di "  Found {cmd:`nother'} total specified values."
	return scalar nspecify = `nother'

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
cap program drop getlabel
program getlabel, rclass

	syntax varname

	qui levelsof `varlist', local(levels)
	local lab: value label `varlist'

	local out ""
	local i = 1
	if "`lab'" != "" {
		foreach l of local levels {
			if `l' < 0 {
				local levels : subinstr local levels "`l'" ""
				local levels : list levels | l
			}
		}
		foreach l of local levels {
			local l`i' : label `lab' `l'
			local out "`out'(`l') `l`i'' "
			local i = `i' + 1
		}
	}

	return local label "`out'"
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
	b.set_font((3, nrow+1), strtoreal(colors[j]), "Calibri", 11, "lightgray")
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
	if (column_widths[i] > 78) {
	column_widths[i] = 78
	}
	b.set_column_width(i, i, column_widths[i] + 2)
}


if (rows(bottomrows) > 0) {
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
