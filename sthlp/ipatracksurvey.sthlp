{smcl}
{* *! version 4.0.0 Innovations for Poverty Action 11may2022}{...}
{title:Title}

{phang}
{cmd:ipatracksurvey} {hline 2}
Compares master/tracking data and survey datasets to create a progress report of 
survey completion rates. 

{title:Syntax}

{p 8 10 2}
{cmd:ipatracksurvey}{cmd:,}
{{opth m:asterdata(filename)} | {opth t:rackingdata(filename)}}
{opth date(varname)} 
{opth by(varname)}
replace   
[{it:{help ipatracksurvey##options:options}}]

{marker options}
{synoptset 30 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:* {opth m:asterdata(filename)}}master dataset{p_end}
{synopt:* {opth t:rackingdata(filename)}}survey tracking dataset{p_end}
{synopt:* {opth by(varname)}}stratify report by values in variable{p_end}
{synopt:* {opth outf:ile(filename)}}save output to Excel workbook{p_end}
{synopt:{opt replace}}replace existing Excel workbook{p_end}

{syntab:Specifications}
{synopt:{opth s:urveydata("surveydata.dta")}}survey data; default is to use data in memory{p_end}
{synopt:{opt outc:ome}{cmd:(}{help varname}{cmd:, }{help numlist}{cmd:)}}}survey outcome variable & values indicating survey completion{p_end}
{synopt:{opt save("filename.dta")}}dta dataset of survey tracking status per observation{p_end}
{synopt:{opt survey:ok}}allows observations that only appear in survey data.{p_end}
{synopt:{opt nol:abel}}export variable values instead of value labels{p_end}

{syntab:Additional Specifications for masterdata()}
{synopt:* {opth id(varname)}}ID variable from survey{p_end}
{synopt:{opth keeps:urvey(varlist)}}additional variables from surveydata to export to Excel worksheet{p_end}
{synopt:{opth keepm:aster(varlist)}}additional variables from masterdata to export to Excel worksheet{p_end}
{synopt:{opth masterid(varname)}}ID variable from master dataset if different from survey dataset ID variable name {p_end}
{synopt:{opt summary:only}}export summary sheet only{p_end}
{synopt:{opt workb:ooks}}creates workbooks of completion rates for each value of by(). If there are over 30 values of the by() variable, warning will suggest using this option.{p_end} 

{syntab:Additional Specifications for trackingdata()}
{synopt:{opth keept:racking(varlist)}}additional variables from trackingdata to export to Excel worksheet{p_end}
{synopt:{opt targ:et(varname)}}variable in trackingdata() survey targets{p_end}

{synoptline}
{p2colreset}{...}

{p 4 6 2}* {opt masterdata()} or {opt trackingdata()} is required.{p_end}
{p 4 6 2}* {opt id()} is required when using {opt masterdata()}.{p_end}
{p 4 6 2}* {opt id()} and {opt trackingdata()} are mutually exclusive.{p_end}
{p 4 6 2}* {opt by()} and {opt outfile()} are always required.{p_end}

{title:Description}

{pstd}
{cmd:ipatracksurvey} merges the master dataset and survey dataset to track the progress
of data collection and reports completion rates by the {cmd:by} variable.

{pstd}
The output for {cmd:ipatracksurvey} includes a summary sheet of completion rate 
by the {cmd:by()} variable. Optionally, the additional sheets for each value of 
the by variable can be included when using a {cmd:masterdata()}. 
This will include a status for each observation in the master dataset and a submission
date for those that have been interviewed. If specified, {cmd:ipatracksurvey()} can also 
create a dta dataset including the status of all observatios in the {cmd:masterdata()} 
and survey datasets.  

{title:Options}

{dlgtab:Main}

{pstd}
{opt masterdata(varname)} specifies the master dataset that contains the details 
of each respondent to be interviewed. This dataset must contain 1 observation for 
each targeted respondent and must be unique by {cmd:id()}). The {cmd:masterdata} must at minimum 
include {cmd:id()} or {cmd:masterid} and the {cmd:by()} variables. Although the 
{cmd:masterdata} may also include additional variables, these variables are not used 
unless specified in {cmd:keepmaster()}. 

{pstd}
{opt trackingdata(varname)} specifies the tracking dataset that contains the target 
number of respondent for each value in the variable specified with {cmd:by()}. 
This dataset must contain 1 observation for each value in {cmd:by()} and must be unique 
by the {cmd:by()} variable. The {cmd:trackingdata} must at minimum 
include the {cmd:by()} variable. Although the {cmd:trackingdata} may also include 
additional variables, these variables are not used unless specified in {cmd:keeptracking()}. 


{pstd}
{opt by(varname)} specifies that the report to should be stratified by the values 
of {cmd:varname}. When using {cmd:masterdata()}, {by()} is expected to be present 
for each observation in the {mastetdata()} and will therefore not be unique. However, 
the {cmd:by()} is expected to contain only unique values when using {cmd:trackingdata()}. 

{pstd}
{opt date(varname)} specifies the date or datetime variable indicating the date of 
survey. Recommended variables are Survey start, end or submission dates. This option 
expects a %td date variable or a %tc/%tC datetime variable. If variable specified 
is a datetime variable, the output will show the correspondent date instead of 
datetime. {cmd:date()} is required. 

{pstd}
{opt outfile("filename.xlsx")} specifies Excel workbook to export the report into. 
{cmd:outfile()} is required. Excel formats xls and xlsx are supported in {cmd:outfile()}. 
If a file extension is not specified with {cmd:outfile()}, .xls is assumed, because 
this format is more common and is compatible with more applications that also can read from Excel files.

{pstd}
{opt replace} replace existing Excel workbooks. This serves as a warning to the user 
that existing Excel workbooks will be replaced. 

{dlgtab:Specifications}

{pstd}
{opt surveydata(varname)} specifies the dataset to be used as the survey dataset. 
By default, {cmd:ipatracksurvey} will assume the dataset in memory as the survey 
dataset unless otherwise specified by this option. 

{pstd}
{opt outc:ome}{cmd:(}{help varname}{cmd:, }{help numlist}{cmd:)}}} specifies the 
variable and values in the survey dataset indicating completion of the interview . 
eg. {cmd:outcome(int_status, 1 2 3)} implies that responses 1, 2 and 3 in the 
int_status indicates a completed survey. 

