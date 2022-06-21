{smcl}
{* *! version 4.0.0 11may2022}{...}
{title:Title}
{phang}
{cmd:ipacheckcorrections} {hline 2}
Make replacements, drop observations, or mark as okay observations that are specified 
in an external dataset.

{marker syntax}{...}
{title:Syntax}

{p 8 10 2}
{cmd:ipacheckcorrections using} {it:{help filename}}{cmd:,}
{opth sheet:name(string)} 
{opth id(varlist)} 
[{it:options}]

{synoptset 26 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}

{synopt:*{opth sh:eet(string)}}Excel worksheet to load{p_end}
{synopt:*{opth id(varname)}}variables for matching observations with
the corrections specified in the using dataset{p_end}

{syntab:Specifications}

{synopt:{opth logf:ile(filename)}}option to produce log of changes{p_end}
{synopt:{opth logsh:eet(string)}}save logfile to excel worksheet{p_end}
{synopt:{opt nol:abel}}export values instead of value labels to logfile{p_end}
{synopt:{opt ignore}}suppress error if correction fails{p_end}
{synoptline}
{p2colreset}{...}

{p 4 6 2}* {opt id()} is always required. {opt sheetname("sheetname")} is required for {opt .xls} and {opt .xlsx} correction files.{p_end} 
{p 4 6 2}Variables {opt variable}, {opt value}, {opt newvalue} & {opt action} are required in using file.

{marker description}{...}
{title:Description}

{pstd}
{cmd:ipacheckcorrections} modifies the dataset currently in memory by
making changes that are specified in an external dataset or the corrections file.

{pstd}
{cmd:ipacheckcorrections} allows the option to replace a current value with 
another value, drop the entire observation (such as in the case of a duplicate), 
or mark a value in an observation as "okay". The action to "okay" a value is only relevant 
when {cmd:ipacheckcorrections} is used within IPA's Data Management System. When 
an observation is "okay", the {help ipacheckoutliers} check no longer flags the value as an outlier. 

{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt sheet("sheetname")} imports the worksheet named sheetname in the 
corrections file. This is required if the correction file is {opt .xls} or 
{opt .xlsx} formats. option {opt sheet()} is ignored if correction file is 
{opt .csv} or {opt .dta} file.

{phang}
{opt id} specifies the id variable for matching observations between the corrections 
file and the dataset in memory.

{dlgtab:Specifications}

{phang}
{opt logfile("filename.xlsx")} exports a corrections logfile to the {opt filename.xlsx}. 
The default is to not export a corrections log file. The corrections logfile saves 
information about the status of each correction specified in the using file. 
Note that the log file will also include all the data in the corrections file.    

{phang}
{opt logsheet("sheetname")} exports the corrections log to the {opt "sheetname"} 
of the {opt "filename.xlsx"} workbook. {opt logsheet()} is required if {opt logfile()} 
is specified.

{phang}
{opt nolabel} exports the underlying numeric values instead of the value labels.

{phang}
{opt ignore} suppresses error if correction fails. Default behaviour is to return 
an error code of 198. {opt ignore} is useful when used with {opt logfile()}. 

{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:ipacheckcorrections} changes the contents of existing variables by
making corrections that are specified in a external dataset. The corrections file 
should contain one row per correction. Corrections are described by a "variable" 
column/variable that contains the name of the variable to change, a "value" 
column/variable that contains the current value, a "newvalue" column/variable that 
contains the correct value (or is missing if action is "okay" or "drop") and an 
"action" variable/column that contains the action to take ie. "replace", "drop" 
or "okay".  The corrections file should also store variables shared by the dataset 
in memory that indicate the subset of the data for which each correction is intended; 
these are specified to option {opt id()}, and are used to match observations in 
memory to the corrections in the correction file.{p_end}

{pstd}
Below, an example corrections file is shown with additional optional variables:
{cmd:hhid}, to be specified to {opt id()}, {cmd:variable}, {cmd: value}, 
{cmd:newvalue}, {cmd:action}. The correction file may also include additional 
variables which contain information that are useful for tracking. Although additional 
variables will not be used, they will be included in the corrections logfile if 
the logfile option is used.{p_end}

{cmd}{...}
    {c TLC}{hline 10}{c -}{hline 12}{c -}{hline 14}{c -}{hline 14}{c -}{hline 12}{c -}{hline 27}{c TRC}
    {c |}  hhid        variable            value        newvalue   action       comments               {c |}
    {c LT}{hline 10}{c -}{hline 12}{c -}{hline 14}{c -}{hline 14}{c -}{hline 12}{c -}{hline 27}{c RT}
    {c |}      105     district             12             13      replace      respondent relocated   {c |}
    {c |}      125          age              1              2      replace      enum mistake           {c |}
    {c |}      138       gender              0                     okay         checked                {c |}
    {c |}      199     district             31                     drop         duplicate              {c |}
    {c |}      112   am_failure              1              3      replace      enum mistake           {c |}
    {c BLC}{hline 10}{c -}{hline 12}{c -}{hline 14}{c -}{hline 14}{c -}{hline 12}{c -}{hline 27}{c BRC}
{txt}{...}

