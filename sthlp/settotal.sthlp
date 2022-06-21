{smcl}
{* *! version 4.0.0 Innovations for Poverty Action 11may2022}{...}

{cmd:settotal()} {c -} set the last row of an excel sheet as a total row. 

 
{title:Syntax}

{p 8 12 2}
{it:void}{bind:         }
{cmd:settotal(}{it:string scalar file}{cmd:,} 
{it:string scalar sheet}{cmd:)}
{p_end}

{title:Description}

{pstd}
{cmd:settotal(}{it:"filename"}{cmd:,} {it:"sheetname"}{cmd:)} sets the last row in Excel sheet as the total row. {cmd:settotal()} will set the last row as bold and italized, set the format to number format "number_sep" as well as set a "medium" bottom border from the first to the number of columns corresponding to the total number of variables of the dataset in memory. Note that the last total row is determined based on the number of observations of the datset in memory. eg. If the dataset in memory has 78 observations {cmd:settotal()} will format the 79th row of the Excel file.  {cmd:settotal()} is intended for use in formatting Excel outputs that are exported from the dataset in memory. 

{title:Remarks}

{pstd}
{cmd:settotal()} is mata program in the lipadms mata library which is part of {helpb ipacheck} Stata package. 

{title:Conformability}

    {cmd:setfont(}{it:file}{cmd:,} sheet{cmd:,}{cmd:)}
	{it:    file}: 1 {it:x} 1
	{it:   sheet}: 1 {it:x} 1
	{it:  result}: {it:void}
	
{title:Examples} 

{synoptline}
  {text:Setup}
	{phang}{com}   . sysuse auto, clear{p_end}
	{phang}{com}   . export excel using "auto.xlsx", sheet("auto") replace first(var){p_end}

  {text:set the first row as the header}
	{phang}{com}   . mata: settotal("auto.xlsx", "auto"){p_end}
{synoptline}
	
{text}
{title:Author}

{pstd}Ishmail Azindoo Baako, GRDS, Innovations for Poverty Action{p_end}
{pstd}{it:Last updated: May 11, 2022}{p_end}

{title:Also see}

Help: {help putexcel:[RPT] putexcel}, {help mf_xl:[M-5] xl()}

Other commands in lipadms: {help addlines:addlines()}, {help addflags:addflags()}, {help colwidths:colwidths()}, {help colformats:colformats()}, {help setfont:setfont()}, {help setheader:setheader()}