{pstd}
{opt save("filename.dta")} specifies that a dta dataset of the outcome of each interview 
be saved. 

{pstd}
{opt surveyok} specifies that observations found in the survey data only should be allowed. 
The default is to show an error. 

{pstd}
{opt nolabel} nolabel exports the underlying numeric values instead of the value labels.

{dlgtab:Additional Specifications for masterdata()}

{pstd}
{opt id(varname)} specifies the id variable for the dataset. {cmd:id()} is required 
and the variable specified with {cmd:id()} must contain unique values only. 
The id variable is automatically included in the output.

{pstd}
{opth masterid(varname)} specifies that the output sheet should only be modified 
but not be replaced if it already exist.

{pstd}
{opth keepsurvey(varlist)} specifies additional variables from the {cmd:surveydata()} 
that should be included in output sheet.   

{pstd}
{opth keepmaster(varlist)} specifies additional variables from the {cmd:masterdata()} 
that should be included in output sheet.

{pstd}
{opt summaryonly} specifies that when using {cmd:masterdata()} 
only the summary sheet should be exported to {cmd:outfile()}. This option cannot be 
specified when using {cmd:trackingdata}

{pstd}
{opt workbooks} creates workbooks of completion rates for each value of by(). 
If there are over 30 values of the by() variable, a warning will suggest using this option.

{dlgtab:Additional Specifications for trackingdata()}

{pstd}
{opth keeptracking(varlist)} specifies additional variables from the {cmd:trackingdata()} 
that should be included in output sheet.   

{pstd}
{opt target(varname)} specifies the variable indicating the target number of respondents 
for each strata specified in the {cmd:trackingdata()}. This option cannot be used when using {cmd:masterdata}. 


{title:Remarks}

{pstd}
{cmd:ipatracksurveys} is one of the checks run in IPA's Data Management System. 
It can be run within IPA's Data Management System, where inputs are entered into 
a globals do-file and outputs are formatted in a .xlsx file or used directly from 
the command window or other do-files. See {help ipacheck} for more details on how 
to use the Data Management System.

{title:Examples}

{synoptline}
  {text:Setup}
	{phang}{com}   . use "https://raw.githubusercontent.com/PovertyAction/ipa_dms4.0/final/data/household_survey.dta", clear{p_end}
	{phang}{com}   . duplicates drop hhid, force
	{phang}{com}   . copy "https://raw.githubusercontent.com/PovertyAction/ipa_dms4.0/final/data/household_preloads.xlsx" "household_preloads.xlsx", replace{p_end}
	{phang}{com}   . copy "https://raw.githubusercontent.com/PovertyAction/ipa_dms4.0/final/data/respondent_targets.xlsx" "respondent_targets.xlsx", replace{p_end}
		
  {text:Run ipatracksurveys with masterdata showing summaryonly}
    {phang}{com}   . ipatracksurvey, m("household_preloads.xlsx") date(submissiondate) id(hhid) by(a_kg) keepm(district) surveyok outfile("tracksurvey.xlsx") nol summary replace{p_end}
	
  {text:Run ipatracksurveys with masterdata showing summary & tracking sheets per kg}
   {phang}{com}   . ipatracksurvey, m("household_preloads.xlsx") date(submissiondate) id(hhid) keeps(a_pl_hhh_fn a_pl_ch_fn a_pl_ch_age a_enum_name c_consent) by(a_kg) surveyok outfile("tracksurvey_sheets.xlsx") nol workb replace{p_end}
	
  {text:Run ipatracksurveys with trackingdata}
    {phang}{com}   . ipatracksurvey, t("respondent_targets.xlsx") date(submissiondate) target(hh_count) by(a_kg) keept(district) outfile("tracksurvey.xlsx") nol replace{p_end}

{txt}{...}

{title:Acknowledgement}

{pstd}
{cmd:ipatracksurvey} is based on {browse "https://github.com/PovertyAction/progreport":progreport} written by Rosemarie Sandino & Chris Boyer of Innovations for Poverty Action.

{title:Authors}

{pstd}
Ishmail Azindoo Baako
(Innovations for Poverty Action){p_end}
{pstd}{it:Last updated: May 11, 2022}{p_end}

{pstd}For questions or suggestions, submit a
{browse "https://github.com/PovertyAction/high-frequency-checks/issues":GitHub issue}
or e-mail researchsupport@poverty-action.org.{p_end}

{title:Also see}

User-written: {helpb progreport}