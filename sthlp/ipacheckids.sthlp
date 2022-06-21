{smcl}
{* *! version 4.0.0 Innovations for Poverty Action 11may2022}{...}
{title:Title}

{phang}
{cmd:ipacheckids} {hline 2}
Find and export duplicates in Survey ID

{marker syntax}{...}
{title:Syntax}

{p 8 10 2}
{cmd:ipacheckids} {it:{help varname}}{cmd:,}
{opth key(varname)} 
{opth enum:erator(varname)}
{opth date(varname)}
{opt outfile("filename.xlsx")}
[{it:{help ipacheckids##options:options}}]

{maeker options}{...}
{synoptset 26 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:* {opth key(varname)}}surveys unique key variable{p_end}
{synopt:* {opth enum:erator(varname)}}enumerator variable{p_end}
{synopt:* {opth date(varname)}}date/datetime variable indication date of survey{p_end}
{synopt:* {opth outf:ile(filename)}}save output to Excel workbook{p_end}

{syntab:Specifications}
{synopt:{opt outsh:eet("sheetname")}}save summary of duplicates to excel sheet{p_end}
{synopt:{opth keep(varlist)}}additional variables to export to Excel worksheet {opt outsheet()}{p_end}
{synopt:{opt dupf:ile("filename1.dta")}}save dataset of duplicate observations to dta file{p_end}
{synopt:{opt sa:ve("filename2.dta")}}save dataset of de-duplicated surveys as a dta file, where one of each duplicate group is randomly kept; must be used with {it:force} {p_end}
{synopt:{opt sheetmod:ify}}modify excel sheet {cmd:outsheet}{p_end}
{synopt:{opt sheetrep:lace}}overwrite excel sheet {cmd:outsheet}{p_end}
{synopt:{opt replace}}overwrite Excel file {cmd:outfile}{p_end}
{synopt:{opt nol:abel}}exports the underlying numeric values instead of the value labels{p_end}
{synopt:{opt force}}randomly keep one observation in each duplicates group{p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}* {opt enumerator()}, {opt date()}, {opt key()} and {opt outfile()} are required.

{marker description}{...}
{title:Description}

{pstd}
{cmd:ipacheckids} checks for duplicates of the Survey ID variable specified. 
If duplicates are found, a summary of the duplicates is exported to {cmd:outfile()}. 
The exported sheet will show the summary of each duplicate group including the number 
of comparison and differences for each duplicate group. If there are more than two 
observations with the same ID variable, each obsrvation will be compared with the 
first observation submitted.{cmd:ipacheckids} requires a unique key variable;This 
unique key variable is different from the Survey ID variable that is checked by 
{cmd:ipacheckids} for duplicates. The unique key variable will help differenciate the 
duplicate observations reported and will be needed when resolving duplicates using 
{helpb ipacheckcorrections}. 

{title:Options}

{dlgtab:Main}

{pstd}
{opt key(varname)} specifies the unique survey key for the dataset. {cmd:key()} is 
required and the variable specified with {cmd:key()} must contain unique values only. 
The key variable is automatically included in the output. 

{pstd}
{opt enumerator(varname)} specifies the enumerator variable for the dataset. {cmd:enumerator()} is 
required and is automatically included in the output. 

{pstd}
{opt date(varname)} specifies the date or datetime variable indicating the date of 
survey. Reommended variables are Survey start, end or submission dates. This option 
expects a %td date variable or a %tc/%tC datetime variable. If variable specified 
is a datetime variable, the output will show the correspondent date instead of 
datetime. {cmd:date()} is required. 

{pstd}
{opt outfile(varname)} specifies Excel workbook to export the duplicate reports to. 
{cmd:outfile()} is required. Excel formats xls and xlsx are supported in {cmd:outfile()}. 
If a file extension is not specified with {cmd:outfile()}, .xls is assumed, because 
this format is more common and is compatible with more applications that also can read from Excel files.

{dlgtab:Specifications}

{pstd}
{opt outsheet("sheetname")} specifies Excel sheet to save summary of duplicates into. 
The default is to save to the Excel sheet "id duplicates".

{pstd}
{opth keep(varlist)} option specifies additional variables that should be included 
in duplicates summary sheet. The Survey ID and the variables specified in the 
{cmd:enumerator()}, {cmd:date} & {cmd:key} will automatically be added to the 
summary sheet. {cmd:keep} 

{pstd}
{opt dupfile("filename.dta")} specifies dta file to a dataset of duplicate observations. 
If {cmd:dupfile()} is not specified, no duplicates dataset will be saved.  

{pstd}
{opt save("filename2.dta")} specifies dta file to save a dataset of of de-deplicated 
observations. {cmd: ipacheckids} randomly keeps one observations from each duplicate pair. 
This option must always be used with the {cmd: force} option. 

{pstd}
{opt sheetmodify} specifies that the duplicates summary sheet should only 
be modified but not be replaced if it already exist.  

{pstd}
{opt sheetreplace} specifies that the duplicates summary sheet should be 
replaced if it already exist.  

{pstd}
{opt nolabel} nolabel exports the underlying numeric values instead of the value 
labels.

{pstd}
{opt replace} overwrites an existing Excel workbook.  replace cannot be specified 
when modifying or replacing a given worksheet. ie when {cmd:sheetmodify} or 
{cmd:sheetreplace} is used. 

{pstd}
{opt force} option utilizes {help duplicates drop} to randomly drop duplicates 
in each duplicate group. {cmd:force} specifies that observations duplicated with 
respect to a named varlist be dropped.  The force option is required when option
{cmd:save()} is used. Force is given as a reminder that information may be lost 
by dropping observations, given that those observations may differ on other 
variables.

{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:ipacheckids} is one of the checks run in IPA's Data Management System. 
It can be run within IPA's Data Management System, where inputs are entered into 
a globals do-file and outputs are formatted in a .xlsx file or used directly from 
the command window or other do-files. See {help ipacheck} for more details on how 
to use the Data Management System.

{title:Examples}

{synoptline}
  {text:Setup}
	{phang}{com}   . use "https://raw.githubusercontent.com/PovertyAction/ipa_dms4.0/final/data/household_survey.dta", clear{p_end}

  {text:Flag and export duplicates in hhid}
	{phang}{com}   . ipacheckids hhid, enum(a_enum_id) date(starttime) key(key) keep(a_enum_name a_pl_hhh_fn submissiondate endtime) outfile("hfc_outputs.xlsx") save("household_survey_checked.dta"){p_end}
	
{synoptline}
 
{text}{...}
{title:Authors}


{pstd}
Rosemarie Sandino & Ishmail Azindoo Baako
(Innovations for Poverty Action){p_end}

{pstd}
For questions or suggestions, submit a
{browse "https://github.com/PovertyAction/high-frequency-checks/issues":GitHub issue}
or e-mail researchsupport@poverty-action.org.{p_end}

{title:Also see}

{psee}
User-written:  {helpb ipacheckdups}, {helpb duplicates}, {helpb isid}, {helpb ipacheckcorrections}
{p_end}