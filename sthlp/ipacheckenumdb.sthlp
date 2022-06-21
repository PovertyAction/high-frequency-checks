{smcl}
{* *! version 4.0.0 Innovations for Poverty Action 11may2022}{...}
{title:Title}

{phang}
{cmd:ipacheckenumdb} {hline 2}
Create enumerator dashboard with rates of interviews, duration, don't know, refusal, 
missing, and other by enumerator, and variable statistics by enumerator. 

{title:Syntax}

{p 8 10 2}
{cmd:ipacheckenumdb [using]} {it:{help filename}}{cmd:,}
{opt sh:eet("sheetname")}
{opth enum:erator(varname)}
{opth date(varname)}
{opth outf:ile(filename)} 
[{it:{help ipacheckenumdb##options:options}}]

{marker options}{...}

{synoptset 30 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:* {opt sheet("sheetname")}}Excel worksheet to load{p_end}
{synopt:* {opth formv:ersion(varlist)}}form version variable{p_end}
{synopt:* {opth enum:erator(varname)}}enumerator variable{p_end}
{synopt:* {opth date(varname)}}date/datetime variable indication date of survey{p_end}
{synopt:* {opth outf:ile(filename)}}save output to Excel workbook{p_end}

{syntab:Specifications}
{synopt:{opth team(varname)}}team variable{p_end}
{synopt:{opth per:iod(ipacheckenumdb##period:period)}}report by specified period eg. daily, weekly, monthly or auto{p_end}
{synopt:{opt cons:ent}{cmd:(}{help varname}{cmd:, }{help numlist}{cmd:)}}}consent variable and values{p_end}
{synopt:{opt dontk:now(#, "string")}}numeric and string values for don't know{p_end}
{synopt:{opt ref:use(#, "string")}}numeric and string values for refuse to answer{p_end}
{synopt:{opth other:specify(varlist)}}other specify variables{p_end}
{synopt:{opth dur:ation(varlist)}}duration variables{p_end}
{synopt:{opt sheetmod:ify}}modify excel sheet {cmd:outsheet}{p_end}
{synopt:{opt sheetrep:lace}}overwrite Excel worksheet{p_end}
{synopt:{opt nol:abel}}export variable values instead of value labels{p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}* {opt sheet()}, {opt enumerator()}, {opt date()}, {opt formversions()} and {opt outfile()} are required.

{title:Description}

{pstd}
{cmd:ipacheckenumdb} creates an Excel workbook with 3 sheets or 6 sheets if {opt team()} is specified: 

{phang2}.  "summary": summary of interviews, missing, don't know, refuse, other, and duration by enumerator. Excel worksheet "summary (team)" showing summary at team level will be included if {opt team()} is specified.{p_end}
{phang2}.  "productivity": number of surveys by days/weeks/months. Excel worksheet "productivity (team)" showing productivity at team level will be included if {opt team()} is specified.{p_end}
{phang2}.  "enumstats": Summary statistics of numeric variables per enumerator. Excel worksheet "enumstats (team)" showing summary at team level will be included if {opt team()} is specified.{p_end}

{title:Options}

{dlgtab:Main}

{phang}
{opt sheet("sheetname")} specifies the Excel worksheet to load from the {cmd:using} file. 
This file will contain the inputs for the enuemerator statistics check. This is required 
if the using file is {opt .xls} or {opt .xlsx} formats. option {opt sheetname()} is 
ignored if the using file is {opt csv} or {opt dta} file.

{pstd}
{opth enumerator(varname)} specifies the enumerator variable for the dataset. 
{cmd:enumerator()} is required and is automatically included in the output. 

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

{dlgtab:Specifications}

{phang}
{opth team(varname)} specifies the team variable for the dataset in memory. If specified, 
3 additional sheets "summary (team)", "productivity (team)" and "enumstats (team)" 
will be included in the output file with additional at the team level. {p_end}

{pstd}
{cmd:period(}{help ipacheckenumdb##period:period}{cmd:)} specifies the time frame for showing summaries and statistics 
in the daashboard. eg. {opt period(daily)} {p_end}

{marker period}{...}
{synoptset 26 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt daily}}show daily summaries.{p_end}
{synopt:{opt weekly}}show weekly summaries. Week is Sunday to Saturday{p_end}
{synopt:{opt monthly}}show monthly summaries. Month is based on calendar month{p_end}
{synopt:{opt auto}}Auto adjust period. Changes period to weekly after 40 days and monthly after 40 weeks{p_end}
{synoptline}
{p2colreset}{...}

{pstd}
{cmd:consent(}{help varname}{cmd:, }{help numlist}{cmd:)} option specifies variable and the 
values for consent. eg. consent(consent, 1) or consent(consent, 1 2). When a 
{help numlist} is specified as values, {cmd:ipacheckenumdb} will assume any of 
these values to indicate a valid consent. 

{pstd}
{opt dontknow(numlist, "string")} option specifies values for don't know responses. eg. dontknow(-999, "-999") or consent(-999, "Dont Know").

{pstd}
{opt refuse(numlist, "string")} option specifies values for refuse to answer responses. eg. dontknow(-999, "-999") or consent(-999, "Dont Know").  

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
{cmd:ipacheckenumdb} is one of the checks run in IPA's Data Management System. 
It can be run within IPA's Data Management System, where inputs are entered into a globals do-file 
and outputs are formatted in a .xlsx file or used directly from the command window or other do-files. See {help ipacheck} for more details on how to use the Data Management System. 

{pstd}
Below, an example {opt inputs file} is shown with an example of inputs for enumstats sheet:

{cmd}{...}
    {c TLC}{hline 70}{c TRC}
    {c |}  variable   combine   min   mean   show_mean_as    median    sd   max{c |}
    {c LT}{hline 70}{c RT}
    {c |}     hc16a             yes    yes                      yes   yes   yes{c |}
    {c |}    st1cb*             yes    yes                      yes   yes   yes{c |}
    {c |}      tn4*       yes   yes    yes     percentage                   yes{c |}
    {c |}      tn9*       yes   yes    yes                      yes   yes   yes{c |}
    {c |}       ws4             yes    yes                      yes   yes   yes{c |}
    {c |}      dc0b             yes    yes                      yes   yes   yes{c |}
    {c BLC}{hline 70}{c BRC}
{txt}{...}

{pstd}
{opt variable} column/variable indicates the variable(s) to display enumerators statistics for. This column only accepts a {help varlist}. The variables specified in this column must be a {cmd:numeric} variable and {cmd:ipacheckenumdb} will return an error if it is not. The variable column is required.  

{pstd}
{opt combine} column/variable indicates if variales specified in the corresponding {opt variables} column should be considered as 1 variable. eg. Assuming the survey has income values for household members stored in 4 different variables {cmd:hhm_income_1}, {cmd:hhm_income_2}, {cmd:hhm_income_3} and {cmd:hhm_income_4}; the {opt combine} column can be used to indicate that thee variables should be considered as the same when calculating summary statistics. Users can combine variables by indicating {cmd:"yes"} in the combine column. The default behaviour is to consider each variable specified in the {cmd:variables} column as individual variables. 

{pstd}
{opt min} column/variable indicates of the minimum value for the corresponding variables in the variable(s) column should be includded in the enumstats report. 

{pstd}
{opt mean} column/variable indicates of the mean/average value for the corresponding variables in the variable(s) column should be includded in the enumstats report.

{pstd}
{opt show_mean_as} column/variable indicates of the mean/average value for the corresponding variables in the variable(s) column should be formatted as a percentage or number. This is useful for displaying percetages for dummy variables. 

{pstd}
{opt sd} column/variable indicates of the standard deviation for the corresponding variables in the variable(s) column should be includded in the enumstats report.

{pstd}
{opt max} column/variable indicates of the maximum value for the corresponding variables in the variable(s) column should be includded in the enumstats report.

{pstd}
{cmd:ipacheckenumdb} is one of the checks run in IPA's Data Management System. 
It can be run within IPA's Data Management System, where inputs are entered into a globals do-file 
and outputs are formatted in a .xlsx file or used directly from the command window or other do-files. See {help ipacheck} for more details on how to use the Data Management System.

{title:Examples}

{synoptline}
  {text:Setup}
	{phang}{com}   . use "https://raw.githubusercontent.com/PovertyAction/ipa_dms4.0/final/data/household_survey.dta", clear{p_end}
	{phang}{com}   . destring duration, replace
		
  {text:Run ipacheckenumdb without enumstats}
    {phang}{com}   . ipacheckenumdb, formv(formdef_version) dur(duration) cons(c_consent, 1) dontk(-999, "-999") ref(-888, "888") other(*_osp*) enum(a_enum_name) team(a_team_name) date(starttime) outf("enumdb.xlsx") sheetrep{p_end}
	
  {text:Run ipacheckenumdb with enumstats}
  	{phang}{com}   . destring f_hr_rpt_count, replace{p_end}
	{phang}{com}   . copy "https://raw.githubusercontent.com/PovertyAction/ipa_dms4.0/final/excel/hfc_inputs_example.xlsm" "hfc_inputs_example.xlsm", replace{p_end}
    {phang}{com}   . ipacheckenumdb using "hfc_inputs_example.xlsm", formv(formdef_version) dur(duration) cons(c_consent, 1) dontk(-999, "-999") ref(-888, "888") other(*_osp*) enum(a_enum_name) team(a_team_name) date(starttime) outf("enumdb_enumstats.xlsx") sheetrep{p_end}
	
{synoptline}

{txt}{...}
	
{title:Authors}

{pstd}
Ishmail Azindoo Baako
(Innovations for Poverty Action){p_end}
{pstd}{it:Last updated: May 11, 2022}{p_end}

{pstd}For questions or suggestions, submit a
{browse "https://github.com/PovertyAction/high-frequency-checks/issues":GitHub issue}
or e-mail researchsupport@poverty-action.org.{p_end}

{title:Also see}

User-written: {helpb ipachecksurveydb:ipachecksurveydb}