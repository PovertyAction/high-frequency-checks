{smcl}
{* *! version 4.0.0 Innovations for Poverty Action 11may2022}{...}
{title:Title}

{phang}
{cmd:ipacheckversions} {hline 2}
Create a summary sheet detailing versions used by day, and flags interviews using outdated form versions. 

{title:Syntax}

{p 8 10 2}
{cmd:ipacheckversions} {it:{help varname}}{cmd:,}
{opth enum:erator(varname)}
{opth date(varname)}
{opt outf:ile("filename.xlsx")}
[{it:{help ipacheckversions##options:options}}]

{marker options}
{synoptset 26 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:* {opth enum:erator(varname)}}enumerator variable{p_end}
{synopt:* {opth date(varname)}}date/datetime variable indicating date of survey. {p_end}
{synopt:* {opt outf:ile("filename.xlsx")}}save output to Excel workbook{p_end}

{syntab:Specifications}
{synopt:{opt outsheet1("sheetname1")}}save "version control" summary to excel sheet{p_end}
{synopt:{opt outsheet2("sheetname2")}}save observations with "outdated form versions" to excel sheet{p_end}
{synopt:{opth keep(varlist)}}additional variables to export to {opt outsheet2}{p_end}
{synopt:{opt sheetmod:ify}}modify {cmd:outsheet1} & {cmd:outsheet2}{p_end}
{synopt:{opt sheetrep:lace}}replace {cmd:outsheet1} & {cmd:outsheet2}{p_end}
{synopt:{opt nol:abel}}export values instead of value labels to {opt sheetname2}{p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}* {opt enumerator()}, {opt date()} and {opt outfile()} are required.


{title:Description}

{pstd}
{cmd:ipacheckversions} exports a table of versions used by date and if applicable, 
a list of all observations that are using a form beside the most recent form version 
available by date. Optionally, the user can specify additional variables to show in 
{opt outsheet2}. 

{title:Options}

{dlgtab:Main}

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
{opt outfile(varname)} specifies Excel workbook to export the duplicate report into. 
{cmd:outfile()} is required. Excel formats xls and xlsx are supported in {cmd:outfile()}. 
If a file extension is not specified with {cmd:outfile()}, .xls is assumed, because 
this format is more common and is compatible with more applications that also can read from Excel files.

{dlgtab:Specifications}

{pstd}
{opt outsheet1("sheetname1")} specifies Excel sheet to export summary report of 
version control. The default is to save to Excel sheet {cmd:"form versions"}.

{pstd}
{opt outsheet2("sheetname2")} specifies Excel sheet to export details of surveys 
submitted with outdated form versions. A form version is considered outdated if it was
not the current version on day that it was used. The default is to save to Excel 
sheet {cmd:"outdated"}.

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
{cmd:ipacheckversions} is one of the checks run in IPA's Data Management System. 
It can be run within IPA's Data Management System, where inputs are entered into a globals do-file 
and outputs are formatted in a .xlsx file or used directly from the command window 
or other do-files. See {help ipacheck} for more details on how to use the Data Management System.
It is important to note that ipacheckversions was written to take advantage 
of the SurveyCTO form versions format and therefore experts that the form versions 
values are numeric and in ascending order from the oldest to the most recent form.

{title:Examples}

{synoptline}
  {text:Setup}
	{phang}{com}   . use "https://raw.githubusercontent.com/PovertyAction/ipa_dms4.0/final/data/household_survey.dta", clear{p_end}

  {text:Run check}
	{phang}{com}   . ipacheckversions formdef_version, enum(a_enum_id) date(starttime) outfile("hfc_outputs.xlsx") keep(a_enum_name hhid a_pl_hhh_fn) sheetrep{p_end}
	
{synoptline}

{txt}{...}
{title:Acknowledgement}

{pstd}
{cmd:ipacheckversions} is is based on {help ipatrackversions} written by Chris Boyer 
of Innovations for Poverty Action.
	
{title:Authors}

{pstd}
Ishmail Azindoo Baako
(Innovations for Poverty Action){p_end}

{pstd}For questions or suggestions, submit a
{browse "https://github.com/PovertyAction/high-frequency-checks/issues":GitHub issue}
or e-mail researchsupport@poverty-action.org.{p_end}
