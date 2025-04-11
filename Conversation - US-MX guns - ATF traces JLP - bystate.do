import delimited "C:\Users\tlm\Downloads\ATF Trace Data Mex-ElSa-Guate-Hond - 1b Source State.csv", clear
save "ATF traces by state.dta", replace
/*
JLP's file from his 2021 FOIA request, now delivered in May 2024
*/
foreach stub in gunselsalvador gunsguatemala gunshonduras gunsmexico {
		use "ATF traces by state.dta", clear
		reshape long `stub', i(stateofpurchase) j(year)
		keep `stub' stateofpurchase year
		gen country = substr("`stub'",5,strlen("`stub'") - 4)
		save "ATF traces by state - `stub'.dta", replace
	}

use "ATF traces by state - gunselsalvador.dta", clear
foreach stub in gunsguatemala gunshonduras gunsmexico {
		append using "ATF traces by state - `stub'.dta"
		replace gunselsalvador = `stub' if gunselsalvador == .
		drop `stub'
	}
rename gunselsalvador guns
replace country = "El Salvador" if country == "elsalvador"
replace country = strproper(country)
replace stateofpurchase = strproper(stateofpurchase)

foreach stub in gunselsalvador gunsguatemala gunshonduras gunsmexico {
		erase "ATF traces by state - `stub'.dta"
	}
* fillin stateofpurchase country year // not necessary
gen origindestination = stateofpurchase + " - " + country
encode origindestination, gen(odnum)
order stateofpurchase country origindestination odnum year guns

	* Generating a gun index by origin-destination, 2015 = 100
gen odindex = .
	labe var odindex "Seizures index"
	order odindex, after(guns)
save "ATF traces by state.dta", replace

keep if year == 2015
collapse (first) guns, by(odnum)
rename guns anchor2015
save "ATF traces by state - anchor2015.dta", replace

use "ATF traces by state.dta", clear
merge m:1 odnum using "ATF traces by state - anchor2015.dta", keepusing(anchor2015)
drop _m
erase "ATF traces by state - anchor2015.dta"
xtset odnum year, yearly

replace odindex = .
replace odindex = 100 if year == 2015
replace odindex = guns/anchor2015 * 100 if year != 2015 & anchor2015 > 0
replace odindex = guns/(anchor2015+1) * 100 if year != 2015 & anchor2015 == 0

drop anchor2015

save "ATF traces by state.dta", replace


/*
Index-based analysis of time trends
*/
use "ATF traces by state.dta", clear

/*
BORDER STATES
graph drop CA AZ NM TX
*/
* California
twoway ///
	(line odindex year if stateofpurchase == "California" & country == ///
	"Mexico", title("California") xtitle("Year") xlabel(,val labsize(vsmall)) ytitle("Gun Trace Index (2015 = 100)") ///
	ylabel(,val labsize(vsmall)) graphregion(color(white)) yline(100) name(CA) legend(order(1 "Mexico" 2 "El Salvador" 3 ///
	"Guatemala" 4 "Honduras")size(small) )) ///
	(line odindex year if stateofpurchase == "California" & country == ///
	"El Salvador", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "California" & country == ///
	"Guatemala", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "California" & country == ///
	"Honduras", graphregion(color(white)))

* Arizona
twoway ///
	(line odindex year if stateofpurchase == "Arizona" & country == ///
	"Mexico", title("Arizona") xtitle("Year") xlabel(,val labsize(vsmall)) ytitle("") ///
	ylabel(,val labsize(vsmall)) graphregion(color(white)) yline(100) legend(order(1 "Mexico" 2 "El Salvador" 3 ///
	"Guatemala" 4 "Honduras") size(small) ) name(AZ) ) ///
	(line odindex year if stateofpurchase == "Arizona" & country == ///
	"El Salvador", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Arizona" & country == ///
	"Guatemala", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Arizona" & country == ///
	"Honduras", graphregion(color(white)))
	
