*! version 3.0.0 Innovations for Poverty Action 22oct2018

program ipacheckfollowup, rclass
	/*  This program checks the values of id variables in memory against 
	    a master tracking list from a prior survey or census. */
	version 14.1

	#d ;
	syntax varlist using/, 
		/* output filename */
	    saving(string) 
	    /* output options */
        id(varname) ENUMerator(varname) SUBMITted(varname) 
		[KEEPVars(string) KEEPMaster(string) SCTOdb(string)] 
		/* other options */
		[SHEETMODify SHEETREPlace NOLabel];	
	#d cr

	* test for fatal conditions
	cap which cfout
	if _rc {
		di as err "SSC package {cmd:cfout} required"
		di as err "to install, type {cmd:ssc install cfout}"
		ex 198
	}

	di ""
	di "HFC 5 => Checking that follow up variables match master tracking sheet..."

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
	local meta `"variable label current_value tracking_value"'

	* add user-specified keep vars to output list
    local lines : subinstr local keepvars ";" "", all
    local lines : subinstr local lines "." "", all

    local unique : list uniq lines
    local keeplist : list admin | unique

	if !missing("`sctodb'") {
		local keeplist `"`keeplist' scto_link"'
	}
	local master "`using'"

	* initialize meta data variables
	foreach var in `meta' {
		g `var' = ""
	}
	if !missing("`sctodb'") g scto_link = ""
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

    /* Check that a survey matches other records for its unique ID.
	   Example: For each ID, check that the name in the baseline data matches
	   the one in the master tracking list. */

	cfout `varlist' using "`master'", ///
	    id(`id') ///
	    saving(`tmp', ///
	    	variable("variable") ///
	    	masterval("current_value") ///
			usingval("tracking_value") ///
			keepmaster("`keeplist'") ///
			keepusing(`keepmaster') ///
			properties(varlabel("label")) ///
			replace ) ///
		lower nopunct  

	* record returned values
	local ncomp = `r(N)'
	local ndiscrep = `r(discrep)'
	local nonlym = `r(Nonlym)'
	local nonlyu = `r(Nonlyu)'

	* import compiled list of violations
	use "`tmp'", clear

*	replace message = "Current value does not match master."
	* if there are no violations
	if `=_N' == 0 {
		set obs 1
		*replace message = ""
	} 

	loc all `keeplist' `meta' `keepmaster'
	order `keeplist' `meta' `keepmaster'
    gsort -`submitted', gen(order)

	format `submitted' %tc
	tempvar bot bottom lines

	bysort `enumerator' (variable order): gen `lines' = _n
	egen `bot' = max(`lines'), by(`enumerator')
	gen `bottom' = cond(`bot' == `lines', 1, 0)
	
		loc colorcols
	foreach var in `enumerator' {
		loc pos : list posof "`var'" in all
		loc colorcols `colorcols' `pos'
	}
	* export compiled list to excel
	export excel `all' using "`saving'" ,  ///
		sheet("5. follow up") `sheetreplace' `sheetmodify' ///
		firstrow(variables) `nolabel'

		unab keeplist : `keeplist'
		mata: basic_formatting("`saving'", "5. follow up", tokens("`all'"), tokens("`colorcols'"), `=_N')	

	*export scto links as links
	if !missing("`sctodb'") {
		unab allvars : _all
		local pos : list posof "scto_link" in allvars
		mata: add_scto_link("`saving'", "5. follow up", "scto_link", `pos')
	}	
	
	* revert to original
	use "`org'", clear
	}
	
	* display check statistics to output screen
	di "  Compared master and using on `ncomp' values."
	di "  Found `ndiscrep' discrepancies."
	di "  Found `nonlym' ids only in current data set."
	di "  Found `nonlyu' ids only in the master tracking sheet."
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

