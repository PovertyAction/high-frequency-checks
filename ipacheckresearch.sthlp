{smcl}
{* *! version 3.0.0 Innovations for Poverty Action 30oct2018}{...}
{title:Title}

{phang}
{cmd:ipacheckresearch} {hline 2}
Creates oneway and twoway summaries of important research variables and exports them as a separate excel file. 

{marker syntax}{...}
{title:Syntax}

{p 8 10 2}
{cmd:ipacheckresearch}[{cmd:using} {help filename}]{cmd:,}
{opth var:iables(string)}
[{it:options}]

{* Using -help readreplace- as a template.}{...}
{* 20 is the position of the last character in the first column + 3.}{...}
{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}

{syntab:Main}
{* Using -help heckman- as a template.}{...}
{p2coldent:* {opth var:iables(string)}}variable and variable type to to create tables{p_end}


{syntab:Specifications}
{synopt:{opth by(varname)}}group over which tables should be calculated{p_end}
{synopt:{opth format(string)}}specify format of tables{p_end}
{synopt:{opt missing}}option to include missing values {p_end}
{synopt:{opt replace}}option to replace workbook{p_end}
{synoptline}
{p2colreset}{...}
{* Using -help heckman- as a template.}{...}


{title:Description}

{pstd}
{cmd:ipacheckresearch} creates a workbook of oneway and twoway tabulations of specified variables.
Since this was created to be inputted through IPA's Data Management System input sheet, it requires specific inputs
for the {it:variables} option to work separately. Each variable must have a specific variable type: {p_end}
{phang2}.  "contn": continuous, normal (mean) {p_end}
{phang2}.  "conts" continuous, skewed (mean) {p_end}
{phang2}.  "cat" categorical, Chi-squared{p_end}
{phang2}.  "cate" categorical, Fisher's exact test {p_end}
{phang2}.  "bin" binary, Chi-squared {p_end}
{phang2}.  "bine" binary, Fisher's exact test{p_end}

{pstd}
{cmd:ipacheckresearch} {it:variables} option should follow this pattern: var1 vartype1 / var2 vartype2 / ...

{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:ipacheckresearch} is one of the checks run in IPA's high frequency checks. 
It can be run within IPA's Data Management System, where inputs are entered into an .xlsm file 
and outputs are formatted in a .xlsx file. See {help ipacheck} for more details on how to use the Data Management System.


{marker examples}{...}
{title:Examples}

{pstd}
In IPA's master_check.do file created when using the Data Management System, the inputs you enter into
hfc_inputs.xlsm are used as globals through {cmd:ipacheckimport} to fill in this command:
{p_end}{cmd}{...}

{phang2}.    ipacheckresearch using "${researchdb}",
    variables(${variablestr15}) // oneway
	
{phang2}.    ipacheckresearch using "${researchdb}",
    variables(${variablestr16}) by(${by16}) // twoway
 
{txt}{...}
{marker authors}{...}
{title:Authors}

{pstd}Innovations for Poverty Action{p_end}

{pstd}For questions or suggestions, submit a
{browse "https://github.com/PovertyAction/high-frequency-checks/issues":GitHub issue}
or e-mail researchsupport@poverty-action.org.{p_end}

