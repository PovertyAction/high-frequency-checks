# ipacheck

## Overview
ipacheck is a Stata package for running high-frequency checks on research data at Innovations for Poverty Action, including:

 - `ipacheckcomplete` - verifies that all surveys are completed.
 - `ipacheckdups` - identifies possible duplicate observations.
 - `ipacheckconsent` - verifies that all surveys have consent.
 - `ipachecknomiss` - verifies that certain variables have no missing values.
 - `ipacheckfollowup` - verifies consistency of data between rounds of data collection (e.g. baseline and follow up).
 - `ipachecklogic` - asserts that skip patterns are followed.
 - `ipacheckallmiss` - identifies variables who contain only missing values.
 - `ipacheckconstraints` - asserts that hard and soft constraints are followed.
 - `ipacheckspecify` - lists all values specified for variables with an 'other' category for possible recoding.
 - `ipacheckdates` - verifies consistency of date variables.
 - `ipacheckoutliers` - identifies possible outliers in numeric variables.
 - `ipatracksummary` - lists number of surveys completed by date. 
 - `progreport` - lists surveys completed against sample/tracking list filtered by a variable.
 - `ipatrackversions`- lists number of surveys by date and version.
 - `ipacheckenum` - aggregates data by enumerator to assess performance.
 - `ipacheckresearch` - produces one- and two-way summaries of research variables.
 - `ipacheckids` - creates a formatted output sheet to compare differences between duplicate observations.
  
 
ipacheck comes with a folder structure for your project including a master do-file and Excel-based inputs sheets. Results of checks can be exported as nicely formatted Excel spreadsheets for distribution among field teams.


## Installation

```Stata
* ipacheck may be installed directly from GitHub
net install ipacheck, from("https://raw.githubusercontent.com/PovertyAction/high-frequency-checks/master/ado") replace 

* after initial installation ipacheck can be updated at any time via
ipacheck update

* to start a new project with folder structure and input files
ipacheck new, surveys("SURVEY_NAME_1") folder("path/to/project")

* when starting a new project with multiple surveys, you can choose to use the subfolders option to create subfolders for each survey
ipacheck new, surveys("SURVEY_NAME_1" "SURVEY_NAME_2") folder("path/to/project") subfolders

* to obtain fresh copies of the master do-file and Excel inputs without creating the folder structure
ipacheck new, files

* to verify you have the latest versions of the commands
ipacheck version
```
If you encounter a clear bug, please file a minimal reproducible example on [github](https://github.com/PovertyAction/high-frequency-checks/issues). For questions and other discussion, please email us at [researchsupport@poverty-action.org](mailto:researchsupport@poverty-action.org).

## Authors
 - Christopher Boyer
 - Caton Brewster
 - Kelsey Larson
 - Ishmail Azindoo Baako
 - Isabel Onate
 - Rosemarie Sandino

