/*----------------------------------------*
 |file:    ipacheckdistinct.ado            | 
 |project: high frequency checks          |
 |author:  christopher boyer              |
 |         matthew bombyk                 |
 |         innovations for poverty action |
 |date:    2016-02-13                     |
 *----------------------------------------*/

 // this program checks that all interviews are complete

capture program drop ipacheckdistinct
program ipacheckdistinct, rclass
	qui {

	syntax, assert(string) condition(string) saving(string) id(name) enumerator(name) [sheetmodify sheetreplace]
	
	version 13.1

	cap assert "`assert' if `condition'"
	if _rc {
		list `id' `enumerator' if "`assert' & `condition'"
	}

	}
end
