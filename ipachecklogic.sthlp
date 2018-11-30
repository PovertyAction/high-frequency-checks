{smcl}
{* *! version 3.0.0 Innovations for Poverty Action 30oct2018}{...}
{title:Title}

{phang}
{cmd:ipachecklogic} {hline 2}
Checks skip patterns and logical constraints.

{marker syntax}{...}
{title:Syntax}

{p 8 10 2}
{cmd:ipachecklogic} {it:{help varlist}}{cmd:,}
{opth ass:ert(string)} 
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
{p2coldent:* {opth ass:ert(string)}}assertion to test. If multiple assertions, separate by ";" {p_end}
{p2coldent:* {opth saving(filename)}}output filename where sheet "6. logic" will be saved {p_end}
{p2coldent:* {opth id(varname)}}ID variable, automatically included in every flagged observation {p_end}
{p2coldent:* {opth enum:erator(varname)}}enumerator variable, automatically included in every flagged observation {p_end}
{p2coldent:* {opth submit:ted(varname)}}submission date variable (usually the SurveyCTO-created submissiondate), automatically included in every flagged observation {p_end}


{syntab:Specifications}
{synopt:{opth cond:ition(string)}}conditions for assertions listed in -assert-. If multiple, separate by ";"{p_end}
{synopt:{opth keep:vars(varlist)}}variables that should also be included in output sheet{p_end}
{synopt:{opth scto:db(string)}}SurveyCTO server name; when included, a column is created that links to the flagged observation on the SurveyCTO server monitoring tab.{p_end}
{synopt:{opt nolab:el}}export variable values instead of value labels{p_end}
{synopt:{opt sheetmod:ify}}export excel option to modify sheet instead of replacing sheet; cannot be used with sheetreplace{p_end}
{synopt:{opt sheetrep:lace}}export excel option to replace sheet instead of replacing modifying; cannot be used with sheetmodify {p_end}

{synoptline}
{p2colreset}{...}
{* Using -help heckman- as a template.}{...}
{p 4 6 2}* {opt assert()}, {opt saving()}, {opt id()}, {opt enumerator()}, and {opt submitted()} are required.


{title:Description}

{pstd}
{cmd:ipachecklogic} confirms skip patterns and logical constraints within a survey using the {help assert} 
command. While it is not necessary to include patterns that are already included in the survey programming, 
{cmd:ipachecklogic} can be used to check indirect skip patterns and other constraints that are not directly
programmed. 

{pstd}
Note that assertions and conditions will be parsed together; the first assertion will be matched 
with the first condition listed in the -condition- option, the second assertion will be matched with the second 
condition listed in the -condition- option, separated by ";", and so on.

{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:ipachecklogic} is one of the checks run in IPA's high frequency checks. 
It can be run within IPA's Data Management System, where inputs are entered into an .xlsm file 
and outputs are formatted in a .xlsx file. See {help ipacheck} for more details on how to use the Data Management System.


{marker examples}{...}
{title:Examples}

{pstd}
In IPA's master_check.do file created when using the Data Management System, the inputs you enter into
hfc_inputs.xlsm are used as globals through {cmd:ipacheckimport} to fill in this command:
{p_end}{cmd}{...}

{phang2}
.      ipachecklogic ${variable6},
    assert(${assert6})
    condition(${if_condition6})
    id(${id})
    enumerator(${enum})
    submit(${date})
    keepvars(${keep6})
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

