{smcl}
{* *! version 4.0.0 11may2022}{...}
{title:Title}

{phang}
{cmd:ipacheckspecifyrecode} {hline 2}
Recode other specify values of the dataset in memory using an external dataset.

{title:Syntax}

{p 8 10 2}
{cmd:ipacheckspecifyrecode using} {it:{help filename}}{cmd:,}
{opth sh:eet("sheetname")} 
{opth id(varlist)} 
[{it:{help ipacheckspecifyrecode##options:options}}]

{marker options}
{synoptset 26 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}

{synopt:*{opth sh:eet(string)}}Excel worksheet to load{p_end}
{synopt:*{opth id(varname)}}survey ID variable{p_end}

{syntab:Specifications}

{synopt:{opt logf:ile("filename.xlsx")}}produce log of changes{p_end}
{synopt:{opt logsh:eet("sheetname")}}save logfile to excel worksheet{p_end}
{synopt:{opth keep(varlist)}}additional variables in survey data export to log file{p_end}
{synopt:{opt sheetmod:ify}}modify Excel worksheet {cmd:outsheet}{p_end}
{synopt:{opt sheetrep:lace}}overwrite Excel worksheet {cmd:outsheet}{p_end}
{synopt:{opt nol:abel}}export values instead of value labels to logfile{p_end}
{synoptline}
{p2colreset}{...}

{p 4 6 2}* {opt id()} is always required. {opt sheet("sheetname")} is required if using file is a {opt xls}, {opt xlsx} or xlsm file.{p_end} 
{p 4 6 2}Variables {opt parent}, {opt child}, {opt match_type}, {opt match_text}, {opt recode_from} & {opt recode_to} are required in using file.

{title:Description}

{pstd}
{cmd:ipacheckspecifyrecode} recodes variables in the dataset in memory using specifications in an external dataset. The command makes it easier to recode other specify responses by allowing the user to set up patterns for recoding in an excel file. {cmd:ipacheckspecifyrecode} allows match_type {it:"exact"}, {it:"contains"}, {it:"begins with"} and {it:"ends with"}. If no match type is specified, "exact" is assumed. 

{title:Options}

{dlgtab:Main}

{phang}
{opt sheet("sheetname")} imports the worksheet "sheetname" from the using file. This is required if the using file is an Excel {opt xls}, {opt xlsx} or {opt xlsm} file. option {opt sheet()} is ignored if using file is a {opt .csv} or {opt .dta} file.

{phang}
{opt id} specifies the id variable for matching observations between the using file and the dataset in memory.

{dlgtab:Specifications}

{phang}
{opt logfile("filename.xlsx")} exports the results of other specify recodes to {opt filename.xlsx}. If the logfile() option is not specified, then no logfile will be exported. The logfile saves information about the status of each observation that was recoded and serves as a way to easily verify the recoding. 

{phang}
{opt logsheet("sheetname")} exports the other specify log to Excel sheetname {opt "sheetname"} of the {opt "filename.xlsx"} Excel workbook. {opt logsheet()} is required if {opt logfile()} is specified.

{pstd}
{opt sheetmodify} specifies that the log sheet should only be modified 
but not be replaced if it already exist.  

{pstd}
{opt sheetreplace} specifies that the log sheet should be replaced if 
it already exist.  

{phang}
{opt nolabel} exports the underlying numeric values instead of the value labels.

{title:Remarks}

{pstd}
{cmd:ipacheckspecifyrecode} changes the contents of existing variables by recoding 
other specify values in the parent variable based on instructions specified in the 
using file. The using file should contain one row per pattern for recoding. 
Replacements are described by a "parent" column/variable that contains the name 
of the parent variable to recode, a "child" column/variable that contains the 
name of the child variable, a "match_type" column/variable that contains the 
directive for matching, a "match_text" variable/column that contains values to 
match, a "recode_from" column/variable that contains the original parent value to 
recode, "recode_to" column/variable that contains the new parent value to recode 
to and an optional "new_label" column/variable that contains a new label definition if neccesary.

{pstd}
Below, an example using file is shown:

{cmd}{...}
    {c TLC}{hline 10}{c -}{hline 12}{c -}{hline 14}{c -}{hline 14}{c -}{hline 12}{c -}{hline 18}{c -}{hline 18}{c TRC}
    {c |}      parent         child     match_type      match_text    recode_from      recode_to        new_label{c |}
    {c LT}{hline 10}{c -}{hline 12}{c -}{hline 14}{c -}{hline 14}{c -}{hline 12}{c -}{hline 18}{c -}{hline 18}{c RT}
    {c |}   hhh_educ    hh_educ_osp          exact         College           -666              8                 {c |}
    {c |}       work       work_osp       contains            farm           -666              1                 {c |}
    {c |}   org_type   org_type_osp    begins with      Plan Inter           -666              7              NGO{c |}
    {c |} relation_* relation_osp_*      ends with          member           -666              8                 {c |}
    {c BLC}{hline 10}{c -}{hline 12}{c -}{hline 14}{c -}{hline 14}{c -}{hline 12}{c -}{hline 18}{c -}{hline 18}{c BRC}
{txt}{...}

{pstd}
For each observation of the using file, {cmd:ipacheckspecifyrecode} checks the value 
of child value using the values specified in "match_type" & "match_text" and recodes 
the corresponding parent value from the value in "recode_from" to the value in "recode_to". 
User can also specify a {helpb varlist} as "parent" & "child" values. However, the number 
of "parent" or "child" specification per row must match after expansion. 

{pstd}
It is recommended to use the specifyrecode.xlsxm template file from IPA's Data 
Management System. See {help ipacheck} for information on how to download this file. 
{cmd:ipacheckspecifyrecode} also accepts Excel xlsx, Excel xls, csv & dta files.

{title:Remarks for recoding string multiple select variables}

{pstd}
{cmd:ipacheckspecifyrecode} can also be used to recode numeric values stored in 
a string variables as in the case of select multiple variables. Ex. to recode the 
value "-666" in the string "1 -666" to "1 3", the user only needs to specify "-666" 
in the "recode_from" column/variable & "3" in the "recode_to" column/variable. 

{title:Remarks for advanced users}

{pstd}
{cmd:ipacheckspecifyrecode} uses {help regex:regular expressions} when {cmd:match_type} 
"contains", "begins width" & "ends with" are used. Advanced users can therefore use 
regular expression functions in the {cmd:match_text} column/variable when needed. 
This also means that users will need to escape regular expression characters if 
they want {cmd:ipacheckspecifyrecode} to assume them as literal text. 

{title:Examples}

{synoptline}
  {text:Setup}
	{phang}{com}   . use "https://raw.githubusercontent.com/PovertyAction/ipa_dms4.0/final/data/household_survey.dta", clear{p_end}
	{phang}{com}   . copy "https://raw.githubusercontent.com/PovertyAction/ipa_dms4.0/final/excel/specifyrecode_example.xlsm" "specifyrecode_example.xlsm", replace{p_end}

  {text:Recode other specify using "other specify recode" sheet of "specify_recode_example.xlsm"}
	{phang}{com}   .ipacheckspecifyrecode using "specifyrecode_example.xlsm", sheet("other specify recode") id(key) logf("specifyrecode_log.xlsx") logs("household survey") sheetrep{p_end}
	
{synoptline}

{text}{...}
{title:Stored results}

{p 6} {cmd:ipacheckspecifyrecode} stores the following in r():{p_end}

{synoptset 20 tabbed}{...}
{syntab:{opt Scalars}}
{synopt:{cmd: r(N_recoded)}}number of values recoded in dataset{p_end}
{p2colreset}{...}

{txt}{...}
{title:Authors(s)}

{pstd}
Ishmail Azindoo Baako
Innovations for Poverty Action{p_end}

{pstd}For questions or suggestions, submit a
{browse "https://github.com/PovertyAction/high-frequency-checks/issues":GitHub issue}
or e-mail researchsupport@poverty-action.org.{p_end}

{title:Also see}

{psee}
User-written:  {helpb ipacheckspecify}, {helpb ipacheckcorrections}, {helpb readreplace}
{p_end}
