*** ATF FFL TRENDS ***
/*
Retrieved estimated yearly gun sales from:
https://www.safehome.org/data/firearms-guns-statistics/

Retrieved monthly (downloaded by year) FFL numbers from the ATF:
https://www.atf.gov/firearms/listing-federal-firearms-licensees
*/
cd "G:\My Drive\Research\Firearms Economics\Conversation Report\FFLs and sales\"
clear
cd "C:\Users\tlm\Downloads\"
import delimited "1223-ffl-list.csv", varnames(1)
	gen year = .
	gen month = ""
	gen count = 1
	drop if _n > 0
	save "FFLs.dta", replace
	clear


forval y = 14/23 {
	foreach m in "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12" {
		if fileexists("`m'`y'-ffl-list.csv") {
			import delimited "`m'`y'-ffl-list.csv", varnames(1)
			capture confirm variable year, exact
			if !_rc {
				drop year
				}
			else {
				}
			capture confirm variable month, exact
			if !_rc {
				drop month
				}
			else {
				}			
			gen year = 2000 + `y'
			gen month = "`m'"
			gen count = 1
			capture confirm variable lictype, exact
			if !_rc {
				rename lictype lic_type
				}
			else {
				}
			capture confirm variable app_lic_type, exact
			if !_rc {
				rename app_lic_type lic_type
				}
			else {
				}
			collapse (first) year month (sum) count, by(lic_type)
			save "FFL_`y'`m'.dta", replace
			use "FFLs.dta", clear
			append using "FFL_`y'`m'.dta", force
			save "FFLs.dta", replace
			erase "FFL_`y'`m'.dta"
			clear
			}
		else
		}
	}

use "FFLs.dta", clear
save "FFLs-final.dta", replace

	keep lic_type year month count
	destring month, gen(monthn)
	fillin year monthn lic_type
	sort lic_type year monthn
	gen monthstr = month
	tostring monthn, gen(monthstr2)
		replace monthstr = monthstr2 if monthstr == "" & strlen(monthstr2) == 2
		replace monthstr = "0" + monthstr2 if monthstr == "" & strlen(monthstr2) == 1
		drop monthstr2
		drop month
	tostring year, gen(yearstr)
		rename monthn month
	drop if month == .
	gen yearmonth = yearstr + monthstr
	destring yearmonth, force replace
	sort lic_type yearmonth
	gen yearmonthstr = monthstr + "-" + yearstr
		order monthstr yearmonth yearmonthstr, after(month)
	labmask yearmonth, values(yearmonthstr)
	bysort lic_type: ipolate count yearmonth, gen(countipol) epolate
	labe var countipol "FFL count"
	labe var lic_type "FFL license type"

* Label defining
label define FFLtypes 1 "Firearms dealer" 2 "Firearms pawnbroker" ///
	3 "Collector of curios and relics" 6 "Manufacturer of ammunition" ///
	7 "Manufacturer of firearms" 8 "Importer of firearms" ///
	9 "Dealer in destructive devices" 10 "Manufacturer of destructive devices" ///
	11 "Importer of destructive devices"
label values lic_type FFLtypes
save "FFLs-final.dta", replace

* Merge estimated firearms sold in the US
clear
import delimited "Gun sales - Gun Sales.csv", varnames(1)
save "gunsales.dta", replace
clear

use "FFLs-final.dta", clear
	merge m:1 year using "gunsales.dta", keepusing(guns)
	drop if _m == 2
	drop _m
	drop if lic_type == .
	replace guns = subinstr(guns,",","",.)
	destring guns, force replace
	gen gunsM = guns / 1000000
	replace guns = . if month != 12
	
	sort lic_type yearmonth
	
* Creating index values for FFL counts
gen indexbase = .
sum yearmonth
	global min_ym = r(min)
foreach l in "01" "02" "03" "06" "07" "08" "09" "10" "11" {
	sum countipol if yearmonth == $min_ym & lic_type == `l'
	replace indexbase = r(mean) if lic_type == `l'
	}
gen fflindex = countipol / indexbase * 100
save "FFLs-final.dta", replace

** Graphs
	* Absolute numbers of FFLs per type
