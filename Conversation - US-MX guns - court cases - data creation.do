	
		*** Survival Analysis Data Creation ***

* To create/ get: US state-level firearms laws
clear
cd "G:\My Drive\Research\Firearms Economics\Conversation Report\"

	/* State-level firearms laws by year:
	
	https://www.icpsr.umich.edu/web/NACJD/studies/37363/versions/V1
	
	Citation: Siegel, Michael. State Firearm Law Database: State Firearm Laws, 
	1991-2019. Inter-university Consortium for Political and Social Research 
	[distributor], 2020-02-26. https://doi.org/10.3886/ICPSR37363.v1
	*/
use "37363-0001-Data.dta"
rename STATE statesale
rename YEAR yearsale

	* Adding the years 2020 - 2023 (the data stop at 2019)
sort statesale year
insobs 4
forval i = 1/4 {
		local obs = _N +1 - `i'
		replace yearsale = 2024 - `i' in `obs'
	}
fillin statesale yearsale
drop if yearsale == .
drop _f
drop if statesale == ""

by statesale: carryforward FELONY-LAWTOTAL, replace

	* Generating standard US state codes
statastates, name(statesale)
order state_abbrev state_fips, after(statesale)
drop if _m == 2
drop _m

egen gunlawquartile = xtile(LAWTOTAL), by(yearsale) p(25(25)75)
labe var gunlawquartile "State gun laws, quartile by year"
gen gunlawslax = 0
	replace gunlawslax = 1 if gunlawquartile == 1
	labe var gunlawslax "Gun laws in bottom 25% of states"
gen gunlawsstrict = 0
	replace gunlawsstrict = 1 if gunlawquartile != 1
	labe var gunlawsstrict "Gun laws in top 75% of states"
labmask state_fips, values(statesale)
labe var yearsale "Year"

duplicates drop state_abbrev yearsale, force
xtset state_fips yearsale

save "US_st_gun_laws.dta", replace

