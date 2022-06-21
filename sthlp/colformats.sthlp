{smcl}
{* *! version 4.0.0 Innovations for Poverty Action 11may2022}{...}

{cmd:colformats()} {c -} sets the numeric format for each Excel cell in the corresponding Excel cell specified.
 
{title:Syntax}

{p 8 12 2}
{it:void}{bind:         }
{cmd:colformats(}{it:string scalar file}{cmd:,} 
{it:string scalar sheet}{cmd:,}
{it:string scalar vars}{cmd:,}
{it:string scalar {help mf_xl##nformat:format}}{cmd:)}
{p_end}

{title:Description}

{pstd}
{cmd:colformats(}{it:"filename"}{cmd:,} {it:"sheetname"}{cmd:,} {it:"variables"}{cmd:,} {it:"format"}{cmd:)} sets the numeric number format for each Excel cell in the columns corresponding to the variables specified in {cmd:vars} of variables in the dataset in memory. {cmd:colformats()} is intended for use in formatting Excel outputs that are exported from the dataset in memory. 

{title:Remarks}

{pstd}
{cmd:colwidths()} is mata program in the lipadms mata library which is part of {helpb ipacheck} Stata package. 

{title:Conformability}

    {cmd:colwidths(}{it:file}{cmd:,} sheet{cmd:,} {it:vars}{cmd:,} {it:format}{cmd:)}
	{it:  file}: 1 {it:x} 1
	{it: sheet}: 1 {it:x} 1
	{it:  vars}: 1 {it:x} 1
	{it:format}: 1 {it:x} 1
	{it:result}: {it:void}
	
{title:Examples} 

{synoptline}
  {text:Setup}
	{phang}{com}   . sysuse auto, clear{p_end}
	{phang}{com}   . export excel using "auto.xlsx", sheet("auto") replace first(var){p_end}

  {text:set number format of price to number_sep}
	{phang}{com}   . mata: colformats("auto.xlsx", "auto", "price", "number_sep"){p_end}
{synoptline}

  {text:Setup}
	{phang}{com}   . sysuse auto, clear{p_end}
	{phang}{com}   . export excel using "auto.xlsx", sheet("auto") replace first(var){p_end}

  {text:set number format of headroom and gear_ratio number_d2}
	{phang}{com}   . mata: colformats("auto.xlsx", "auto", ("headroom", "gear_ratio"), "number_sep"){p_end}
{synoptline}
	
{text}
{title:Author}

{pstd}Rosemarie Sandino, GRDS, Innovations for Poverty Action{p_end}
{pstd}Ishmail Azindoo Baako, GRDS, Innovations for Poverty Action{p_end}
{pstd}{it:Last updated: May 11, 2022}{p_end}

{title:Also see}

Help: {help putexcel:[RPT] putexcel}, {help mf_xl:[M-5] xl()}

Other commands in lipadms: {help addlines:addlines()}, {help addflags:addflags()}, {help colwidths:colwidths()}, {help setfont:setfont()}, {help setheader:setheader()}, {help settotal:settotal()}