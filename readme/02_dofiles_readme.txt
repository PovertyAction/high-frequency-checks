++++++++++++++++
DO FILES
++++++++++++++++

This folder is designed to store all do files needed to run high frequency checks on your data. The IPA HFC package comes with a template for running the checks themselves; this will be automatically downloaded as a do file called "master_check" and saved in the do files folder.

You will need to either create the remaining do files needed to set globals, import raw data (the template for this do file can be downloaded from the server if you are using SurveyCTO), conduct preliminary cleaning, and generate any outcome variables of interest.

It is important to name your dofiles descriptively and with numbering that indicates the order in which they should be run. For example:

- 01_set_globals
- 02_import
- 03_prep_survey
- 04_outcomes
- 05_master_check (from IPA HFC package)