{smcl}
{* *! version 4.0.0 Innovations for Poverty Action 11may2022}{...}

{cmd:ipagettd} {c -} convert datetime variable to %td format date variable

{title:Syntax}

{pmore}
{cmd:ipagettd}
{help varlist}

{title:Description} 

{pstd}
{cmd:ipagettd} converts a numeric datatime variable into a numeric date variable
of %td {help datetime_display_formats:date} format. 
 
{hline}

{title:Examples} 

{synoptline}
  {text:Setup}
	{phang}{com}   . use "https://raw.githubusercontent.com/PovertyAction/ipa_dms4.0/final/data/household_survey.dta", clear{p_end}

  {text:convert submissiondate, starttime and endtime from datetime to date}
	{phang}{com}   . ipagettd submissiondate starttime endtime{p_end}
{synoptline}

{text}
{title:Author}

{pstd}Ishmail Azindoo Baako, GRDS, Innovations for Poverty Action{p_end}
{pstd}{it:Last updated: May 11, 2022}{p_end}

{title:Also see}

Help: {help decode:[D] decode}, {help _strip_labels:[P] _strip_labels}