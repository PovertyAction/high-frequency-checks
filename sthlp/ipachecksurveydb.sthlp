{smcl}
{* *! version 4.0.0 Innovations for Poverty Action 11may2022}{...}
{title:Title}

{phang}
{cmd:ipachecksurveydb} {hline 2}
Create survey dashboard with rates of interviews, duration, don't know, refusal, 
missing, and other useful statistics. 

{title:Syntax}

{p 8 10 2}
{cmd:ipachecksurveydb}{cmd:,}
{opth formv:ersion(varname)}
{opth enum:erator(varname)}
{opth date(filename)}   
{opth outf:ile(filename)} 
[{it:{help ipachecksurveydb##options:options}}]

{marker options}{...}
{synoptset 26 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:* {opth formv:ersion(varname)}}form version variable{p_end}
{synopt:* {opth enum:erator(varname)}}enumerator variable{p_end}
{synopt:* {opth date(varname)}}date/datetime variable indication date of survey{p_end} 
{synopt:* {opth outf:ile(filename)}}save output to Excel workbook{p_end}

{syntab:Specifications}
{synopt:{opth by(varname)}} group statistics by variable{p_end}
{synopt:{opth per:iod(ipachecksurveydb##period:period)}}report by specified period eg. daily, weekly, monthly or auto{p_end}
{synopt:{opt cons:ent}{cmd:(}{help varname}{cmd:, }{help numlist}{cmd:)}}}consent variable and values{p_end}
{synopt:{opt dontk:now(#, "string")}}numeric and string values for don't know{p_end}
{synopt:{opt ref:use(#, "string")}}numeric and string values for refuse to answer{p_end}
{synopt:{opth other:specify(varlist)}}other specify variables{p_end}
{synopt:{opth dur:ation(varname)}}duration variables{p_end}
{synopt:{opt sheetmod:ify}}modify excel sheet {cmd:outsheet}{p_end}
{synopt:{opth sheetrep:lace}}overwrite Excel worksheet{p_end}
{synopt:{opt nol:abel}}export variable values instead of value labels{p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}* {opt formversion()}, {opt enumerator()}, {opt date()} and {opt outfile()} are required.

{title:Description}

{pstd}
{cmd:ipachecksurveydb} creates an Excel workbook with 3 (or 6) output sheets if: 

{phang2}.  "summary": summary of interviews, missing, don't know, refuse, other, 
and duration by enumerator. Excel worksheet "summary (team)" showing summary at 
team level will be included if {opt team()} is specified.{p_end}
{phang2}.  "productivity": number of surveys by period specified by {cmd:period()}. 
Excel worksheet "productivity (team)" showing productivity at team level will be 
included if {opt team()} is specified.{p_end}
{phang2}.  "enumstats": Summary statistics of numeric variables per enumerator. 
Excel worksheet "enumstats (team)" showing summary at team level will be included 
if {opt team()} is specified.{p_end}


{title:Options}

{dlgtab:Main}

{pstd}
{opth formversion(varname)} specifies the numeric form definition variable. eg, 
formversions(formdef_version). 

{pstd}
{opth enumerator(varname)} specifies the enumerator variable for the dataset. 
{cmd:enumerator()} is required and is automatically included in the output. 

{pstd}
{opt date(varname)} specifies the date or datetime variable indicating the date of 
survey. Reommended variables are Survey start, end or submission dates. This option 
expects a %td date variable or a %tc/%tC datetime variable. If variable specified 
is a datetime variable, the output will show the correspondent date instead of 
datetime. {cmd:date()} is required. 

{pstd}
{opt outfile("filename.xlsx")} specifies Excel workbook to export the report into. 
{cmd:outfile()} is required. Excel formats xls and xlsx are supported in {cmd:outfile()}. 
If a file extension is not specified with {cmd:outfile()}, .xls is assumed, because 
this format is more common and is compatible with more applications that also can read from Excel files.

{dlgtab:Specifications}

{phang}
{opth by(varname)} specifies that the output shows a disggregation based on the values 
of the variable specified with the {cmd:by()} option. eg. by(district), by(treatment_status). 

{pstd}
{cmd:period(}{help ipachecksurveydb##period:period}{cmd:)} specifies the time frame for showing summaries and statistics 
in the daashboard. eg. {opt period(daily)} {p_end}

{marker period}{...}
{synoptset 26 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt daily}}show daily summaries.{p_end}
{synopt:{opt weekly}}show weekly summaries. Week is Sunday to Saturday{p_end}
{synopt:{opt monthly}}show monthly summaries. Month is based on calendar month{p_end}
{synopt:{opt auto}}Auto adjust period. The auto option auto adjust the period based on the number of days ie. using days if number of days are less than or equal to 40, weeks if the number of days more than 40 and months if the number of months are greater than 40 weeks{p_end}
{synoptline}
{p2colreset}{...}

{pstd}
{opt consent({help varname},{help numlist})} option specifies variable and the 
values for consent. eg. consent(consent, 1) or consent(consent, 1 2). When a 
{help numlist} is specified as values, {cmd:ipacheckenumdb} will assume any of 
these values to indicate a valid consent. 

{pstd}
{opt dontk:now(numlist, "string")} option specifies values for don't know responses. eg. dontknow(-999, "-999") or consent(-999, "Dont Know").

{pstd}
{opt ref:use(numlist, "string")} option specifies values for refuse to answer responses. eg. dontknow(-999, "-999") or consent(-999, "Dont Know").  

{pstd}
{opth otherspecify(varlist)} option specifies other specify child variables. If specified, {cmd:ipacheckenumdb} will show statistics on percentage of times enumerator used the other specify option.   

{pstd}
{opth duration(varname)} option specifies the duration variable. If specified, {cmd:ipacheckenumdb} will show statistics on minimimum, maximum, mean and median duration per enumerator.   

{pstd}
{opt sheetmodify} specifies that the output sheet should only be modified 
but not be replaced if it already exist.  

{pstd}
{opt sheetreplace} specifies that the output sheet should be replaced if 
it already exist.  

{pstd}
{opt nolabel} nolabel exports the underlying numeric values instead of the value labels.

{title:Remarks}

{pstd}
{cmd:ipachecksurveydb} is one of the checks run in IPA's Data Management System. 
It can be run within IPA's Data Management System, where inputs are entered into a 
globals do-file and outputs are formatted in a .xlsx file or used directly from 
the command window or other do-files. See {help ipacheck} for more details on 
how to use the Data Management System. 

{title:Examples}

{synoptline}
  {text:Setup}
	{phang}{com}   . use "https://raw.githubusercontent.com/PovertyAction/ipa_dms4.0/final/data/household_survey.dta", clear{p_end}
	{phang}{com}   . destring duration, replace
		
  {text:Run ipachecksurveydb}
    {phang}{com}   . ipachecksurveydb, formv(formdef_version) dur(duration) cons(c_consent, 1) dontk(-999, "-999") ref(-888, "888") other(*_osp*) enum(a_enum_name) date(starttime) outf("surveydb.xlsx") sheetrep{p_end}
	
  {text:Run ipachecksurveydb, disggregate by district}
    {phang}{com}   . ipachecksurveydb, by(a_district) formv(formdef_version) dur(duration) cons(c_consent, 1) dontk(-999, "-999") ref(-888, "888") other(*_osp*) enum(a_enum_name) date(starttime) outf("surveydb_grouped.xlsx") sheetrep{p_end}
	
{synoptline}
	
{title:Authors}

{pstd}
Ishmail Azindoo Baako
(Innovations for Poverty Action){p_end}
{pstd}{it:Last updated: May 11, 2022}{p_end}

{pstd}For questions or suggestions, submit a
{browse "https://github.com/PovertyAction/high-frequency-checks/issues":GitHub issue}
or e-mail researchsupport@poverty-action.org.{p_end}

{title:Also see}

User-written: {helpb ipacheckenumdb:ipacheckenumdb}