/*----------------------------------------*
 |file:    ipacheckskip.ado               |    
 |project: high frequency checks          |
 |author:  christopher boyer              |
 |         matthew bombyk                 |
 |         innovations for poverty action |
 |date:    2016-02-13                     |
 *----------------------------------------*/

 // this program checks skip patterns and logical constraints

capture program drop ipacheckskip
program ipacheckskip, rclass
	qui {

	syntax, assert(string) condition(string) saving(string) id(name) enumerator(name) [sheetmodify sheetreplace]
	
	version 13.1

	}
end
