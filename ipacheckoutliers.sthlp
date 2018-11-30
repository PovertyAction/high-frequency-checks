{smcl}
{* *! version 3.0.0 Innovations for Poverty Action 30oct2018}{...}
{title:Title}

{phang}
{cmd:ipacheckoutliers} {hline 2}
Checks for outliers among unconstrained survey variables.

 
{marker syntax}{...}
{title:Syntax}

{p 8 10 2}
{cmd:ipacheckoutliers} {it:{help varlist}}{cmd:,}
{opth multi:plier(numlist)}  
{opth saving(filename)} 
{opth id(varname)} 
{opth enum:erator(varname)}
{opth submit:ted(varname)} 
[{it:options}]

{* Using -help readreplace- as a template.}{...}
{* 20 is the position of the last character in the first column + 3.}{...}
{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{* Using -help heckman- as a template.}{...}
{p2coldent:* {opth multi:plier(numlist)}}multiple of the interquartile range or standard deviation that signifies an outlier{p_end}
{p2coldent:* {opth saving(filename)}}output filename where sheet "11. outliers" will be saved {p_end}
{p2coldent:* {opth id(varname)}}ID variable, automatically included in every flagged observation {p_end}
{p2coldent:* {opth enum:erator(varname)}}enumerator variable, automatically included in every flagged observation {p_end}
{p2coldent:* {opth submit:ted(varname)}}submission date variable (usually the SurveyCTO-created submissiondate), automatically included in every flagged observation {p_end}


{syntab:Specifications}
{synopt:{opth ign:ore(string)}}{p_end}
{synopt:{opth keep:vars(varlist)}}variables that should also be included in output sheet{p_end}
{synopt:{opth scto:db(string)}}SurveyCTO server name; when included, a column is created that links to the flagged observation on the SurveyCTO server monitoring tab.{p_end}
{synopt:{opt nolab:el}}export variable values instead of value labels{p_end}
{synopt:{opt sheetmod:ify}}export excel option to modify sheet instead of replacing sheet; cannot be used with sheetreplace{p_end}
{synopt:{opt sheetrep:lace}}export excel option to replace sheet instead of replacing modifying; cannot be used with sheetmodify {p_end}
{synopt:{opt sd}}option to use standard deviation a measure of an outlier; default is interquartile range p_end}

{synoptline}
{p2colreset}{...}
{* Using -help heckman- as a template.}{...}
{p 4 6 2}* {opt multiplier()}, {opt saving()}, {opt id()}, {opt enumerator()}, and {opt submitted()} are required.


{title:Description}

{pstd}
{cmd:ipacheckoutliers} checks for outliers among unconstrained survey variables. Note 
that each variable specified in {help varlist} requires its own multiplier number.

{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:ipacheckoutliers} is one of the checks run in IPA's high frequency checks. 
It can be run within IPA's Data Management System, where inputs are entered into an .xlsm file 
and outputs are formatted in a .xlsx file. See {help ipacheck} for more details on how to use the Data Management System.


{marker examples}{...}
{title:Examples}

{pstd}
In IPA's master_check.do file created when using the Data Management System, the inputs you enter into
hfc_inputs.xlsm are used as globals through {cmd:ipacheckimport} to fill in this command:
{p_end}{cmd}{...}

{phang2}
.  ipacheckoutliers ${variable11}, id(${id})
    enumerator(${enum})
    submit(${date})
    multiplier(${multiplier11})
    keepvars(${keep11})
    ignore(${ignore11})
    saving("${outfile}")
    sctodb("${server}")
    sheetreplace ${nolabel} ${sd}
{txt}{...}
	
 

{marker authors}{...}
{title:Authors}

{pstd}Innovations for Poverty Action{p_end}

{pstd}For questions or suggestions, submit a
{browse "https://github.com/PovertyAction/high-frequency-checks/issues":GitHub issue}
or e-mail researchsupport@poverty-action.org.{p_end}

