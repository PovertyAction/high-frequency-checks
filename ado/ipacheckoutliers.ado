/*----------------------------------------*
 |file:    ipacheckoutliers.ado           | 
 |project: high frequency checks          |
 |author:  christopher boyer              |
 |         matthew bombyk                 |
 |         innovations for poverty action |
 |date:    2016-02-13                     |
 *----------------------------------------*/

 // this program checks for outliers among unconstrained survey variables

capture program drop ipacheckoutliers
program ipacheckoutliers, rclass
	di ""
	di "HFC 11 => Checking that unconstrained variables have no outliers..."
	qui {

	syntax varlist, saving(string) id(name) sd(name) [enumerator(name) modify replace]
	
	version 13.1
	
	file open myfile using `minmax_output', text write replace
	file write myfile "Enumerator,Survey ID,Variable,Label,Value,Message" _n 

	egen mean = mean(wklyinc)
	egen sd = sd(wklyinc)
	generate sds = (wklyinc - mean) / sd
	format mean sd sds %9.2f
	display "Displaying wklyinc outliers:"
	sort id
	list id wklyinc mean sd sds if abs(sds) > 3 & !missing(sds)
	drop mean sd sds

	file close myfile	

	*Output this to Excel:
	insheet using `minmax_output' , comma case clear
	export excel using "New HFC templates/Example_HFC output.xlsx" , sheet("Outliers") sheetreplace firstrow(variables) nolabel
		
	}

	// 



end
