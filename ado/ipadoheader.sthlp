{smcl}
{* *! version 3.0.0 Innovations for Poverty Action 30oct2018}{...}
{title:Title}

{phang}
{cmd:ipadoheader} {hline 2}
Standardize Stata settings and options across team members.

{marker syntax}{...}
{title:Syntax}

{p 8 10 2}
{cmd:ipadoheader}{cmd:,}
[{it:options}]

{* Using -help readreplace- as a template.}{...}
{* 20 is the position of the last character in the first column + 3.}{...}
{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Specifications}
{synopt:{opth version(string)}} Stata version number {p_end}
{synopt:{opth maxvar(numlist)}}maximum number of variables allowed{p_end}
{synopt:{opth matsize:(numlist)}}maximum size of matrices{p_end}
{synopt:{opt noclear}}option to stop clearing of data {p_end}
{synoptline}
{p2colreset}{...}
{* Using -help heckman- as a template.}{...}


{title:Description}

{pstd}
{cmd:ipadoheader} standardizes Stata options that can differ across different computers
in order to improve uniformity when running do files. 

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

{phang2}.  ipadoheader, version(15.0)
 
{txt}{...}
{marker authors}{...}
{title:Authors}

{pstd}Innovations for Poverty Action{p_end}

{pstd}For questions or suggestions, submit a
{browse "https://github.com/PovertyAction/high-frequency-checks/issues":GitHub issue}
or e-mail researchsupport@poverty-action.org.{p_end}

