# IPACHECK 4

## Overview
ipacheck is Innovations for Poverty Action's Stata package for running high-frequency checks during data collection. This package includes the following programs:

### Main programs

 - `ipacheckcorrections` - make corrections to data.
 - `ipacheckspecifyrecode` - recode other specify values.
 - `ipacheckversions`- export statistics on survey form versions & flags outdated survey submissions.
 - `ipacheckids`- export duplicates in survey ID.
 - `ipacheckdups`- export duplicates in non-ID variables.
 - `ipacheckmissing`- export statistics on missingness & distintness for each variable.
 - `ipacheckoutliers` - export outliers in numeric variables.
 - `ipacheckoconstraints` - export outliers in numeric variables.
 - `ipacheckspecify` - export all values specified for variables with 'other speciy' category.
 - `ipacheckcomments` - export field comments generated with SurveyCTO's comments field type.
 - `ipachecktextaudit` - export statistics on duration per field using the SurveyCTO's text audit files.
 - `ipachecktimeuse` - export statistics on hours of engagement using the SurveyCTO's text audit files.
 - `ipachecksurveydb` - export general statistics about dataset.
 - `ipacheckenumdb` - export general statistics about enumerator performance.
 - `ipatracksurvey` - export dashboard for tracking survey progress.
 - `ipabcstats` - compare survey and back check data.
  
 ### Ancilliary programs

- `ipacodebook` - export codebook to excel. Includes an option to use notes as variable labels

ipacheck comes with a folder structure for your project including a master do-file, a globals do-file, prep do-file and Excel-based inputs sheets. Results of checks are exported as nicely formatted Excel spreadsheets for distribution among field teams. As of version 4.2.0, ipacheck now uses programs from the [ipahelper](https://github.com/PovertyAction/ipahelper/main).


## Installation

```Stata
* ipacheck may be installed directly from GitHub
net install ipacheck, all replace from("https://raw.githubusercontent.com/PovertyAction/high-frequency-checks/master")
ipacheck update

* after initial installation ipacheck can be updated at any time using
ipacheck update

* to start a new project with folder structure and input files
ipacheck new, surveys("SURVEY_NAME_1") folder("path/to/project")

* when starting a new project with multiple surveys, you can choose to use the subfolders option to create subfolders for each survey
ipacheck new, surveys("SURVEY_NAME_1" "SURVEY_NAME_2") folder("path/to/project") subfolders

* to obtain fresh copies of the master do-file and Excel inputs without creating the folder structure
ipacheck new, filesonly

* to go through IPA's exercise with instructions, exercise data, and folder structure with input files
ipacheck new, exercise 

* to verify you have the latest versions of the commands
ipacheck version
```

## Learn about the DMS
Check out the [DMS wiki](https://github.com/PovertyAction/high-frequency-checks/wiki) for more information about the DMS. You can also review the [DMS exercise](https://github.com/PovertyAction/high-frequency-checks/wiki/Exercise) to learn how to setup the DMS for your project. 

If you encounter a clear bug, please file a minimal reproducible example on [github](https://github.com/PovertyAction/high-frequency-checks/issues). For questions and other discussion, please email us at [researchsupport@poverty-action.org](mailto:researchsupport@poverty-action.org).

## Current Author(s)
 - Ishmail Azindoo Baako

## Past Author(s)
 - Rosemarie Sandino
 - Christopher Boyer
 - Isabel Onate
 - Kelsey Larson
 - Caton Brewster
