/*----------------------------------------*
 |file:    ipacheckdates.ado            | 
 |project: high frequency checks          |
 |author:  christopher boyer              |
 |         matthew bombyk                 |
 |         innovations for poverty action |
 |date:    2016-02-13                     |
 *----------------------------------------*/

 // this program checks that all interviews are complete

capture program drop ipacheckdates
program ipacheckdates, rclass
	qui {

	syntax ,  saving(string) [enumerator(string) modify replace]
	
	version 13.1
	
	}
end
