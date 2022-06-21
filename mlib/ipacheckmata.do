mata: 
mata clear

void addlines(string scalar file, string scalar sheet, real vector rows, string scalar style)
{
	real scalar i
	class xl scalar b
	b = xl()
	b.load_book(file)
	b.set_sheet(sheet)
	b.set_mode("open")

	for (i = 1;i <= length(rows); i++) {
		b.set_bottom_border(rows[i], (1, st_nvar()), style)
	}
	
	b.close_book()
}

void addflags (string scalar file, string scalar sheet, real vector rows, string scalar var, string scalar color)
{
	real scalar i
	class xl scalar b
	b = xl()
	b.load_book(file)
	b.set_sheet(sheet)
	b.set_mode("open")
	
	for (i = 1;i <= length(rows); i++) {
		b.set_fill_pattern(rows[i] + 1, st_varindex(var), "solid", color)
	}
	
	b.close_book()
}

void colwidths(string scalar file, string scalar sheet) 
{
	real scalar i
	class xl scalar b
	real rowvector datawidths, varnamewidths
	b = xl()
	b.load_book(file)
	b.set_sheet(sheet)
	b.set_mode("open")
	datawidths = colmax(strlen(st_sdata(. , .)))
	varnamewidths = colmax(strlen(st_varname(1..st_nvar())))
	for (i=1; i<=cols(datawidths); i++) {
		if	(datawidths[i] < varnamewidths[i]) {
			datawidths[i] = varnamewidths[i]
		}
		if (datawidths[i] > 81) {
			datawidths[i] = 81
		}
		b.set_column_width(i, i, datawidths[i] + 4)
	}
	b.close_book()
}

void colformats(string scalar file, string scalar sheet, string vector vars, string scalar format) 
{
	
	real scalar i
	class xl scalar b
	real scalar endrow, index 
	b = xl()
	b.load_book(file)
	b.set_sheet(sheet)
	b.set_mode("open")
	
	endrow = st_nobs() + 1
	for (i=1; i<=cols(vars); i++) {
		b.set_number_format((2, endrow), st_varindex(vars[i]), format)		
	} 
	b.close_book()
	
}

void setfont(string scalar file, string scalar sheet, real vector rows, real vector cols, string scalar fontname, real scalar size)
{
	real scalar i
	class xl scalar b
	b = xl()
	b.load_book(file)
	b.set_sheet(sheet)
	b.set_mode("open")
	
	b.set_font(rows, cols, fontname, size)
	
	b.close_book()
}

void setheader(string scalar file, string scalar sheet)
{
	real scalar i
	class xl scalar b
	b = xl()
	b.load_book(file)
	b.set_sheet(sheet)
	b.set_mode("open")
	
	b.set_font_bold((1, 1), (1, st_nvar()), "on")
	b.set_font_italic((1, 1), (1, st_nvar()), "on")
	b.set_bottom_border((1, 1), (1, st_nvar()), "medium")	
	b.close_book()
}

void settotal(string scalar file, string scalar sheet)
{
	class xl scalar b
	b = xl()
	b.load_book(file)
	b.set_sheet(sheet)
	b.set_mode("open")
	
	b.set_font_bold((st_nobs() + 1, st_nobs() + 1), (1, st_nvar()), "on")
	b.set_font_italic((st_nobs() + 1, st_nobs() + 1), (1, st_nvar()), "on")
	b.set_top_border((st_nobs() + 1, st_nobs() + 1), (1, st_nvar()), "medium")
	b.set_number_format((st_nobs() + 1, st_nobs() + 1), (2, st_nvar()), "number_sep")
	
	b.close_book()
}