/*
use "US_st_gun_laws.dta", clear

table state, contents(sum seizures sum pguns )
labe var seizures "Seizures"
labe var pguns "Police Purchases"
* #1
twoway ///
	(line seizures yearsale if state == "TAMAULIPAS", lcolor(red) graphregion(color(white)) ///
	ytitle("Number of Firearms", xoffset(-2) ) ylabel(,labsize(small) angle(0) ) xlabel(,labsize(small)) legend(size(vsmall) region(lstyle(none)) ) title("TAMAULIPAS") ) ///
	(line pguns yearsale if state == "TAMAULIPAS", lcolor(blue) graphregion(color(white)))
	graph save "TAMAULIPAS.grph", replace
* #2
twoway ///
	(line seizures yearsale if state == "MICHOACAN", lcolor(red) graphregion(color(white)) ///
	ytitle("", xoffset(-2) ) ylabel(,labsize(small) angle(0) ) xlabel(,labsize(small)) legend(size(vsmall) region(lstyle(none)) ) title("MICHOACAN") ) ///
	(line pguns yearsale if state == "MICHOACAN", lcolor(blue) graphregion(color(white)))
	graph save "MICHOACAN.grph", replace
* #3
twoway ///
	(line seizures yearsale if state == "SINALOA", lcolor(red) graphregion(color(white)) ///
	ytitle("", xoffset(-2) ) ylabel(,labsize(small) angle(0) ) xlabel(,labsize(small)) legend(size(vsmall) region(lstyle(none)) ) title("SINALOA") ) ///
	(line pguns yearsale if state == "SINALOA", lcolor(blue) graphregion(color(white)))
	graph save "SINALOA.grph", replace
* #4
twoway ///
	(line seizures yearsale if state == "GUERRERO", lcolor(red) graphregion(color(white)) ///
	ytitle("Number of Firearms", xoffset(-2) ) ylabel(,labsize(small) angle(0) ) xlabel(,labsize(small)) legend(size(vsmall) region(lstyle(none)) ) title("GUERRERO") ) ///
	(line pguns yearsale if state == "GUERRERO", lcolor(blue) lcolor(blue) graphregion(color(white)))
	graph save "GUERRERO.grph", replace
* #5
twoway ///
	(line seizures yearsale if state == "DURANGO", lcolor(red) graphregion(color(white)) ///
	ytitle("", xoffset(-2) ) ylabel(,labsize(small) angle(0) ) xlabel(,labsize(small)) legend(size(vsmall) region(lstyle(none)) ) title("DURANGO") ) ///
	(line pguns yearsale if state == "DURANGO", lcolor(blue) graphregion(color(white)))
	graph save "DURANGO.grph", replace
* #6
twoway ///
	(line seizures yearsale if state == "CHIHUAHUA", lcolor(red) graphregion(color(white)) ///
	ytitle("", xoffset(-2) ) ylabel(,labsize(small) angle(0) ) xlabel(,labsize(small)) legend(size(vsmall) region(lstyle(none)) ) title("CHIHUAHUA") ) ///
	(line pguns yearsale if state == "CHIHUAHUA", lcolor(blue) graphregion(color(white)))
	graph save "CHIHUAHUA.grph", replace
* #7
twoway ///
	(line seizures yearsale if state == "NUEVO LEON", lcolor(red) graphregion(color(white)) ///
	ytitle("Number of Firearms", xoffset(-2) ) ylabel(,labsize(small) angle(0) ) xlabel(,labsize(small)) legend(size(vsmall) region(lstyle(none)) ) title("NUEVO LEON") ) ///
	(line pguns yearsale if state == "NUEVO LEON", lcolor(blue) lcolor(blue) graphregion(color(white)))
	graph save "NEVO LEON.grph", replace
* #8
twoway ///
	(line seizures yearsale if state == "SONORA", lcolor(red) graphregion(color(white)) ///
	ytitle("", xoffset(-2) ) ylabel(,labsize(small) angle(0) ) xlabel(,labsize(small)) legend(size(vsmall) region(lstyle(none)) ) title("SONORA") ) ///
	(line pguns yearsale if state == "SONORA", lcolor(blue) graphregion(color(white)))
	graph save "SONORA.grph", replace
* #9
twoway ///
	(line seizures yearsale if state == "BAJA CALIFORNIA", lcolor(red) graphregion(color(white)) ///
	ytitle("", xoffset(-2) ) ylabel(,labsize(small) angle(0) ) xlabel(,labsize(small)) legend(size(vsmall) region(lstyle(none)) ) title("BAJA CALIFORNIA") ) ///
	(line pguns yearsale if state == "BAJA CALIFORNIA", lcolor(blue) graphregion(color(white)))
	graph save "BAJA CALIFORNIA.grph", replace
	
graph combine ///
	"TAMAULIPAS.grph" "MICHOACAN.grph" "SINALOA.grph" ///
	"GUERRERO.grph" "DURANGO.grph" "CHIHUAHUA.grph" ///
	"NEVO LEON.grph"  "SONORA.grph" "BAJA CALIFORNIA.grph", cols(3) ycommon xcommon
graph save "Legal-v-trafficked_9-states.grph", replace

foreach grph in ///
	"TAMAULIPAS.grph" "MICHOACAN.grph" "SINALOA.grph" "GUERRERO.grph" ///
	"DURANGO.grph" "CHIHUAHUA.grph" "NEVO LEON.grph"  "SONORA.grph" ///
	"BAJA CALIFORNIA.grph"{
		erase `grph'
	}
* Year-on-year percentagewise change. Very uninteresting!
labe var seizures_chg "Seizures"
labe var pguns_chg "Police purchases"
twoway ///
	(line seizures_chg yearsale if state == "TAMAULIPAS", lcolor(red) ///
		graphregion(color(white)) ytitle("Year-on-Year Percentage Change", xoffset(-2) ) ///
		ylabel(,labsize(small)) xlabel(,labsize(small)) legend(size(vsmall) region(lstyle(none)) ) title("TAMAULIPAS") ) ///
	(line pguns_chg yearsale if state == "TAMAULIPAS", lcolor(blue) graphregion(color(white)))
	graph save "TAMAULIPAS.grph", replace
twoway ///
	(line seizures_chg yearsale if state == "MICHOACAN", lcolor(red) ///
		graphregion(color(white)) ytitle("", xoffset(-2) ) ///
		ylabel(,labsize(small)) xlabel(,labsize(small)) legend(size(vsmall) region(lstyle(none)) ) title("TAMAULIPAS") ) ///
	(line pguns_chg yearsale if state == "MICHOACAN", lcolor(blue) graphregion(color(white)))
	graph save "MICHOACAN.grph", replace
twoway ///
	(line seizures_chg yearsale if state == "SINALOA", lcolor(red) ///
		graphregion(color(white)) ytitle("", xoffset(-2) ) ///
		ylabel(,labsize(small)) xlabel(,labsize(small)) legend(size(vsmall) region(lstyle(none)) ) title("TAMAULIPAS") ) ///
	(line pguns_chg yearsale if state == "SINALOA", lcolor(blue) graphregion(color(white)))
	graph save "SINALOA.grph", replace
twoway ///
	(line seizures_chg yearsale if state == "GUERRERO", lcolor(red) ///
		graphregion(color(white)) ytitle("Year-on-Year Percentage Change", xoffset(-2) ) ///
		ylabel(,labsize(small)) xlabel(,labsize(small)) legend(size(vsmall) region(lstyle(none)) ) title("TAMAULIPAS") ) ///
	(line pguns_chg yearsale if state == "GUERRERO", lcolor(blue) graphregion(color(white)))
	graph save "GUERRERO.grph", replace
twoway ///
	(line seizures_chg yearsale if state == "DURANGO", lcolor(red) ///
		graphregion(color(white)) ytitle("", xoffset(-2) ) ///
		ylabel(,labsize(small)) xlabel(,labsize(small)) legend(size(vsmall) region(lstyle(none)) ) title("TAMAULIPAS") ) ///
	(line pguns_chg yearsale if state == "DURANGO", lcolor(blue) graphregion(color(white)))
	graph save "DURANGO.grph", replace
twoway ///
	(line seizures_chg yearsale if state == "CHIHUAHUA", lcolor(red) ///
		graphregion(color(white)) ytitle("", xoffset(-2) ) ///
		ylabel(,labsize(small)) xlabel(,labsize(small)) legend(size(vsmall) region(lstyle(none)) ) title("TAMAULIPAS") ) ///
	(line pguns_chg yearsale if state == "CHIHUAHUA", lcolor(blue) graphregion(color(white)))
	graph save "CHIHUAHUA.grph", replace
graph combine "TAMAULIPAS.grph" "MICHOACAN.grph" "SINALOA.grph" "GUERRERO.grph" "DURANGO.grph" "CHIHUAHUA.grph", cols(3) ycommon


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
*/
	
