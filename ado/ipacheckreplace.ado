
pr ipacheckreplace, rclass

syntax using, ///
	id(varlist) variable(varname) value(varname) [import(string)] /// options required for readreplace
	survey(string) // option to import survey
	
preserve

di "appending replacements to survey"
*check for fatal conditions
if !missing("`import'") {
	cap assert inlist("`import'", "insheet", "use", "excel")
	if _rc {
		di as err "option 'import' incorrectly specified"
		error 198
	}
}

*initiate temporary variables
tempfile correction_nomvars correction_mvars
	
******** Import excel survey spreadsheet ********
import excel using "`survey'", sheet("choices") firstrow clear	
keep name type
keep if regexm(type, "select_multiple")
levelsof name
local select_mult_vars `r(levels)'

******* Import corrections sheet *********
if "`import'" == "use" {
	use "`using'", clear
}
else if "`import'" == "excel" {
	import excel using "`using'", firstrow clear
}
else {
	import delimited using "`using'", clear
}

save `correction_mvars'

foreach mult_var in `select_mult_vars' {
	drop if `variable' == `mult_var'
}
save `correction_nomvars'