void format_sdb_summary(string scalar file, string scalar sheet, real scalar consent, real scalar dontknow, real scalar refuse, real scalar other, real scalar duration, string scalar firstdate, string scalar lastdate) 
{
	real scalar i
	class xl scalar b
	b = xl()
	b.load_book(file)
	b.set_sheet(sheet)
	b.set_mode("open")
	
	b.set_column_width(1, 1, 2)
	b.set_column_width(2, 2, 42)
	b.set_column_width(3, 3, 16)
	
	b.set_border((1, st_nobs()), (2, 3), "thin")
	b.set_bottom_border((1, 1), (2, 3), "medium")
		
	b.set_horizontal_align((1, st_nobs()), (3, 3), "center")
	b.set_font_bold((1, st_nobs()), (2, 2), "on")
	b.set_font_bold((2, 2), (2, 2), "off")
	b.set_font_italic((2, 2), (2, 2), "on")
	b.set_font_italic((1, st_nobs()), (3, 3), "on")
	
	b.set_sheet_merge(sheet, (1, 1), (2, 3))
	b.set_horizontal_align((1, 1), (2, 3), "center")
	b.set_sheet_merge(sheet, (2, 2), (2, 3))
	b.set_horizontal_align((2, 2), (2, 3), "center")
	b.set_sheet_merge(sheet, (3, 3), (2, 3))
	b.set_horizontal_align((3, 3), (2, 3), "center")
	b.set_fill_pattern((3, 3), (2, 3), "solid", "255 192 0")
	b.set_number_format((4, 7), (3, 3), "number_sep")


	b.set_sheet_merge(sheet, (8, 8), (2, 3))
	b.set_horizontal_align((8, 8), (2, 3), "center")
	b.set_fill_pattern((8, 8), (2, 3), "solid", "255 192 0")
	
	b.set_number_format((9, 9), (3, 3), "percent_d2")
	
	if (consent == 0) {
		b.put_string(9, 3, "-")
	}
	
	b.set_sheet_merge(sheet, (10, 10), (2, 3))
	b.set_horizontal_align((10, 10), (2, 3), "center")
	b.set_fill_pattern((10, 10), (2, 3), "solid", "255 192 0")
	
	if (dontknow == 0) {
		b.put_string(12, 3, "-")
	}
	
	if (refuse == 0) {
		b.put_string(13, 3, "-")
	}
	
	b.set_number_format((11, 13), (3, 3), "percent_d2")
	
	b.set_sheet_merge(sheet, (14, 14), (2, 3))
	b.set_horizontal_align((14, 14), (2, 3), "center")
	b.set_fill_pattern((14, 14), (2, 3), "solid", "255 192 0")
	
	if (other == 0) {
		b.put_string(15, 3, "-")
		b.put_string(16, 3, "-")
	}
	
	b.set_number_format((15, 15), (3, 3), "number_sep")
	b.set_number_format((16, 16), (3, 3), "percent_d2")
	
	b.set_sheet_merge(sheet, (17, 17), (2, 3))
	b.set_horizontal_align((17, 17), (2, 3), "center")
	b.set_fill_pattern((17, 17), (2, 3), "solid", "255 192 0")
	b.set_number_format((18, 21), (3, 3), "number_sep")
		
	b.set_sheet_merge(sheet, (22, 22), (2, 3))
	b.set_horizontal_align((22, 22), (2, 3), "center")
	b.set_fill_pattern((22, 22), (2, 3), "solid", "255 192 0")
	b.set_number_format((23, 26), (3, 3), "number_sep")
	
	if (duration == 0) {
		b.put_string(23, 3, "-")
		b.put_string(24, 3, "-")
		b.put_string(25, 3, "-")
		b.put_string(26, 3, "-")
	}

	b.set_sheet_merge(sheet, (27, 27), (2, 3))
	b.set_horizontal_align((27, 27), (2, 3), "center")
	b.set_fill_pattern((27, 27), (2, 3), "solid", "255 192 0")
	b.set_number_format((28, 29), (3, 3), "number_sep")
	b.set_number_format((32, 32), (3, 3), "number_sep")
	
	
	b.put_string(30, 3, firstdate)
	b.put_string(31, 3, lastdate)
	
	b.close_book()

}

void format_edb_stats(string scalar file, string scalar sheet, string vector labs, string vector percentcols) 
{
	real scalar i, j, k
	class xl scalar b
	b = xl()
	b.load_book(file)
	b.set_sheet(sheet)
	b.set_mode("open")
	
	real scalar n, startcol
	string scalar var, nextvar, meanvar
	
	b.set_font_bold((1, 2), (1, st_nvar()), "on")
	b.set_font_italic((1, 2), (1, st_nvar()), "on")
	b.set_number_format((3, st_nobs() + 2), (2, st_nvar()), "number_d2")
	b.set_bottom_border((2, 2), (1, st_nvar()), "medium")
	
	n = 2
	for (i = 1; i <= length(labs); i++) {
	    
		startcol = n
		var = st_varname(n)
		b.put_string(1, n, labs[i])
		for (j = 1; j <= 5;j++) {
			if (n + 1 <= st_nvar()) {
				nextvar = st_varname(n + 1)
				if (regexm(nextvar, "_count") == 0) {
					n = n + 1
				}
				if (regexm(nextvar, "_mean") == 1) {
				    meanvar = nextvar
				}
			}
		}
		
		b.set_sheet_merge(sheet, (1, 1), (startcol, n))
		b.set_horizontal_align((1, 1), (startcol, n), "center")
		b.set_left_border((1, st_nobs() + 2), (startcol, startcol), "medium")
		
		n = n + 1
		
		if (length(percentcols) > 0) {
		    for (k=1; k <= length(percentcols); k++) {
			    if (percentcols[k] == labs[i]) {
				    b.set_number_format((3, st_nobs() + 2), (st_varindex(meanvar), st_varindex(meanvar)), "percent_d2")
				}
			}
		} 
	}
	
	
	b.close_book()

}

