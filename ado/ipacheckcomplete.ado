*! version 3.0.0 Innovations for Poverty Action 22oct2018

program ipacheckcomplete, rclass
	/* Check that all interviews were completed. 

	   IPA best practice is generally to include a question at
	   the end of a survey that asks the enumerator to document 
	   the completness of the interview. This command checks that 
	   all survey values of the completeness variable are equal
	   to the "completed" option. Incomplete surveys are listed 
	   in the output.
	   
	   Optionally, users can also specify a minimum nonmissing 
	   response threshold and this check will output the surveys
	   that have fewer nonmissing responses than the minimum. */
	version 14.1

	#d ;
	syntax varlist, 
		/* completeness options */
	    COMPlete(numlist) [Percent(real 0)]
		/* output filename */
	    saving(string) 
	    /* output options */
        id(varname) ENUMerator(varname) SUBMITted(varname) 
		[KEEPvars(string) SCTOdb(string)] 

		/* other options */
		[SHEETMODify SHEETREPlace NOLabel];	
	#d cr

	* test for fatal conditions
	if `percent' != 0 {
		cap assert `percent' > 0 & `percent' <= 100
		if _rc {
			di as err "percent value must be between 0 and 100."
			error 198
		} 
	}

	* display header text
	di ""
	di "HFC 1 => Checking that all interviews are complete..."

	qui {

	* count nvars
	unab vars : _all
	local nvars : word count `vars'

	* define temporary files 
	tempfile tmp org
	save "`org'"

	* define temporary variable
	tempvar comp nonmiss
	g `comp' = .

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
	local nincomplete = 0
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

	* loop through varlist and capture the number of incomplete surveys 
	foreach var in `varlist' {
		local val : word `i' of `complete'

		* check if there are any violations
		cap assert `var' == `val'
		if _rc {
			* create temp marker variable
			replace `comp' = `var' == `val'

			* count the incomplete
			count if `comp' == 0
			local num = `r(N)'

			local varl : variable label `var'

			* update values for additional variables
			replace variable = "`var'"
			replace label = "`varl'"
			replace value = string(`var') if `comp' == 0
			replace message = "Interview is marked as incomplete."

			* append violations to the temporary data set
			saveappend using "`tmp'" if `comp' == 0, ///
			    keep("`keeplist'") sort(`id')
		}
		else {
			* if all complete, set the number of incomplete to zero
			local num = 0
		}
		* update the total number of incomplete 
		local nincomplete = `nincomplete' + `num'
		local i = `i' + 1
	}

	
	if `percent' > 0 {
		* check nonmissing percentage
		egen `nonmiss' = rownonmiss(`vars'), strok
		replace `nonmiss' = `nonmiss'/`nvars'

		* update values for additional variables
		replace variable = ""
		replace label = ""
		replace value = ""
		replace message = "Interview is " + string(`nonmiss'*100, "%2.0f") + ///
		    "% complete (max is " + string(`percent', "%2.0f") + "%)."

		* store number of violations in local 
		count if `nonmiss' < `percent' / 100
		local nonmissviol = `r(N)'	
		
		* append violation list to output file
		saveappend using "`tmp'" if `nonmiss' < `percent' / 100 , ///
		    keep("`keeplist'")
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
	
	bysort `enumerator' (order) : gen `lines' = _n
	egen `bot' = max(`lines'), by(`enumerator')
	gen `bottom' = cond(`bot' == `lines', 1, 0)
	
	loc colorcols
	foreach var in `enumerator' variable label  {
		loc pos : list posof "`var'" in keeplist
		loc colorcols `colorcols' `pos'
	}

	* export compiled list to excel
	export excel `keeplist' using "`saving'" ,  ///
		sheet("1. incomplete") `sheetreplace' `sheetmodify' ///
		firstrow(variables) `nolabel' 
	
	unab keeplist : `keeplist'	
	mata: basic_formatting("`saving'", "1. incomplete", tokens("`keeplist'"), tokens("`colorcols'"), `=_N')	
		
	*export scto links as links
	if !missing("`sctodb'") {
		unab allvars : _all
		local pos : list posof "scto_link" in allvars
		mata: add_scto_link("`saving'", "1. incomplete", "scto_link", `pos')
	}
	* revert to original
	use "`org'", clear
	}

	* display stats and return 
	di "  Found `nincomplete' total incomplete interviews."
	return scalar nincomplete = `nincomplete'
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

	b.set_column_width(i, i, column_widths[i] + 2)
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