{pstd}
For each observation of the corrections file, {cmd:ipacheckcorrections} validates 
the current value by verifying that the value specified in "value" matches the 
value for the variable and id specified. The correction fails if there is a mismatch 
and the command returns and error unless the option {opt: ignore} is specified. 

{pstd}
For each observation of the corrections file,
{cmd:ipacheckcorrections} essentially runs the following {help replace} 
command when the {opt replace} option is used:

{phang}
{cmd:replace} {it:variable} {cmd:=} {it:newvalue}
{cmd:if uniqueid ==} {it:id}

{pstd}
That is, the effect of {cmd:ipacheckcorrections} here is the same as
these {cmd:replace} commands:

{cmd}{...}
{phang}replace district{space 3}= 13 if hhid == 105{p_end}
{phang}replace age{space 8}= 2{space 2}if hhid == 125{p_end}
{phang}replace am_failure = 3{space 2}if hhid == 112{p_end}
{txt}{...}

{pstd} 
Similarly, for the {opt drop} option, {ipacheckreadreplace} essentially runs:

{phang}
{cmd:drop} {cmd:if} {it:id} {cmd:==} {it:value}

{pstd}
The variable specified to {opt value()} may be numeric or string.

{pstd}
It is recommended to use the corrections.xlsm template file from IPA's 
Data Management System. See {help ipacheck} for information on how to download
this file. {cmd:ipacheckcorrections} also accepts .xlsx, .xls, .csv & .dta files.

{marker remarks_promoting}{...}
{title:Remarks for promoting storage types}

{pstd}
{cmd:ipacheckcorrections} will change variables' {help data types:storage types} in
much the same way as {helpb replace},
promoting storage types according to these rules:

{phang2}1.  Storage types are only promoted; they are never {help compress:compressed}.{p_end}
{phang2}2.  The storage type of {cmd:float} variables is never changed.{p_end}
{phang2}3.  If a variable of integer type ({cmd:byte}, {cmd:int}, or {cmd:long}) is replaced with
a non-integer value, its storage type is changed to
{cmd:float} or {cmd:double} according to
the current {helpb set type} setting.{p_end}
{phang2}4.  If a variable of integer type is replaced with an integer value that
is too large or too small for its current storage type, it is promoted to
a longer type ({cmd:int}, {cmd:long}, or {cmd:double}).{p_end}
{phang2}5.  When needed, {cmd:str}{it:#} variables are promoted to
a longer {cmd:str}{it:#} type or to {cmd:strL}.{p_end}

{marker examples}{...}
{title:Examples}

{synoptline}
  {text:Setup}
	{phang}{com}   . use "https://raw.githubusercontent.com/PovertyAction/ipa_dms4.0/final/data/household_survey.dta", clear{p_end}
	{phang}{com}   . copy "https://raw.githubusercontent.com/PovertyAction/ipa_dms4.0/final/excel/corrections_example.xlsm" "corrections_example.xlsm", replace{p_end}

  {text:Apply changes in duplicates sheet}
	{phang}{com}   .ipacheckcorrections using "corrections_example.xlsm", sheet("duplicates") id(key) logf("corrections_log.xlsx") logs("duplicates"){p_end}
	
  {text:Apply changes in other issues sheet ignoring failed corrections}
	{phang}{com}   .ipacheckcorrections using "corrections_example.xlsm", sheet("other issues") id(hhid) logf("corrections_log.xlsx") logs("other issues") ignore{p_end}
	
{synoptline}

{text}{...}
{marker stored_results}{...}
{title:Stored results}

{p 6} {cmd:ipacheckcorrections} stores the following in r():{p_end}

{synoptset 20 tabbed}{...}
{syntab:{opt Scalars}}
{synopt:{cmd: r(N_obs)}}number of observations in correction file{p_end}
{synopt:{cmd: r(N_succesful)}}number of successful corrections{p_end}
{synopt:{cmd: r(N_failed)}}number of failed corrections{p_end}
{p2colreset}{...}

{txt}{...}
{marker acknowledgement}{...}
{title:Acknowledgement}

{pstd}
{cmd:ipacheckcorrections} and it's previous version {cmd:ipacheckreadreplace} are based on {help readreplace} written by Ryan Knight & Matthew White of Innovations for Poverty Action.

{txt}{...}
{marker authors}{...}
{title:Authors(s)}

{pstd}
Ishmail Azindoo Baako
(Innovations for Poverty Action){p_end}

{pstd}For questions or suggestions, submit a
{browse "https://github.com/PovertyAction/high-frequency-checks/issues":GitHub issue}
or e-mail researchsupport@poverty-action.org.{p_end}

{title:Also see}

{psee}
User-written:  {helpb ipacheckspecifyrecode}, {helpb readreplace}
{p_end}
