*! version 4.1.0 17oct2022
*! Innovations for Poverty Action
* ipacheck: Update ipacheck package and initialize new projects

program ipacheck, rclass
	
	version 17
	
	#d;
	syntax 	name(name=subcmd id="sub command"), 
			[SURVeys(string)] 
			[FOLDer(string)] 
			[SUBfolders] 
			[FILESonly] 
			[EXercise]
			[BRanch(name)]
			;
	#d cr

	qui {
		if !inlist("`subcmd'", "new", "version", "update") {
			disp as err "illegal ipacheck sub command. Sub commands are:"
			noi di as txt 	"{cmd:ipacheck new}"
			noi di as txt 	"{cmd:ipacheck update}"
			noi di as txt 	"{cmd:ipacheck version}"
			ex 198
		}
		if inlist("`subcmd'", "update", "version") {
			if "`surveys'" ~= "" {
				disp as error "subccommand `subcmd' and surveys options are mutually exclusive"
				ex 198
			}
			if "`folder'" ~= "" {
				disp as error "sub command `subcmd' and folder options are mutually exclusive"
				ex 198
			}
			if "`subfolders'" ~= "" {
				disp as error "sub command `subcmd' and subfolders options are mutually exclusive"
				ex 198
			}
			if "`filesonly'" ~= "" {
				disp as error "sub command `subcmd' and files options are mutually exclusive"
				ex 198
			}
			if "`exercise'" ~= "" {
				disp as error "sub command `subcmd' and exercise options are mutually exclusive"
				ex 198
			}
	 	}
		else if "`subcmd'" == "new" {
			if "`surveys'" == "" & "`subfolders'" ~= "" {
				disp as err "subfolders option & survey options must be specified together"
				ex 198
			}
			if "`exercise'" ~= "" {
				if "`subfolders'" ~= "" {
					disp as err "exercise and subfolders options are mutually exclusive"
					ex 198
				}
				if "`filesonly'" ~= "" {
					disp as err "exercise and filesonly options are mutually exclusive"
					ex 198
				}
			}
		}
		
		loc url 	= "https://raw.githubusercontent.com/PovertyAction/high-frequency-checks"

		if "`subcmd'" == "new" {
			noi ipacheck_new, surveys(`surveys') folder("`folder'") `subfolders' `filesonly' url("`url'") branch(`branch') `exercise'
			ex
		}
		else {
			noi ipacheck_`subcmd', branch(`branch') url(`url')
			ex
		}
	}
end

program define ipacheck_update
	
	syntax, [branch(name)] url(string)
	
	qui {
		loc branch 	= cond("`branch'" ~= "", "`branch'", "master")
		noi net install ipacheck, replace from("`url'/`branch'")
		qui do "`url'/`branch'/mlib/ipacheckmata.do"
		noi disp "Mata library lipadms installed"
		noi mata mata mlib index
	}
	
end

program define ipacheck_version
	
	qui {
		#d;
		local 	programs          
				ipacheckcorrections	
				ipacheckspecifyrecode
				ipacheckversions
				ipacheckids
				ipacheckdups
				ipacheckmissing
				ipacheckoutliers
				ipacheckconstraints
				ipacheckspecify
				ipacheckcomments
				ipachecktextaudit
				ipachecktimeuse
				ipachecksurveydb
				ipacheckenumdb
				ipatracksurvey
				ipacodebook
				ipasctocollate
				ipalabels
				ipagettd
				ipagetcal
				ipaanycount
				ipabcstats
			;
		#d cr

		cap frames drop frm_verdate
		frames create frm_verdate str32 (program version date)

		foreach prg in `programs' {
			cap which `prg'
			if !_rc {
				mata: get_version("`c(sysdir_plus)'i/`prg'.ado")
				di regexm("`verdate'", "[1-4]\.[0-9]+\.[0-9]+")
				loc vers_num 	= regexs(0)
				di regexm("`verdate'", "[0-9]+[a-zA-Z]+[0-9]+")
				loc vers_date 	= regexs(0)

				frames post frm_verdate ("`prg'") ("`vers_num'") ("`vers_date'")
			}
		}

		frames frm_verdate {
			compress
			sort program
			noi list, noobs h sep(0)
		}
	}
	
end

mata: 
void get_version(string scalar program) {
	real scalar fh
	
    fh = fopen(program, "r")
    line = fget(fh)
    st_local("verdate", line) 
    fclose(fh)
}
end