/* Bespoke US court case data:

	These cases are identified within the PACER (Public Access to Court 
	Electronic Records) Case Locator system by some combination of charges 
	falling under the federal laws detailed in 18 U.S. Code § 922 concerning 
	firearms trafficking. In particular, 18 U.S. Code § 922(a)(6) is in almost 
	all cases invoked, as it makes it illegal for anyone connected to a 
	weapon’s purchase to make false statements that would misrepresent the 
	legality of their purchase.

	Data collected by Sean Campbell with assistance from Crystal Secaira and 
	Payton Bradley.

	Data kept (as of May 2024) at:
	https://drive.google.com/drive/folders/1r5YBlMh4GSZuWnlZbvPmcyw8H25iUSPH
	--> "court_case_data
*/
clear
import delimited "court_case_data - Sheet1.csv", varnames(1)

	* Generate recognised date fields for sale, recovery, and court filings
	gen daterecov = mexrecoverydate
	replace daterecov = usrecoverydate if daterecov == ""
	gen daterecov2 = date(daterecov,"MDY",2024)
	format daterecov2 %td
	drop daterecov
	rename daterecov2 daterecov
	labe var daterecov "Recovery date"
	gen datesale = date( purchasedate,"MDY",2024)
	format datesale %td
	lab var datesale "Sale date"
	* gen datecomp = date( complaintdate,"MDY",2024)
	* format datecomp %td
	* labe var datecomp "Complaint date"
	
	* Generate variables for recovery time (primary variable of interest) and recovery-court lag
	gen recoverytime = daterecov- datesale 
	labe var recoverytime "Recovery time"
	* gen courtlag = datecomp- daterecov
	* labe var courtlag "Recovery-court lag"
	rename purchasecountry countrysale
	rename city citysale
	rename purchasestate statesale
	replace statesale = "TX" if strlower(statesale)=="texas"
	replace statesale = "IA" if strlower(statesale)=="indiana"
	replace statesale = "NV" if strlower(statesale)=="nv via tx"

statastates, a(statesale)
	drop if _m == 2
	drop _m
order state_fips state_name, after(statesale)
labmask state_fips, values( statesale )
labe var state_fips "US state"

* Generate ID/ group variables
gen id = _n
encode casenumber, gen(case)

* Manyfacturer corrections/ standardizations
rename manufacturerorbrand make

do "Conversation - US-MX guns - manufcorrect.do"