void format_timeuse(string scalar file, string scalar sheet, string scalar title, real scalar fmtdate) 
{

	class xl scalar b	
	b = xl()
	b.load_book(file)
	b.set_sheet(sheet)
	b.set_mode("open")
	
	real scalar min, max, colormax, i, j, value, fmtid, colwidth
	real scalar red, green, blue
	real scalar max_r, max_g, max_b
	real scalar min_r, min_g, min_b 
	
	string scalar time_lab, rgb
	
	colwidth = max(strlen(st_sdata(. , 1)))
	if (colwidth == 0) {
		colwidth = 10
		if (fmtdate) {
			b.set_number_format((4, st_nobs() + 4), (2, 2), "date_d_mon_yy")
		}
	}
	
	b.set_sheet_gridlines(sheet, "off")
	b.set_column_width(2, 2, colwidth + 3)
	b.set_column_width(3, 26, 3)
	
	for (i = 0;i <= 23; i++) {
		if (i == 0) {
			time_lab = "Midnight"
		}
		else if (i >= 0 & i <= 11) {
			time_lab = strofreal(i) + " AM"
		}
		else if (i == 12) {
			time_lab = "12 Noon"
		}
		else {
			time_lab = strofreal(i - 12) + " PM"
		}
		b.put_string(st_nobs() + 5, i + 3, time_lab)
		
	}
	
	fmtid = b.add_fmtid()
	b.set_fmtid((st_nobs() + 5, st_nobs() + 5), (3, 26), fmtid)
	b.fmtid_set_text_rotate(fmtid, 90)
	b.fmtid_set_vertical_align(fmtid, "top")
	
	min = min(colmin(st_data(. , st_varname(2..st_nvar()))))
	max = max(colmax(st_data(. , st_varname(2..st_nvar()))))
	
	max_r = 209
	max_g = 200
	max_b = 162
	min_r = 11
	min_g = 59
	min_b = 79
	
	if (max > 20) {
		colormax = 20
	}
	else {
		colormax = max
	}
		
	for (i = 1; i <= 24; i++) {
		for (j = 1; j <= st_nobs(); j++) {
			
			value = st_data(j, i + 1)
			
			if (value ~= .) {
				
				red = max_r - floor(((value/max) * (max_r - min_r)))
				green = max_g - floor(((value/max) * (max_g - min_g)))
				blue = max_b- floor(((value/max) * (max_b - min_b)))
				
				rgb = strofreal(red) + " " + strofreal(green) + " " + strofreal(blue)
				
				b.set_fill_pattern((j + 3, j + 3), (i + 2, i + 2), "solid", rgb)
			}
		}
	}
	
	b.put_string(4, 28, "Scale")
	b.put_number(6, 29, min)
	
	for (i = 1; i <= colormax; i ++) {
	    
	    red = max_r - floor(((i/colormax) * (max_r - min_r)))
		green = max_g - floor(((i/colormax) * (max_g - min_g)))
		blue = max_b- floor(((i/colormax) * (max_b - min_b)))
		
		rgb = strofreal(red) + " " + strofreal(green) + " " + strofreal(blue)
		
		b.set_fill_pattern((5 + i, 5 + i), (28, 28), "solid", rgb)

	}
	
	b.put_number(5 + colormax, 29, max)
	
	b.set_column_width(28, 29, 5)
	
	b.put_string(2, 3, title)
	b.set_sheet_merge(sheet, (2, 2), (3, 27))
	b.set_horizontal_align((2, 2), (3, 27), "center")
	b.set_font_bold((2, 2), (3, 27), "on")
	b.set_font_italic((2, 2), (3, 27), "on")
	
	b.close_book()
}

mata mlib create lipadms, dir(PLUS) replace
mata mlib add lipadms *()
end

noi mata: mata mlib index
