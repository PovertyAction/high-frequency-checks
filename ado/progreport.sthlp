{smcl}
{* *! version 1.0.2 Rosemarie Sandino 20jul2018}{...}
{title:Title}

{phang}
{cmd:progreport} {hline 2}
Compares master and survey datasets to create a progress report of completion rates
and optionally creates a dataset of those who have not been interviewed

{marker syntax}{...}
{title:Syntax}

{p 8 10 2}
{cmd:progreport}{cmd:,}
{opth m:aster(filename)} 
{opth s:urvey(filename)} 
{opth id(varname)} 
{opth sort:by(varname)} 
{opth keepm:aster(varlist)} 
[{it:options}]

{* Using -help readreplace- as a template.}{...}
{* 20 is the position of the last character in the first column + 3.}{...}
{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{* Using -help heckman- as a template.}{...}
{p2coldent:* {opth m:aster(filename)}}master dataset{p_end}
{p2coldent:* {opth s:urvey(filename)}}survey dataset{p_end}
{p2coldent:* {opth id(varname)}}ID variable from survey{p_end}
{p2coldent:* {opth sort:by(varname)}}variable to stratify progress report from master dataset {p_end}
{p2coldent:* {opth keepm:aster(varlist)}}variables to keep from master dataset; 
ID variable and sortby variable already included{p_end}


{syntab:Specifications}
{synopt:{opth mid(varname)}}ID variable from master dataset if different from
survey dataset ID variable name {p_end}
{synopt:{opth keeps:urvey(varlist)}}variables to keep from survey dataset; 
ID variable and sortby variable already included {p_end}
{synopt:{opth dta(filename)}}creates a dta file of those who have 
not been interviewed from master dataset {p_end}
{synopt:{opth track:ing(filename)}}tracking form dataset {p_end}
{synopt:{opth tvar(varname)}}categorical variable from tracking form dataset 
that specifies reason respondent has not been interviewed {p_end}

{synopt:{opth file:name(filename)}}specifies the name of the 
progress report file; default is {it:Progress Report.xlsx}{p_end}
{synopt:{opt t:arget(#)}}target completion rate between 0 and 1; default is 1 
(100% or all master dataset respondents interviewed){p_end}
{synopt:{opt var:iable}}specifies that variable names should be used as column
headers instead of variable labels{p_end}
{synopt:{opt nolab:el}}export variable values instead of value labels{p_end}
{synopt:{opt clear}}clears current memory and replaces with merged datasets{p_end}
{synopt:{opt surveyok}}allows observations that only appear in survey data instead of only those that match across master and survey data.{p_end}
{synopt:{opt work:books}}creates workbooks of completion rates for each value of 
sortby variable instead of sheets. If there are over 20 values of the sortby variable, warning will suggest using this option.{p_end}

{synoptline}
{p2colreset}{...}
{* Using -help heckman- as a template.}{...}
{p 4 6 2}* {opt master()}, {opt survey()}, {opt id()}, {opt sortby()}, and {opt keepmaster()} are required.


{title:Description}

{pstd}
{cmd:progreport} merges the master dataset and survey dataset to track the progress
of data collection and reports completion rates by the sortby variable.

{pstd}
Progress Report.xlsx is created and includes a summary sheet of completion rate 
by the sortby variable, as well as a sheet for each value of the sortby variable. 
This includes a status for each observation in the master dataset and a submission
date for those that have been interviewed. If specified, {cmd:progreport} can also 
create a dataset only including those who have not been interviewed. 


{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:progreport} reduces time spent tracking survey progress by clearly 
reporting progress across all data collection and broken down by a sorting variable.  

{marker remarks}{...}
{title:Remarks for options tracking() and tvar()}

{pstd}
{cmd:tracking()} and {cmd:tvar()} are used when the data collection also includes 
a tracking form that enumerators use when they cannot interview a respondent.{cmd:tracking()} 
is the location of the tracking dataset, and {cmd:tvar()} is the 
categorical variable in the tracking dataset that specifies the reason why the respondent
could not be interviewed at that time. This tracking dataset should also have an 
observation for each attempt to interview a respondent. 

{pstd}
When {cmd:tracking()} and {cmd:tvar()} are included, each sheet's output will 
also include columns "track_date" and "pr_attempts". For each observation, "track_date"
will show the most recent tracking form submission date (if any)and "pr_attempts" 
will show the number of attempts, calculated by collapsing the tracking dataset
by observation.

{pstd}
The "status" output column will still appear green and will say "Submitted" if the
respondent has a survey submitted in the survey dataset, even if they had a previous
tracking form entry. The "status" column will appear yellow and read "Only Tracking Form"
 if the respondent does not appear in the survey dataset but has at least one 
 tracking dataset observation, and will appear red and read "Not Submitted" if the 
 respondent only appears in the master dataset.


{marker examples}{...}
{title:Examples}

{pstd}
Create progress report for survey_data.dta from master dataset master_data.dta
{p_end}{cmd}{...}
{phang2}. progreport, master("master_data.dta") survey("survey_data.dta")
id(respondent_id) keepmaster(treatment contact1 contact2) keepsurvey(phone_1 phone_2) sortby(comm_live) {p_end}
{txt}{...}

{pstd}
Create progress report and create dataset of those not yet interviewed named "need_to_interview.dta"
{p_end}{cmd}{...}
{phang2}. progreport, master("master_data.dta") survey("survey_data.dta") dta("need_to_interview.dta")
id(respondent_id) keepmaster(treatment contact1 contact2) keepsurvey(phone_1 phone_2) sortby(comm_live){p_end}
{txt}{...}


{marker authors}{...}
{title:Authors}

{pstd}Rosemarie Sandino{p_end}
{pstd}Christopher Boyer{p_end}

{pstd}For questions or suggestions, submit a
{browse "https://github.com/PovertyAction/progreport/issues":GitHub issue}
or e-mail researchsupport@poverty-action.org.{p_end}

