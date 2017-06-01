# ipacheck

## Overview
ipacheck is a Stata package for running high-frequency checks on research data at Innovations for Poverty Action, including:

 - `ipacheckcomplete` - verifies that all surveys are completed.
 - `ipacheckdups` - identifies possible duplicate observations.
 - `ipacheckconsent` - verifies that all surveys have consent.
 - `ipachecknomiss` - verifies that certain variables have no missing values.
 - `ipacheckfollowup` - verifies consistency of data between rounds of data collection (e.g. baseline and follow up).
 - `ipacheckskip` - asserts that skip patterns are followed.
 - `ipacheckallmiss` - identifies variables who contain only missing values.
 - `ipacheckconstraints` - asserts that hard and soft constraints are followed.
 - `ipacheckspecify` - lists all values specified for variables with an 'other' category for possible recoding.
 - `ipacheckdates` - verifies consistency of date variables.
 - `ipacheckoutliers` - identifies possible outliers in numeric variables.
 - `ipatracksummary` - lists number of surveys completed by date. 
 - `ipatracksurveys` - lists surveys completed (optionally by region) against sample/tracking list.
 - `ipatrackversions`- lists number of surveys by date and version.
 - `ipacheckenum` - aggregates data by enumerator to assess performance.
 - `ipacheckresearch` - produces one- and two-way summaries of research variables.
 
ipacheck comes with bundled with a master do-file and Excel-based inputs sheets. Results of checks can be exported as nicely formatted Excel spreadsheets for distribution among field teams.


## Installation

```Stata
* ipacheck may be installed directly from GitHub
net install ipacheck, ///
    from("https://raw.githubusercontent.com/PovertyAction/high-frequency-checks/master/ado") ///
    replace 

* after initial installation ipacheck can be updated at any time via
ipacheck update

* fresh copies of the supplementary do-files, Excel inputs, etc. are available via
ipacheck new

* to verify you have the latest versions of the commands
ipacheck version
```
If you encounter a clear bug, please file a minimal reproducible example on [github](https://github.com/PovertyAction/high-frequency-checks/issues). For questions and other discussion, please email us at [researchsupport@poverty-action.org](mailto:researchsupport@poverty-action.org).
