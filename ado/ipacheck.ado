*! version 3.0.0 Innovations for Poverty Action 22oct2018

program ipacheck, rclass
	/* This is a utility function to help update the ipacheck package
	   and initialize new projects. */
	version 13
	gettoken cmd 0 : 0, parse(" ,")
	syntax [anything], [surveys(string)] [folder(string)] [SUBFOLDERS] [files] [exercise]

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
		ipachecknew, surveys(`surveys') folder(`folder') `subfolders' `files' `exercise'
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
	    ipacheckids         ///
	    ipacheckimport      ///
	    ipachecknomiss      ///
	    ipacheckoutliers    ///
	    ipacheckresearch    ///
	    ipachecklogic       ///
	    ipacheckspecify     ///
	    ipadoheader         ///
	    ipatracksummary     ///
	    progreport          ///     
	    ipatrackversions           

	foreach prg in `programs' {
		cap which `prg'
		if !_rc {
			local path = c(sysdir_plus)
			if substr("`prg'", 1, 1) == "i" {
			mata: get_version("`path'i/`prg'.ado")
			}
			else mata: get_version("`path'p/`prg'.ado")
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
	syntax, [surveys(string)] [folder(string)] [SUBfolders] [files] [exercise]
	
	// Set up URL
	loc git "https://raw.githubusercontent.com/PovertyAction"
	loc git_hfc "`git'/high-frequency-checks"
	loc git_readme "https://raw.githubusercontent.com/PovertyAction/New_HFCs-Readmes"
	loc branch master	
	
	
	////////////////////
	// ERROR MESSAGES
	////////////////////
	if "`folder'" == "" {
		loc folder `c(pwd)'
	}
	if `:word count `surveys'' == 1 & "`subfolders'" != "" {
		noi disp as err "Option for subfolders is not allowed with only one survey form"
		exit 101
	}
	if "`surveys'" == "" &  "`subfolders'" != "" {
		noi disp as err "Option for subfolders is not allowed without specifying the surveys option"
		exit 101 
	}
	
	if "`files'" == "files" & "`surveys'" != "" {
		noi disp as err "Option for files can only be used with the folders option"
		exit 101 	
	}
	
	if "`exercise'" == "exercise" & "`surveys'" != "" {
		noi disp as error "Option for exercise can only be used with the folders option"
		exit 101
	}
	
	////////////////////
	// SET UP FOLDER
	////////////////////
	{
		// Seting up main structure
		#d;
		loc folders 
			""00_archive"
			"01_instruments"
				"01_instruments/01_paper"
				"01_instruments/02_print"
				"01_instruments/03_xls"
			"02_dofiles"
			"03_tracking"
				"03_tracking/01_inputs"
				"03_tracking/02_outputs"
			"04_checks"
				"04_checks/01_inputs"
				"04_checks/02_outputs"	
			"05_data"
				"05_data/01_preloads"
				"05_data/02_survey"
				"05_data/03_bc"
				"05_data/04_monitoring"
			"06_media"
			"07_documentation"
			"08_field_manager""
			;
		#d cr
		
		if "`files'" == "files" {
	
		// HFC input file
		di "Saving HFC input file"
		cap confirm file "`folder'/hfc_inputs.xlsm"
		if !_rc {
			
			noi disp "{red:Skipped}: hfc_inputs.xlsm already exists"
			} 
		else {
			loc output "`folder'/hfc_inputs.xlsm"
			copy "`git_hfc'/`branch'/xlsx/hfc_inputs.xlsm" "`output'", replace
		}
		
		// HFC replacements file
		di "Saving HFC replacements file"
		
		cap confirm file "`folder'/hfc_replacements.xlsm"
		if !_rc {

			noi disp "{red:Skipped}: hfc_replacements.xlsm already exists"
			} 
		else {
		
		loc output "`folder'/hfc_replacements.xlsm"
		copy "`git_hfc'/`branch'/xlsx/hfc_replacements.xlsm" "`output'", replace
		}
		// HFC master do file
		di "Saving master do file"
		cap confirm file "`folder'/master_check.do"
		if !_rc {
			
			noi disp "{red:Skipped}: master_check.do already exists"
			} 
		else {
		
		loc output "`folder'/master_check.do"
		copy "`git_hfc'/`branch'/master_check.do" "`output'", replace
		}
		exit
	}

		
		
		// Create folders in local directory 
		noi disp
		noi disp "Setting up folders ..."
		noi disp

		foreach f in `folders' {
			* Check that folder already exist
			cap confirm file "`folder'/`f'/nul"
			* If folder exist, return message that folder already exist, else create folder
			if !_rc {
				noi disp "{red:Skipped}: Folder `f' already exists"
			}
			* else create folder
			else {
				mkdir "`folder'/`f'"
				noi disp "Successful: Folder `f' created"
			}
		}
		
		
		// Additional folders if multiple surveys
		
		if `:word count `surveys'' > 1 & "`subfolders'" != "" {
			di
			di "Creating folders for multiple forms..."
			di
				
			// List with folders where subfolders will be created
			#d;
			loc folders_add 
				""04_checks/01_inputs" 
				"05_data/02_survey""
			;
			#d cr
			
			// Create list of new folders for each form
			loc new_list
			forvalues f=1/`:word count `folders_add'' {
				loc set "`:word `f' of `folders_add''"
				forvalues n=1/`:word count `surveys'' {
					loc form "`:word `n' of `surveys''"
					loc fol "`set'/`n'_`form'"
					loc new_list `new_list' `fol'
				}
			}
			
			// Create new folders
			foreach f in `new_list' {
				* Check that folder already exist
				cap confirm file "`folder'/`f'/nul"
				* If folder exist, return message that folder already exist, else create folder
				if !_rc {
					noi disp "{red:Skipped}: Folder `f' already exists"
				}
				* else create folder
				else {
					mkdir "`folder'/`f'"
					noi disp "Successful: Folder `f' created"
				}
			}
		}
	
	}
	
	////////////////////
	// README FILES
	////////////////////
	{
		noi di
		noi di "Saving readme files..."
		noi di
		// List of main folders and names for read me files
		loc folders_main ""00_archive" "01_instruments" "02_dofiles" "03_tracking" "04_checks" "05_data" "06_media" "07_documentation" "08_field_manager""
		loc folders_names archive instruments dofiles tracking checks data media documentation field_manager
		assert `:word count `folders_main'' == `:word count `folders_names''
		
		// Saving read me content in locals
		
		// Looping thorugh main folders to save readme files in each
		forvalues i=1/`:word count `folders_names'' {
			loc fol = "`:word `i' of `folders_main''"
			loc name = "`:word `i' of `folders_names''"
			loc output "`folder'/`fol'/`fol'_readme.txt"
			cap confirm file "`output'"
			if !_rc {
				noi disp "{red:Skipped}: `fol'_readme.txt already exists"

			}
			else {
			di "Saving readme for `fol'"

			copy "`git_readme'/master/`fol'_readme.txt" "`output'", replace
			}
		}
	}
	

	////////////////////
	// SAVE FILES
	////////////////////
	{
		di
		di "Populating folder..."
		di
		// Locals for file locations
		loc hfc_input_loc "04_checks/01_inputs"
		loc hfc_enum_loc "04_checks/01_inputs"
		loc hfc_replace_loc "04_checks/01_inputs"
		loc hfc_master_loc "02_dofiles"
		
		// Single form
		if (`:word count `surveys'' == 1) | (`:word count `surveys'' == 0) {	

			loc subfolders `" 04_checks/01_inputs 04_checks/01_inputs 02_dofiles "'
			loc ex_folders `" 04_checks/01_inputs 04_checks/01_inputs 05_data/02_survey 05_data/01_preloads 05_data/03_bc 06_media "'

			
			loc outputs `" hfc_inputs.xlsm hfc_replacements.xlsm master_check.do "'
			loc ex_outputs `" hfc_inputs_ANSWERS.xlsm hfc_replacements_ANSWERS.xlsm survey_data.dta sample.dta bc_survey_data.dta survey_media.zip exercise_instructions.pdf "'

			
			if "`exercise'" == "exercise" {
				loc subfolders `subfolders' `ex_folders'
				loc outputs `outputs' `ex_outputs'
			}
			
			forval i = 1/`:word count `outputs'' {
			loc subfolder "`: word `i' of `subfolders''"
			loc output "`: word `i' of `outputs''"

			if "`output'" == "hfc_inputs.xlsm" | "`output'" == "hfc_replacements.xlsm" | "`output'" == "master_check.do" | "`output'" == "exercise_instructions.pdf" {
				loc gitfolder "xlsx"
				if "`output'" == "master_check.do" | {
					loc gitfolder ""
				}
				if "`output'" == "exercise_instructions.pdf" {
					loc subfolder ""
					loc gitfolder "exercise"
				}
			}
			
			else loc gitfolder "exercise"
	
			cap confirm file "`folder'/`subfolder'/`output'"
			if !_rc {
				noi disp "{red:Skipped}: `output' already exists"
			}
			* else create folder
			else {
				copy "`git_hfc'/`branch'/`gitfolder'/`output'" "`folder'/`subfolder'/`output'"
				di "`output' saved"

		}
		
			}
			
		
		}
		
		// Multiple forms with subfolders
		if `:word count `surveys'' > 1 & "`subfolders'" != "" {
		
			//foreach form in `surveys' {
			forvalues n=1/`:word count `surveys'' {
			loc form "`:word `n' of `surveys''"
				// HFC input file
				di "Saving HFC input file - `form'"
				loc output "`folder'//`hfc_input_loc'//`n'_`form'/hfc_inputs_`form'.xlsm"
				cap confirm file "`output'"
				if !_rc {
					noi disp "{red:Skipped}: `output' already exists"
				}
				else {
					copy "`git_hfc'/`branch'/xlsx/hfc_inputs.xlsm" "`output'", replace
					dis "`output' saved"
				}
				
				// HFC replacements file
				di "Saving HFC replacements file - `form'"
				loc output "`folder'//`hfc_replace_loc'//`n'_`form'/hfc_replacements_`form'.xlsm"
				cap confirm file "`output'"
				if !_rc {
					noi disp "{red:Skipped}: `output' already exists"
				}
				else {
					copy "`git_hfc'/`branch'/xlsx/hfc_replacements.xlsm" "`output'", replace
					dis "`output' saved"
				}
				
				// HFC master do file
				di "Saving master do file - `form'"
				loc output "`folder'//`hfc_master_loc'/master_check_`form'.do"
				cap confirm file "`output'"
				if !_rc {
					noi disp "{red:Skipped}: `output' already exists"
				}
				else {
					copy "`git_hfc'/`branch'/master_check.do" "`output'", replace
					dis "`output' saved"
			}
			
			}	
		}
		
		// Multiple forms without subfolders
		if `:word count `surveys'' > 1 & "`subfolders'" == "" {
		
			foreach form in `surveys' {
				// HFC input file
				di "Saving HFC input file - `form'"
				loc output "`folder'//`hfc_input_loc'//hfc_inputs_`form'.xlsm"
				cap confirm file "`output'"
				if !_rc {
					noi disp "{red:Skipped}: `output' already exists"
				}
				else {
					copy "`git_hfc'/`branch'/xlsx/hfc_inputs.xlsm" "`output'", replace
					dis "`output' saved"
				}
				// HFC replacements file
				di "Saving HFC replacements file - `form'"
				loc output "`folder'//`hfc_replace_loc'//hfc_replacements_`form'.xlsm"
				cap confirm file "`output'"
				if !_rc {
					noi disp "{red:Skipped}: `output' already exists"
				}
				else {
					copy "`git_hfc'/`branch'/xlsx/hfc_replacements.xlsm" "`output'", replace
					dis "`output' saved"
				}
				
				// HFC master do file
				di "Saving master do file - `form'"
				loc output "`folder'//`hfc_master_loc'/master_check_`form'.do"
				cap confirm file "`output'"
				if !_rc {
					noi disp "{red:Skipped}: `output' already exists"
				}
				else {
					copy "`git_hfc'/`branch'/master_check.do" "`output'", replace
					dis "`output' saved"
				}
			}
		}	
	}
	
end





