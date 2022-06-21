{smcl}
{* *! version 4.0.0 Innovations for Poverty Action 11may2022}{...}

{phang}
{cmd:colwidths()} {c -} adjust the column width for each column in the Excel sheet using the length of the values in the corresponding variable of the dataset in memory.  
{p_end}

{title:Syntax}

{p 8 12 2}
{it:void}{bind:         }
{cmd:colwidths(}{it:string scalar file}{cmd:,} 
{it:string scalar sheet}{cmd:)}
{p_end}

{title:Description}

{pstd}
{cmd:colwidths(}{it:"filename"}{cmd:,} {it:"sheetname"}{cmd:)} sets the column width of each column in "sheetname" using the length of values of the corresponding variablenof the dataset in memory. Column width is measured as the number of characters (0-255) rendered in Excel's default style's font. If the variable name is longer than the values specified, then {cmd:colwidths} uses the length of the variable name. Note that {cmd:colwidths()} adjust each column size upwards by 4 and also sets a maximum column length of 85. 

{title:Remarks}

{pstd}
{cmd:colwidths()} is mata program in the lipadms mata library which is part of {helpb ipacheck} Stata package. 

{title:Conformability}

    {cmd:colwidths(}{it:file}{cmd:,} {it:sheet}{cmd:)}
	{it:  file}: 1 {it:x} 1
	{it: sheet}: 1 {it:x} 1
	{it:result}: {it:void}
	
{title:Examples} 

{synoptline}
  {text:Setup}
	{phang}{com}   . sysuse auto, clear{p_end}
	{phang}{com}   . export excel using "auto.xlsx", sheet("auto") replace first(var){p_end}

  {text:adjust column widths}
	{phang}{com}   . mata: colwidths("auto.xlsx", "auto"){p_end}
{synoptline}
	
{text}
{title:Author}

{pstd}Rosemarie Sandino, GRDS, Innovations for Poverty Action{p_end}
{pstd}Ishmail Azindoo Baako, GRDS, Innovations for Poverty Action{p_end}
{pstd}{it:Last updated: May 11, 2022}{p_end}

{title:Also see}

Help: {help putexcel:[RPT] putexcel}, {help mf_xl:[M-5] xl()}

Other commands in lipadms: {help addlines:addlines()}, {help addflags:addflags()}, {help colformats:colformats()}, {help setfont:setfont()}, {help setheader:setheader()}, {help settotal:settotal()}