* Generate firearms type binaries
encode priotype, gen(priotypeint)
labmask priotypecode, values( priotype )
gen longgun = 1
replace longgun = 0 if priotypecode == 210
replace longgun = . if priotypecode >= 400
labe var longgun "Long gun"
gen sniper = 0
replace sniper = 1 if priotypecode == 235
labe var sniper "Sniper rifle"
gen milgrade = 0
replace milgrade = 1 if priotypecode == 233 | priotypecode == 235 | priotypecode == 240
labe var milgrade "Assault or military grade"

* Generate binary for US (vs MX) recovery
gen recovUS = 0
replace recovUS = 1 if usrecoverydate != ""
labe var recovUS "Recovered in US"

* Generate binary for serial number:
gen serialnoBIN = 0
replace serialnoBIN = 1 if serialnumber != ""
labe var serialnoBIN "Weapon has a serial number"
label define Binary 0 "No" 1 "Yes"
label values serialnoBIN Binary
label values milgrade Binary
label values sniper Binary
label values longgun Binary

* Required for survival analysis, despite no variation in court cases by definition
gen capture = 1

* Generate year of sale variable to match gun laws
gen yearsale = year(datesale)

* Harmonize state IDs with gun law dataset
rename statesale state_abbrev
statastates, abbrev(state_abbrev)
rename state_name statesale
replace statesale = strproper(strtrim(statesale))

* Merge with state gun laws
order id case countrysale citysale statesale state_abbrev state_fips yearsale capture recovUS recoverytime datesale daterecov priotype priotypecode longgun sniper milgrade, first
drop if _m == 2
drop _m
merge m:1 state_abbrev yearsale using "US_st_gun_laws.dta"
drop if _m == 2
drop _m

* Principal Component Analysis for gun laws
* correlate DEALERH RECORDSDEALER REPORTDEALER PURGE SECURITY FINGERPRINT AGE18LONGGUNSALE GUNSHOW BACKGROUNDPURGE MENTALHEALTH STATECHECKS COLLEGE CCBACKGROUND

pca FELONY- LAWTOTAL
	* screeplot
predict pc1 pc2 pc3
* correlate pc1 pc2 pc3

	* Z-scores for PC
foreach v in pc1 pc2 pc3 {
	qui sum `v'
	gen z`v' = (`v' - r(mean))/r(sd)
	order z`v', after(`v')
	}

encode caliber, gen(calibercode)

save "courtcases.dta", replace


* Imputing lag-times from seizure to complaint (to boost usable recovery time observations)

/*
* This isn't useful. Predictions are crap. Averages would be better.

xtset state_fips yearsale, yearly

reghdfe courtlag pc1, absorb(i.state_fips i.priotypecode i.calibercode)
predict courtlagimp
gen recoverytime2 = recoverytime
replace recoverytime2 = datecomp - courtlagimp if recoverytime == .
labe var recoverytime2 "Recovery time (imputed)"
	* replace recoverytime2 = . if recoverytime2 < datesale
	

*/