* New Mexico
twoway ///
	(line odindex year if stateofpurchase == "New Mexico" & country == ///
	"Mexico", title("New Mexico") xtitle("Year") xlabel(,val labsize(vsmall)) ytitle("") ///
	ylabel(,val labsize(vsmall)) graphregion(color(white)) yline(100) legend(order(1 "Mexico" 2 "El Salvador" 3 ///
	"Guatemala" 4 "Honduras") size(small)) name(NM) ) ///
	(line odindex year if stateofpurchase == "New Mexico" & country == ///
	"El Salvador", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "New Mexico" & country == ///
	"Guatemala", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "New Mexico" & country == ///
	"Honduras", graphregion(color(white)))
	
* Texas
twoway ///
	(line odindex year if stateofpurchase == "Texas" & country == ///
	"Mexico", title("Texas") xtitle("Year") xlabel(,val labsize(vsmall)) ytitle("") ///
	ylabel(,val labsize(vsmall)) graphregion(color(white)) yline(100) legend(order(1 "Mexico" 2 "El Salvador" 3 ///
	"Guatemala" 4 "Honduras") size(small)) name(TX) ) ///
	(line odindex year if stateofpurchase == "Texas" & country == ///
	"El Salvador", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Texas" & country == ///
	"Guatemala", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Texas" & country == ///
	"Honduras", graphregion(color(white)))

graph combine CA AZ NM TX, cols(4) ycommon imargin(zero) graphregion(color(white)) b1()
graph save Graph "OD index - border states.gph"

/*
PACIFIC NW
graph drop OR WA
*/
* Oregon
twoway ///
	(line odindex year if stateofpurchase == "Oregon" & country == ///
	"Mexico", title("Oregon") xtitle("Year") xlabel(,val labsize(vsmall)) ytitle("Gun Trace Index (2015 = 100)") ///
	ylabel(,val labsize(vsmall)) graphregion(color(white)) yline(100) name(OR) legend(order(1 "Mexico" 2 "El Salvador" 3 ///
	"Guatemala" 4 "Honduras")size(small) )) ///
	(line odindex year if stateofpurchase == "Oregon" & country == ///
	"El Salvador", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Oregon" & country == ///
	"Guatemala", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Oregon" & country == ///
	"Honduras", graphregion(color(white)))

* Washington
twoway ///
	(line odindex year if stateofpurchase == "Washington" & country == ///
	"Mexico", title("Washington") xtitle("Year") xlabel(,val labsize(vsmall)) ytitle("") ///
	ylabel(,val labsize(vsmall)) graphregion(color(white)) yline(100) legend(order(1 "Mexico" 2 "El Salvador" 3 ///
	"Guatemala" 4 "Honduras") size(small) ) name(WA) ) ///
	(line odindex year if stateofpurchase == "Washington" & country == ///
	"El Salvador", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Washington" & country == ///
	"Guatemala", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Washington" & country == ///
	"Honduras", graphregion(color(white)))

graph combine OR WA, cols(2) ycommon imargin(zero) graphregion(color(white)) b1()
graph save Graph "OD index - pac NW.gph"

/*
ROCKY MTN STATES
graph drop CO UT ID MT WY
*/
* Colorado
twoway ///
	(line odindex year if stateofpurchase == "Colorado" & country == ///
	"Mexico", title("Colorado") xtitle("Year") xlabel(,val labsize(vsmall)) ytitle("Gun Trace Index (2015 = 100)") ///
	ylabel(,val labsize(vsmall)) graphregion(color(white)) yline(100) name(CO) legend(order(1 "Mexico" 2 "El Salvador" 3 ///
	"Guatemala" 4 "Honduras")size(small) )) ///
	(line odindex year if stateofpurchase == "Colorado" & country == ///
	"El Salvador", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Colorado" & country == ///
	"Guatemala", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Colorado" & country == ///
	"Honduras", graphregion(color(white)))

