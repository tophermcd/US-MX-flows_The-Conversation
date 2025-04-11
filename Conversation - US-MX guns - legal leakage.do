/*

			*** DATA COLLECTION 2: Police-originating firearms seizures ***
The following analysis is done by joining:
	1. Relac Armas_Of.2915_4323_(Sep2020).xlsx 
	2. gunid.dta (itself a duplicates-dropped combination of "sedena_gunid.dta" and "cenapi_gunid.dta")
We considered substituting out "gunid.dta" for "cenapi_gunid.dta" alone, since 
it appears that SEDENA's original data sweep was through a dataset of 24,000
(which is around the size of "CENAPI.dta"). However, the study periods don't
overlap: CENAPI 22 Nov 2018 - 11 Dec 2020 vs RELAC ARMAS 03 Jan 2014 - 31 Mar 2016
*/
clear
cd "G:\My Drive\Research\Firearms Economics\Conversation Report\"

import excel "G:\My Drive\Research\Firearms Economics\Conversation Report\Relac Armas_Of.2915_4323_(Sep2020).xlsx", sheet("Hoja1") firstrow clear
rename NUMERODERASTREO traceno
rename REGISTROENSEDENA SedenaReg
rename FABRICANTEOMARCA make
rename CALIBRESMEXICO caliber
rename NUMERODESERIE serialno
rename MODELO model
rename TIPO type
rename SUBTIPO subtype
rename PAISDEFABRICACION countrymanuf
rename IMPORTADOR importer
rename ESTADODELDISTRIBUIDOR fflstate
rename FECHADERECUPERACION daterecov
rename MUNICIPIODERECUPERACION municrecov
rename ESTADODERECUPERACION staterecov
gen legalimport = 1
gen yearrecov = year(daterecov)
gen monthrecov = month(daterecov)
order daterecov monthrecov yearrecov, first

	* Manufacturer standardizations
do "Conversation - US-MX guns - manufcorrect.do"


duplicates report staterecov municrecov serialno caliber make type daterecov
duplicates drop staterecov municrecov serialno caliber make type daterecov, force

save "legalleakage.dta", replace // N = 638

duplicates drop type make serialno daterecov, force
save "legalleakagetemp.dta", replace

use "gunid.dta", clear

duplicates drop type make serialno daterecov, force

capture confirm variable _merge
if !_rc {
                       drop _merge
               }
               else {
               }

drop yearrecov
gen yearrecov = year(daterecov), after(daterecov)
merge 1:1 type make serialno daterecov using "legalleakagetemp.dta"

erase "legalleakagetemp.dta"

sum daterecov if _m == 1
	global min_date_m1 = r(min)
	global max_date_m1 = r(max)
	display "Minimum date: " %td $min_date_m1
	display "Maximum date: " %td $max_date_m1

sum daterecov if _m == 2
	global min_date_m2 = r(min)
	global max_date_m2 = r(max)
	display "Minimum date: " %td $min_date_m2
	display "Maximum date: " %td $max_date_m2

/*
* To see how many records drop in the "Relac Armas" study period, we can do
* compare the following to:
* (03 January 2014 - 31 March 2016):
drop if daterecov < date("1/3/2014","MDY",2050) | daterecov > date("3/31/2016","MDY",2050)
*/

global maxmin = max($min_date_m1, $min_date_m2)
global minmax = min($max_date_m1, $max_date_m2)
	display "Combined minimum date: " %td $maxmin
	display "Combined maximum date: " %td $minmax

sum _m if daterecov < $minmax & daterecov > $maxmin
drop if daterecov > $minmax | daterecov < $maxmin


gen makelegal = make + " - Yes" if _m == 2
replace makelegal = make + " - No" if _m == 1
encode makelegal, gen(makelegalint)

replace legalimport = 0 if legalimport == .

do "Conversation - US-MX guns - manufcorrect.do"

drop if make == "SIN MARCA" | make == ""


save "legalleakage_percent.dta", replace
collapse (count) makelegalint, by(makelegal)
rename makelegalint ct
save "makecounts.dta", replace

use "legalleakage_percent.dta", clear
drop _m
merge m:1 makelegal using "makecounts.dta"
drop _m
save "legalleakagepercent.dta", replace

use "legalleakagepercent.dta", clear


drop if legalimport == 0
collapse (count) makelegalint, by(make)
rename makelegalint ct_L
save "ct_L.dta", replace

use "legalleakagepercent.dta", clear
drop if legalimport == 1
collapse (count) makelegalint, by(make)
rename makelegalint ct_T
save "ct_T.dta", replace

use "ct_T.dta", clear
merge 1:1 make using "ct_L.dta"
drop _m
replace ct_L = 0 if ct_L == .
replace ct_T = 0 if ct_T == .
gen ct_all = ct_T + ct_L

gsort - ct_all
gen axis = _n
labmask axis, values(make)

gen pc_T = ct_T/ ct_all * 100 // "T" stands for "trafficked"
lab var pc_T "Percentage trafficked"
gen pc_L = ct_L/ ct_all * 100 // "L" stands for "legally imported"
lab var pc_L "Percentage legal"

drop if make == ""

labe var ct_T "Count: trafficked firearms"
labe var ct_L "Count: legally imported firearms"
labe var make "Firearms manufacturer"
labe var ct_all "Count: legally and illegally imported firearms"

save "ct_legal.dta", replace

* Graphs
use "ct_legal.dta", clear
	* Figure 6 in the methodological note
graph hbar ct_T ct_L if ct_all > 20, ///
	over(axis, lab(angle(0) labsize(vsmall))) ///
	bar(1, fcolor(orange)) bar(2, fcolor(midblue)) ///
	stack ylab(,labsize(small)) legend(col(1)order(1 "Trafficked" 2 "Legally imported") ///
	subtitle("Legend", size(small)) size(vsmall)) graphregion(color(white))
	* Tabulating the data for the above for use by The Conversation visualization folks
table make [fw = ct_T] 
table make [fw = ct_L] 
	
sum pc_L [fweight = ct_all]
tabstat ct_T ct_L [fweight = ct_all]

* Obtaining percentage of legally imported arms seized
use "legalleakagepercent.dta", clear
	* Method 1
sum ct if legalimport == 1
global legalct `r(N)'
sum ct
global total `r(N)'
di $legalct/$total * 100
	* Method 2
tabulate legalimport
	* Method 3
tabstat legalimport, statistics( mean sd )

