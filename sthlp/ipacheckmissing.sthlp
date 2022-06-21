{smcl}
{* *! version 4.0.0 Innovations for Poverty Action 11may2022}{...}
{title:Title}

{phang}
{cmd:ipacheckmissing} {hline 2}
Create statistics or missingness and distinctness of variables. 

{marker syntax}{...}
{title:Syntax}

{p 8 10 2}
{cmd:ipacheckmissing} {it:{help varlist}}{cmd:,}
{opth outf:ile(filename)} 
[{it:{help ipacheckmissing##options:options}}]

{marker options}{...}
{synoptset 26 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:* {opt outf:ile("filename.xlsx")}}save output to Excel workbook{p_end}

{syntab:Specifications}
{synopt:{opt outsh:eet("sheetname")}}save summary of duplicates to excel sheet{p_end}
{synopt:{opth pr:iority(varlist)}}show these variables at the top of the output{p_end}
{synopt:{opt show(integer[%])}}show variables statistics if variable is at least integer[%] missing values/percentage{p_end}
{synopt:{opt sheetmod:ify}}modify excel sheet {cmd:outsheet}{p_end}
{synopt:{opt sheetrep:lace}}overwrite excel sheet {cmd:outsheet}{p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}* {opt outfile()} is required.

{title:Description}

{pstd}
{cmd:ipacheckmissing} creates and outputs statistics on variable missingness and 
distinctness for specified variables in varlist. If this command is used as part of 
the IPA Data Management System, it will be imporatant to note that IPA's Data Management 
System changes values to missing as specified in the globals do-file sheet 
(i.e. -999 = .d), which will also be considered missing in this check. 

{title:Options}

{dlgtab:Main}

{pstd}
{opt outfile(varname)} specifies Excel workbook to export the missingess report into. 
{cmd:outfile()} is required. Excel formats xls and xlsx are supported in {cmd:outfile()}. 
If a file extension is not specified with {cmd:outfile()}, .xls is assumed, because 
this format is more common and is compatible with more applications that also can read from Excel files.

{dlgtab:Specifications}

{pstd}
{opt outsheet("sheetname")} specifies Excel sheet to export missingess report into. 
The default is to save to Excel sheet {cmd:"missing"}.

{pstd}
{opt show(integer[%])} specifes that only nly variables that have a minimum number 
or percentage specified should be show in the output. The default is {opt show(0)} 
which will show statistics for all variables. {cmd:show()} can be specified as 
show(5) or show(10%).

{pstd}
{opth priority(varlist)} option specifies variables to prioritize in the outputs. 
If specified, these variables will be sorted to the top of the output. 
By default, variables are sorted in descending order based on percentage of missing
values that are missing.

{pstd}
{opt sheetmodify} specifies that the output sheet should only be modified 
but not be replaced if it already exist.  

{pstd}
{opt sheetreplace} specifies that the output sheet should be replaced if 
it already exist.  

{title:Remarks}

{pstd}
{cmd:ipacheckmissing} is one of the checks run in IPA's Data Management System. 
It can be run within IPA's Data Management System, where inputs are entered into a globals do-file 
and outputs are formatted in a .xlsx file or used directly from the command window 
or other do-files. See {help ipacheck} for more details on how to use the Data Management System.

{title:Examples}

{synoptline}
  {text:Setup}
	{phang}{com}   . use "https://raw.githubusercontent.com/PovertyAction/ipa_dms4.0/final/data/household_survey.dta", clear{p_end}

  {text:Check missingness of all variables}
	{phang}{com}   . ipacheckmissing _all, outf("hfc_outputs.xlsx") sheetrep{p_end}
	
{synoptline}

{txt}{...}

{title:Acknowledgement}

{pstd}
{cmd:ipacheckmissing} is based on {cmd:ipachecknomiss} & {cmd:ipacheckallmiss} written by Chris Boyer of Innovations for Poverty Action.

{title:Authors}

{pstd}
Ishmail Azindoo Baako
(Innovations for Poverty Action){p_end}

{pstd}For questions or suggestions, submit a
{browse "https://github.com/PovertyAction/high-frequency-checks/issues":GitHub issue}
or e-mail researchsupport@poverty-action.org.{p_end}

{title:Also see}

Help: {helpb misstable:[R] misstable}