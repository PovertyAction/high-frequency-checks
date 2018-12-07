{smcl}
{* *! version 3.0.0 Innovations for Poverty Action 30oct2018}{...}
{title:Title}

{phang}
{cmd:ipacheckconstraints} {hline 2}
Check that certain numeric variables fall within reasonable constraints.

{marker syntax}{...}
{title:Syntax}

{p 8 10 2}
{cmd:ipacheckconstraints} {it:{help varlist}}{cmd:,}
{opth smin(numlist)} 
{opth smax(numlist)} 
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
{p2coldent:* {opth smin(numlist)}}minimum value for variables specified{p_end}
{p2coldent:* {opth smax(numlist)}}maximum value for variables specified{p_end}
{p2coldent:* {opth saving(filename)}}output filename where sheet "8. constraints" will be saved {p_end}
{p2coldent:* {opth id(varname)}}ID variable, automatically included in every flagged observation {p_end}
{p2coldent:* {opth enum:erator(varname)}}enumerator variable, automatically included in every flagged observation {p_end}
{p2coldent:* {opth submit:ted(varname)}}submission date variable (usually the SurveyCTO-created submissiondate), automatically included in every flagged observation {p_end}


{syntab:Specifications}
{synopt:{opth keep:vars(varlist)}}variables that should also be included in output sheet{p_end}
{synopt:{opth scto:db(string)}}SurveyCTO server name; when included, a column is created that links to the flagged observation on the SurveyCTO server monitoring tab.{p_end}
{synopt:{opt nolab:el}}export variable values instead of value labels{p_end}
{synopt:{opt sheetmod:ify}}export excel option to modify sheet instead of replacing sheet; cannot be used with sheetreplace{p_end}
{synopt:{opt sheetrep:lace}}export excel option to replace sheet instead of replacing modifying; cannot be used with sheetmodify {p_end}

{synoptline}
{p2colreset}{...}
{* Using -help heckman- as a template.}{...}
{p 4 6 2}* {opt smin()}, {opt smax()}, {opt saving()}, {opt id()}, {opt enumerator()}, and {opt submitted()} are required.


{title:Description}

{pstd}
{cmd:ipacheckconstraints} checks that certain numeric variables fall within reasonable 
hard and soft constraints. Most numeric questions that are asked during an interview 
have a logical range of possible values. Entries that exceed these limits could be a 
sign of misentry or fraud. Note that values entered in -smin- and -smax- are applied 
to the order of the variables specified. The first variable's minimum and maximum acceptable
value will be the first value in -smin- and the first value in -smax-, respectively. 



{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:ipacheckconstraints} is one of the checks run in IPA's high frequency checks. 
It can be run within IPA's Data Management System, where inputs are entered into an .xlsm file 
and outputs are formatted in a .xlsx file. See {help ipacheck} for more details on how to use the Data Management System.


{marker examples}{...}
{title:Examples}

{pstd}
In IPA's master_check.do file created when using the Data Management System, the inputs you enter into
hfc_inputs.xlsm are used as globals through {cmd:ipacheckimport} to fill in this command:
{p_end}{cmd}{...}

{phang2}
. ipacheckconstraints ${variable8},
    smin(${soft_min8})
    smax(${soft_max8})
    id(${id})
    enumerator(${enum})
    submit(${date})
    keepvars(${keep8})
    saving("${outfile}")
    sctodb("${server}")
    sheetreplace ${nolabel}
{txt}{...}
	
 

{marker authors}{...}
{title:Authors}

{pstd}Innovations for Poverty Action{p_end}

{pstd}For questions or suggestions, submit a
{browse "https://github.com/PovertyAction/high-frequency-checks/issues":GitHub issue}
or e-mail researchsupport@poverty-action.org.{p_end}

