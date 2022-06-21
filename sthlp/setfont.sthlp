{smcl}
{* *! version 4.0.0 Innovations for Poverty Action 11may2022}{...}

{cmd:setfont()} {c -} set the font and font size for each Excel cell in the Excel cell range specified in rows and cols

 
{title:Syntax}

{p 8 12 2}
{it:void}{bind:         }
{cmd:setfont(}{it:string scalar file}{cmd:,} 
{it:string scalar sheet}{cmd:,}
{it:real vector rows}{cmd:,}
{it:real vector cols}{cmd:,}
{it:string scalar fontname}
{it:real scalar size}{cmd:)}
{p_end}

{title:Description}

{pstd}
{cmd:setfont(}{it:"filename"}{cmd:,} {it:"sheetname"}{cmd:,} {it:rows}{cmd:,}{it:cols}{cmd:,} {it:"fontname"}{cmd:,} {it:size}{cmd:)} sets the font and font size for each Excel cell in the Excel cell range specified in rows and cols. {cmd:setfont()} is intended for use in formatting Excel outputs that are exported from the dataset in memory. 

{title:Remarks}

{pstd}
{cmd:setfont()} is mata program in the lipadms mata library which is part of {helpb ipacheck} Stata package. 

{title:Conformability}

    {cmd:setfont(}{it:file}{cmd:,} sheet{cmd:,} {it:rows}{cmd:,} {it:cols}{cmd:,} {it:fontname}{cmd:,} {it:size}{cmd:)}
	{it:    file}: 1 {it:x} 1
	{it:   sheet}: 1 {it:x} 1
	{it:    rows}: 1 {it:x} m
	{it:    cols}: 1 {it:x} m
	{it:fontname}: 1 {it:x} 1
	{it:    size}: 1 {it:x} 1
	{it:  result}: {it:void}
	
{title:Examples} 

{synoptline}
  {text:Setup}
	{phang}{com}   . sysuse auto, clear{p_end}
	{phang}{com}   . export excel using "auto.xlsx", sheet("auto") replace first(var){p_end}

  {text:set the font type and size of price to "Times New Roman" and 12}
	{phang}{com}   . mata: setfont("auto.xlsx", "auto", (1, `c(k)'), 2, "Times New Roman", 12){p_end}
{synoptline}

  {text:Setup}
	{phang}{com}   . sysuse auto, clear{p_end}
	{phang}{com}   . export excel using "auto.xlsx", sheet("auto") replace first(var){p_end}

  {text:set the font type and size of the first row price to "Courier New" and 10}
	{phang}{com}   . mata: setfont("auto.xlsx", "auto", 1, (1, `c(N)' + 1), "Courier New", 10){p_end}
{synoptline}
	{text:Setup}
	{phang}{com}   . sysuse auto, clear{p_end}
	{phang}{com}   . export excel using "auto.xlsx", sheet("auto") replace first(var){p_end}

  {text:set the font type and size of the cells containing data to "Calibri" and 10}
	{phang}{com}   . mata: setfont("auto.xlsx", "auto", (1, `c(N)' + 1), (1, `c(k)'), "Calibri", 10){p_end}
{synoptline}
	
{text}
{title:Author}

{pstd}Ishmail Azindoo Baako, GRDS, Innovations for Poverty Action{p_end}
{pstd}{it:Last updated: May 11, 2022}{p_end}

{title:Also see}

Help: {help putexcel:[RPT] putexcel}, {help mf_xl:[M-5] xl()}

Other commands in lipadms: {help addlines:addlines()}, {help addflags:addflags()}, {help colwidths:colwidths()}, {help colformats:colformats()}, {help setheader:setheader()}, {help settotal:settotal()}