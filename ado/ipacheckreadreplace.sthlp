{smcl}
{* *! version 3.0.0 Innovations for Poverty Action 30oct2018}{...}
{title:Title}

{phang}
{cmd:ipacheckreadreplace} {hline 2}
Similar to {help readreplace}, this command make replacements, drop observations,
or marks as okay observations that are specified in an external dataset.


{marker syntax}{...}
{title:Syntax}

{p 8 10 2}
{cmd:readreplace using} {it:{help filename}}{cmd:,}
{opth id(varlist)} 
{opth var:iable(varname)} 
{opth val:ue(varname)}
{opth newval:ue(varname)} 
{opth act:ion(varname)}
{opth comm:ents(varname)}
[{it:options}]

{* Using -help readreplace- as a template.}{...}
{* 20 is the position of the last character in the first column + 3.}{...}
{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{* Using -help heckman- as a template.}{...}
{p2coldent:* {opth id(varname)}}variables for matching observations with
the replacements specified in the using dataset{p_end}
{p2coldent:* {opth var:iable(varname)}}variable in the using dataset that
indicates the variables to replace{p_end}
{p2coldent:* {opth val:ue(varname)}}variable in the using dataset that
stores the current values{p_end}
{p2coldent:* {opth newval:ue(varname)}}variable in the using dataset that
stores the replacement values{p_end}
{p2coldent:* {opth act:ion(varname)}}variable in the using dataset that
indicates the action to take for each observation{p_end}
{p2coldent:* {opth comm:ents(varname)}}variable in the using dataset that
stores the comments for each action{p_end}

{syntab:Specifications}
{synopt:{opth logus:ing(filename)}}option to produce log of changes{p_end}
{synopt:{opth sheet(string)}}specify sheet within replacements file to use{p_end}
{synoptline}
{p2colreset}{...}
{* Using -help heckman- as a template.}{...}
{p 4 6 2}* {opt id()}, {opt variable()}, {opt value()}, {opt newvalue()}, 
{opt action()}, and {opt comments()} are required.


{title:Description}

{pstd}
{cmd:ipacheckreadreplace} modifies the dataset currently in memory by
making replacements that are specified in an external dataset,
the replacements file.

{pstd}
{cmd:ipacheckreadreplace} allows the option to replace a current value with 
another value, drop the entire observation (such as in the case of a duplicate), 
or "okay" an observation. The option to "okay" an observation is only relevant 
when {cmd:ipacheckreadreplace} is used within IPA's Data Management System. When 
an observation is "okay", it no longer appears as output in the high frequency 
checks output file. It is recommended to use a truly unique value (such as "key" 
if SurveyCTO is used to collect data) because {cmd:ipacheckreadreplace} will not
run if there are duplicates in the ID variable specified.


{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:From {help readreplace}:} {cmd:ipacheckreadreplace} changes the contents of existing variables by
making replacements that are specified in a separate dataset,
the replacements file. The replacements file should be long by
replacement such that each observation is a replacement to complete.
Replacements are described by a variable that contains
the name of the variable to change, specified to option {opt variable()},
and a variable that stores the new value for the variable,
specified to option {opt value()}. The replacements file should also hold
variables shared by the dataset in memory that indicate
the subset of the data for which each change is intended;
these are specified to option {opt id()}, and are used to match
observations in memory to their replacements in the replacements file.

{pstd}
Below, an example replacements file is shown with six variables:
{cmd:uniqueid}, to be specified to {opt id()},
{cmd:Question}, to be specified to {opt variable()},
{cmd: CurrentValue}, to be specified to {opt value()},
{cmd:CorrectValue}, to be specified to {opt newvalue()},
{cmd:Action}, to be specified to {opt action()}, 
and {cmd:Comments}, to be specified to {opt comments()}.

{cmd}{...}
    {c TLC}{hline 10}{c -}{hline 12}{c -}{hline 14}{c -}{hline 14}{c -}{hline 12}{c -}{hline 18}{c TRC}
    {c |} uniqueid     Question   CurrentValue   CorrectValue      Action       Comments      {c |}
    {c LT}{hline 10}{c -}{hline 12}{c -}{hline 14}{c -}{hline 14}{c -}{hline 12}{c -}{hline 18}{c RT}
    {c |}      105     district             12             13      replace      enum comment  {c |}
    {c |}      125          age              1              2      replace      enum mistake  {c |}
    {c |}      138       gender              0                     okay         checked       {c |}
    {c |}      199     district             31                     drop         duplicate     {c |}
    {c |}        2   am_failure              1              3      replace      enum mistake  {c |}
    {c BLC}{hline 10}{c -}{hline 12}{c -}{hline 14}{c -}{hline 14}{c -}{hline 12}{c -}{hline 18}{c BRC}
{txt}{...}

{pstd}
For each observation of the replacements file,
{cmd:ipacheckreadreplace} essentially runs the following {helpb replace} 
command when the {opt replace} option is used:

{phang}
{cmd:replace} {it:Question_value} {cmd:=} {it:CorrectValue_value}
{cmd:if uniqueid ==} {it:uniqueid_value}

{pstd}
That is, the effect of {cmd:ipacheckreadreplace} here is the same as
these {cmd:replace} commands:

{cmd}{...}
{phang}replace district{space 3}= 13 if uniqueid == 105{p_end}
{phang}replace age{space 8}= 2{space 2}if uniqueid == 125{p_end}
{phang}replace am_failure = 3{space 2}if uniqueid == 2{p_end}
{txt}{...}

{pstd} 
Similarly, for the {opt drop} option, {ipacheckreadreplace} essentially runs:

{phang}
{cmd:drop} {cmd:if} {it:uniqueid} {cmd:==} {it:uniqueid_value}


{pstd}
The variable specified to {opt value()} may be numeric or string;
either is accepted.

{pstd}
The replacements file should be the hfc_replacements.xlsm file from IPA's 
Data Management System. See {help ipacheck} for information on how to download
this file. {cmd:ipacheckreadreplace} also accepts .xlsx, .xls, and .csv files.


{marker remarks_promoting}{...}
{title:Remarks for promoting storage types}

{pstd}
{cmd:readreplace} will change variables' {help data types:storage types} in
much the same way as {helpb replace},
promoting storage types according to these rules:

{* Using -help 663- as a template.}{...}
{phang2}1.  Storage types are only promoted;
they are never {help compress:compressed}.{p_end}
{phang2}2.  The storage type of {cmd:float} variables is never changed.{p_end}
{phang2}3.  If a variable of
integer type ({cmd:byte}, {cmd:int}, or {cmd:long}) is replaced with
a noninteger value, its storage type is changed to
{cmd:float} or {cmd:double} according to
the current {helpb set type} setting.{p_end}
{phang2}4.  If a variable of integer type is replaced with an integer value that
is too large or too small for its current storage type, it is promoted to
a longer type ({cmd:int}, {cmd:long}, or {cmd:double}).{p_end}
{phang2}5.  When needed, {cmd:str}{it:#} variables are promoted to
a longer {cmd:str}{it:#} type or to {cmd:strL}.{p_end}


{marker examples}{...}
{title:Examples}

{pstd}
In IPA's master_check.do file created when using the Data Management System, the inputs you enter into
hfc_inputs.xlsm are used as globals through {cmd:ipacheckimport} to fill in this command, Note the 
hfc_replacements.xlsm file created when using IPA's Data Management System creates sheets for replacements
with the following column names and recommends using "key" for the ID variable.
{p_end}{cmd}{...}

{phang2}. ipacheckreadreplace using "${repfile}",
    id("key")
    variable("variable")
    value("value")
    newvalue("newvalue")
    action("action")
    comments("comments")
    sheet("${repsheet}")
    logusing("${replog}")


{txt}{...}
{marker authors}{...}
{title:Authors}

{pstd}Innovations for Poverty Action{p_end}

{pstd}For questions or suggestions, submit a
{browse "https://github.com/PovertyAction/high-frequency-checks/issues":GitHub issue}
or e-mail researchsupport@poverty-action.org.{p_end}



{title:Also see}

{psee}
User-written:  {helpb cfout}, {helpb bcstats}, {helpb readreplace}
{p_end}
