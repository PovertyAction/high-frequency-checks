* Purpose: Install Stata source code files, for instance, an ado-file.


*********************************MODIFY THESE!**********************************

* The directory that contains the source code files to install
local dir "../ado/"

* Advanced: 1 to overwrite the source code file if it already exists and
* 0 otherwise; default is 0.
local replace 1
* Advanced: 0 to install in the PLUS system directory and 1 to install in the
* PERSONAL system directory; default is 0.
local personal 0


*********************************UNDER THE HOOD*********************************
*********************************DON'T BOTHER!**********************************

* Check `replace' and `personal'.
foreach loc in replace personal {
	if !inlist("``loc''", "0", "1") {
		di as err "{c 'g}`loc'' must be 0 or 1"
		ex 198
	}
}

* List of Stata file extensions
loc exts_source ado mlib mo
loc exts_help sthlp hlp ihlp dlg
loc exts : list exts_source | exts_help

* Define `sourcelist', the list of the names of the source code files to
* install.
if !`:length loc dir' ///
	loc dir .
foreach ext of loc exts {
	loc files : dir "`dir'" file "*.`ext'"
	loc files : subinstr loc files ".`ext'" "", all
	loc sourcelist : list sourcelist | files
}
loc sourcelist : list sort sourcelist
if !`:list sizeof sourcelist' qui {
	noi di as txt _n "No source code files found."
	ex
}

* Check `sourcelist'.
foreach source of loc sourcelist {
	if !regexm(substr("`source'", 1, 1), "^[a-zA-z_]") {
		di as err "`source' is an invalid name"
		ex 198
	}
}

* Create the system directory if necessary.
if !`personal' ///
	loc sysdir "`c(sysdir_plus)'"
else ///
	loc sysdir "`c(sysdir_personal)'"
mata:
sysdir = st_local("sysdir")
// "el" for "element"; "els" for "elements."
el = els = ""
while (sysdir != "") {
	pathsplit(sysdir, sysdir, el)
	els = `"""' + el + `"" "' + els
}
st_local("els", els)
end
foreach el of loc els {
	cap mkdir "`prevels'`el'"
	* "prevels" for "previous elements"
	loc prevels `prevels'`el'/
}

* Install the source code files of `sourcelist'.
foreach source of loc sourcelist {
	loc outdir "`sysdir'"
	if !`personal' {
		loc outdir "`outdir'`=substr("`source'", 1, 1)'/"
		cap mkdir "`outdir'"
	}

	loc copy 1
	if !`replace' {
		loc any 0
		loc i 0
		loc n_exts : list sizeof exts
		while !`any' & `++i' <= `n_exts' {
			loc ext : word `i' of `exts'
			loc file "`outdir'`source'.`ext'"
			cap conf f "`file'"
			if !_rc {
				loc any 1
				cap noi conf new f "`file'"
			}
		}
		loc copy = !`any'
	}

	if `copy' {
		loc any_source 0
		foreach ext of loc exts {
			loc orig "`dir'/`source'.`ext'"
			loc dest "`outdir'`source'.`ext'"
			cap erase "`dest'"
			cap conf f "`orig'"
			if !_rc {
				copy "`orig'" "`dest'"
				if `:list ext in exts_source' ///
					loc any_source 1
			}
		}

		di as txt "Installation of {cmd:`source'} complete" _c
		if !`any_source' ///
			di as txt " (help files only)" _c
		di "."
	}
}
