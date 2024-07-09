{smcl}
{* *! version 1.1.0 Innovations for Poverty Action 11may2022}{...}

{cmd:ipacodebook} {c -} Save codebook in excel format

{title:Syntax}

{pmore}
{cmd:ipacodebook}
{help varlist}
{cmd:using} 
{help filename}
{help if:[if]} {help in:[in]}
[{cmd:,}
{it:{help ipacodebook##options:options}}]

{marker options}
{synoptset 50 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{bf:note(#, {opt rep:lace}|{opt coal:esce}|{opt long:er}|{opt short:er})}}use notes as labels{p_end}
{synopt:{opt template}}Generate codebook as a template apply option{p_end}
{synopt:{opth apply:using(filename.xlsx)}}Apply new variable names and labels from template codebbok{p_end}
{synopt:{opt replace}}overwrite Excel file{p_end}
{synoptline}
{p2colreset}{...}

{title:Description} 

{pstd}
{cmd:ipacodebook} creates a codebook in excel format saving the variable name, variable label, variable type, number and percentage of missing values abd number of distinct values for each variable. Optionally, {cmd:ipacodebook} allows the user to generate a template for making corrections to labels and variable names as well as changing which can then be applied to the dataset using the apply option{p_end}
 
{title:Options}

{phang}
{cmd:note(#, replace|coalesce|longer|shorter)} specifies how notes and labels should be treated. {cmd:#} specifies the note number to use. {cmd:replace} specifies that the note should always be used as the variable label, {cmd:coalesce} indicates that the note be used if the variable label is missing, {cmd:longer} specifies that the note be used if it is longer than the variable label and {cmd:shorter} specifies that the note be used if it is not missing and shorter than the variable label. 

{phang}
{cmd:template} generates a template codebook which can be used to make edits to the variable names and labels. {cmd:template} generates a codebook fole with "new_variable" and "new_label" columns which will be used to indicate new variable names or labels where neccesary. 

{phang}
{cmd:applyusing("codebook_template.xlsx")} is used to apply changes from codebook template created by {cmd:template} option to the dataset. This option can only be used to change the variable names or variable labels. 

{phang}
{cmd:replace} overwrites an existing Excel workbook.

{hline}

{title:Examples} 

{synoptline}
  {text:Setup}
	{phang}{com}   . sysuse auto, clear{p_end}

  {text:export codebook for all variables}
	{phang}{com}   . ipacodebook _all using "auto_codebook.xlsx", replace{p_end}
{synoptline}
  {text:Setup}
	{phang}{com}   . sysuse auto, clear{p_end}

  {text:export codebook for all variables using the notes as variable labels if notes are longer}
	{phang}{com}   . ipacodebook _all using "auto_codebook.xlsx", note(1, longer) replace{p_end}
{synoptline}

{title:Stored results}

{p 6} {cmd:ipacodebook} stores the following in r():{p_end}

{synoptset 25 tabbed}{...}
{syntab:{opt Scalars}}
{synopt:{cmd: r(N_vars)}}number variables{p_end}
{synopt:{cmd: r(N_allmiss)}}number of variables with all missing values{p_end}
{synopt:{cmd: r(N_miss)}}number of variables with at least 1 missing values{p_end}
{p2colreset}{...}

{text}
{title:Acknowlegement}
{pstd}ipacodebook uses elements from the {browse https://github.com/PovertyAction/cbook_stat:cbook_stat} command written by Michael Rosenbaum of Innovations for Poverty Action. The {cmd:applyusing()} option of the command also is also inspired by the iecodebook command from World Bank DIME analytics team{p_end}
	
{text}
{title:Author}

{pstd}Ishmail Azindoo Baako & Arsene, GRDS, Innovations for Poverty Action{p_end}

{title:Also see}

Help: {help codebook:[D] codebook}

User-written: {help codebookout:codebookout}, {help iecodebook:iecodebook}