{smcl}
{* *! version 4.0.0 Innovations for Poverty Action 11may2022}{...}
{title:Title}

{phang}
{cmd:ipacheckspecify} {hline 2}
Checks for recodes of other specify variables by listing all values specified. 

{marker syntax}{...}
{title:Syntax}

{p 8 10 2}
{cmd:ipacheckspecify} {it:{help using}}{cmd:,}
{opth sheet("sheetname")}
{opth id(varname)} 
{opth enum:erator(varname)}
{opth date(varname)}
{opth outf:ile(filename)}
[{it:{help ipacheckspecify##options:options}}]

{marker options}{...}
{synoptset 26 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:* {opth sh:eet("sheetname")}}Excel worksheet to load{p_end}
{synopt:* {opth enum:erator(varname)}}enumerator variable{p_end}
{synopt:* {opth id(varname)}}unique Survey ID variable{p_end}
{synopt:* {opth date(varname)}}date/datetime variable indication date of survey{p_end}
{synopt:* {opt outf:ile("filename.xlsx")}}save output to Excel workbook{p_end}

{syntab:Specifications}
{synopt:{opt outsheet1("sheetname1")}}save other specify values to Excel worksheet{p_end}
{synopt:{opt outsheet2("sheetname2")}}save choice value and labels to Excel worksheet{p_end}
{synopt:{opt sheetmod:ify}}modify Excel worksheet {cmd:outsheet}{p_end}
{synopt:{opt sheetrep:lace}}overwrite Excel worksheet {cmd:outsheet}{p_end}
{synopt:{opt nol:abel}}export variable values instead of value labels{p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}* {opt sheet()}, {opt id()}, {opt enumerator()}, {opt date()} and {opt outfile()} are required.

{title:Description}

{pstd}
{cmd:ipacheckspecify} exports to {opt outsheet1} the values that are specified 
when a question has an "other, specify" option. This shows possible recodes or 
enumerator performance issues with utilizing the "other, specify" option. 
{opt outsheet2} contains the value, value labels and some additional statistics 
of the parent variable.

{title:Options}

{dlgtab:Main}

{phang}
{opt sheet("sheetname")} specifies the Excel worksheet to load from the {help using} 
file. This is required if the using file is an Excel {opt xls}, {opt xlsx} or {opt xlsm} file. 
option {opt sheet()} is ignored if the using file is a {opt csv} or {opt dta} file.

{pstd}
{opt id(varname)} specifies the id variable for the dataset. {cmd:id()} is required 
and the variable specified with {cmd:id()} must contain unique values only. 
The id variable is automatically included in the output

{pstd}
{opth enumerator(varname)} specifies the enumerator variable for the dataset. {cmd:enumerator()} is 
required and is automatically included in the output. 

{pstd}
{opt date(varname)} specifies the date or datetime variable indicating the date of 
survey. Reommended variables are Survey start, end or submission dates. This option 
expects a %td date variable or a %tc/%tC datetime variable. If variable specified 
is a datetime variable, the output will show the correspondent date instead of 
datetime. {cmd:date()} is required.  

{pstd}
{opt outfile(varname)} specifies Excel workbook to export the other specify output into. 
{cmd:outfile()} is required. Excel formats xls and xlsx are supported in {cmd:outfile()}. 
If a file extension is not specified with {cmd:outfile()}, .xls is assumed, because 
this format is more common and is compatible with more applications that also can read from Excel files.

{dlgtab:Specifications}

{pstd}
{opt outsheet1("sheetname1")} specifies the Excel worksheet to export the other 
specify values to the {opt outfile()} specified. The default is to save to Excel sheet "other specify".

{pstd}
{opt outsheet2("sheetname2")} specifies the Excel worksheet to export the choice values and labels of the parent variable to the {opt outfile()} specified. The default is to save to Excel sheet "other specify (choices)".

{pstd}
{opt sheetmodify} specifies that the output sheet should only be modified 
but not be replaced if it already exist.  

{pstd}
{opt sheetreplace} specifies that the output sheet should be replaced if 
it already exist.  

{pstd}
{opt nolabel} nolabel exports the underlying numeric values instead of the value labels.

{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:ipacheckspecify} is one of the checks run in IPA's Data Management System. 
It can be run within IPA's Data Management System, where inputs are entered into an inputs file 
and outputs are formatted in a .xlsx file or used directly from the command window 
or other do-files. See {help ipacheck} for more details on how to use the Data Management System. 

{pstd}
Below, an example {opt inputs file} is shown:
The variabels {cmd:parent}, {cmd:child} and {cmd:keepvars} are required. The inputs file may also include additional variables which contain information that are useful for tracking, although these additional variables will not be used. 

{cmd}{...}
    {c TLC}{hline 17}{c -}{hline 25}{c -}{hline 30}{c TRC}
    {c |}           parent                       child                     keepvars{c |}
    {c LT}{hline 17}{c -}{hline 25}{c -}{hline 30}{c RT}
    {c |} ed11b_? ed11b_??    ed11b_osp_? ed11b_osp_??    enum_name fmemb_fullname1{c |}
    {c |}           tn12_?                  tn12_osp_?                             {c |}
    {c |}              eu1                     eu1_osp                             {c |}
    {c |}             ws10                    ws10_osp                             {c |}
    {c |}              hw1                     hw1_osp                             {c |}
    {c |}              hw4                     hw4_osp                             {c |}
    {c BLC}{hline 17}{c -}{hline 25}{c -}{hline 30}{c BRC}
{txt}{...}

{pstd}
{opt parent} column/variable indicates the {cmd:parent} variable(s). The {opt parent} variable(s) are the variables which contain the "other specify" option. This column only accepts a {help varlist}. The parent column is required.  

{pstd}
{opt child} column/variable indicates the {cmd:child} variable(s). The {opt child} variable(s) is the variable that actually stores the "other specify" value. {cmd:ipacheckspecify} collates and exports a list of "other specify" values to the {opt outfile()} 


{pstd}
{opt keepvars} column/variable indicates the additional variables to export to the {opt outfile} sheet. 


{title:Examples}

{synoptline}
  {text:Setup}
	{phang}{com}   . use "https://raw.githubusercontent.com/PovertyAction/ipa_dms4.0/final/data/household_survey.dta", clear{p_end}
	{phang}{com}   . copy "https://raw.githubusercontent.com/PovertyAction/ipa_dms4.0/final/excel/hfc_inputs_example.xlsm" "hfc_inputs_example.xlsm", replace{p_end}

  {text:Check for other specify values}
	{phang}{com}   . ipacheckspecify using "hfc_inputs_example.xlsm", sh("other specify") id(hhid) enum(a_enum_id) date(starttime) outf("hfc_outputs.xlsx") sheetrep{p_end}
	
{synoptline}

{txt}{...}

{title:Acknowledgement}

{pstd}
{cmd:ipacheckspecify} is based on previous versions of {cmd:ipacheckspecify} written by Chris Boyer of Innovations for Poverty Action.
 
{title:Authors}

{pstd}
Ishmail Azindoo Baako
(Innovations for Poverty Action){p_end}

{pstd}For questions or suggestions, submit a
{browse "https://github.com/PovertyAction/high-frequency-checks/issues":GitHub issue}
or e-mail researchsupport@poverty-action.org.{p_end}

{title:Also see}

User-written: {helpb ipacheckspecifyrecode:ipacheckspecifyrecode}
