{smcl}
{* *! version 3.0.0 Innovations for Poverty Action 30oct2018}{...}
{title:Title}

{phang}
{cmd:ipatrackversions} {hline 2}
Create a summary sheet detailing versions used by day, and flags interviews using outdated form versions. 

{marker syntax}{...}
{title:Syntax}

{p 8 10 2}
{cmd:ipatrackversions} {it:{help varname}}{cmd:,}
{opth saving(filename)} 
{opth id(varname)} 
{opth enum:erator(varname)}
{opth submit(varname)} 
[{it:options}]

{* Using -help readreplace- as a template.}{...}
{* 20 is the position of the last character in the first column + 3.}{...}
{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{* Using -help heckman- as a template.}{...}
{p2coldent:* {opth saving(filename)}}output filename where sheet "Version Control" will be saved {p_end}
{p2coldent:* {opth id(varname)}}ID variable, automatically included in every flagged observation {p_end}
{p2coldent:* {opth enum:erator(varname)}}enumerator variable, automatically included in every flagged observation {p_end}
{p2coldent:* {opth submit(varname)}}submission date variable (usually the SurveyCTO-created submissiondate), automatically included in every flagged observation {p_end}

{syntab:Specifications}
{synopt:{opth starttime(varname)}} variable that indicates start time of survey; must be in %t format {p_end}
{synopt:{opth endtime(varname)}}variable that indicates end time of survey; must be in %t format {p_end}
{synopt:{opth keep:vars(varlist)}}variables that should also be included in output sheet{p_end}


{synoptline}
{p2colreset}{...}
{* Using -help heckman- as a template.}{...}
{p 4 6 2}* {opt saving()}, {opt id()}, {opt enumerator()}, and {opt submit()} are required.


{title:Description}

{pstd}
{cmd:ipatrackversions} exports a table of versions used by submission date and, if applicable, 
a list of all observations that are using a form beside the most recent form version available by 
submission date. This table includes the starttime and endtime variable to provide information on when 
the survey was conducted in comparison with a new form version. 

{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:ipatrackversions} is one of the checks run in IPA's high frequency checks. 
It can be run within IPA's Data Management System, where inputs are entered into an .xlsm file 
and outputs are formatted in a .xlsx file. See {help ipacheck} for more details on how to use the Data Management System.


{marker examples}{...}
{title:Examples}

{pstd}
In IPA's master_check.do file created when using the Data Management System, the inputs you enter into
hfc_inputs.xlsm are used as globals through {cmd:ipacheckimport} to fill in this command:
{p_end}{cmd}{...}
{phang2}.  ipatrackversions ${formversion}, 
  id(${id})
  enumerator(${enum})
  submit(${date})
  saving("${outfile}")
{txt}{...}
	
 

{marker authors}{...}
{title:Authors}

{pstd}Innovations for Poverty Action{p_end}

{pstd}For questions or suggestions, submit a
{browse "https://github.com/PovertyAction/high-frequency-checks/issues":GitHub issue}
or e-mail researchsupport@poverty-action.org.{p_end}

