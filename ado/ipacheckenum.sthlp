{smcl}
{* *! version 3.0.0 Innovations for Poverty Action 30oct2018}{...}
{title:Title}

{phang}
{cmd:ipacheckenum} {hline 2}
Create enumerator dashboard with rates of interviews, duration, don't know, refusal, 
missing, and other by enumerator, and variable statistics by enumerator. 

{marker syntax}{...}
{title:Syntax}

{p 8 10 2}
{cmd:ipacheckenum} {it:{help varname}} {cmd:using} {it:{help filename}}{cmd:,}
{opth dkrfvars(varlist)} 
{opth missvars(varlist)} 
{opth othervars(varlist)} 
{opth statvars(varlist)} 
{opth subdate(varname)}
[{it:options}]

{* Using -help readreplace- as a template.}{...}
{* 20 is the position of the last character in the first column + 3.}{...}
{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{* Using -help heckman- as a template.}{...}
{p2coldent:* {opth dkrfvars(varlist)}}variables to show rates of don't know/refuse{p_end}
{p2coldent:* {opth missvars(varlist)}}variables to show rates of missing values {p_end}
{p2coldent:* {opth othervars(varlist)}}variables to show rates of choosing "other"{p_end}
{p2coldent:* {opth statvars(varlist)}}variables to show statistics by enumerator {p_end}
{p2coldent:* {opth subdate(varname)}}submission date variable (usually the SurveyCTO-created submissiondate), used in summary sheet {p_end}

{syntab:Specifications}
{synopt:{opth durvars(varlist)}}variables that measure duration{p_end}
{synopt:{opth duration(varname)}}variable for entire survey duration, used in summary sheet{p_end}
{synopt:{opth exclude(varlist)}}variables to exclude from rates {p_end}
{synopt:{opth foteam(varname)}}variable of field officer teams {p_end}
{synopt:{opth days(numlist)}}number of days to show summary statistics next to total; default is 7{p_end}
{synopt:{opt mean}}calculate mean in variable statistics by enumerator {p_end}
{synopt:{opt sd}}calculate standard devation in variable statistics by enumerator {p_end}
{synopt:{opt min}}calculate minimum in variable statistics by enumerator {p_end}
{synopt:{opt max}}calculate maximum in variable statistics by enumerator {p_end}

{synoptline}
{p2colreset}{...}
{* Using -help heckman- as a template.}{...}
{p 4 6 2}* {opt dkrfvars()}, {opt missvars()}, {opt othervars()}, {opt statvars()}, and {opt subdate()} are required.


{title:Description}

{pstd}
{cmd:ipacheckenum} creates an Excel workbook with 7 sheets: 

{phang2}.  "summary": summary of average interviews, missing, don't know, refuse, other, and duration by enumerator in total and number of days specified in {it:days} option{p_end}
{phang2}.  "missing": average of missing values by enumerator for {it:missvars} variables{p_end}
{phang2}.  "dontknow": average of "don't know" values by enumerator for {it:dkrfvars} variables{p_end}
{phang2}.  "refusal": average of "refuse" values by enumerator for {it:dkrfvars} variables{p_end}
{phang2}.  "other": average of "other" values by enumerator for {it:othervars} variables{p_end}
{phang2}.  "duration": average of duration by enumerator for {it:durvars} variables{p_end}
{phang2}.  "stats": statistics by enumerator for {it:statvars} variables{p_end}

{pstd}
Note that this command recognizes "refuse" as ".r", "missing" as ".", "other" as ".o", and "don't know" as ".d".

{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:ipacheckenum} is one of the checks run in IPA's high frequency checks. 
It can be run within IPA's Data Management System, where inputs are entered into an .xlsm file 
and outputs are formatted in a .xlsx file. See {help ipacheck} for more details on how to use the Data Management System.


{marker examples}{...}
{title:Examples}

{pstd}
In IPA's master_check.do file created when using the Data Management System, the inputs you enter into
hfc_inputs.xlsm are used as globals through {cmd:ipacheckimport} to fill in this command:
{p_end}{cmd}{...}
{phang2}.    ipacheckenum ${enum} using "${enumdb}",
     dkrfvars(${dkrf_variable14})
     missvars(${missing_variable14})
     durvars(${duration_variable14})
     othervars(${other_variable14})
     statvars(${stats_variable14})
     exclude(${exclude_variable14})
     subdate(${submission_date14})
     ${stats}
{txt}{...}
	
{marker authors}{...}
{title:Authors}

{pstd}Innovations for Poverty Action{p_end}

{pstd}For questions or suggestions, submit a
{browse "https://github.com/PovertyAction/high-frequency-checks/issues":GitHub issue}
or e-mail researchsupport@poverty-action.org.{p_end}

