*! version 3.0.0 Innovations for Poverty Action 30oct2018

* Stata program for merging and outputting field comments
prog define ipacheckcomment, rclass
	#d;
	syntax varname, MEDia(string) 
					saving(string) 
					id(varname) 
					ENUMerator(varname) 
					SUBMITted(varname) 
					[KEEPvars(string) 
					SHEETMODify SHEETREPlace NOLabel]
		;	
	#d cr	

	* written in version 15
	* requires version 14.1
	version 14.1		
	
	qui {
		* clean keepvars
		loc keepvars = trim(itrim(subinstr("`keepvars'", ";", "", .)))

		* temporary files
		tempfile 	master commdata commdata_long
		
		save "`master'", replace
		
		* keep only data with text audits
		drop if missing(`varlist')
		save "`commdata'", emptyok
		loc commcount `=_N'
	
		if `commcount' > 0 {
			* check that data is unique on field comment var
			isid `varlist'
			
			* loop through and save the name of each comment file name in a local
			forval i = 1/`commcount' {
				loc comm_`i' = subinstr(`varlist'[`i'], "media\", "", 1) 
			}
			
			* Loop through scto media folder and import comm csvs one at a time 
			* appending them to the prevously imported dataset
			clear
			save "`commdata_long'", emptyok

			* misscount will track number of ta files that could not be found in file
			loc misscount 0
			forval i = 1/`commcount' {
				cap import delim using "`media'/`comm_`i''", clear varnames(1)  stringcols(_all)
				if !_rc {
					gen 	`varlist' = "media\\`comm_`i''"
					append	using "`commdata_long'"
					save 	"`commdata_long'", replace
				}
				else if _rc == 601 loc ++misscount
				
			}
			
			* drop observations with missing comments
			drop if missing(comment) 
			save 	"`commdata_long'", replace
			
			* Compares the number of missing ta files to the number of files expected
			* STOP: If all files are missing from folder	
			if `misscount' == `commcount' {
				noi disp as err "{p}All " as res "`misscount'" as txt " of " as res "`commcount'" ///
					as txt " media files not found in folder `media'. Please specify the correct media folder{p_end}"
				ex 601
			}
			else {
				* SHOW WARNING: If some ta files are missing
				if `misscount' > 0 {
					noi disp as err "{p}" as res "`miss_ta'" as txt " of " `tacount' ///
						" media files not found in folder `media'. Please specify the correct media folder{p_end}"
				}
			
				
			}
			
			* clean variable names
			* rename fieldname to groupname and generate fieldname var
			rename 	fieldname 	groupname
			egen 	fieldname = ends(groupname), last punc(/)
			drop 	groupname
			
			* Merge in additional variables from dataset
			loc keeplist: list enumerator | keepvars
			merge m:1 `varlist' using "`commdata'", keepusing(`id' `submitted' `keeplist') ///
					keep(match) nogen
			* format submissiondate
			gen 	`submitted'_fmt = dofc(`submitted') 
			format %td `submitted'_fmt
			drop 	`submitted'
			ren 	`submitted'_fmt `submitted'
			
			* drop comm var and sort
			drop 	`varlist'
			order 	`submitted' `id' `keeplist' fieldname comment
			gsort -`submitted'
			
			* export data
			export excel using "`saving'", first(var) ///
				sheet("12. field comments") cell(A2) `sheetmodify' `sheetreplace'
				
			* add_formatting
			mata: add_formatting("`saving'")

			return local comments = `=_N'
		}
		
		else {
			nois disp "{red:No text comments recorded}"
			return local comments = 0
		}

		use "`master'", clear
	}
end

* Chris Boyer's alphacol 
program alphacol, rclass
	syntax anything(name = num id = "number")

	local col = ""

	while `num' > 0 {
		local let = mod(`num'-1, 26)
		local col = char(`let' + 65) + "`col'"
		local num = floor((`num' - `let') / 26)
	}

	return local alphacol = "`col'"
end

mata:
mata clear

void add_formatting(string scalar filename)
{

	class xl scalar b
	real scalar column_width, columns, ncols, nrows, i, colmaxval

	ncols = st_nvar()
	nrows = st_nobs() + 2

	b = xl()

	b.load_book(filename)
	b.set_sheet("12. field comments")
	b.set_mode("open")

	b.set_top_border(1, (1, ncols), "thick")
	b.set_bottom_border((1,2), (1, ncols), "thick")
	b.set_horizontal_align(1, (1, ncols), "merge")
	b.put_string(1, 1, "Field Comments") 

	b.set_font_bold((1,2), (1,ncols), "on")

	b.set_right_border((1,nrows), ncols, "thick")
	b.set_bottom_border(nrows, (1,ncols), "thick")

	for (i = 1;i <= ncols;i ++) {
		namelen = strlen(st_varname(i))
		if (st_isnumvar(i)) {
			colmaxval = colmax(st_data(., i))
			if (colmaxval == 0) {
				collen = 0
			}
			else {
				collen = log(colmax(st_data(., i)))
			}
		}
		else {
			collen = colmax(strlen(st_sdata(., i)))
		}
		if (namelen > collen) {
			column_width = namelen + 1
		}
		else {
			column_width = collen + 1
		}
		if (column_width > 102) {
			column_width = 102
		}	
		b.set_column_width(i, i, column_width)
	}	

	b.close_book()
}
end

