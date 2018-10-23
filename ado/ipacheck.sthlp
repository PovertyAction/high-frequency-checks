{smcl}

{title:Title}

{cmd:ipacheck} {hline 2} Updates the ipacheck package and sets up high frequency check projects


{title:Syntax}

{p 8 17 2}
{cmd:ipacheck} [version] [update] [new, (options)]

{synoptset 23 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{p2coldent:* {opt v:ersion}}displays version history for each ado package{p_end}
{p2coldent:* {opt u:pdate}}updates versions for ado packages wherever needed{p_end}
{p2coldent:* {opt n:ew(options)}}sets up new high frequency check folder and populates with subfolders and Read Me files{p_end}

{syntab:Options}
{synopt:{opt surveys(string)}}include survey forms{p_end}
{synopt:{opth folder(filename)}}save to folder location{p_end}
{synopt:{opt subfolders}}create subfolders for each survey form{p_end}
{synopt:{opt files}}saves only files{p_end}
{synoptline}
{p2colreset}{...}

{p 4 6 2}* {opt version}, {opt update}, or {opt new()} is required. You may only select one option.

{title:Description} 

{pstd}
{cmd:ipacheck} updates the ipacheck package and initializes the high frquency check process by setting up a folder & populating it with sub-folders and templates

{title:Options}

{phang}
{opt surveys(string)} lists all survey forms on which you will run high frequency checks.

{phang}
{opth folder(filename)} specifies the location in which new folder should be saved; if not specified, the folder will be saved in the current working directory.

{phang}
{opt subfolders} creates individual sub-folders for each survey form and can only be used with multiple forms; if not specified but multiple survey forms are added, files with be saved with the form name.

{phang}
{opt files} saves only the files without creating any individual sub-folders.

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
