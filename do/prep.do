* project: 
* author: 
* organization:
* date: 

/* This is the prepping do-file, it's purpose is to:
	 1. Make any replacements to data
	 2. Identify duplicate submissions
     3. Clean and prepare data for data quality checks */

use "", clear


/* --------------------------- Make Replacements --------------------------- */

/* This section makes the replacements to the form data specified in the 
   replacements file in the 6_Replacements folder using the user-written 
   -readreplace- command. */

 readreplace using "", ///
			id(id) ///
			variable(variable) ///
			value(newvalue) ///
			excel import (sheet("") firstrow)*/

/* -------------------------- Identify Duplicates -------------------------- */

/* This section identifies any duplicate submissions and provides a work flow 
   for specifying which of the duplicate submissions to keep and which to 
   drop. It then de-duplicates the data set prior to tracking/checks (necessary 
   for several of the checks). */


ipacheckids , enum() nolabel variable


/* ------------------------`-- Clean Data for HFCs -------------------------- */

/* This section cleans and prepares the data for tracking and HFC including:
     - Generating analysis variables (e.g. indices, etc)
     - Merging in timing or other external QC variables.
     - More ...  */


save "", replace

