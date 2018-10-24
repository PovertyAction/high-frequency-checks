{smcl}

{title:Title}

{cmd:ipacheck} {hline 2} Updates the ipacheck package and sets up high frequency check projects


{title:Syntax}

{phang}
Start new project with folder structure and/or input files

{p 8 10 2}
{cmd:ipacheck new}
[{cmd:,} {it:options}]

{phang}
Update ipacheck package to most recent version

{p 8 10 2}
{cmd:ipacheck update}

{phang}
Display version for each ado file in ipacheck

{p 8 10 2}
{cmd:ipacheck version}


{synoptset 23 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt surveys(string)}}list of surveys in project {p_end}
{synopt:{opth folder(filename)}}save to folder location{p_end}

{syntab:Options}
{synopt:{opt subfolders}}create subfolders for each survey listed in {cmd:surveys}{p_end}
{synopt:{opt files}}only generates input files without folder structure {p_end}
{synoptline}
{p2colreset}{...}


{title:Description} 

{pstd}
{cmd:ipacheck} creates a new project folder structure, updates all ado files, or displays the 
current version of ado files, depending on the subcommand specified.

{pstd}
{cmd:ipacheck new} initializes a project's high frequency checks with options to
 create the folder structure, include subfolders for multiple projects, or just the 
 inputs files, depending on options specified.

{pstd}
{cmd:ipacheck update} updates all commands in the ipacheck package to the most 
recent versions in the master branch on the high-frequency-checks repository 
in the PovertyAction Github.

{pstd}
{cmd:ipacheck version} displays the version information for all ado files in 
the ipacheck package.


{title:Options}

{phang}
{opt surveys(string)} lists all survey forms on which you will run high frequency checks.

{phang}
{opth folder(filename)} specifies the location in which new folder structure should be saved; if not specified, the folder will be saved in the current working directory.

{phang}
{opt subfolders} creates individual sub-folders for each survey form and can only be used with multiple forms; if not specified but multiple survey forms are added, files with be saved with the form name.

{phang}
{opt files} saves only the input files for high-frequency checks (hfc_inputs.xlsm, hfc_replacements.xlsm, and master_check.do). 
These will be saved in the location specified in the -folder- option or the current working directory if nothing is specified.


{title:Examples} 

{phang}
{txt}Setting up new HFC folder for a project with two forms (Adult and Household) and with sub-folders for running individual checks on each form{p_end}
{phang}
{com}. ipacheck new, surveys(Household Adult) folder("My project") subfolders{p_end}

{phang}
{txt}Setting up new HFC folder for a project with two forms (Adult and Household) with files for checks of these forms in same location{p_end}
{phang}
{com}. ipacheck new, surveys(Household Adult) folder("My project"){p_end}

{phang}
{txt}Setting up new HFC folder for a project with one single form{p_end}
{phang}
{com}. ipacheck new, folder("My project"){p_end}

{phang}
{txt}Setting up new HFC folder for a project with one single form and saving only files{p_end}
{phang}
{com}. ipacheck new, folder("My project") files {p_end}
{txt}

{title:Remarks}

{pstd}The GitHub repository for {cmd:ipacheck} is {browse "https://github.com/PovertyAction/high-frequency-checks":here}.

{title:Author}

{pstd}Christopher Boyer and Isabel Oñate{p_end}
{pstd}Last updated: October 15, 2018{p_end}
	