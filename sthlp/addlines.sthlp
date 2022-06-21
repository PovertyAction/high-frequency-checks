{smcl}
{* *! version 4.0.0 Innovations for Poverty Action 11may2022}{...}

{cmd:addlines()} {c -} set a black bottom border for Excel cell rows 
 
{title:Syntax}

{p 8 12 2}
{it:void}{bind:         }
{cmd:addlines(}{it:string scalar file}{cmd:,} 
{it:string scalar sheet}{cmd:,}
{it:real vector rows}{cmd:,}
{it:string scalar {help mf_xl##style:style}}{cmd:)}
{p_end}

{title:Description}

{pstd}
{cmd:addlines(}{it:"filename"}{cmd:,} "sheetname"{cmd:,} {it:rows}{cmd:,} {it:"style"}{cmd:)} sets a bottom border and style for each Excel cell in the rows specified in {cmd:rows} and columns spanning from the first to the total number of variables in the dataset in memory. {cmd:addlines()} is intended for use in formatting Excel outputs that are exported from the dataset in memory. Note that when {cmd:addlines()} adds one to each row specified in {cmd:rows} to account for the header column in the excel output. 

{title:Remarks}

{pstd}
{cmd:addlines()} is mata program in the lipadms mata library which is part of {helpb ipacheck} Stata package. 

{title:Conformability}

    {cmd:addlines(}{it:file}{cmd:,} sheet{cmd:,} {it:rows}{cmd:,} {it:style}{cmd:)}
	{it:  file}: 1 {it:x} 1
	{it: sheet}: 1 {it:x} 1
	{it:  rows}: 1 {it:x} m
	{it: style}: 1 {it:x} 1
	{it:result}: {it:void}
	
{title:Examples} 

{synoptline}
  {text:Setup}
	{phang}{com}   . sysuse auto, clear{p_end}
	{phang}{com}   . export excel using "auto.xlsx", sheet("auto") replace first(var){p_end}

  {text:Set a dotted bottom border on first row}
	{phang}{com}   . mata: addlines("auto.xlsx", "auto", 1, "dotted"){p_end}
{synoptline}

  {text:Setup}
	{phang}{com}   . sysuse auto, clear{p_end}
	{phang}{com}   . export excel using "auto.xlsx", sheet("auto") replace first(var){p_end}

  {text:Set a thick bottom border on the first and to last rows}
	{phang}{com}   . mata: addlines("auto.xlsx", "auto", (1, `c(N)' + 1), "thick"){p_end}
{synoptline}
	
{text}
{title:Author}

{pstd}Ishmail Azindoo Baako, GRDS, Innovations for Poverty Action{p_end}
{pstd}{it:Last updated: May 11, 2022}{p_end}

{title:Also see}

Help: {help putexcel:[RPT] putexcel}, {help mf_xl:[M-5] xl()}

Other commands in lipadms: {help addflags:addflags()}, {help colwidths:colwidths()}, {help colformats:colformats()}, {help setfont:setfont()}, {help setheader:setheader()}, {help settotal:settotal()}