{smcl}
{* *! version 1.0.0 Innovations for Poverty Action 13dec2019}{...}
{title:Title}

{phang}
{cmd:ipabcstats} {hline 2} Compare survey and back check data,
producing an Excel output of comparisons and error rates.


{marker syntax}{...}
{title:Syntax}

{p 8 10 2}
{cmd:ipabcstats,}
{opth s:urveydata(filename)} 
{opth b:cdata(filename)} 
{opth id(varlist)}
{opth enum:erator(varlist)}
{opth back:checker(varlist)}
{opth file:name(filename)}
{opth surveydate(varlist)}
{opth bcdate(varlist)}
[{it:options}]


{* Using -help bcstats- from SSC as a template.}{...}
{synoptset 23 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{* Using -help ca postestimation- as a template.}{...}
{p2coldent:* {opth s:urveydata(filename)}}the survey data{p_end}
{p2coldent:* {opth b:cdata(filename)}}the back check data{p_end}
{p2coldent:* {opth id(varlist)}}the unique ID(s){p_end}
{p2coldent:* {opth enum:erator(varlist)}}the enumerator ID{p_end}
{p2coldent:* {opth back:checker(varlist)}}the backchecker ID{p_end}
{p2coldent:* {opth file:name(filename)}}save output file as {it:filename} {p_end}
{p2coldent:* {opth surveydate(varlist)}}the survey date variable (%tc format) {p_end}
{p2coldent:* {opth bcdate(varlist)}}the survey date variable (%tc format) {p_end}

{syntab:Comparison variables}
{p2coldent:+ {opth t1vars(varlist)}}the list of
{help bcstats##type1:type 1 variables}{p_end}
{p2coldent:+ {opth t2vars(varlist)}}the list of
{help bcstats##type2:type 2 variables}{p_end}
{p2coldent:+ {opth t3vars(varlist)}}the list of
{help bcstats##type3:type 3 variables}{p_end}

{syntab:Enumerator checks}
{synopt:{opth enumt:eam(varname)}}display the overall error rates of
all enumerator teams; {varname} in survey data is used{p_end}
{synopt:{opth bct:eam(varname)}}display the overall error rates of
all back check teams; {varname} in back check data is used{p_end}
{synopt:{cmdab:showid(}{it:integer}[%]{cmd:)}}display unique IDs with
at least {it:integer} differences or at least an {it:integer}% error rate or {it:integer} differences if {it:%} is not included;
default is {cmd:showid(30%)}{p_end}

{syntab:Stability checks}
{synopt:{opth ttest(varlist)}}run paired two-sample mean-comparison tests for
{varlist} in the back check and survey data using {helpb ttest}{p_end}
{synopt:{opth prtest(varlist)}}run two-sample test of equality of proportions in 
the back check and survey data for dichotmous variables in {varlist} using {helpb prtest}{p_end}
{synopt:{opt l:evel(#)}}set confidence level for {helpb ttest} and {helpb prtest};
default is {cmd:level(95)}{p_end}
{synopt:{opth signrank(varlist)}}run
Wilcoxon matched-pairs signed-ranks tests for {varlist} in
the back check and survey data using {helpb signrank}{p_end}

{syntab:Reliability checks}
{synopt:{opth rel:iability(varlist)}}calculate the simple response variance (SRV) 
and reliability ratio for type 2 and 3 variables in {varlist}{p_end}

{syntab:Comparisons}
{synopt:{opth keepsu:rvey(varlist)}}include {varlist} in the survey data in
the comparisons data set{p_end}
{synopt:{opth keepbc(varlist)}}include {varlist} in the back check data in
the comparisons data set{p_end}
{synopt:{opt full}}include all comparisons, not just differences{p_end}
{synopt:{opt nol:abel}}do not use value labels{p_end}
{synopt:{opt replace}}overwrite existing file{p_end}

{syntab:Options}
{synopt:{cmd:okrange(}{varname} {it:range} [, {varname} {it:range} ...]{cmd:)}}do
not count a value of {varname} in the back check data as a difference if
it falls within {it:range} of the survey data{p_end}
{synopt:{opth nodiffn:um(numlist)}} do not count
back check responses that equal {it:#} as differences{p_end}

{synopt:{cmd:{ul:nodiffs}tr(}{it:"string"} [ {it:"string"} ...]{cmd:)}} do not count
back check responses that equal {it:string(s)} as differences. Use quotations around each individual string.{p_end}

{synopt:{opth excluden:um(numlist)}} do not compare back check responses that equal any number in {it:numlist}.{p_end}
{synopt:{cmd:{ul:excludes}tr(}{it:"string"} [ {it:"string"} ...]{cmd:)}} do not compare back check responses that equal any string.{p_end}
{synopt:{opt excludemiss:ing}} do not compare back check responses that
are missing. Includes extended missing values for numeric variables [., .a, .b, ..., .z] and blanks "" for string variables.{p_end}
{synopt:{opt lo:wer}}convert all string variables to lower case before
comparing{p_end}
{synopt:{opt up:per}}convert all string variables to upper case before
comparing{p_end}
{synopt:{opt nos:ymbol}}replace symbols with spaces in string variables before
comparing{p_end}
{synopt:{opt tr:im}}remove leading or trailing blanks and
multiple, consecutive internal blanks in string variables before
comparing{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}* {opt surveydata()}, {opt bcdata()}, {opt id()}, {opt enumerator()}, and {opt backchecker()} are required.{p_end}
{p 4 6 2}* Note that {opt enumerator()}, {opt backchecker()}, {opt enumteam()}, and {opt bcteam()} must be numeric variables.{p_end}
{p 4 6 2}+ At least one type option must be specified. {p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:bcstats} compares back check data and survey data,
producing a data set of comparisons.
It completes enumerator checks for type 1 and type 2 variables and
stability checks for type 2 and type 3 variables.


{marker remarks}{...}
{title:Remarks}

{pstd}
The GitHub repository for {cmd:ipabcstats} is
{browse "https://github.com/PovertyAction/ipabcstats":here}.
Previous versions may be found there: see the tags.


{marker options}{...}
{title:Options}

{dlgtab:Comparison variables}

{phang}
{marker type1}
{opth t1vars(varlist)} specifies the list of type 1 variables.
Type 1 variables are expected to stay constant between
the survey and back check, and differences may result in action against
the enumerator. Display variables with high error rates and
complete enumerator checks.
See the Innovations for Poverty Action
{help ipabcstats##back_check_manual:back check manual} for
more on the three types.

{phang}
{marker type2}
{opth t2vars(varlist)} specifies the list of type 2 variables.
Type 2 variables may be difficult for enumerators to administer.
For instance, they may involve complicated skip patterns or many examples.
Differences may indicate the need for further training,
but will not result in action against the enumerator.
Display the error rates of all variables and
complete enumerator and stability checks.
See the Innovations for Poverty Action
{help bcstats##back_check_manual:back check manual} for
more on the three types.

{phang}
{marker type3}
{opth t3vars(varlist)} specifies the list of type 3 variables.
Type 3 variables are variables whose stability between
the survey and back check is of interest.
Differences will not result in action against the enumerator.
Display the error rates of all variables and complete stability checks.
See the Innovations for Poverty Action
{help bcstats##back_check_manual:back check manual} for
more on the three types.

{dlgtab:Stability checks}

{phang}
{opt level(#)} specifies the confidence level, as a percentage, for
confidence intervals calculated by {helpb ttest} and {helpb prtest}.
The default is {cmd:level(95)} or as set by {helpb set level}.

{dlgtab:Comparisons data set}

{phang}
{opth keepsurvey(varlist)} specifies that variables in {varlist} in
the survey data are to be included in the output file.
{opth keepbc(varlist)} specifies that variables in {varlist} in
the back check data are to be included in the output file.

{phang}
{opt nolabel} specifies that survey and back check responses are
not to be value-labeled in the comparisons data set.
Variables specified through {opt keepsurvey} or {opt keepbc} are
also not value-labeled.

{dlgtab:Options}

{phang}
{cmd:okrange(}{varname} {it:range} [, {varname} {it:range} ...]{cmd:)}
specifies that a value of {varname} in the back check data will not
be counted as a difference if it falls within {it:range} of the survey data.
{it:range} may be of the form {cmd:[}{it:-x}, {it:y}{cmd:]} (absolute) or
{cmd:[}{it:-x%}, {it:y%}{cmd:]} (relative).

{phang}
{opth excludenum(numlist)} specifies that
back check responses that equal any value in {it:numlist} will not be compared.
These responses will not affect error rates and
will be marked as "not compared" if you use the {it:full} option. Otherwise, they will not appear in the output file. 

{phang}
{cmd:excludestr(}{it:"string"} [, {it:"string"} ...]{cmd:)} specifies that
back check responses that equal any string in this list will not be compared.
These responses will not affect error rates and
will be marked as "not compared" if you use the {it:full} option. Otherwise, they will not appear in the output file. Be sure to keep each string in its own quotations, especially if there are spaces within a string.  

{phang}
{opt excludemissing} specifies that
back check responses that are missing will not be compared. This uses the {manhelp missing R} command, so any extended missing value [., .a, .b, ..., .z] for numeric variables, and blanks ("") for string variables. Used when the back check data set contains data for
multiple back check survey versions.

{phang}
{cmd:nodiffstr(}{it:"string"} [, {it:"string"} ...]{cmd:)} specifies that
if a back check response equal any string in the list, it will not be counted as difference,
regardless of what the survey response is.

{phang}
{opth excludenum(numlist)} specifies that
if a back check response equals any number in {it:numlist}, it will not be counted as difference,
regardless of what the survey response is.

{phang}
{opt nosymbol} replaces the following characters in string variables with
a space before comparing:
{cmd:. , ! ? ' / ; : ( ) ` ~ @ # $ % ^ & * - _ + = [ ] { } | \ " < >}

{phang}
{opt trim} removes leading or trailing blanks and
multiple, consecutive internal blanks before comparing.
If {opt nosymbol} is specified,
this occurs after symbols are replaced with a space.


{marker examples}{...}
{title:Examples}

{pstd}Assume that missing values were not asked in
the back check survey version.{p_end}
{phang2}{cmd:bcstats, surveydata(bcstats_survey) bcdata(bcstats_bc) id(id) ///}{p_end}
{phang3}{cmd:okrange(gameresult [-1, 1], itemssold [-5%, 5%]) excludemissing ///}{p_end}
{phang3}{cmd:t1vars(gender) enumerator(enum) enumteam(enumteam) backchecker(bcer) ///}{p_end}
{phang3}{cmd:t2vars(gameresult) signrank(gameresult) ///}{p_end}
{phang3}{cmd:t3vars(itemssold) ttest(itemssold) ///}{p_end}
{phang3}{cmd:surveydate(submissiondate) bcdate(submissiondate) keepbc(comments) keepsurvey(comments) full replace}{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:bcstats} saves the following in {cmd:r()}:

{* Using -help describe- as a template.}{...}
{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(showid)}}1 if {opt showid()} displayed
number of IDs over the threshold specified in {opt showid}{p_end}
{synopt:{cmd:r(bc_only)}}1 number of IDs only in backcheck data {p_end}
{synopt:{cmd:r(total_rate)}}1 total error rate {p_end}
{synopt:{cmd:r(avd)}}1 average days between survey and backcheck {p_end}
{synopt:{cmd:r(survey)}}1 number of survey observations {p_end}
{synopt:{cmd:r(bc)}}1 number of backcheck observations {p_end}

{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(enum)}}the total error rates of all enumerators{p_end}
{synopt:{cmd:r(enum1)}}the type 1 variable error rates of all enumerators{p_end}
{synopt:{cmd:r(enum2)}}the type 2 variable error rates of all enumerators{p_end}
{synopt:{cmd:r(enum3)}}the type 3 variable error rates of all enumerators{p_end}
{synopt:{cmd:r(backchecker)}}the total error rates of
the back checkers{p_end}
{synopt:{cmd:r(backchecker1)}}the type 1 variable error rates of
the back checkers{p_end}
{synopt:{cmd:r(backchecker2)}}the type 2 variable error rates of
the back checkers{p_end}
{synopt:{cmd:r(backchecker3)}}the type 3 variable error rates of
the back checkers{p_end}
{synopt:{cmd:r(enumteam)}}the total error rates of
the enumerator teams{p_end}
{synopt:{cmd:r(enumteam1)}}the type 1 variable error rates of
the enumerator teams{p_end}
{synopt:{cmd:r(enumteam2)}}the type 2 variable error rates of
the enumerator teams{p_end}
{synopt:{cmd:r(enumteam3)}}the type 3 variable error rates of
the enumerator teams{p_end}

{synopt:{cmd:r(bcteam)}}the total error rates of
the back checker teams{p_end}
{synopt:{cmd:r(bcteam1)}}the type 1 variable error rates of
the back checker teams{p_end}
{synopt:{cmd:r(bcteam2)}}the type 2 variable error rates of
the back checker teams{p_end}
{synopt:{cmd:r(bcteam3)}}the type 3 variable error rates of
the back checker teams{p_end}

{synopt:{cmd:r(var)}}the error rates of all variables{p_end}
{synopt:{cmd:r(var1)}}the error rates of all type 1 variables{p_end}
{synopt:{cmd:r(var2)}}the error rates of all type 2 variables{p_end}
{synopt:{cmd:r(var3)}}the error rates of all type 3 variables{p_end}
{synopt:{cmd:r(ttest)}}the results of {cmd:ttest} for selected variables{p_end}
{synopt:{cmd:r(ttest2)}}the results of {cmd:ttest} for type 2 variables{p_end}
{synopt:{cmd:r(ttest3)}}the results of {cmd:ttest} for type 3 variables{p_end}
{synopt:{cmd:r(signrank)}}the results of {cmd:signrank} for selected variables{p_end}
{synopt:{cmd:r(signrank2)}}the results of {cmd:signrank} for
type 2 variables{p_end}
{synopt:{cmd:r(signrank3)}}the results of {cmd:signrank} for
type 3 variables{p_end}
{synopt:{cmd:r(prtest)}}the results of {cmd:prtest} for selected variables{p_end}
{synopt:{cmd:r(prtest2)}}the results of {cmd:prtest} for type 2 variables{p_end}
{synopt:{cmd:r(prtest3)}}the results of {cmd:prtest} for type 3 variables{p_end}

{synopt:{cmd:r(enum_bc)}}percentage of surveys backchecked for all enumerators {p_end}
{synopt:{cmd:r(rates)}}error rates by variable type {p_end}
{synopt:{cmd:r(rates_time)}}error rates by variable type over time{p_end}
{p2colreset}{...}


{marker references}{...}
{title:References}

{marker back_check_manual}{...}
{phang}
{browse "https://povertyaction.force.com/support/s/article/back-check-manual":Innovations for Poverty Action Back Check Manual}


{marker acknowledgements}{...}
{title:Acknowledgements}

{pstd}
Hana Scheetz Freymiller of Innovations for Poverty Action conceived of
the three variable types. bcstats was originally written by Matthew White with edits from Christopher Boyer, and the code and structure of this command draws heavily from their work.

{marker author}{...}
{title:Author}

{pstd}Ishmail Azindoo Baako{p_end}
{pstd}Rosemarie Sandino{p_end}

{pstd}For questions or suggestions, submit a
{browse "https://github.com/PovertyAction/ipabcstats/issues":GitHub issue}
or e-mail researchsupport@poverty-action.org.{p_end}


{title:Also see}

{psee}
Help:  {manhelp ttest R}, {manhelp prtest R}, {manhelp signrank R}

