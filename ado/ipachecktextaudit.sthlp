{smcl}
{* *! version 3.0.0 Innovations for Poverty Action 30oct2018}{...}
{title:Title}

{phang}
{cmd:ipachecktextaudit} {hline 2}
Merges and summarizes text audit media files from SurveyCTO.
 
{marker syntax}{...}
{title:Syntax}

{p 8 10 2}
{cmd:ipachecktextaudit} {it:{help varname}} {cmd:using} {help filename}{cmd:,}
{opth med:ia(string)}  
{opth saving(filename)} 
{opth enumerator(varname)}
[{it:options}]

{* Using -help readreplace- as a template.}{...}
{* 20 is the position of the last character in the first column + 3.}{...}
{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{* Using -help heckman- as a template.}{...}
{p2coldent:* {opth med:ia(string)}}media files directory {p_end}
{p2coldent:* {opth saving(filename)}}output filename where sheet "12. comments" will be saved {p_end}
{p2coldent:* {opth id(varname)}}ID variable, automatically included in every flagged observation {p_end}
{p2coldent:* {opth enumerator(varname)}}enumerator variable, automatically included in every flagged observation {p_end}

{syntab:Specifications}
{synopt:{opth keep:vars(varlist)}}variables that should also be included in output sheet{p_end}
{synopt:{opth pre:fix(varname)}}specifies the prefix of text audit file names. Default is "ta_"{p_end}
{synopt:{opth stats(string)}}specified which statistics are summarized in output sheet{p_end}
{synopt:{opth dta(string)}}saves a dataset of output{p_end}


{synoptline}
{p2colreset}{...}
{* Using -help heckman- as a template.}{...}
{p 4 6 2}* {opt media()}, {opt saving()}, {opt id()}, and {opt enumerator()} are required.


{title:Description}

{pstd}
{cmd:ipachecktextaudit} creates an output sheet that merges all media files created when using the SurveyCTO
{it:text audit} features. Since these are downloaded as separate media files per observation, 
this command compiles all text audits by question and by group (if specified) into
an excel sheet "13. text audit". Note that this command requires an excel input sheet with at least one 
column, "group_name", where all groups to be summarized should be listed. IPA's Data Management System input 
sheet also includes "exclude_variable" (can be empty) and "keep" (for keepvars option).

{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:ipachecktextaudit} is one of the checks run in IPA's high frequency checks. 
It can be run within IPA's Data Management System, where inputs are entered into an .xlsm file 
and outputs are formatted in a .xlsx file. See {help ipacheck} for more details on how to use the Data Management System.


{marker examples}{...}
{title:Examples}

{pstd}
In IPA's master_check.do file created when using the Data Management System, the inputs you enter into
hfc_inputs.xlsm are used as globals through {cmd:ipacheckimport} to fill in this command:
{p_end}{cmd}{...}

{phang2}
.     ipachecktextaudit ${textaudit} using "${infile}",
    saving("${textauditdb}")
    media("${sctomedia}")
    enumerator(${enum})
    keepvars(${keep13})
{txt}{...}
	
 

{marker authors}{...}
{title:Authors}

{pstd}Innovations for Poverty Action{p_end}

{pstd}For questions or suggestions, submit a
{browse "https://github.com/PovertyAction/high-frequency-checks/issues":GitHub issue}
or e-mail researchsupport@poverty-action.org.{p_end}

