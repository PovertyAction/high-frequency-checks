{smcl}
{* *! version 4.0.0 Innovations for Poverty Action 15oct2022}{...}
{title:Title}

{phang}
{cmd:ipacheckconstraints} {hline 2}
Checks for soft and hard constraint violations in numeric survey variables.

{marker syntax}{...}
{title:Syntax}

{p 8 10 2}
{cmd:ipacheckconstraints using} {it:{help filename}}{cmd:,}
{opt sh:eet("sheetname")}  
{opth enum:erator(varname)}  
{opth date(varname)} 
{opth id(varname)} 
{opt outf:ile("filename.xlsx")}
[{it:{help ipacheckconstraints##options:options}}]

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
{synopt:{opt outsh:eet("sheetname")}}save output of constraint violations to excel sheet{p_end}
{synopt:{opt sheetmod:ify}}modify excel sheet {cmd:outsheet}{p_end}
{synopt:{opt sheetrep:lace}}overwrite excel sheet {cmd:outsheet}{p_end}
{synopt:{opt nol:abel}}export variable values instead of value labels{p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}* {opt enumerator()}, {opt id()}, {opt date()} and {opt outfile()} are required.{p_end}
{p 4 6 2}* Variables {opt variable}, {opt hard_min}, {opt soft_min}, {opt soft_max} and {opt hard_max} are required in using data.{p_end}

{title:Description}

{pstd}
{cmd:ipacheckconstraints} checks for hard and soft constraint violations in numeric survey variables. Hard constraints violations occur when variables contain values which should not exist in the dataset. These are often constrained in the electronic survey instrument. eg. It will be an obvious error if a respondents age is listed as 200 years. Soft constraints on the other hand occur when the data contains values which are within possible but are less likely. For instance, the Research Associate may like to flag and investigate any situation where the respondent is over 80 years old or if the income of a household member of over 10,000 USD per month. Please note that the threshold for flagging constraints have to be specified by the user in the using file. 

{title:Options}

{dlgtab:Main}

{phang}
{opt sheet("sheetname")} specifies the Excel worksheet to load from the {help using} file. This is used if the using file is {opt .xls} or {opt .xlsx} formats and is ignored if the using file is {opt .csv} or {opt .dta} file. The default value is "constraints".

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
{opt outfile("filename.xlsx")} specifies Excel workbook to export the constraints report into. 
{cmd:outfile()} is required. Excel formats xls and xlsx are supported in {cmd:outfile()}. 
If a file extension is not specified with {cmd:outfile()}, .xls is assumed, because 
this format is more common and is compatible with more applications that also can read from Excel files.

{dlgtab:Specifications}

{pstd}
{opt outsheet("sheetname")} specifies the Excel worksheet Excel sheet to export the 
output to for the {opt outfile()} specified. The default is to save to Excel sheet "constraints".

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
{cmd:ipacheckconstraints} is one of the checks run in IPA's Data Management System. 
It can be run within IPA's Data Management System, where inputs are entered into an Excel inputs sheet 
and outputs are formatted in a .xlsx file or used directly from the command window 
or other do-files. See {help ipacheck} for more details on how to use the 
Data Management System. 

{pstd}
Below, an example {opt inputs file} is shown with additional optional variables:
The variabels {cmd:variable}, {cmd:hard_min}, {cmd:soft_min}, {cmd:soft_max} and {cmd:hard_max} are required. The inputs file may also include additional variables which contain information that are useful for tracking, although these additional variables will not be used. 

{cmd}{...}
    {c TLC}{hline 15}{c -}{hline 9}{c -}{hline 9}{c -}{hline 12}{c -}{hline 20}{c TRC}
    {c |}       variable hard_min soft_min soft_max    hard_max       keepvars{c |}
    {c LT}{hline 15}{c -}{hline 9}{c -}{hline 9}{c -}{hline 12}{c -}{hline 20}{c RT}
    {c |}    f_hr_age_r1       18       25       80         120    a_enum_name{c |}
    {c |}    f_hr_age_r*                         80         120    a_pl_hhh_fn{c |}
    {c |}      m_mon_inc        0              1500        9000    a_pl_pgv_fn{c |}
    {c |}    f_hr_sch_r*        0                   f_hr_age_r*     a_pl_ch_fn{c |}
    {c BLC}{hline 15}{c -}{hline 9}{c -}{hline 9}{c -}{hline 12}{c -}{hline 20}{c BRC}
{txt}{...}

{pstd}
{opt variable} column/variable stores the variable to check for constraint violations. This column only accepts a {help varlist}. The variables specified in this column must be a numeric variable and {cmd:ipacheckconstraints} will return an error if it is not. The variable column is required.  

{pstd}
{opt hard_min} column/variable specified the hard minimum value or variable. Any value in the dataset that is less than the value specified in {opt hard_min} or the value of the corresponding variable specified in {opt hard_min} will be flagged as a hard constraint violation. For instance, using the above table, {cmd:ipacheckconstraints} will flag any non missing value for f_hr_age_r1 as a hard_min violation if f_hr_age_r1 < 18. 

{pstd}
{opt soft_min} column/variable specified the soft minimum value or variable. Any value in the dataset that is less than the value specified in {opt soft_min} or the value of the corresponding variable specified in {opt soft_min} will be flagged as a soft constraint violation. For instance, using the above table, {cmd:ipacheckconstraints} will flag any non missing value for f_hr_age_r1 as a soft_min violation if f_hr_age_r1 < 25. 

{pstd}
{opt soft_max} column/variable specified the soft maximum value or variable. Any value in the dataset that is greater than the value specified in {opt soft_max} or the value of the corresponding variable specified in {opt soft_max} will be flagged as a soft constraint violation. For instance, using the above table, {cmd:ipacheckconstraints} will flag any non missing value for f_hr_age_r1 as a soft_max violation if f_hr_age_r1 > 25. 

{pstd}
{opt hard_max} column/variable specified the hard maximum value or variable. Any value in the dataset that is greater than the value specified in {opt hard_max} or the value of the corresponding variable specified in {opt hard_max} will be flagged as a hard constraint violation. For instance, using the above table, {cmd:ipacheckconstraints} will flag any non missing value for f_hr_age_r1 as a hard_max violation if f_hr_age_r1 > 120. 

{pstd}
{opt keepvars} column/variable indicates the additional variables to export to the {opt outfile} sheet. 

{pstd}
{cmd:ipacheckoutliers} is one of the checks run in IPA's Data Management System. 
It can be run within IPA's Data Management System, where inputs are entered into a globals do-file 
and outputs are formatted in a .xlsx file or used directly from the command window or other do-files. See {help ipacheck} for more details on how to use the Data Management System.

{title:Examples}

{synoptline}
  {text:Setup}
	{phang}{com}   . use "https://raw.githubusercontent.com/PovertyAction/high-frequency-checks/master/data/household_survey.dta", clear{p_end}
	{phang}{com}   . copy "https://raw.githubusercontent.com/PovertyAction/high-frequency-checks/master/excel/examples/hfc_inputs_example.xlsm" "hfc_inputs_example.xlsm", replace{p_end}

  {text:Destring duration variable}

	{phang}{com}   . destring duration, replace{p_end}

  {text:Recode extended missing values so they are not flagged as violations}

	{phang}{com}   . ds, has(type numeric){p_end}
	{phang}{com}   . recode `r(varlist)' (-888 = .r) (-999 = .d){p_end}

  {text:Run check}
	{phang}{com}   . ipacheckconstraints using "hfc_inputs_example.xlsm", id(hhid) enum(a_enum_id) date(starttime) outf("hfc_outputs.xlsx") sheetrep{p_end}
	
{synoptline}

{txt}{...}

{title:Stored results}

{p 6} {cmd:ipacheckconstraints} stores the following in r():{p_end}

{synoptset 25 tabbed}{...}
{syntab:{opt Scalars}}
{synopt:{cmd: r(N_constraints)}}number of constraint violation found{p_end}
{synopt:{cmd: r(N_vars)}}number variables with outlier values{p_end}
{p2colreset}{...}
	
{title:Acknowledgement}

{pstd}
{cmd:ipacheckconstraints} is based on previous versions written by Chris Boyer of Innovations for Poverty Action.

{title:Authors}

{pstd}
Ishmail Azindoo Baako
(Innovations for Poverty Action){p_end}
{pstd}{it:Last updated: October 15, 2022}{p_end}

{pstd}For questions or suggestions, submit a
{browse "https://github.com/PovertyAction/high-frequency-checks/issues":GitHub issue}
or e-mail researchsupport@poverty-action.org.{p_end}

{title:Also see}

User-written: {helpb ipacheckcoonstraints:ipacheckoutliers}, {helpb ipacheckcorrections:ipacheckcorrections}