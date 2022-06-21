{smcl}
{* *! version 4.0.0 Innovations for Poverty Action 11may2022}{...}
{title:Title}

{phang}
{cmd:ipacheckdups} {hline 2}
Check for duplicate values of variables that should be unique. 

{marker syntax}{...}
{title:Syntax}

{p 8 10 2}
{cmd:ipacheckdups} {it:{help varlist}} {help if:[if]} {help in:[in]}{cmd:,}
{opth id(varname)}
{opth enum:erator(varname)}
{opth date(varname)}
{opt outf:ile("filename.xlsx")}
[{it:{help ipacheckdups##options:options}}]

{marker options}
{synoptset 26 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:* {opth id(varname)}}unique Survey ID variable{p_end}
{synopt:* {opth enum:erator(varname)}}enumerator variable{p_end}
{synopt:* {opth date(varname)}}date/datetime variable indication date of survey{p_end}
{synopt:* {opth outf:ile("filename.dta")}}save output to Excel workbook{p_end}

{syntab:Specifications}
{synopt:{opt outsh:eet("sheetname")}}save summary of duplicates to excel sheet{p_end}
{synopt:{opth keep(varlist)}}additional variables to export to {opt outsheet}{p_end}
{synopt:{opt sheetmod:ify}}modify excel sheet {cmd:outsheet}{p_end}
{synopt:{opt sheetrep:lace}}overwrite excel sheet {cmd:outsheet}{p_end}
{synopt:{opt nol:abel}}export variable values instead of value labels{p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}* {opt enumerator()}, {opt id()}, {opt date()}, and {opt outfile()} are required.

{title:Description}

{pstd}
{cmd:ipacheckdups} checks for duplicates of variables that should be unique, such 
as GPS points and other household indicators for enumerator monitoring. Note this 
check should not be used for the ID variable when running within IPA's Data Management System, 
since other checks in the Data Management System require a unique ID variable. 
{help ipacheckids} is used to summarize duplicates and differences between interviews 
with the same value for the ID variable.

{title:Options}

{dlgtab:Main}

{pstd}
{opt id(varname)} specifies the id variable for the dataset. {cmd:id()} is required 
and the variable specified with {cmd:id()} must contain unique values only. 
The id variable is automatically included in the output.

{pstd}
{opth enumerator(varname)} specifies the enumerator variable for the dataset. {cmd:enumerator()} is 
required and is automatically included in the output. 

{pstd}
{opt date(varname)} specifies the date or datetime variable indicating the date of 
survey. Recommended variables are Survey start, end or submission dates. This option 
expects a %td date variable or a %tc/%tC datetime variable. If variable specified 
is a datetime variable, the output will show the correspondent date instead of 
datetime. {cmd:date()} is required. 

{pstd}
{opt outfile(varname)} specifies Excel workbook to export the duplicate report into. 
{cmd:outfile()} is required. Excel formats xls and xlsx are supported in {cmd:outfile()}. 
If a file extension is not specified with {cmd:outfile()}, .xls is assumed, because 
this format is more common and is compatible with more applications that also can read from Excel files.

{dlgtab:Specifications}

{pstd}
{opt outsheet("sheetname")} specifies Excel sheet to export duplicates report into. 
The default is to save to Excel sheet {cmd:"duplicates"}.

{pstd}
{opth keep(varlist)} specifies additional variables that should be included 
in output sheet. The Survey ID and the variables specified in the {cmd:enumerator()} 
and {cmd:date} will automatically be added to the output.   

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
{cmd:ipacheckdups} is one of the checks run in IPA's Data Management System. 
It can be run within IPA's Data Management System, where inputs are entered into 
a globals do-file and outputs are formatted in a .xlsx file or used directly from 
the command window or other do-files. See {help ipacheck} for more details on how 
to use the Data Management System.

{title:Examples}

{synoptline}
  {text:Setup}
	{phang}{com}   . use "https://raw.githubusercontent.com/PovertyAction/ipa_dms4.0/final/data/household_survey.dta", clear{p_end}

  {text:Flag and export duplicates in phone_number variable}
	{phang}{com}   . ipacheckdups phone_number, id(hhid) enum(a_enum_id) date(starttime) keep(a_enum_name a_pl_hhh_fn submissiondate endtime) outf("hfc_outputs.xlsx") sheetrep{p_end}
	
{synoptline}

{txt}{...}

{title:Acknowledgement}

{pstd}
{cmd:ipacheckdups} is based on previous versions of {cmd:ipacheckdups} written by Chris Boyer of Innovations for Poverty Action.

{title:Authors}

{pstd}
Ishmail Azindoo Baako
(Innovations for Poverty Action){p_end}

{pstd}For questions or suggestions, submit a
{browse "https://github.com/PovertyAction/high-frequency-checks/issues":GitHub issue}
or e-mail researchsupport@poverty-action.org.{p_end}

{title:Also see}

{psee}
User-written:  {helpb ipacheckids}, {helpb duplicates}, {helpb ipacheckcorrections}
{p_end}
