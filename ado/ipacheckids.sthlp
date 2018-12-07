{smcl}
{* *! version 3.0.0 Innovations for Poverty Action 30oct2018}{...}
{title:Title}

{phang}
{cmd:ipacheckids} {hline 2}
Search dataset for duplicates, and create an export of all duplicate groups and 
comparisons across variables. 

{marker syntax}{...}
{title:Syntax}

{p 8 10 2}
{cmd:ipacheckids} {it:{help varname}} [{cmd:using} {it:{help filename}}]{cmd:,}
{opth enum:erator(varname)}
[{it:options}]

{* Using -help readreplace- as a template.}{...}
{* 20 is the position of the last character in the first column + 3.}{...}
{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{* Using -help heckman- as a template.}{...}
{p2coldent:* {opth enum:erator(varname)}}enumerator variable, automatically included in every flagged observation {p_end}

{syntab:Specifications}
{synopt:{opth save(string)}}save de-duplicated dataset as a dta file, where one of each duplicate group is randomly kept; must be used with {it:force} {p_end}
{synopt:{opt nolab:el}}export variable values instead of value labels{p_end}
{synopt:{opt var:iable}}export variable names instead of variable labels in output sheet {p_end}
{synopt:{opt force}}force drop all duplicates in a duplicate group except one {p_end}

{synoptline}
{p2colreset}{...}
{* Using -help heckman- as a template.}{...}
{p 4 6 2}* {opt enumerator()}is required.


{title:Description}

{pstd}
{cmd:ipacheckids} checks for duplicates of the ID variable specified. If duplicates are found, an export will be 
made with two sheets. "Diffs" will show each duplicate group and uses {help:cfout} to compare all variables between the 
duplicates. If there are more than two observations with the same ID variable, each will be compared with the first observation
submitted. "Raw" shows each duplicate group with all variables that have different values across the same ID variable to 
help reconcile duplicates.

{pstd}
The {it:force} option uses {help duplicates drop} in order to randomly drop all observations in a duplicate group except one. 
This allows the workflow to continue, since IPA's Data Management System cannot run with duplicates.

{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:ipacheckids} is one of the checks run in IPA's high frequency checks. 
It can be run within IPA's Data Management System, where inputs are entered into an .xlsm file 
and outputs are formatted in a .xlsx file. See {help ipacheck} for more details on how to use the Data Management System.


{marker examples}{...}
{title:Examples}

{pstd}
In IPA's master_check.do file created when using the Data Management System, the inputs you enter into
hfc_inputs.xlsm are used as globals through {cmd:ipacheckimport} to fill in this command:
{p_end}{cmd}{...}
{phang2}.  ipacheckids ${id} using "${dupfile}",
  enum(${enum})
  nolabel
  variable
  force
  save("${sdataset_f}_checked")

{txt}{...}
{marker authors}{...}
{title:Authors}

{pstd}Innovations for Poverty Action{p_end}

{pstd}For questions or suggestions, submit a
{browse "https://github.com/PovertyAction/high-frequency-checks/issues":GitHub issue}
or e-mail researchsupport@poverty-action.org.{p_end}

