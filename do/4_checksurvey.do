*! version 4.0.0 Innovations for Poverty Action 30mar2022

/* =============================================================================
   =================== IPA HIGH FREQUENCY CHECK TEMPLATE ======================= 
   ============================================================================= */
   
   *====================== Remove existing excel files ========================* 
   
	foreach file in hfc corrlog id_dups textaudit surveydb enumdb timeuse tracking bc {
		cap confirm file "${`file'_output}"
		if !_rc {
			rm "${`file'_output}"
		}
	}
   
   *========================= Import Prepped Dataset ==========================* 

	use "${preppedsurvey}", clear
   
   *======================== Resolve Survey Duplicates =========================* 
   
	if $run_corrections {
		ipacheckcorrections using "${corrfile}",		///
			sheet("${cr_dupsheet}")						///
			id(${key}) 									///
			logfile("${cr_output}")						///
			logsheet("${cr_dupsheet}")					///
			${cr_nolabel}								///
			${cr_ignore}
	}
	
   *========================== Find Survey Duplicates ==========================* 
   
   if $run_ids {
	   ipacheckids ${id},								///
				enumerator(${enum}) 					///	
				date(${date})	 						///
				key(${key}) 							///
				outfile("${hfc_output}") 				///
				outsheet("id duplicates")				///
				keep(${id_keepvars})	 				///
				dupfile("${id_dups_output}")			///
				save("${checkedsurvey}")				///
				${id_nolabel}							///
				force									///
				sheetreplace
				
		use "${checkedsurvey}", clear
		
   }
   else {
		isid ${id}
		save "${checkedsurvey}", replace
   }
   
   *========================== Other HFC Corrections ==========================* 
   
   if $run_corrections {		
		ipacheckcorrections using "${corrfile}", 		///
			sheet("${cr_othersheet}")					///
			id(${id}) 									///
			logfile("${cr_output}")						///
			logsheet("${cr_othersheet}")				///
			${cr_nolabel}
			
		save "${checkedsurvey}", replace
	}
   
    *========================== Recode other specify ==========================* 
   
   if $run_specifyrecode {		
		ipacheckspecifyrecode using "$recodefile",		///
			sheet("$rc_sheet")							///
			id($id)										///
			logfile("$rc_output")						///
			logsheet("$rc_logsheet")					///
			${rc_nolabel}
			
		save "${checkedsurvey}", replace
	}
  
    *============================= Form versions ===============================* 

   if $run_version {
		ipacheckversion ${formversion}, 				///
				enumerator(${enum}) 					///	
				date(${date})							///
				outfile("${hfc_output}") 				///
				outsheet1("form versions")				///
				outsheet2("outdated")					///
				keep(${vs_keepvars})					///
				sheetreplace							///
				$vs_nolabel
   }
   
   *========================== Variable Duplicates ============================* 
   
   if $run_dups {
	   ipacheckdups ${dp_vars},							///
				id(${id})								///
				enumerator(${enum}) 					///	
				date(${date})	 						///
				outfile("${hfc_output}") 				///
				outsheet("duplicates")					///
				keep(${dp_keepvars})	 				///
				${dp_nolabel}							///
				sheetreplace
   }
   
   *========================= Variable Missingness ============================* 
   
   if $run_missing {
		ipacheckmissing ${ms_vars}, 					///
			priority(${ms_pr_vars})						///
			outfile("${hfc_output}") 					///
			outsheet("missing")							///
			sheetreplace
   }
   
   *=============================== Outliers ==================================* 

   if $run_outliers {
		ipacheckoutliers using "${inputfile}",			///
			id(${id})									///
			enumerator(${enum}) 						///	
			date(${date})	 							///
			sheet("outliers")							///
        	outfile("${hfc_output}") 					///
			outsheet("outliers")						///
			${ol_nolabel}								///
			sheetreplace
   }
   
   *============================= Other Specify ===============================* 
   
   if $run_specify {
		ipacheckspecify using "${inputfile}",			///
			id(${id})									///
			enumerator(${enum})							///	
			date(${date})	 							///
			sheet("other specify")						///
        	outfile("${hfc_output}") 					///
			outsheet1("other specify")					///
			outsheet2("other specify (choices)")		///
			${os_nolabel}								///
			sheetreplace
   }
   
   return list
   
   *============================ field comments ================================*
   
    if $run_comments {

		ipasctocollate comments ${fieldcomments}, 		///
			folder("${media_folder}")					///
			save("${commentsdata}")						///
			replace
		
		ipacheckcomments ${fieldcomments},				///
			enumerator(${enum}) 						///	
			commentsdata("${commentsdata}")				///
        	outfile("${hfc_output}") 					///
			outsheet("field comments")					///
			keep(${cm_keepvars})						///
			${cm_nolabel}								///
			sheetreplace
   }
   
   *======================== text audit & time use ============================* 

   if $run_textaudit | $run_timeuse {
       ipasctocollate textaudit ${textaudit}, 			///
			folder("${media_folder}")					///
			save("${textauditdata}")					///
			replace
   }

   if $run_textaudit {
		ipachecktextaudit ${textaudit},					///
			enumerator(${enum}) 						///	
			textauditdata("${textauditdata}")			///
        	outfile("${textaudit_output}")				///
			stats("${ta_stats}")						///
			${ta_nolabel}								///
			sheetreplace
			
   }
   
   if $run_timeuse {
		ipachecktimeuse ${textaudit}, 					///
			enumerator(${enum})							///	
			starttime(${starttime})						///
			textauditdata("${textauditdata}")			///
        	outfile("${timeuse_output}")				///
			${tu_nolabel} 								///
			sheetreplace
   }
   
   *=========================== Survey Dashboard ==============================* 

   if $run_surveydb {
		ipachecksurveydb,			 					///
			by(${sv_by})								///
			enumerator(${enum}) 						///
			date(${date})								///
			period("${sv_period}")						///
			consent(${consent}, ${cons_vals})			///
			dontknow(.d, ${dk_str})						///
			refuse(.r, ${ref_str})						///
			otherspecify(`r(childvarlist)')				///
			duration(${duration})						///
			formversion(${formversion})					///
        	outfile("${surveydb_output}")				///
			${sv_nolabel}								///
			sheetreplace
   }
   
   *========================= Enumerator Dashboard ============================* 
  
   if $run_enumdb {
		ipacheckenumdb using "${inputfile}",			///
			sheetname("enumstats")						///		
			enumerator(${enum})							///
			team(${team})								///
			date(${date})								///
			period("${en_period}")						///
			consent($consent, ${cons_vals})				///
			dontknow(.d, ${dk_str})						///
			refuse(.r, ${ref_str})						///
			otherspecify(`r(childvarlist)')				///
			duration(${duration})						///
			formversion(${formversion})					///
        	outfile("${enumdb_output}")					///
			${en_nolabel}								///
			sheetreplace
   }
  
   
   *========================= Track Survey Progress ===========================* 

   if $run_tracksurvey {
       ipatracksurvey,									///
			surveydata("$checkedsurvey")				///
			id(${id})									///
			date(${date})								///
			by(${tr_by})								///
			outcome(${tr_outcome})						///
			target(${tr_target})						///
			masterdata("${mastersurvey}")				///
			masterid(${tr_masterid})					///
			trackingdata("${trackingsurvey}")			///
			keepmaster(${tr_keepmaster})				///
			keeptracking(${tr_keeptracking})			///
			keepsurvey(${tr_keepsurvey})				///
			outfile("${tracking_output}")				///
			save("${tr_save}")							///
			${tr_nolabel} 								///
			${tr_summaryonly}							///
			${tr_workbooks} 							///
			${tr_surveyok}								///
			replace
   }