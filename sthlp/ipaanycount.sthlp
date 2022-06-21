{smcl}
{* *! version 4.0.0 Innovations for Poverty Action 11may2022}{...}

{phang}
{cmd:ipaanycount} {c -} Returns the number of variables in varlist for which values 
are equal to any integer value in a supplied numlist and any word value in supplied string values.{p_end}

{title:Syntax}

{pmore}
{cmd:ipaanycount}
{help varlist}
[{cmd:,}
{opth gen:erate(newvar)}
{it:{help ipaanycount##options:options}}]

{marker options}
{synoptset 23 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:* {opth gen:erate(newvar)}}generate new variable{p_end}
{synopt:{opth num:val(numlist)}}numeric items to match{p_end}
{synopt:{opt str:val("string")}}space seperate string items to match{p_end}
{synoptline}
{p2colreset}{...}

{title:Description} 

{pstd}
{cmd:ipaanycount} returns in a new variable the number of variables in the varlist 
specified with values that match the list of items supplied in the {cmd:numval()} 
and {cmd:strval()} options.
 
{title:Options}

{dlgtab:Main}

{phang}
{cmd:generate(newvar)} specifies the new variable to created with the count of variables 
with values matching numlist speciffied in {cmd:numval} and wordlist specified in 
{cmd:strval()}. 

{dlgtab:Specifications}

{phang}
{cmd:numval(numlist)} specifies the integer values to match. Although numval() does
not accept the generic numeric missing value ".", it allows extended numeric missing
values such as .a, .b, ... , .z.   

{phang}
{cmd:strval(numlist)} specifies the string values to match. {cmd:strval()} expects 
a space seperated list of items. eg "-999" or "-888 -999". 

{title:Examples} 

{synoptline}
  {text:Setup}
	{phang}{com}   . use f_hr_lead_r* using "https://raw.githubusercontent.com/PovertyAction/ipa_dms4.0/final/data/household_survey.dta", clear{p_end}

  {text:count the number of don't know responses ie. -999}
	{phang}{com}   . ipaanycount _all, gen(dk_count) str("-999"){p_end}
{synoptline}

{text}
{title:Author}

{pstd}Ishmail Azindoo Baako, GRDS, Innovations for Poverty Action{p_end}
{pstd}{it:Last updated: May 11, 2022}{p_end}

{title:Also see}

Help: {help egen:[D] egen}