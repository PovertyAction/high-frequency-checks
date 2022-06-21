*! version 4.0.0 Innovations for Poverty Action 30mar2022

/* =============================================================================
   =================== IPA BACK CHECK COMPARISON TEMPLATE ====================== 
   ============================================================================= */
   
   *========================= Import Prepped Dataset ==========================* 

	use "${preppedbc}", clear
   
   *======================== Resolve Survey Duplicates =========================* 
   
	if $run_corrections {
		ipacheckcorrections using "${corrfile}",		///
			sheet("${cr_dupsheetbc}")					///
			id(${key}) 									///
			logfile("${corrlog_output}")				///
			logsheet("${cr_dupslogsheetbc}")			///
			${cr_nolabel}								///
			${cr_ignore}
			
			save "${checkedbc}", replace
	}
	
   *========================== Find Survey Duplicates ==========================* 
   
   if $run_ids {
	   ipacheckids ${id},								///
				enumerator(${bcer}) 					///	
				date(${date})	 						///
				key(${key}) 							///
				outfile("${hfc_output}") 				///
				outsheet("BC id duplicates")			///
				keep(${id_keepvars})	 				///
				dupfile("${id_dups_output}")			///
				save("${checkedbc}")					///
				${id_nolabel}							///
				force									///
				sheetreplace
				
		use "${checkedbc}", clear
		
   }
   else {
		isid ${id}
		save "${checkedbc}", replace
   }
   
   *======================= Track Back Check Progress =========================* 

   if $run_tracksurvey {
       ipatracksurvey,									///
			surveydata("$checkedbc")					///
			id(${id})									///
			date(${date})								///
			by(${bs_tr_by})								///
			outcome(${bs_tr_outcome})					///
			target(${bs_tr_target})						///
			masterdata("${masterbc}")					///
			masterid(${bs_tr_masterid})					///
			trackingdata("${trackingsurvey}")			///
			keepmaster(${bs_tr_keepmaster})				///
			keeptracking(${bs_tr_keeptracking})			///
			keepsurvey(${bs_tr_keepsurvey})				///
			outfile("${trackingbc_output}")				///
			save("${bs_tr_save}")						///
			${bs_tr_nolabel} 							///
			${bs_tr_summaryonly}						///
			${bs_tr_workbooks} 							///
			${bs_tr_surveyok}							///
			replace
   }
   
	*========================= Back Check Comparison ==========================* 
	
	if $run_bc {
		ipabcstats,						 				///
			t1vars("${bs_t1vars}")						///
			t2vars("${bs_t2vars}")						///
			t3vars("${bs_t3vars}")						///
			ttest("${bs_ttest}")						///
			prtest("${bs_prtest}")						///
			signrank("${bs_signrank}")					///
			reliability("${bs_reliability}")			///
			surveydata("${checkedsurvey}") 				///
			bcdata("${checkedbc}")						///
			id(${id})									///
			enumerator(${enum})							///
			enumteam(${team})							///
			backchecker(${bcer})						///
			bcteam(${bcerteam})							///
			filename("${bc_output}")					///								
			surveydate(${starttime})					///
			bcdate(${starttime})						///
			showid(${bs_showid})						///
			level(${bs_level})							///
			${bc_full}									///
			${bc_nolabel}								///
			replace
	}