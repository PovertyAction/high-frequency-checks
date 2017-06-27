*! version 1.0.1 Christopher Boyer 27jun2017

program ipadoheader , rclass
	 * note this file is adapted from Kristoffer Bjärkefur's fantastic ieboilstart program

	di ""
	qui {

	syntax ,  Version(string) [noclear maxvar(numlist) matsize(numlist)]
		
	version 10.0
	version `version'
	
	/*-------------
	  Check version 
	  -------------*/			
	
	if "`maxvar'" != "" & "`noclear'" != "" {
	
		di as error "{phang}It is not possible to set maximum numbers of variables allowed without clearing the data. noclear and maxvar() can therefore not be specified at the same time{p_end}"
		error 198
	}
			
	local stata_versions "10.0 10.1 11.0 11.1 11.2 12.0 12.1 13.0 13.1 14.0 14.1 14.2 15.0"
	
	if `:list version in stata_versions' == 0 {

		di as error "{phang}Only relatively recent major releases are allowed. One decimal must always be included. The releases currently allowed are:{break}`stata_versions'{p_end}"
		error 198
		exit
	}
	
	
	/*	Check input for maxvar and matsize if specified, other wise set 
		maximum value allowed. */			
	
	local stata_types ic se mp
	foreach maxlocal in maxvar matsize {
		
		if "`maxlocal'" == "maxvar" {
			if c(MP) == 1 | c(SE) == 1 {
				local max 32767
				local min 2048
			}
			else {
				local max 2047
				local min 2047	
			}
		}
		
		if "`maxlocal'" == "matsize" {
			if c(MP) == 1 | c(SE) == 1 {
				local max 11000
				local min 10
			}
			else {
				local max 800
				local min 10	
			}				
		}
		
		if c(MP) == 1 | c(SE) == 1 {
			local vusing "Stata SE and Stata MP"
		}
		else {
			local vusing "Stata IC"
		}		
		
		
		// Test if user set maxvar
		if "``maxlocal''" != "" {
		
			if ``maxlocal'' >= `min' & ``maxlocal'' <= `max' {
			di 2.1
				
				local `maxlocal'_di "`maxlocal' is set to ``maxlocal''. "
				local `maxlocal' ``maxlocal''
			}
			else {
				
				di as error "{phang}`maxlocal' must be between `min' and `max' (inclusive) if you are using `vusing'. You entered ``maxlocal''.{p_end}"
				if ``maxlocal'' < `min' {
					error 910
				}
				else {
					error 912
				}
				exit
			}
		}
		else {
			
			local `maxlocal'_di "`maxlocal' is by default set to `max' which is the maximum value for `vusing'. "
		
			*User did not specify value, use max value allowed
			local `maxlocal' `max'
		}
	}

	/*--------------------
	  Execute all settings 
	  --------------------*/			
	
	// set verison number 
	
	// set basic memory limits
	if "`noclear'" == "" {
		clear all
		set maxvar 	`maxvar'
	} 
	else {
		local maxvar_di ""
	}
	set matsize 	`matsize'
	
	// set advanced memory limits
	set niceness	5
	set min_memory	0
	set max_memory	.
	
	if c(bit) == 64 { 
		set segmentsize	32m
	}
	else {
		set segmentsize	16m
	}
	
	
	// set default options
	set more 		off
	pause 			on
	set varabbrev 	off
	
	return local ipaversion "`version'"

	noi di "{phang}You have set this do-file to run version `version' of Stata. `maxvar_di'`matsize_di'Click {stata query memory:query memory} for more details"
}

end