* Utah
twoway ///
	(line odindex year if stateofpurchase == "Utah" & country == ///
	"Mexico", title("Utah") xtitle("Year") xlabel(,val labsize(vsmall)) ytitle("") ///
	ylabel(,val labsize(vsmall)) graphregion(color(white)) yline(100) legend(order(1 "Mexico" 2 "El Salvador" 3 ///
	"Guatemala" 4 "Honduras") size(small) ) name(UT) ) ///
	(line odindex year if stateofpurchase == "Utah" & country == ///
	"El Salvador", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Utah" & country == ///
	"Guatemala", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Utah" & country == ///
	"Honduras", graphregion(color(white)))
	
* Idaho
twoway ///
	(line odindex year if stateofpurchase == "Idaho" & country == ///
	"Mexico", title("Idaho") xtitle("Year") xlabel(,val labsize(vsmall)) ytitle("") ///
	ylabel(,val labsize(vsmall)) graphregion(color(white)) yline(100) legend(order(1 "Mexico" 2 "El Salvador" 3 ///
	"Guatemala" 4 "Honduras") size(small)) name(ID) ) ///
	(line odindex year if stateofpurchase == "Idaho" & country == ///
	"El Salvador", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Idaho" & country == ///
	"Guatemala", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Idaho" & country == ///
	"Honduras", graphregion(color(white)))
	
* Montana
twoway ///
	(line odindex year if stateofpurchase == "Montana" & country == ///
	"Mexico", title("Montana") xtitle("Year") xlabel(,val labsize(vsmall)) ytitle("") ///
	ylabel(,val labsize(vsmall)) graphregion(color(white)) yline(100) legend(order(1 "Mexico" 2 "El Salvador" 3 ///
	"Guatemala" 4 "Honduras") size(small)) name(MT) ) ///
	(line odindex year if stateofpurchase == "Montana" & country == ///
	"El Salvador", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Montana" & country == ///
	"Guatemala", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Montana" & country == ///
	"Honduras", graphregion(color(white)))
	
* Wyoming
twoway ///
	(line odindex year if stateofpurchase == "Wyoming" & country == ///
	"Mexico", title("Wyoming") xtitle("Year") xlabel(,val labsize(vsmall)) ytitle("") ///
	ylabel(,val labsize(vsmall)) graphregion(color(white)) yline(100) legend(order(1 "Mexico" 2 "El Salvador" 3 ///
	"Guatemala" 4 "Honduras") size(small)) name(WY) ) ///
	(line odindex year if stateofpurchase == "Wyoming" & country == ///
	"El Salvador", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Wyoming" & country == ///
	"Guatemala", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Wyoming" & country == ///
	"Honduras", graphregion(color(white)))

graph combine CO UT ID MT WY, cols(5) ycommon imargin(zero) graphregion(color(white)) b1()
graph save Graph "OD index - rocky mtn states.gph"


/*
SE STATES
graph drop FL AL MS GA SC NC LA
*/
* Florida
twoway ///
	(line odindex year if stateofpurchase == "Florida" & country == ///
	"Mexico", title("Florida") xtitle("Year") xlabel(,val labsize(vsmall)) ytitle("Gun Trace Index (2015 = 100)") ///
	ylabel(,val labsize(vsmall)) graphregion(color(white)) yline(100) name(FL) legend(order(1 "Mexico" 2 "El Salvador" 3 ///
	"Guatemala" 4 "Honduras")size(small) )) ///
	(line odindex year if stateofpurchase == "Florida" & country == ///
	"El Salvador", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Florida" & country == ///
	"Guatemala", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Florida" & country == ///
	"Honduras", graphregion(color(white)))

* Alabama
twoway ///
	(line odindex year if stateofpurchase == "Alabama" & country == ///
	"Mexico", title("Alabama") xtitle("Year") xlabel(,val labsize(vsmall)) ytitle("") ///
	ylabel(,val labsize(vsmall)) graphregion(color(white)) yline(100) legend(order(1 "Mexico" 2 "El Salvador" 3 ///
	"Guatemala" 4 "Honduras") size(small) ) name(AL) ) ///
	(line odindex year if stateofpurchase == "Alabama" & country == ///
	"El Salvador", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Alabama" & country == ///
	"Guatemala", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Alabama" & country == ///
	"Honduras", graphregion(color(white)))
	
