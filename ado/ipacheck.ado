*! version 1.0.0 Christopher Boyer 04may2016

program ipacheck, rclass
	/* This is a utility function to help update the ipacheck package
	   and initialize new projects. */
	version 13

	gettoken cmd 0 : 0, parse(" ,")

	if `"`cmd'"'=="" {
		di as txt "ipacheck options are"
		di as txt "    {cmd:ipacheck version}"
		di as txt "    {cmd:ipacheck update} [{it: branch}]"
		di as txt "    {cmd:ipacheck new} [{it: filepath}]"
		exit 198
	}

	local l = length(`"`cmd'"')
	if `"`cmd'"' == substr("update", 1, max(1,`l')) {
		ipacheckupdate `0'
		exit
	}
	if `"`cmd'"' == substr("version", 1, max(1,`l')) {
		ipacheckversion `0'
		exit
	}
	if `"`cmd'"' == substr("new", 1, max(1,`l')) {
		ipachecknew `0'
		exit
	}
end

program define ipacheckupdate
	gettoken cmd 0 : 0, parse(" ,")

	local url = "https://raw.githubusercontent.com/PovertyAction/high-frequency-checks"

	if inlist(`"`cmd'"', "", "master") {
		local url = "`url'/master/ado"
	}
	else {
		local url = "`url'/`cmd'/ado"
	}

	net install ipacheck, replace from("`url'")
end

program define ipacheckversion
	local programs          ///
	    ipacheckallmiss     ///
	    ipacheckcomplete    ///
	    ipacheckconsent     ///
	    ipacheckconstraints ///
	    ipacheckdates       ///
	    ipacheckdups        ///
	    ipacheckenum        ///
	    ipacheckfollowup    ///
	    ipacheckimport      ///
	    ipachecknomiss      ///
	    ipacheckoutliers    ///
	    ipacheckresearch    ///
	    ipacheckskip        ///
	    ipacheckspecify     ///
	    ipadoheader         ///
	    ipatracksummary     ///
	    ipatracksurveys     ///     
	    ipatrackversions 	///
		ipachecktextaudit	

	foreach prg in `programs' {
		cap which `prg'
		if !_rc {
			local path = c(sysdir_plus)
			mata: get_version("`path'i/`prg'.ado")
		}
	}
end

mata: 
void get_version(string scalar program) {
	real scalar fh
	
    fh = fopen(program, "r")
    line = fget(fh)
    printf("  " + program + "\t\t%s\n", line) 
    fclose(fh)
}
end

program define ipachecknew
	gettoken path 0 : 0, parse(" ,")

	local url = "https://raw.githubusercontent.com/PovertyAction/high-frequency-checks/master/ado"

	if `"`path'"' != "" {
		cd `"`path'"'
	}

	net get ipacheck, from("`url'")
end

