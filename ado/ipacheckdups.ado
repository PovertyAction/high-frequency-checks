*! version 3.0.0 Innovations for Poverty Action 22oct2018

program ipacheckdups, rclass
	/* This program checks that there are no duplicate interviews.

	    */
	version 14.1

	#d ;
	syntax anything [if] [in], 	
		/* consent options */
	    [UNIQUEvars(string)]
		/* output filename */
	    saving(string) 
	    /* output options */
        id(varname) ENUMerator(varname) SUBMITted(varname) 
		[KEEPvars(string) SCTOdb(string)] 

		/* other options */
		[SHEETMODify SHEETREPlace NOLabel];	
	#d cr

	marksample touse, novarlist

	di ""
	di "HFC 2 => Checking that there are no duplicates..."
	qui {

	* define temporary files 
	tempfile tmp org
	save "`org'"

	* define temporary variable
	tempvar dup1
	
	* merge the variable lists in uniquevars and anything
	loc n = 0
	while strpos("`anything'", ";") > 0 {
		local ++n
		gettoken varlista`n' anything : anything, p(";")
		local anything : subinstr loc anything ";" ""
		
		if strpos("`uniquevars'", ";") != 1 {
			gettoken varlistb`n' uniquevars : uniquevars, p(";")
		}
		local uniquevars: subinstr loc uniquevars ";" ""
		local varlistb`n': subinstr loc varlistb`n' ";" ""
		
		loc varlist`n' `varlista`n'' `varlistb`n''
		
	}
	loc checksneeded `n'

	* define default output variable list
	unab admin : `submitted' `id' `enumerator'
	local meta `"variable label value"'
	if !missing("`sctodb'") {
		local meta `"`meta' scto_link"'
	}
	
	* add user-specified keep vars to output list
    local keeprows : subinstr local keepvars ";" "", all
    local keeprows : subinstr local keeprows "." "", all

    local uniquekeepvars : list uniq keeprows
    local uniqueidvars: list uniq uniquevars
    local keeplist : list admin | uniqueidvars
    local keeplist : list keeplist | meta
    local keeplist : list keeplist | uniquekeepvars

	
    * define locals
	local ndups1 = 0
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

	* keep only subset of data relevant to command
	keep if `touse'

	* initialize temporary output file
	poke `tmp', var(`keeplist')

	forval x = 1 / `checksneeded' {

		* tag duplicates of id variable 
		duplicates tag `varlist`x'', gen(`dup1')

		* sort data set
		if "`varlist`x''" != "" {
			sort `varlist`x''
		}
		
		* if there are any duplicates
		cap assert `dup1' == 0 
		if _rc {

			* count the duplicates for id var
			count if `dup1' != 0
			local ndups1 = `r(N)'

			* alert the user
			loc length : word count "`varlist`x'"
			if `length' == 1 {
				nois di "  Variable `varlist`x'' has `ndups1' duplicate observations."
			}
			else {
				nois di "  The variable combination `varlist`x'' has `ndups1' duplicate observations"
			}
			
			* update values of meta data variables 
			replace value = ""
			replace variable = "`varlist`x''"
			
			loc n = 0
			foreach var in `varlist`x'' {
				loc ++n
				local varl : variable label `var'
				replace label = "`varl'" if label == ""
				cap confirm numeric variable `var' 
				if !_rc {
					replace value = value + " " + string(`var')
				}
				else {
					replace value = value + " " + `var'
				}
			}
			replace value = strtrim(value) // removes extra spaces

				* append violations to the temporary data set
				saveappend using "`tmp'" if `dup1' != 0, ///
					keep("`keeplist'")
		}
		else {
			* alert the user
			nois di "  No duplicates found for ID variable `var'."
		}
		drop `dup1'
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
	
	bysort value (variable `enumerator') : gen `lines' = _n
	egen `bot' = max(`lines'), by(value)
	gen `bottom' = cond(`bot' == `lines', 1, 0)
	
	loc colorcols
	foreach var in variable label value {
		loc pos : list posof "`var'" in keeplist
		loc colorcols `colorcols' `pos'
	}
	
	* export compiled list to excel
	export excel `keeplist' using "`saving'" ,  ///
		sheet("2. duplicates") `sheetreplace' `sheetmodify' ///
		firstrow(variables) `nolabel'

	unab keeplist : `keeplist'		
	mata: basic_formatting("`saving'", "2. duplicates", tokens("`keeplist'"), tokens("`colorcols'"), `=_N')	
		
	*export scto links as links
	if !missing("`sctodb'") {
		unab allvars : _all
		local pos : list posof "scto_link" in allvars
		mata: add_scto_link("`saving'", "2. duplicates", "scto_link", `pos')
	}
	
	* revert to original
	use "`org'", clear
	}
	
	return scalar ndups1 = `ndups1'
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

	b.set_column_width(i, i, column_widths[i] + 2)
}
for (i=1; i<=rows(bottomrows); i++) {
	b.set_bottom_border(bottomrows[i]+1, (1, ncol), "thin")
	if (length(colors) > 1) {
	for (k=1; k<=length(colors); k++) {
	b.set_font(bottomrows[i]+2, strtoreal(colors[k]), "Calibri", 11, "black")
	}
	}
}




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