* Mississippi
twoway ///
	(line odindex year if stateofpurchase == "Mississippi" & country == ///
	"Mexico", title("Mississippi") xtitle("Year") xlabel(,val labsize(vsmall)) ytitle("") ///
	ylabel(,val labsize(vsmall)) graphregion(color(white)) yline(100) legend(order(1 "Mexico" 2 "El Salvador" 3 ///
	"Guatemala" 4 "Honduras") size(small)) name(MS) ) ///
	(line odindex year if stateofpurchase == "Mississippi" & country == ///
	"El Salvador", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Mississippi" & country == ///
	"Guatemala", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Mississippi" & country == ///
	"Honduras", graphregion(color(white)))
	
* Georgia
twoway ///
	(line odindex year if stateofpurchase == "Georgia" & country == ///
	"Mexico", title("Georgia") xtitle("Year") xlabel(,val labsize(vsmall)) ytitle("") ///
	ylabel(,val labsize(vsmall)) graphregion(color(white)) yline(100) legend(order(1 "Mexico" 2 "El Salvador" 3 ///
	"Guatemala" 4 "Honduras") size(small)) name(GA) ) ///
	(line odindex year if stateofpurchase == "Georgia" & country == ///
	"El Salvador", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Georgia" & country == ///
	"Guatemala", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Georgia" & country == ///
	"Honduras", graphregion(color(white)))
	
* South Carolina
twoway ///
	(line odindex year if stateofpurchase == "South Carolina" & country == ///
	"Mexico", title("South Carolina") xtitle("Year") xlabel(,val labsize(vsmall)) ytitle("") ///
	ylabel(,val labsize(vsmall)) graphregion(color(white)) yline(100) legend(order(1 "Mexico" 2 "El Salvador" 3 ///
	"Guatemala" 4 "Honduras") size(small)) name(SC) ) ///
	(line odindex year if stateofpurchase == "South Carolina" & country == ///
	"El Salvador", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "South Carolina" & country == ///
	"Guatemala", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "South Carolina" & country == ///
	"Honduras", graphregion(color(white)))

* North Carolina
twoway ///
	(line odindex year if stateofpurchase == "North Carolina" & country == ///
	"Mexico", title("North Carolina") xtitle("Year") xlabel(,val labsize(vsmall)) ytitle("") ///
	ylabel(,val labsize(vsmall)) graphregion(color(white)) yline(100) legend(order(1 "Mexico" 2 "El Salvador" 3 ///
	"Guatemala" 4 "Honduras") size(small)) name(NC) ) ///
	(line odindex year if stateofpurchase == "North Carolina" & country == ///
	"El Salvador", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "North Carolina" & country == ///
	"Guatemala", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "North Carolina" & country == ///
	"Honduras", graphregion(color(white)))
	
* Louisiana
twoway ///
	(line odindex year if stateofpurchase == "Louisiana" & country == ///
	"Mexico", title("Louisiana") xtitle("Year") xlabel(,val labsize(vsmall)) ytitle("") ///
	ylabel(,val labsize(vsmall)) graphregion(color(white)) yline(100) legend(order(1 "Mexico" 2 "El Salvador" 3 ///
	"Guatemala" 4 "Honduras") size(small)) name(LA) ) ///
	(line odindex year if stateofpurchase == "Louisiana" & country == ///
	"El Salvador", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Louisiana" & country == ///
	"Guatemala", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Louisiana" & country == ///
	"Honduras", graphregion(color(white)))
	
graph combine FL AL MS GA SC NC LA, cols(4) ycommon imargin(zero) graphregion(color(white)) b1()
graph save Graph "OD index - SE states.gph"


