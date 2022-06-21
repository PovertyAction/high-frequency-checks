{smcl}
{* *! version 4.0.0 Innovations for Poverty Action 11may2022}{...}

{cmd:addflags()} {c -} set a solid background color for Excel cells 
 
{title:Syntax}

{p 8 12 2}
{it:void}{bind:         }
{cmd:addlines(}{it:string scalar file}{cmd:,} 
{it:string scalar sheet}{cmd:,}
{it:string scalar var}{cmd:,}
{it:real vector rows}{cmd:,}
{it:string scalar {help mf_xl##syn_format_colors:color}}{cmd:)}
{p_end}

{title:Description}

{pstd}
{cmd:addflags(}{it:"filename"}{cmd:,} {it:"sheetname"}{cmd:,} {it:"varname"}{cmd:,} {it:rows}{cmd:,} {it:"color"}{cmd:)} sets a solid background color for each Excel cell in the rows specified in {cmd:rows} and for the column matching the variable specified in {cmd:var} of variables in the dataset in memory. {cmd:addflags()} is intended for use in formatting Excel outputs that are exported from the dataset in memory. 

{title:Remarks}

{pstd}
{cmd:addflags()} is mata program in the lipadms mata library which is part of {helpb ipacheck} Stata package. 

{title:Conformability}

    {cmd:addflags(}{it:file}{cmd:,} sheet{cmd:,} {it:rows}{cmd:,} {it:var}{cmd:,} {it:color}{cmd:)}
	{it:  file}: 1 {it:x} 1
	{it: sheet}: 1 {it:x} 1
	{it:  rows}: 1 {it:x} m
	{it:   var}: 1 {it:x} 1
	{it: color}: 1 {it:x} 1
	{it:result}: {it:void}
	
{title:Examples} 

{synoptline}
  {text:Setup}
	{phang}{com}   . sysuse auto, clear{p_end}
	{phang}{com}   . export excel using "auto.xlsx", sheet("auto") replace first(var){p_end}

  {text:set the background color of the second row of the price column to "yellow"}
	{phang}{com}   . mata: addflags("auto.xlsx", "auto", 1, "price", "yellow"){p_end}
{synoptline}

  {text:Setup}
	{phang}{com}   . sysuse auto, clear{p_end}
	{phang}{com}   . export excel using "auto.xlsx", sheet("auto") replace first(var){p_end}

  {text:set the background color of the rows 5, 10 and 15 of the price column to "lightpink"}
	{phang}{com}   . mata: addflags("auto.xlsx", "auto", (5, 10, 15), "price", "lightpink"){p_end}
{synoptline}
	
{text}
{title:Author}

{pstd}Ishmail Azindoo Baako, GRDS, Innovations for Poverty Action{p_end}
{pstd}{it:Last updated: May 11, 2022}{p_end}

{title:Also see}

Help: {help putexcel:[RPT] putexcel}, {help mf_xl:[M-5] xl()}

Other commands in lipadms: {help addlines:addlines()}, {help colwidths:colwidths()}, {help colformats:colformats()}, {help setfont:setfont()}, {help setheader:setheader()}, {help settotal:settotal()}