program define ipacheck_new
	
	syntax, [surveys(string)] [folder(string)] [SUBfolders] [filesonly] [exercise] [branch(name)] url(string)
	
	loc branch 	= cond("`branch'" ~= "", "`branch'", "master") 
	
	if "`folder'" == "" {
		loc folder "`c(pwd)'"
	}
	
	loc surveys_cnt = `:word count `surveys''
	
	if "`filesonly'" == "" {
		#d;
		loc folders 
			""0_archive"
			"1_instruments"
				"1_instruments/1_paper"
				"1_instruments/2_scto_print"
				"1_instruments/3_scto_xls"
			"2_dofiles"
			"3_checks"
				"3_checks/1_inputs"
				"3_checks/2_outputs"	
			"4_data"
				"4_data/1_preloads"
				"4_data/2_survey"
				"4_data/3_backcheck"
				"4_data/4_monitoring"
			"5_media"
				"5_media/1_audio"
				"5_media/2_images"
				"5_media/3_video"
			"6_documentation"
			"7_field_manager"
			"8_reports""
			;
		#d cr
		
		noi disp
		noi disp "Setting up folders ..."
		noi disp

		foreach f in `folders' {
			mata : st_numscalar("exists", direxists("`folder'/`f'"))
			if scalar(exists) == 1 {
				noi disp "{red:Skipped}: Folder `f' already exists"
			}
			else {
				mkdir "`folder'/`f'"
				noi disp "Successful: Folder `f' created"
			}
		}
		
		if "`subfolders'" == "subfolders" {
			
			#d;
			loc sfs
				""3_checks/1_inputs"
				"3_checks/2_outputs"
				"4_data/1_preloads"
				"4_data/2_survey"
				"4_data/3_backcheck"
				"4_data/4_monitoring"
				"5_media/1_audio"
				"5_media/2_images"
				"5_media/3_video""
				;
			#d cr
			
			noi disp
			noi disp "Creating subfolders ..."
			noi disp
			loc i 1
			
			foreach survey in `surveys' {
				loc sublab = "`i'_`survey'"
				foreach sf in `sfs' {
					mata : st_numscalar("exists", direxists("`folder'/`sf'/`sublab'"))
					if scalar(exists) == 1 {
						noi disp "{red:Skipped}: Sub-folder `sf' already exists"
					}
					else {
						mkdir "`folder'/`sf'/`sublab'"
						noi disp "Successful: Folder `sf'/`sublab' created"
					}
				}
				loc ++i
			}
		}
	}
	
	loc exp_dir "`folder'"
		
	noi disp
	noi disp "Copying files to `exp_dir' ..."
	noi disp
	
	cap confirm file "`exp_dir'/0_master.do"
	if _rc == 601 {
		copy "`url'/`branch'/do/0_master.do" "`exp_dir'/0_master.do"
		noi disp "0_master.do copied to `exp_dir'"
	}
	else {
		noi disp  "{red:Skipped}: File 0_master.do already exists"
	}
	
	if "`filesonly'" == "" 	loc exp_dir "`folder'/2_dofiles"
	else 					loc exp_dir "`folder'"
	
	foreach file in 1_globals 3_prepsurvey 4_checksurvey 5_prepbc 6_checkbc {
		if `surveys_cnt' > 0 {
			forval i = 1/`surveys_cnt' {
				loc exp_file = "`file'_" + word("`surveys'", `i')
				cap confirm file "`exp_dir'/`exp_file'.do"
				if _rc == 601 {
					copy "`url'/`branch'/do/`file'.do" "`exp_dir'/`exp_file'.do"
					noi disp "`exp_file'.do copied to `exp_dir'"
				}
				else {
					noi disp  "{red:Skipped}: File `file'.do already exists"
				}
			}
		}
		else {
			cap confirm file "`exp_dir'/`file'.do"
			if _rc == 601 {
				copy "`url'/`branch'/do/`file'.do" "`exp_dir'/`file'.do"
				noi disp "`file'.do copied to `exp_dir'"
			}
			else {
				noi disp  "{red:Skipped}: File `file'.do already exists"
			}
		}
	}
	
	if "`filesonly'" == "" 	loc exp_dir "`folder'/3_checks/1_inputs"
	else 					loc exp_dir "`folder'"
	
	noi disp
	noi disp "Copying files to `folder'/3_checks/1_inputs ..."
	noi disp
	
	foreach file in hfc_inputs corrections specifyrecode {
		if `surveys_cnt' > 0 {
			forval i = 1/`surveys_cnt' {
				loc exp_file = "`file'_" + word("`surveys'", `i')
				loc exp_dirmult  = cond("`subfolders'" == "", "`exp_dir'", "`exp_dir'/`i'_" + word("`surveys'", `i'))
				cap confirm file "`exp_dirmult'/`exp_file'.xlsm"
				if _rc == 601 {
					qui copy "`url'/`branch'/excel/templates/`file'.xlsm" "`exp_dirmult'/`exp_file'.xlsm"
					noi disp "`exp_file'.xlsm copied to `exp_dirmult'"
				}
				else {
					noi disp "{red:Skipped}: File `file' already exists"
				}
			}
		}
		else {
			cap confirm file "`exp_dir'/`file'.xlsm"
			if _rc == 601 {
				qui copy "`url'/`branch'/excel/templates/`file'.xlsm" "`exp_dir'/`file'.xlsm"
				noi disp "`file'.xlsm copied to `exp_dir'"
			}
			else {
				noi disp "{red:Skipped}: File `file' already exists"
			}
		}
	}

	if "`exercise'" ~= "" {
	
		* copy exercise files

		noi disp
		noi disp "Copying exercise files ..."
		noi disp

		foreach file in household_survey.dta household_backcheck.dta household_preloads.xlsx respondent_targets.xlsx {
			qui copy "`url'/`branch'/data/`file'" "`folder'/4_data/2_survey/`file'", replace
			noi disp "`file' copied to 4_data/2_survey/`file'"
		}
		
		qui copy "`url'/`branch'/data/household_backcheck.dta" "`folder'/4_data/3_backcheck/household_backcheck.dta", replace
		noi disp "household_backcheck.dta copied to 4_data/3_backcheck/household_backcheck.dta"

		foreach file in corrections hfc_inputs specifyrecode {
			qui copy "`url'/`branch'/excel/exercise/`file'_exercise.xlsm" "`folder'/0_archive/`file'_exercise.xlsm", replace
			noi disp "`file'_exercise.xlsm copied to 0_archive/`file'_exercise.xlsm"
		}
		
		qui copy "`url'/`branch'/excel/exercise/Household_Survey.xlsx" "`folder'/1_instruments/3_scto_xls/Household_Survey.xlsx", replace
		noi disp "Household_Survey.xlsx copied to 1_instruments/3_scto_xls/Household_Survey.xlsx"
		
		qui copy "`url'/`branch'/excel/exercise/Household_Back_Check_Survey.xlsx" "`folder'/1_instruments/3_scto_xls/Household_Back_Check_Survey.xlsx", replace
		noi disp "Household_Back_Check_Survey.xlsx copied to 1_instruments/3_scto_xls/Household_Back_Check_Survey.xlsx"

		noi disp
		noi disp "Unpacking text audit and comment files ..."
		noi disp

		mata: st_numscalar("exists", direxists("`folder'/4_data/2_survey/media"))
		if scalar(exists) == 1 {
			cd "`folder'/4_data/2_survey"
		}
		else {
			mkdir "`folder'/4_data/2_survey/media"
			cd "`folder'/4_data/2_survey"
		} 

		* unpack text audits and comment files
		unzipfile "`url'/`branch'/data/media.zip", replace

		cd "`folder'"

		noi disp
		noi disp "Unpacking audio audit files ..."
		noi disp

		cap frames drop frm_audio_audit
		frames create frm_audio_audit
		frames frm_audio_audit: use aud_audit using "`url'/`branch'/data/household_survey.dta"

		qui copy "`url'/`branch'/data/m4a_sample_on_&_on.m4a" "`c(tmpdir)'/audio_file_sample.m4a", replace
		
		frames frm_audio_audit {
			
			drop if missing(aud_audit)

			loc import_cnt `c(N)'
			
			noi _dots 0, title(Unpacking `import_cnt' audio audit files ...) reps(`import_cnt')
			
			forval i = 1/`import_cnt' {

				loc file = subinstr("`=aud_audit[`i']'", "media\", "", 1)
			
				qui copy 	"`c(tmpdir)'/audio_file_sample.m4a" "`folder'/4_data/2_survey/media/`file'", replace
				noi _dots `i' 0
			}

		}
	}

end