/*
LOWER MIDWEST STATES
graph drop OK MO IN KS AR
*/
* Florida
twoway ///
	(line odindex year if stateofpurchase == "Oklahoma" & country == ///
	"Mexico", title("Oklahoma") xtitle("Year") xlabel(,val labsize(vsmall)) ytitle("Gun Trace Index (2015 = 100)") ///
	ylabel(,val labsize(vsmall)) graphregion(color(white)) yline(100) name(OK) legend(order(1 "Mexico" 2 "El Salvador" 3 ///
	"Guatemala" 4 "Honduras")size(small) )) ///
	(line odindex year if stateofpurchase == "Oklahoma" & country == ///
	"El Salvador", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Oklahoma" & country == ///
	"Guatemala", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Oklahoma" & country == ///
	"Honduras", graphregion(color(white)))

* Missouri
twoway ///
	(line odindex year if stateofpurchase == "Missouri" & country == ///
	"Mexico", title("Missouri") xtitle("Year") xlabel(,val labsize(vsmall)) ytitle("") ///
	ylabel(,val labsize(vsmall)) graphregion(color(white)) yline(100) legend(order(1 "Mexico" 2 "El Salvador" 3 ///
	"Guatemala" 4 "Honduras") size(small) ) name(MO) ) ///
	(line odindex year if stateofpurchase == "Missouri" & country == ///
	"El Salvador", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Missouri" & country == ///
	"Guatemala", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Missouri" & country == ///
	"Honduras", graphregion(color(white)))
	
* Indiana
twoway ///
	(line odindex year if stateofpurchase == "Indiana" & country == ///
	"Mexico", title("Indiana") xtitle("Year") xlabel(,val labsize(vsmall)) ytitle("") ///
	ylabel(,val labsize(vsmall)) graphregion(color(white)) yline(100) legend(order(1 "Mexico" 2 "El Salvador" 3 ///
	"Guatemala" 4 "Honduras") size(small)) name(IN) ) ///
	(line odindex year if stateofpurchase == "Indiana" & country == ///
	"El Salvador", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Indiana" & country == ///
	"Guatemala", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Indiana" & country == ///
	"Honduras", graphregion(color(white)))
	
* Kansas
twoway ///
	(line odindex year if stateofpurchase == "Kansas" & country == ///
	"Mexico", title("Kansas") xtitle("Year") xlabel(,val labsize(vsmall)) ytitle("") ///
	ylabel(,val labsize(vsmall)) graphregion(color(white)) yline(100) legend(order(1 "Mexico" 2 "El Salvador" 3 ///
	"Guatemala" 4 "Honduras") size(small)) name(KS) ) ///
	(line odindex year if stateofpurchase == "Kansas" & country == ///
	"El Salvador", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Kansas" & country == ///
	"Guatemala", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Kansas" & country == ///
	"Honduras", graphregion(color(white)))
	
* Arkansas
twoway ///
	(line odindex year if stateofpurchase == "Arkansas" & country == ///
	"Mexico", title("Arkansas") xtitle("Year") xlabel(,val labsize(vsmall)) ytitle("") ///
	ylabel(,val labsize(vsmall)) graphregion(color(white)) yline(100) legend(order(1 "Mexico" 2 "El Salvador" 3 ///
	"Guatemala" 4 "Honduras") size(small)) name(AR) ) ///
	(line odindex year if stateofpurchase == "Arkansas" & country == ///
	"El Salvador", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Arkansas" & country == ///
	"Guatemala", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Arkansas" & country == ///
	"Honduras", graphregion(color(white)))
	
graph combine OK MO IN KS AR, cols(5) ycommon imargin(zero) graphregion(color(white)) b1()
graph save Graph "OD index - lower midwest states.gph"


/*
UPPER MIDWEST STATES
graph drop MN WI MI IL NE IA 
*/
* Minnesota
twoway ///
	(line odindex year if stateofpurchase == "Minnesota" & country == ///
	"Mexico", title("Minnesota") xtitle("Year") xlabel(,val labsize(vsmall)) ytitle("Gun Trace Index (2015 = 100)") ///
	ylabel(,val labsize(vsmall)) graphregion(color(white)) yline(100) name(MN) legend(order(1 "Mexico" 2 "El Salvador" 3 ///
	"Guatemala" 4 "Honduras")size(small) )) ///
	(line odindex year if stateofpurchase == "Minnesota" & country == ///
	"El Salvador", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Minnesota" & country == ///
	"Guatemala", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Minnesota" & country == ///
	"Honduras", graphregion(color(white)))

