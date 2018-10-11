++++++++++++++++
DATA
++++++++++++++++

This folder is designed to store all files containing data. If your data contains personally identifiable information, you need to make sure this folder is encrypted.

- 01_preloads

This is where you should store preload files. If your survey makes use of preload data, which is usually the case for any follow-up survey round (i.e. not a baseline), then save a copy of the files you create here.

- 02_survey

This is where you should download the raw survey data directly from the server. Datasets can be downloaded in either wide or long format, and usually come as a comma separated (csv) file.

- 03_bc

This is where you should download the raw back check data directly from the server. When running the HFCs, you can pull in this data and compare it to the original dataset. THe HFCs will output any discrepancies that need to be reconciled.

- 04_monitoring

This is where you should download the raw field monitoring data. This is only relevant if your project has a monitoring component that involves data collection.