use "FFLs-final.dta", clear
twoway (area gunsM yearmonth if lic_type == 1, graphregion(color(white))) ///
	(line countipol yearmonth if lic_type == 1, yaxis(2) graphregion(color(white))) ///
	(line countipol yearmonth if lic_type == 2, yaxis(2) graphregion(color(white))) ///
	(line countipol yearmonth if lic_type == 3, yaxis(2) graphregion(color(white))) ///
	(line countipol yearmonth if lic_type == 6, yaxis(2) graphregion(color(white))) ///
	(line countipol yearmonth if lic_type == 7, yaxis(2) graphregion(color(white))) ///
	(line countipol yearmonth if lic_type == 8, yaxis(2) graphregion(color(white))) ///
	(line countipol yearmonth if lic_type == 9, yaxis(2) graphregion(color(white))) ///
	(line countipol yearmonth if lic_type == 10, yaxis(2) graphregion(color(white))) ///
	(line countipol yearmonth if lic_type == 11, yaxis(2) graphregion(color(white))), ///
	legend(size(*.75) cols(1) label(1 "Gun sales") label(2 "Firearms dealers") label(3 "Firearms pawnbrokers") ///
	label(4 "Collectors") label(5 "Ammunition manufacturers") label(6 "Firearms manufacturers") ///
	label(7 "Firearms importers") label(8 "Destructive device dealers") ///
	label(9 "Destructive device manufacturers") label(10 "Destructive device importers")) ///
	xlabel(,val labsize(vsmall)) ylabel(,labsize(vsmall)) ylabel(,labsize(vsmall) ///
	axis(2)) ytitle("Guns Sold (M)") ytitle("FFLs", axis(2))

	* Indexed numbers of FFLs per type
twoway (area gunsM yearmonth if lic_type == 1, graphregion(color(white))) ///
	(line fflindex yearmonth if lic_type == 1, yaxis(2) graphregion(color(white))) ///
	(line fflindex yearmonth if lic_type == 2, yaxis(2) graphregion(color(white))) ///
	(line fflindex yearmonth if lic_type == 3, yaxis(2) graphregion(color(white))) ///
	(line fflindex yearmonth if lic_type == 6, yaxis(2) graphregion(color(white))) ///
	(line fflindex yearmonth if lic_type == 7, yaxis(2) graphregion(color(white))) ///
	(line fflindex yearmonth if lic_type == 8, yaxis(2) graphregion(color(white))) ///
	(line fflindex yearmonth if lic_type == 9, yaxis(2) graphregion(color(white))) ///
	(line fflindex yearmonth if lic_type == 10, yaxis(2) graphregion(color(white))) ///
	(line fflindex yearmonth if lic_type == 11, yaxis(2) graphregion(color(white))), ///
	legend(size(*.75) cols(1) label(1 "Gun sales") label(2 "Firearms dealers") label(3 "Firearms pawnbrokers") ///
	label(4 "Collectors") label(5 "Ammunition manufacturers") label(6 "Firearms manufacturers") ///
	label(7 "Firearms importers") label(8 "Destructive device dealers") ///
	label(9 "Destructive device manufacturers") label(10 "Destructive device importers")) ///
	xlabel(,val labsize(vsmall)) ylabel(,labsize(vsmall)) ylabel(,labsize(vsmall) ///
	axis(2)) ytitle("Guns Sold (M)") ytitle("FFL index (Jan 2014 = 100)", axis(2))
	
	* Indexed numbers of FFLs per type (simplified)
twoway (area gunsM yearmonth if lic_type == 1, xtitle("Month and Year") graphregion(color(white))) ///
	(line fflindex yearmonth if lic_type == 1, yaxis(2) graphregion(color(white))) ///
	(line fflindex yearmonth if lic_type == 2, yaxis(2) graphregion(color(white))) ///
	(line fflindex yearmonth if lic_type == 7, yaxis(2) graphregion(color(white))) ///
	(line fflindex yearmonth if lic_type == 8, yaxis(2) graphregion(color(white))), ///
	legend(size(*.75) cols(1) label(1 "Gun sales") label(2 "Firearms dealers") label(3 "Firearms pawnbrokers") ///
	label(4 "Firearms manufacturers") label(5 "Firearms importers") ) ///
	xlabel(,labels labsize(vsmall)) ylabel(,labsize(vsmall)) ylabel(,labsize(vsmall) ///
	axis(2)) ytitle("Guns Sold (M)") ytitle("FFL index (Jan 2014 = 100)", axis(2) ///
	)