* Wisconsin
twoway ///
	(line odindex year if stateofpurchase == "Wisconsin" & country == ///
	"Mexico", title("Wisconsin") xtitle("Year") xlabel(,val labsize(vsmall)) ytitle("") ///
	ylabel(,val labsize(vsmall)) graphregion(color(white)) yline(100) legend(order(1 "Mexico" 2 "El Salvador" 3 ///
	"Guatemala" 4 "Honduras") size(small) ) name(WI) ) ///
	(line odindex year if stateofpurchase == "Wisconsin" & country == ///
	"El Salvador", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Wisconsin" & country == ///
	"Guatemala", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Wisconsin" & country == ///
	"Honduras", graphregion(color(white)))
	
* Michigan
twoway ///
	(line odindex year if stateofpurchase == "Michigan" & country == ///
	"Mexico", title("Michigan") xtitle("Year") xlabel(,val labsize(vsmall)) ytitle("") ///
	ylabel(,val labsize(vsmall)) graphregion(color(white)) yline(100) legend(order(1 "Mexico" 2 "El Salvador" 3 ///
	"Guatemala" 4 "Honduras") size(small)) name(MI) ) ///
	(line odindex year if stateofpurchase == "Michigan" & country == ///
	"El Salvador", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Michigan" & country == ///
	"Guatemala", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Michigan" & country == ///
	"Honduras", graphregion(color(white)))
	
* Illinois
twoway ///
	(line odindex year if stateofpurchase == "Illinois" & country == ///
	"Mexico", title("Illinois") xtitle("Year") xlabel(,val labsize(vsmall)) ytitle("") ///
	ylabel(,val labsize(vsmall)) graphregion(color(white)) yline(100) legend(order(1 "Mexico" 2 "El Salvador" 3 ///
	"Guatemala" 4 "Honduras") size(small)) name(IL) ) ///
	(line odindex year if stateofpurchase == "Illinois" & country == ///
	"El Salvador", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Illinois" & country == ///
	"Guatemala", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Illinois" & country == ///
	"Honduras", graphregion(color(white)))
	
* Nebraska
twoway ///
	(line odindex year if stateofpurchase == "Nebraska" & country == ///
	"Mexico", title("Nebraska") xtitle("Year") xlabel(,val labsize(vsmall)) ytitle("") ///
	ylabel(,val labsize(vsmall)) graphregion(color(white)) yline(100) legend(order(1 "Mexico" 2 "El Salvador" 3 ///
	"Guatemala" 4 "Honduras") size(small)) name(NE) ) ///
	(line odindex year if stateofpurchase == "Nebraska" & country == ///
	"El Salvador", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Nebraska" & country == ///
	"Guatemala", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Nebraska" & country == ///
	"Honduras", graphregion(color(white)))

* Iowa
twoway ///
	(line odindex year if stateofpurchase == "Iowa" & country == ///
	"Mexico", title("Iowa") xtitle("Year") xlabel(,val labsize(vsmall)) ytitle("") ///
	ylabel(,val labsize(vsmall)) graphregion(color(white)) yline(100) legend(order(1 "Mexico" 2 "El Salvador" 3 ///
	"Guatemala" 4 "Honduras") size(small)) name(IA) ) ///
	(line odindex year if stateofpurchase == "Iowa" & country == ///
	"El Salvador", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Iowa" & country == ///
	"Guatemala", graphregion(color(white))) ///
	(line odindex year if stateofpurchase == "Iowa" & country == ///
	"Honduras", graphregion(color(white)))
	
graph combine MN WI MI IL NE IA, cols(3) ycommon imargin(zero) graphregion(color(white)) b1()
graph save Graph "OD index - upper midwest states.gph"
