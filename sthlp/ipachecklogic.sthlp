{smcl}
{* *! version 4.0.0 Innovations for Poverty Action jul2022}{...}
{title:Title}

{phang}
{cmd:ipachecklogic} {hline 2}
Checks for logical inconsistencies in survey data.

{marker syntax}{...}
{title:Syntax}

{p 8 10 2}
{cmd:ipachecklogic using} {it:{help filename}}{cmd:,}
{opt sh:eet("sheetname")}  
{opth enum:erator(varname)}  
{opth date(varname)} 
{opth id(varname)} 
{opt outf:ile("filename.xlsx")}
[{it:{help ipachecklogic##options:options}}]

{marker options}{...}
{synoptset 30 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:* {opth sh:eet(filename)}}Excel worksheet to load{p_end}
{synopt:* {opth id(varname)}}unique Survey ID variable{p_end}
{synopt:* {opth enum:erator(varname)}}enumerator variable{p_end}
{synopt:* {opth date(varname)}}date/datetime variable indication date of survey{p_end}
{synopt:* {opt outf:ile("filename.xlsx")}}save output to Excel workbook{p_end}

{syntab:Specifications}
{synopt:{opt outsh:eet("sheetname")}}save output to wooksheet{p_end}
{synopt:{opt sheetmod:ify}}modify excel sheet {cmd:outsheet}{p_end}
{synopt:{opt sheetrep:lace}}overwrite excel sheet {cmd:outsheet}{p_end}
{synopt:{opt nol:abel}}export variable values instead of value labels{p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}* {opt enumerator()}, {opt id()}, {opt date()} and {opt outfile()} are required.{p_end}
{p 4 6 2}* Variables {opt variable} is required in using data.{p_end}

{title:Description}

{pstd}
{cmd:ipachecklogic} checks for logical inconsistencies in survey variables. ipachecklogic checks for logic violations using logical statements as indicated in the assert column of the input sheet. Users can include an additional if statement to restrict logic checks to a subset of values.  

{title:Options}

{dlgtab:Main}

{phang}
{opt sheet("sheetname")} specifies the Excel worksheet to load from the {help using} file. This is required if the using file is {opt .xls} or {opt .xlsx} formats. option {opt sheet()} is ignored if the using file is {opt .csv} or {opt .dta} file.

{pstd}
{opt id(varname)} specifies the id variable for the dataset. {cmd:id()} is required 
and the variable specified with {cmd:id()} must contain unique values only. 
The id variable is automatically included in the output.

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
{opt outfile("filename.xlsx")} specifies Excel workbook to export the duplicate report into. 
{cmd:outfile()} is required. Excel formats xls and xlsx are supported in {cmd:outfile()}. 
If a file extension is not specified with {cmd:outfile()}, .xls is assumed, because 
this format is more common and is compatible with more applications that also can read from Excel files.

{dlgtab:Specifications}

{pstd}
{opt outsheet("sheetname")} specifies the Excel worksheet Excel sheet to export the 
output to for the {opt outfile()} specified. The default is to save to Excel sheet "outliers".

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
{cmd:ipachecklogic} is one of the checks run in IPA's Data Management System. 
It can be run within IPA's Data Management System, where inputs are entered into an Excel inputs sheet 
and outputs are formatted in a .xlsx file or used directly from the command window 
or other do-files. See {help ipacheck} for more details on how to use the 
Data Management System. 

{pstd}
Below, an example {opt inputs file} is shown with additional optional variables:
The variabels {cmd:variable}, {cmd:by}, {cmd:method}, {cmd:multiplier}, {cmd:combine} and {cmd:keepvars} are required. The inputs file may also include additional variables which contain information that are useful for tracking, although these additional variables will not be used. 

{cmd}{...}
    {c TLC}{hline 11}{c -}{hline 26}{c -}{hline 15}{c -}{hline 17}{c TRC}
    {c |}  variable                      assert    if_condition              keep{c |}
    {c LT}{hline 11}{c -}{hline 26}{c -}{hline 15}{c -}{hline 17}{c RT}
    {c |}    bc_rand  bc_rand > 0 & bc_rand < 1                 kg_name community{c |}
    {c |}  bc_sel_yn    inlist(bc_sel_yn, 0, 1)                                  {c |}
    {c |}e_hhh_relig           e_hhh_relig != .  c_consent == 1                  {c |}
    {c |} f_hr_fn_r1       !missing(f_hr_fn_r1)  c_consent == 1                  {c |}
    {c BLC}{hline 11}{c -}{hline 26}{c -}{hline 15}{c -}{hline 17}{c BRC}
{txt}{...}

{pstd}
{opt variable} column/variable stores the variable to check for outliers. This column only accepts a {help varname}. The variable column is required.  

{pstd}
{opt assert} column/variable indicates the logic check to perform on the variable specified in the corresponding variable column. Note that this is expected to be a valid Stata syntax and {cmd:ipachecklogic} will flag observations that do not pass this logical check.

{pstd}
{opt if_condition} column/variable is used to apply the logical check to a subset of the dataset. eg. to apply logical checks to a subset of observations with valid consent. Like the assert column, this is expected to be a valid Stata statement. eg. consent == 1 or subdate == date("14feb2023", "DMY")


{pstd}
{opt keepvars} column/variable indicates the additional variables to export to the {opt outfile} sheet. 

{pstd}
{cmd:ipachecklogic} is one of the checks run in IPA's Data Management System. 
It can be run within IPA's Data Management System, where inputs are entered into a globals do-file 
and outputs are formatted in a .xlsx file or used directly from the command window or other do-files. See {help ipacheck} for more details on how to use the Data Management System.

{title:Examples}

{synoptline}
  {text:Setup}
	{phang}{com}   . use "https://raw.githubusercontent.com/PovertyAction/high-frequency-checks/master/data/household_survey.dta", clear{p_end}
	{phang}{com}   . copy "https://raw.githubusercontent.com/PovertyAction/high-frequency-checks/master/excel/examples/hfc_inputs_example.xlsm" "hfc_inputs_example.xlsm", replace{p_end}

  {text:Run check}
	{phang}{com}   . ipachecklogic using "hfc_inputs_example.xlsm", id(hhid) enum(a_enum_id) date(starttime) outf("hfc_outputs.xlsx") sheetrep{p_end}
	
{synoptline}

{txt}{...}

{title:Stored results}

{p 6} {cmd:ipachecklogic} stores the following in r():{p_end}

{synoptset 25 tabbed}{...}
{syntab:{opt Scalars}}
{synopt:{cmd: r(N_logic)}}number of logic violations found{p_end}
{synopt:{cmd: r(N_vars)}}number variables with logic violations{p_end}
{p2colreset}{...}
	
{title:Acknowledgement}

{pstd}
{cmd:ipachecklogic} is based on previous versions written by Chris Boyer of Innovations for Poverty Action.

{title:Authors}

{pstd}
Ishmail Azindoo Baako
(Innovations for Poverty Action){p_end}

{pstd}For questions or suggestions, submit a
{browse "https://github.com/PovertyAction/high-frequency-checks/issues":GitHub issue}
or e-mail researchsupport@poverty-action.org.{p_end}

{title:Also see}

User-written: {helpb ipacheckcorrections:ipacheckcorrections}