{smcl}
{* *! version 3.0.0 Innovations for Poverty Action 30oct2018}{...}
{title:Title}

{phang}
{cmd:ipacheckfollowup} {hline 2}
Check values of variables in memory against a master tracking list from a prior survey or census.

{marker syntax}{...}
{title:Syntax}

{p 8 10 2}
{cmd:ipacheckfollowup} {it:{help varlist}} {cmd:using} {it:{help filename}}{cmd:,}
{opth saving(filename)} 
{opth id(varname)} 
{opth enum:erator(varname)}
{opth submit:ted(varname)} 
[{it:options}]

{* Using -help readreplace- as a template.}{...}
{* 20 is the position of the last character in the first column + 3.}{...}
{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{* Using -help heckman- as a template.}{...}
{p2coldent:* {opth saving(filename)}}output filename where sheet "5. follow up" will be saved {p_end}
{p2coldent:* {opth id(varname)}}ID variable, automatically included in every flagged observation {p_end}
{p2coldent:* {opth enum:erator(varname)}}enumerator variable, automatically included in every flagged observation {p_end}
{p2coldent:* {opth submit:ted(varname)}}submission date variable (usually the SurveyCTO-created submissiondate), automatically included in every flagged observation {p_end}


{syntab:Specifications}
{synopt:{opth keepv:ars(varlist)}}variables that should also be included in output sheet from memory {p_end}
{synopt:{opth keepm:aster(varlist)}}variables that should also be included in output sheet from master dataset{p_end}
{synopt:{opth scto:db(string)}}SurveyCTO server name; when included, a column is created that links to the flagged observation on the SurveyCTO server monitoring tab.{p_end}
{synopt:{opt nolab:el}}export variable values instead of value labels{p_end}
{synopt:{opt sheetmod:ify}}export excel option to modify sheet instead of replacing sheet; cannot be used with sheetreplace{p_end}
{synopt:{opt sheetrep:lace}}export excel option to replace sheet instead of replacing modifying; cannot be used with sheetmodify {p_end}

{synoptline}
{p2colreset}{...}
{* Using -help heckman- as a template.}{...}
{p 4 6 2}* {opt saving()}, {opt id()}, {opt enumerator()}, and {opt submitted()} are required.


{title:Description}

{pstd}
{cmd:ipacheckfollowup} compares values of identifying variables from a master tracking list to data
in memory to confirm reliability of question and enumerator performance. Variables with different 
values across the two datasets will be exported to the output sheet. Note that variables must have
the same name across the master dataset and dataset in memory to be compared.  

{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:ipacheckfollowup} is one of the checks run in IPA's high frequency checks. 
It can be run within IPA's Data Management System, where inputs are entered into an .xlsm file 
and outputs are formatted in a .xlsx file. See {help ipacheck} for more details on how to use the Data Management System.


{marker examples}{...}
{title:Examples}

{pstd}
In IPA's master_check.do file created when using the Data Management System, the inputs you enter into
hfc_inputs.xlsm are used as globals through {cmd:ipacheckimport} to fill in this command:
{p_end}{cmd}{...}

{phang2}
.    ipacheckfollowup ${variable5} using ${master},
    id(${id})
    enumerator(${enum})
    submit(${date})
    saving("${outfile}")
    sctodb("${server}")
    sheetreplace
{txt}{...}
	
 

{marker authors}{...}
{title:Authors}

{pstd}Innovations for Poverty Action{p_end}

{pstd}For questions or suggestions, submit a
{browse "https://github.com/PovertyAction/high-frequency-checks/issues":GitHub issue}
or e-mail researchsupport@poverty-action.org.{p_end}

