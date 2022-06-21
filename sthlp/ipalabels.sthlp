{smcl}
{* *! version 4.0.0 Innovations for Poverty Action 11may2022}{...}

{cmd:ipalabels} {c -} remove value labels or values from numeric variables

{title:Syntax}

{pmore}
{cmd:ipalabels}
{help varlist}
[{cmd:,}
{it:{help ipalabels##options:options}}]

{marker options}
{synoptset 23 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt nolab:el}}remove value labels{p_end}
{synoptline}
{p2colreset}{...}

{title:Description} 

{pstd}
{cmd:ipalabels} removes the value labels leaving the underlying values of numeric 
variables or removes the underlying values leaving the value labels of numeric 
variables with labels. Note that when {cmd:ipalabels} is used without the {cmd:nolabel}
option, the {help data_types:data type} of the variable will be changed to a string
storage type to accomodate the value labels. {cmd:ipalabels} will ignore any string
variables specified in {cmd:varlist}. 
 
{title:Options}

{phang}
{cmd:nolabel} specifies that the value labels of should be removed. By default
{cmd:ipalabels} removes the values leaving the labels. 

{hline}

{title:Examples} 

{synoptline}
  {text:Setup}
	{phang}{com}   . sysuse auto, clear{p_end}

  {text:remove values from the foreign variable}
	{phang}{com}   . ipalabels foreign{p_end}
{synoptline}
  {text:Setup}
	{phang}{com}   . sysuse auto, clear{p_end}

  {text:remove value labels from the foreign variable}
	{phang}{com}   . ipalabels foreign, nolabel{p_end}
{synoptline}

{text}
{title:Author}

{pstd}Ishmail Azindoo Baako, GRDS, Innovations for Poverty Action{p_end}
{pstd}{it:Last updated: May 11, 2022}{p_end}

{title:Also see}

Help: {help decode:[D] decode}, {help _strip_labels:[P] _strip_labels}