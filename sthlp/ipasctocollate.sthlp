{smcl}
{* *! version 4.0.0 Innovations for Poverty Action 11may2022}{...}
{cmd:ipasctocollate} {c -} collate and export a dataset of SurveyCTO generated text audit or comment files.

{title:Syntax}

{pmore}
{cmd:ipasctocollate comments|textaudit}
{help varname:mediavar} 
{help if:[if]} {help in:[in]}
{cmd:,}
{opt folder("folder path")} 
{opt save("filename")}
[{it:{help ipasctocollate##options:options}}]

{marker options}
{synoptset 28 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:* {opt folder("folder path")}}folder containing comments/textaudit files{p_end}
{synopt:* {opt save("filename")}}save dta file{p_end}
{synopt:  {opt replace}}overwrite existing dataset{p_end}
{synoptline}
{p2colreset}{...}

{phang}* options {opt folder()} and {opt save()} are required.

{title:Description} 

{pstd}
{cmd:ipasctocollate} imports, appends and exports a single dta dataset for SurveyCTO 
generated text audit and comments files. This data is prepared for use by the {helpb ipachecktextaudit}
and {helpb ipacheckcomments} commands. {cmd:ipasctocollate} requires the data in memory
to include a variable "mediavar" which contains strings matching the names of files to import 
from {cmd:folder()}. If dataset specified in {cmd:save} already exist, {cmd:ipasctocollate} 
will skip the files that already exist in this dataset and import and append only new 
files detected. This significantly reduces the time required to import these files. 
 
{title:Options}

{dlgtab:Main}

{phang}
{cmd:folder("folder path"} specifies the folder that contains the text audit and comments files. 
{cmd:ipasctocollate} will check for files in {cmd:folder()} using the values
specified as {cmd:mediavar}. {cmd:ipasctocollate} will display a message if some of
files are not found in {cmd:folder()}. 

{phang}
{cmd:save("filename"} specifies the dta file to save after collating and appending
the text audit or comments files.  

{dlgtab:Specifications} 

{phang}
{cmd:replace} permits ipacheckcollate to overwrite an existing dataset.

{hline}

{title:Examples} 

{synoptline}
  {text:Setup}
	{phang}{com}   . use "https://raw.githubusercontent.com/PovertyAction/ipa_dms4.0/final/data/household_survey.dta", clear{p_end}
	{phang}{com}   . unzipfile "https://raw.githubusercontent.com/PovertyAction/ipa_dms4.0/final/data/media.zip", replace{p_end}

  {text:Collate field comments}
	{phang}{com}   . ipasctocollate comments field_comments, folder("./media") save("comments_data.dta") replace{p_end}
	
  {text:Collate text audit comments}
	{phang}{com}   . ipasctocollate textaudit text_audit, folder("./media") save("textaudit_data.dta") replace{p_end}
	
{synoptline}

{txt}{...}

{title:Stored results}

{p 6} {cmd:ipasctocollate} stores the following in r():{p_end}

{synoptset 25 tabbed}{...}
{syntab:{opt Scalars}}
{synopt:{cmd: r(N_total)}}number of text audit or field comment files expected{p_end}
{synopt:{cmd: r(N_allmiss)}}number of files found and imported{p_end}
{synopt:{cmd: r(N_miss)}}number of not found{p_end}
{p2colreset}{...}
	
{text}
{title:Author}

{pstd}Ishmail Azindoo Baako
(Innovations for Poverty Action){p_end}
{pstd}{it:Last updated: May 11, 2022}{p_end}

{pstd}For questions or suggestions, submit a
{browse "https://github.com/PovertyAction/high-frequency-checks/issues":GitHub issue}
or e-mail researchsupport@poverty-action.org.{p_end}

{title:Also see}

User-written: {help ipachecktextaudit:ipachecktextaudit}, {help ipacheckcomments:ipacheckcomments}