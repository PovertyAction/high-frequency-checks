{smcl}
{* *! version 4.0.0 Innovations for Poverty Action 11may2022}{...}

{cmd:ipacheck} {c -} Update ipacheck package and initialize a high frequency check project or exercise

{title:Syntax}

{phang}
Start new project with folder structure and/or input files

{pmore}
{cmd:ipacheck new}
[{cmd:,} {it:{help ipacheck##new_options:new_options}}]

{phang}
Update ipacheck package

{pmore}
{cmd:ipacheck update}
[{cmd:,} {it:{help ipacheck##update_options:update_options}}]

{phang}
Display version for each command in ipacheck

{pmore}
{cmd:ipacheck version}

{marker new_options}
{synoptset 23 tabbed}{...}
{synopthdr:new_options}
{synoptline}
{synopt:{opt surv:eys(namelist)}}get input files for multiple projects{p_end}
{synopt:{opt fold:er("folder path")}}save to folder location{p_end}
{synopt:{opt sub:folders}}create subfolders for each survey in {cmd:surveys()} option{p_end}
{synopt:{opt files:only}}get input files only{p_end}
{synopt:{opt br:anch("branchname")}}install programs and files from specified repository instead of master{p_end}
{synopt:{opt ex:ercise}}generate folder structure with input files and exercise data{p_end}
{synoptline}
{p2colreset}{...}

{marker update_options}
{synoptset 23 tabbed}{...}
{synopthdr:update_options}
{synoptline}
{synopt:{opt branch("branchname")}}install programs and files from specified repository instead of master{p_end}
{synoptline}
{p2colreset}{...}

{title:Description} 

{pstd}
{cmd:ipacheck} creates a new project folder structure, updates all ado files and 
mata libraries, or displays the current version of ado files.

{hline}

{pstd}
{cmd:ipacheck new} initializes a project's high frequency checks. It incluses options to
 create the folder structure, subfolders for multiple projects, and download inputs files.
 
{title:Options for {it:ipacheck new}}

{phang}
{cmd:surveys(string)} lists all survey forms on which HFCs will be run. 
The {cmd:surveys()} option is typical used for managing projects with multiple surveys. The 
{cmd:surveys()} option can be specified as {cmd:surveys(household adult)} to indidate 2 
surveys; a household and an adult survey. Items in the {cmd:survey()}  option 
must be enclosed in double quotes if they contain blacks. eg. 
{cmd:surveys("household survey" "adult survey")}. If {cmd:surveys()} is not 
specified, the default is to set up input files for one survey only
  
{phang}
{cmd:folder("folder path")} specifies the location in which the new folder structure 
should be saved. If the {cmd:folder()} option is not specified, the default is to save 
the folder structure and files in the current working directory.

{phang}
{cmd:subfolders} creates individual sub-folders for each survey form specified with 
{cmd:surveys()} option. This option therefore can only be specified if multiple 
survey forms are added with the {cmd:surveys()} option. This option also saves 
input files will in each sub-folder. If {cmd:subfolders} is not specified, the default
is to save all input files in the same checks folder. 

{phang}
{cmd:filesonly} saves only the input files for high-frequency checks 
(hfc_inputs.xlsm, corrections.xlsm, specifyrecode.xlsm, 0_master.do, 2_prep.do &
 3_globals.do). These will be saved in the location specified in the {cmd:folder()} 
 option or the current working directory if {cmd:folder()} is not specified.

{phang}
{cmd:exercise} generates the folder structure and populates input files and an 
exercise dataset for completing exercise. These will be saved in the location 
specified in the {cmd:folder()} option or the current working directory if 
{cmd:folder()} is not specified.

{phang}
{cmd:branch("branchname")} specifies the branch from the github repository to 
connect to. This option is mostly used for debugging and should only be used upon
the request of the authors. 

{hline}

{pstd}
{cmd:ipacheck update} updates all commands and mata libraries in the ipacheck package 
to the most recent versions on the 
{browse "https://github.com/PovertyAction/high-frequency-checks/master":high-frequency-checks} 
repository of PovertyAction Github account. 

{title:Options for {it:ipacheck update}}

{phang}
{cmd:branch("branchname")} specifies the branch from the github repository to 
connect to. This option is mostly used for debugging and should only be used upon
the request of the authors. 

{hline}

{pstd}
{cmd:ipacheck version} displays the version information for all commands in the 
ipacheck package.

{hline}

{title:Examples} 

{phang}
{txt}Setting up new HFC folder for a project with two forms (Adult and Household) and with sub-folders for running individual checks on each form{p_end}

{phang}{com}. ipacheck new, surveys(Household Adult) folder("My project") subfolders{p_end}

{phang}
{txt}Setting up new HFC folder for a project with two forms (Adult and Household) with files for checks of these forms in same location{p_end}

{phang}{com}. ipacheck new, surveys(Household Adult) folder("My project"){p_end}

{phang}
{txt}Setting up new HFC folder for a project with one single form{p_end}

{phang}{com}. ipacheck new, folder("My project"){p_end}

{phang}
{txt}Saving only input files for a project without generating a HFC folder{p_end}

{phang}{com}. ipacheck new, folder("My project") files {p_end}

{phang}
{txt}Learning how data flow works by running exercise {p_end}

{phang}{com}. ipacheck new, folder("Exercise Project") exercise {p_end}
{txt}

{title:Remarks}

{pstd}All files and source code for the {cmd:ipacheck} package can found
{browse "https://github.com/PovertyAction/high-frequency-checks":here} on Github. 
The {cmd:ipacheck} package contains the following commands:

{synoptset 30 tabbed}{...}
{synopthdr:Program}
{synoptline}
{syntab:Main programs}
{synopt:{help ipacheckcorrections}}makes corrections to data{p_end}
{synopt:{help ipacheckspecifyrecode}}recodes other specify values{p_end}
{synopt:{help ipacheckversions}}analyze and report on survey form version{p_end}
{synopt:{help ipacheckids}}export duplicates in survey ID{p_end}
{synopt:{help ipacheckdups}}export duplicates in non-ID variables{p_end}
{synopt:{help ipacheckmissing}}export statistics on missingness & distinctness for each variable{p_end}
{synopt:{help ipacheckspecify}}export all values specified for variables with an 'other' category{p_end}
{synopt:{help ipacheckoutliers}}export outliers in numeric variables{p_end}
{synopt:{help ipacheckcomments}}export field comments generated with SurveyCTO's comments field type{p_end}
{synopt:{help ipachecktextaudit}}export field duration statistics using the SurveyCTO's text audit files{p_end}
{synopt:{help ipachecktimeuse}}export statistics on hours of engagement using the SurveyCTO's text audit files{p_end}
{synopt:{help ipachecksurveydb}}export general statistics about dataset{p_end}
{synopt:{help ipacheckenumdb}}export general statistics about enumerator performance{p_end}
{synopt:{help ipatracksurvey}}export dashboard for tracking survey progress{p_end}

{syntab:Ancilliary programs}
{synopt:{help ipacodebook}}export codebook to excel{p_end}
{synopt:{help ipasctocollate}}collate and export a dataset of SurveyCTO generated text audit or comment files{p_end}
{synopt:{help ipalabels}}remove labels or values from variables{p_end}
{synopt:{help ipagettd}}convert datetime variables to date{p_end}
{synopt:{help ipagetcal}}create a date calendar dataset{p_end}
{synopt:{help ipaanycount}}create a variable that returns the number of variables in varlist for which values are equal to any specified integer/string{p_end}

{syntab:Mata library}
{synopt:{help addlines}}add a lower border line to a row in an excel file{p_end}
{synopt:{help addflags}}add a background color to a cell in an excel file{p_end}
{synopt:{help colwidths}}adjust column widths in excel file using length of values in current dataset{p_end}
{synopt:{help colformats}}apply number format to a column in an excel file{p_end}
{synopt:{help setfont}}set font size and type for a range of cells in an excel file{p_end}
{synopt:{help setheader}}set the first row in an excel file as a header row{p_end}
{synopt:{help settotal}}set the last row in an excel file as a total row{p_end}

{synoptline}
{p2colreset}{...}

{title:Acknowledgements}

{pstd}The {cmd:ipacheck} and all of its associated content and materials is developed 
by the Global Research & Data Support (GRDS) Team of Innovations for Poverty Action. 
The current {cmd:version 4.0} of this Stata package is partly based on previous 
versions of which were authored by:

{phang} .Chris Boyer{p_end}
{phang} .Ishmail Azindoo Baako{p_end}
{phang} .Rosemarie Sandino{p_end}  
{phang} .Isabel Onate{p_end}
{phang} .Kelsey Larson{p_end}
{phang} .Caton Brewster{p_end}

{title:Author}

{pstd}Ishmail Azindoo Baako, GRDS, Innovations for Poverty Action{p_end}
{pstd}Rosemarie Sandino, GRDS, Innovations for Poverty Action{p_end}
{pstd}{it:Last updated: June 11, 2022}{p_end}