* Imputing dates of recovery and complaint (to boost usable recovery time observations)
* (New version as of 7/9/2024 doesn't have complaint dates any longer

collapse (mean) daterecov, by(case)
rename daterecov daterecov_avg
labe var daterecov_avg "Mean date recovered by case"

save "meandates.dta", replace
use "courtcases.dta", clear
merge m:1 case using "meandates.dta", keepusing(daterecov_avg)
erase "meandates.dta"
order daterecov_avg, after(daterecov)
replace daterecov_avg = daterecov if daterecov != .

gen recoverytime_imp = daterecov_avg - datesale
order recoverytime_imp, after(recoverytime)
	* sum recoverytime recoverytime_imp
save "courtcases.dta", replace


* Calculating number of cases per state
gen casest = casenumber + state_abbrev
duplicates drop casest, force
encode casest, gen(casestnum)
collapse (count) casestnum, by(state_fips)
rename casestnum casecount
labe var casecount "Number of cases involving this purchase state"
statastates, f(state_fips)
	drop if _m == 2
	drop _m
save "casecountbyst.dta", replace

use "courtcases.dta", clear
drop _m 
merge m:1 state_fips using "casecountbyst.dta", keepusing(casecount)
drop _m
order casecount, after(case)

* CEM weights/ strata:
	* Imbalance between control and treatment groups (by law) may exists on predictors such as:
	* sniper milgrade longgun serialnoBIN
	* (Making sure none of these are too lopsided first):
	* sum sniper milgrade longgun serialnoBIN if recoverytime != .
		
		* Table ?. Imbalance check
			/*
			drop cem*
			*/
			* imb sniper milgrade longgun serialnoBIN if recoverytime != ., treatment(gunlawslax)
			cem sniper milgrade longgun serialnoBIN if recoverytime != ., treatment(gunlawslax)
	rename state_abbrev state_abbr

save "courtcases.dta", replace


/*
* Creating GEOGRAPHIC DISTANCES between sale and recovery states
* This is actually not helpful: we don't have enough observations with both states
clear
	* Getting US population-weighted centroids
	* Source: https://www2.census.gov/geo/docs/reference/cenpop2010/CenPop2010_Mean_ST.txt?#
	* See end of <01_data_Washington_Post.do>
import delimited "CenPop2010_Mean_ST.csv"
	* Getting MX centroids (not population-weighted)
	* Source: https://www.mapsofworld.com/lat_long/mexico-lat-long.html
import delimited "MXstatesLatLon.csv"
*/

/*			
*** Tables of Descriptive Stats ***
	** Table 2: 
tabulate statesale, summarize(recoverytime)
tabstat  casecount if recoverytime != ., by(state_fips)

	** Figure 1: 
graph box recoverytime if recoverytime != ., horizontal over(statesale, label(labsize(small) ) ) ylab(,labsize(small)) graphregion(color(white))

	** Table 3:
summarize RECORDSDEALER REPORTDEALER PURGE SECURITY FINGERPRINT GUNSHOW BACKGROUNDPURGE STATECHECKS LAWTOTAL
*/

/*
* Number of unique cases/ states represented in our data [is only currently i = 12, s = 5]:
use "courtcases.dta", clear
by case, sort: gen nvals = _n == 1
count if nvals & recoverytime != .
by state_fips, sort: gen nvals2 = _n == 1
count if nvals2 & recoverytime != .
di if nvals2 == 1 & recoverytime != .
drop nvals*
*/

/*
* Graph of gun laws in study states
cd "G:\My Drive\Research\Firearms Economics\Conversation Report\"
use "US_st_gun_laws.dta", clear
xtset state_fips yearsale, yearly
merge m:1 state_fips using "casecountbyst.dta"
gen guncase = 0
replace guncase = 1 if casecount != .
drop if _m == 2
drop _m
drop casecount
save "US_st_gun_laws.dta", replace

xtline LAWTOTAL if guncase == 1, overlay ytitle("Number of firearms laws",size(small)) ///
	xtitle("Year",size(small)) ylab(,labsize(2)) xlab(,labsize(2)) ///
	legend(size(tiny)) graphregion(color(white))
*/

/* 	Creating LISAs (local indicators of spatial association)
	This is to control for the possible "balloon effect" in which strict gun
	laws in one state push purchases to nearby states.
*/


	* LISA creation
use "courtcases.dta", clear
	gen guncount = 1
	collapse (sum) guncount (first) LAWTOTAL statesale state_abbr, by(state_fips year)
	fillin state_abbr year
	replace guncount = 0 if guncount == .
		* U.S. state centroid geographic coordinate data state_fips state_abbr state_name
	merge m:1 state_abbr using "G:\My Drive\Research\Whaling & Slavery\Data\usstatecentroids.dta", keepusing(latitude longitude)
	drop if _m == 2

	rename latitude lat
	rename longitude lon
		drop _m
	drop if state_abbr == ""
	drop state_fips
	statastates, a(state_abbr)
	order state_fips, first
	drop statesale
	rename state_name statesale
	order lat lon, after(state_fips)
	drop _f
	drop if _m == 2
	drop _m
	
		* Re-merge with state gun laws (since <fillin> created more obs)
	rename state_abbr state_abbrev
	drop LAWTOTAL
	merge m:1 state_abbrev yearsale using "US_st_gun_laws.dta", keepusing(LAWTOTAL)
	drop if _m == 2
	drop _m
	rename state_abbrev state_abbr
	drop if year == .
	
save "courtcases_guncount.dta", replace

	* Outcome LISA: guncount (gun of total guns sold in that state in that year)
		forval i = 2006(1)2025 {
			use "courtcases_guncount.dta", clear
			order state_fips yearsale guncount LAWTOTAL lat lon, first
			keep if yearsale == `i' & lon != . & lat != .
			spmat idistance matidist lon lat, id(state_fips) replace
			* Retrieving the matrix
			spmat getmatrix matidist W
			* First, get the outcome (guncount) for year = `i' as a vector
			mata: guncount = st_data(., 3)
			* Then multiply it by the weights matrix
			mata: guncountW = guncount:*W
			* Next, column sum the resulting matrix to obtain a horizontal vector
			mata: guncountWcs = colsum(guncountW)
			* Transpose the vector so that it is vertical, like the rest of our data
			mata: guncountWcsT = guncountWcs'
			* Add the new vector to the Stata dataset as a variable
			mata: st_store(., st_addvar("float","guncountWcsT"),guncountWcsT)
			save "courtcases_guncount_year`i'.dta",replace
			}

		use "courtcases_guncount.dta", clear
		gen guncountLISA = .
		save "courtcases_guncount.dta", replace

		forval i = 2006(1)2025 {
			use "courtcases_guncount.dta", clear
			if fileexists("courtcases_guncount_year`i'.dta") == 1 {
				merge 1:1 state_fips yearsale using "courtcases_guncount_year`i'.dta", keepusing(guncountWcsT)
				drop if _merge == 2
				replace guncountLISA = guncountWcsT if _merge == 3
				drop _merge guncountWcsT
				save "courtcases_guncount.dta", replace
				clear
				sleep 40
				erase "courtcases_guncount_year`i'.dta"
				di `i'
				}
			else
			}

	* Predictor: LAWTOTAL (total firearms sales laws)
		forval i = 2006(1)2025 {
			use "courtcases_guncount.dta", clear
			order state_fips yearsale guncount LAWTOTAL lat lon, first
			keep if yearsale == `i' & lon != . & lat != .
			spmat idistance matidist lon lat, id(state_fips) replace
			* Retrieving the matrix
			spmat getmatrix matidist W
			* First, get the outcome (LAWTOTAL) for yearsale = `i' as a vector
			mata: LAWTOTAL = st_data(., 4)
			* Then multiply it by the weights matrix
			mata: LAWTOTALW = LAWTOTAL:*W
			* Next, column sum the resulting matrix to obtain a horizontal vector
			mata: LAWTOTALWcs = colsum(LAWTOTALW)
			* Transpose the vector so that it is vertical, like the rest of our data
			mata: LAWTOTALWcsT = LAWTOTALWcs'
			* Add the new vector to the Stata dataset as a variable
			mata: st_store(., st_addvar("float","LAWTOTALWcsT"),LAWTOTALWcsT)
			save "courtcases_lawtotal_year`i'.dta",replace
			}

		use "courtcases_guncount.dta", clear
		gen LAWTOTALLISA = .
		save "courtcases_guncount.dta", replace

		forval i = 2006(1)2025 {
			if fileexists("courtcases_lawtotal_year`i'.dta") == 1 {
				use "courtcases_guncount.dta", clear
				merge 1:1 state_fips yearsale using "courtcases_lawtotal_year`i'.dta", keepusing(LAWTOTALWcsT)
				drop if _merge == 2
				replace LAWTOTALLISA = LAWTOTALWcsT if _merge == 3
				drop _merge LAWTOTALWcsT
				save "courtcases_guncount.dta", replace
				clear
				sleep 40
				erase "courtcases_lawtotal_year`i'.dta"
				di `i'
				}
			else
			}
use "courtcases.dta", clear
merge m:1 state_fips yearsale using "courtcases_guncount.dta", keepusing(guncountLISA LAWTOTALLISA)
drop if _m == 2
drop _m
save "courtcases.dta", replace


* Getting frequency weights for analysis
clear

	/* Creating a frequency table from "CENAPI.dta"
	Years 2018-2020 will have to be treated as representative of the court cases
	*/
	use "CENAPI.dta", clear
	drop if statesale == "" | statesale == "Mx" | statesale == "Ciudad De Mexico" 
	collapse (sum) count, by(statesale)
	egen freq_cenapi = pc(count)
	save "cenapi_f.dta",replace
			
use "courtcases.dta", clear
merge m:1 statesale using "cenapi_f.dta", keepusing(freq_cenapi)
drop if _m == 2
drop _m
save "courtcases.dta", replace
	drop if statesale == ""
	collapse (count) id, by(statesale)
	egen freq_court = pc(id)
	save "courtcases_f.dta",replace

use "courtcases.dta", clear
merge m:1 statesale using "courtcases_f.dta", keepusing(freq_court)
drop if _m == 2
drop _m
gen pw = freq_cenapi /freq_court
labe var pw "Population Weight"
labe var dblcnt_cenapi "Double-counted in CENAPI dataset"
save "courtcases.dta", replace
