{smcl}
{* *! version 3.0.0 Innovations for Poverty Action 30oct2018}{...}
{title:Title}

{phang}
{cmd:ipatracksummary} {hline 2}
Create a summary sheet detailing progress toward survey targets by submission date. 

{marker syntax}{...}
{title:Syntax}

{p 8 10 2}
{cmd:ipatracksummary} {cmd:using} {it:{help filename}}{cmd:,}
{opth targ:et(numlist)}
{opth submit(varname)} 

{* Using -help readreplace- as a template.}{...}
{* 20 is the position of the last character in the first column + 3.}{...}
{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{* Using -help heckman- as a template.}{...}
{p2coldent:* {opth targ:et(numlist)}} target number of total completed surveys {p_end}
{p2coldent:* {opth submit(varname)}}submission date variable (usually the SurveyCTO-created submissiondate), automatically included in every flagged observation {p_end}

{synoptline}
{p2colreset}{...}
{* Using -help heckman- as a template.}{...}
{p 4 6 2}* {opt target()} and {opt submit()} are required.


{title:Description}

{pstd}
{cmd:ipatracksummary} exports a table of completed surveys and progress toward the target
number by submission date.

{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:ipatracksummary} is one of the checks run in IPA's high frequency checks. 
It can be run within IPA's Data Management System, where inputs are entered into an .xlsm file 
and outputs are formatted in a .xlsx file. See {help ipacheck} for more details on how to use the Data Management System.


{marker examples}{...}
{title:Examples}

{pstd}
In IPA's master_check.do file created when using the Data Management System, the inputs you enter into
hfc_inputs.xlsm are used as globals through {cmd:ipacheckimport} to fill in this command:
{p_end}{cmd}{...}
{phang2}.  ipatracksummary using "${progreport}",
  submit(${date})
  target(${pnumber}) 
{txt}{...}
	
 

{marker authors}{...}
{title:Authors}

{pstd}Innovations for Poverty Action{p_end}

{pstd}For questions or suggestions, submit a
{browse "https://github.com/PovertyAction/high-frequency-checks/issues":GitHub issue}
or e-mail researchsupport@poverty-action.org.{p_end}

