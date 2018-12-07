{smcl}
{* *! version 3.0.0 Innovations for Poverty Action 30oct2018}{...}
{title:Title}

{phang}
{cmd:ipacheckcomplete} {hline 2}
Check that all interviews were completed. 
{marker syntax}{...}
{title:Syntax}

{p 8 10 2}
{cmd:ipacheckcomplete} {it:{help varlist}}{cmd:,}
{opth comp:lete(numlist)} 
{opth p:ercent(numlist)} 
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
{p2coldent:* {opth comp:lete(numlist)}}the value that indicates a complete survey for the completion variable specified {p_end}
{p2coldent:* {opth p:ercent(numlist)}}the percentage of questions (0 to 100) that is a threshold for an incomplete survey (i.e. flag surveys with only 40% of questions answered or not missing) {p_end}
{p2coldent:* {opth saving(filename)}}output filename where sheet "1. incomplete" will be saved {p_end}
{p2coldent:* {opth id(varname)}}ID variable, automatically included in every flagged observation {p_end}
{p2coldent:* {opth enum:erator(varname)}}enumerator variable, automatically included in every flagged observation {p_end}
{p2coldent:* {opth submit:ted(varname)}}submission date variable (usually the SurveyCTO-created submissiondate), automatically included in every flagged observation {p_end}


{syntab:Specifications}
{synopt:{opth keep:vars(varlist)}}variables that should also be included in output sheet{p_end}
{synopt:{opth scto:db(string)}}SurveyCTO server name; when included, a column is created that links to the flagged observation on the SurveyCTO server monitoring tab.{p_end}
{synopt:{opt nolab:el}}export variable values instead of value labels{p_end}
{synopt:{opt sheetmod:ify}}export excel option to modify sheet instead of replacing sheet; cannot be used with sheetreplace{p_end}
{synopt:{opt sheetrep:lace}}export excel option to replace sheet instead of replacing modifying; cannot be used with sheetmodify{p_end}

{synoptline}
{p2colreset}{...}
{* Using -help heckman- as a template.}{...}
{p 4 6 2}* {opt complete()}, {opt percent()}, {opt saving()}, {opt id()}, {opt enumerator()}, and {opt submitted()} are required.


{title:Description}

{pstd}
IPA best practice is generally to include a question at the end of a survey that asks the enumerator to document the completness of the interview. This command checks that 
all survey values of the completeness variable are equal to the "completed" option. Incomplete surveys are listed  in the output. 

{pstd}
Optionally, users can also specify a minimum nonmissing response threshold and this check will output the surveys that have fewer nonmissing responses than the minimum.


{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:ipacheckcomplete} is one of the checks run in IPA's high frequency checks. 
It can be run within IPA's Data Management System, where inputs are entered into an .xlsm file 
and outputs are formatted in a .xlsx file. See {help ipacheck} for more details on how to use the Data Management System.


{marker examples}{...}
{title:Examples}

{pstd}
In IPA's master_check.do file created when using the Data Management System, the inputs you enter into
hfc_inputs.xlsm are used as globals to fill in this command:
{p_end}{cmd}{...}
{phang2}. ipacheckcomplete ${variable1}, 
    complete(${complete_value1})
    percent(${complete_percent1})
    id(${id})
    enumerator(${enum})
    submit(${date})
    keepvars("${keep1}")
    saving("${outfile}")
    sctodb("${server}")
    sheetreplace ${nolabel}
{txt}{...}
	
 

{marker authors}{...}
{title:Authors}

{pstd}Innovations for Poverty Action{p_end}

{pstd}For questions or suggestions, submit a
{browse "https://github.com/PovertyAction/progreport/issues":GitHub issue}
or e-mail researchsupport@poverty-action.org.{p_end}

