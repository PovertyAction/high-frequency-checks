++++++++++++++++
CHECKS
++++++++++++++++

This folder is designed to store the various input sheets that get called by the master_check do file and to store the output sheet that is produced by running this do file.

Before running the checks, look to the 01_inputs sub-folder to find templates for the different input spreadsheets:

- hfc_enumerators

This is a blank document that will serve as the template for the enumerator dashboard. You should not populate this spreadsheet with any information prior to running the checks.

- hfc_inputs

This is the main document where you will select which variables from your dataset you want to run in each check. Be selective with the variables you include. The more variables you have, the more comprehensive your checks become, but it also means more output that will likely become difficult to read and interpret quickly.

- hfc_replacements

This is a blank document that should only be populated if you need to make corrections to your dataset before running the master_check do file. Typically, you should proceed by running the HFCs, reading the output, identifying what observations or variables have problematic values (e.g. a clearly erroneous value that was looka misentered, such as someone declaring age to be 118 instead of 18), communicating with the field team, and then applying any neessary corrections by adding a row to the replacements spreadsheet.

Once you run the checks, look to the 02_outputs folder to see what has been generated:

- hfc_enumerators

This is the eumerator dashboard, which contains a set of checks by enumerator to monitor performance.

- hfc_output

This is the main output for the HFCs, where each tab represents a different check's output.

- research_dashboard

This is the research dashboard, which contains one-way and two-way summary statistics for specified variables.