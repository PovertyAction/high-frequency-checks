{smcl}
{* *! version 4.0.0 Innovations for Poverty Action 11may2022}{...}
{title:Title}

{phang}
{cmd:ipachecktimeuse} {hline 2}
Create a heatmap of enumerator & survey productivity using question-level timestamps captured using SurveyCTO's text audit feature.

{title:Syntax}

{p 8 10 2}
{cmd:ipachecktimeuse} {help varname:textauditvar}{cmd:,}
{opth textaudit:data(filename)}
{opth start:time(varname)}
{opth enum:erator(varname)}
{opth outf:ile(filename)}
[{it:{help ipachecktimeuse##options:options}}]

{marker options}
{synoptset 26 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:* {opth textaudit:data(filename)}}date/datetime variable indicating date of survey. {p_end}
{synopt:* {opth start:time(varname)}}datetime variable indicating starttime of survey. {p_end}
{synopt:* {opth enum:erator(varname)}}save "version control" summary to excel sheet{p_end}
{synopt:* {opth outf:ile(filename)}}save output to Excel workbook{p_end}

{syntab:Specifications}
{synopt:{opt sheetmod:ify}}modify Excel sheets {cmd:outsheet1} & {cmd:outsheet2}{p_end}
{synopt:{opt sheetrep:lace}}replace Excel sheets {cmd:outsheet1} & {cmd:outsheet2}{p_end}
{synopt:{opt nol:abel}}export values instead of value labels to {opt sheetname2}{p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}* {opt textauditdata()}, {opt starttime()}, {opt enumerator()} and {opt outfile()} are required.


{title:Description}

{pstd}
{cmd:ipachecktimeuse} exports heatmap of hourly engagement for each survey date 
to the "timeuse by date" sheet of the specified {opt outfile()} and for each enumerator 
to the "timeuse by enumerator" sheet as well. The output from {cmd:ipachecktimeuse} 
gives a visual overview of productivity for the various hours during the day. 


{title:Options}

{dlgtab:Main}

{phang}
{opt textauditdata(filename)} specifies the .dta file to load. This .dta file contains 
a dataset collated by {help ipaimportsctomedia} command. 

{pstd}
{opth starttime(varname)} specifies the %tc/%tC datetime variable for the dataset which 
indicates the starttime for each survey.

{pstd}
{opth enumerator(varname)} specifies the enumerator variable for the dataset. 
{cmd:enumerator()} is required and is automatically included in the output. 

{pstd}
{opt outfile("filename.xlsx")} specifies Excel workbook to export the report into. 
{cmd:outfile()} is required. Excel formats xls and xlsx are supported in {cmd:outfile()}. 
If a file extension is not specified with {cmd:outfile()}, .xls is assumed, because 
this format is more common and is compatible with more applications that also can read from Excel files.

{dlgtab:Specifications}

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
{cmd:ipachecktimeuse} is one of the checks run in IPA's Data Management System. 
It can be run within IPA's Data Management System, where inputs are entered into an globals do file 
and outputs are formatted in a .xlsx file or used directly from the command window or other do-files. See {help ipacheck} for more details on how to use the Data Management System. 


{title:Examples}

{synoptline}
  {text:Setup}
	{phang}{com}   . use "https://raw.githubusercontent.com/PovertyAction/ipa_dms4.0/final/data/household_survey.dta", clear{p_end}
	{phang}{com}   . unzipfile "https://raw.githubusercontent.com/PovertyAction/ipa_dms4.0/final/data/media.zip", replace{p_end}
	
  {text:Collate text audit comments}
	{phang}{com}   . ipasctocollate textaudit text_audit, folder("./media") save("textaudit_data.dta") replace{p_end}
	
  {text:Analyse time use}
    {phang}{com}   . ipachecktimeuse text_audit, textaudit("textaudit_data.dta") start(starttime) enum(a_enum_name) outf("textaudit.xlsx") sheetrep{p_end}
	
{synoptline}
{txt}{...}  

{txt}{...}

{title:Acknowledgement}

{pstd}
{cmd:ipachecktimeuse} is is based on {browse "https://github.com/PovertyAction/sctotimeuse":sctotimeuse} written by William Blackmon of Innovations for Poverty Action.
	
{title:Authors}

{pstd}
Ishmail Azindoo Baako
(Innovations for Poverty Action){p_end}
{pstd}{it:Last updated: May 11, 2022}{p_end}

{pstd}For questions or suggestions, submit a
{browse "https://github.com/PovertyAction/high-frequency-checks/issues":GitHub issue}
or e-mail researchsupport@poverty-action.org.{p_end}

{title:Also see}

User-written: {helpb ipasctocollate:ipasctocollate}

