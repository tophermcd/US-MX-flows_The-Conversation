*** FFL ID ANALYSIS (w/ CENAPI data) ***

cd "G:\My Drive\Research\Firearms Economics\Conversation Report\"
clear

/*
* Prerequisite: Cenapi data creation
do "Conversation - US-MX guns - Cenapi - data creation.do"
*/

use "CENAPI.dta", clear


	* Identifying pawn shops
gen pawn = 0
	/*
	replace pawn = 0
	*/
labe var pawn "Firearm was sold in a pawn shop"
replace pawn = 1 if strpos(strlower(FFL),"pawn")>0 | strpos(strlower(FFL),"loan")>0 | strpos(strlower(FFL),"hock")>0

	* Identifying guns legally imported to Mexico
gen legal = 0
	/*
	replace legal = 0
	*/
labe var legal "Firearm legally exported/ obtained from US"
replace legal = 1 if strpos(strlower(FFL),"secretaria")>0 | ///
	strpos(strlower(FFL),"secreteria")>0 | ///
	strpos(strlower(FFL),"direccion")>0 | ///
	strpos(strlower(FFL),"comisariato")>0 | ///
	strpos(strlower(FFL),"secretaria")>0 | ///
	strpos(strlower(FFL),"sedena")>0 | ///
	strpos(strlower(FFL),"of mexico")>0 | ///
	strpos(strlower(FFL),"confort electrico")>0 | ///
	strpos(strlower(FFL),"mexican military")>0 | ///
	strpos(strlower(FFL),"state of")>0 | ///
	strpos(strlower(FFL),"consulate")>0 | ///
	strpos(strlower(FFL),"estado")>0 | ///
	strpos(strlower(FFL),"mexican state")>0 | ///
	strpos(strlower(FFL),"programa nacional")>0 | ///
	strpos(strlower(FFL),"embassy")>0 | ///
	strpos(strlower(FFL),"banco nacional")>0

	* Generating counts for later collapsing
	gen count = 1
		/*
		replace count = 1
		*/
	* Identifying long guns
gen longgun = 1
		/*
		replace longgun = 1
		*/
replace longgun = . if type == "LANZA GRANADAS" | type == "TIPO DESCONOCIDO" | type == "N/D"
replace longgun = 0 if strpos(type,"PISTOL")>0 | strpos(type,"REVOLV")>0 | strpos(type,"DERRING")>0
replace longgun = 1 if class == "LARGA"
replace longgun = 0 if class == "CORTA"

	* FFL retailer name standardizations
	replace FFL = "Wal-Mart" if strpos(strlower(FFL),"wal-mart")>0
	replace FFL = "Cabela's" if strpos(strlower(FFL),"cabela's")>0
	replace FFL = "Academy" if strpos(strlower(FFL),"academy")>0
	replace FFL = "First Cash Pawn" if strpos(strlower(FFL),"first cash pawn")>0
	replace FFL = "Gibson Discount" if strpos(strlower(FFL),"gibson discount")>0
	replace FFL = "EZPawn" if strpos(strlower(FFL),"ezpawn")>0
	replace FFL = "Turners Outdoorsman" if strpos(strlower(FFL),"turners outdoors")>0
	replace FFL = "Sprague's" if strpos(strlower(FFL),"sprague's")>0
	replace FFL = "Zeroed In Armory" if strpos(strlower(FFL),"zeroed in")>0
	replace FFL = "Andrews Sporting" if strpos(strlower(FFL),"andrews sporting")>0
	replace FFL = "Guns Unlimited" if strpos(strlower(FFL),"guns unlimited")>0
	replace FFL = "Western Firearms" if strpos(strlower(FFL),"western firearms")>0
	replace FFL = "Kmart" if strpos(strlower(FFL),"kmart corporation")>0
	replace FFL = "Big 5" if strpos(strlower(FFL),"big 5")>0
	replace FFL = "Superpawn" if strpos(strlower(FFL),"superpawn")>0
	replace FFL = "RG Industries" if strpos(strlower(FFL),"rg industries")>0
	replace FFL = "Superpawn" if strpos(strlower(FFL),"superpawn")>0
	
	* Identifying manufacturing FFLs (as opposed to retailers)
gen manuf = 0
		/*
		replace manuf = 0
		*/
labe var manuf "FFL is manufacturer"
replace manuf = 1 if strpos(strlower(FFL),"colt")>0 | ///
	strpos(strlower(FFL),"smith & wesson")>0 | ///
	strpos(strlower(FFL),"primary arms")>0 | ///
	strpos(strlower(FFL),"bryco")>0 | ///
	strpos(strlower(FFL),"ruger")>0 | ///
	strpos(strlower(FFL),"springfield")>0 | ///
	strpos(strlower(FFL),"polymer80")>0 | ///
	strpos(strlower(FFL),"hi-point")>0 | ///
	strpos(strlower(FFL),"high standard")>0 | ///
	strpos(strlower(FFL),"fabrique nationale")>0 | ///
	strpos(strlower(FFL),"universal firearms")>0 | ///
	strpos(strlower(FFL),"century")>0 | ///
	strpos(strlower(FFL),"mossberg")>0 | ///
	strpos(strlower(FFL),"us repeating")>0 | ///
	strpos(strlower(FFL),"sig sauer")>0 | ///
	strpos(strlower(FFL),"firearms import & export")>0 | ///
	strpos(strlower(FFL),"jenning")>0 | ///
	strpos(strlower(FFL),"anderson manuf")>0 | ///
	strpos(strlower(FFL),"usrac")>0 | ///
	strpos(strlower(FFL),"itm arms company")>0 | ///
	strpos(strlower(FFL),"savage arms")>0 | ///
	strpos(strlower(FFL),"military surplus")>0 | ///
	strpos(strlower(FFL),"armalite")>0 | ///
	strpos(strlower(FFL),"barrett")>0 | ///
	strpos(strlower(FFL),"beretta")>0 | ///
	strpos(strlower(FFL),"bushmaster firearms")>0 | ///
	strpos(strlower(FFL),"h&r")>0 | ///
	strpos(strlower(FFL),"remington")>0 | ///
	strpos(strlower(citysale),"east hart")>0 | ///
	strpos(strlower(citysale),"ilion")>0 | ///
	strpos(strlower(citysale),"fitchburg")>0 | ///
	strpos(strlower(citysale),"east bloomfield")>0 | ///
	strpos(strlower(citysale),"north haven")>0 | ///
	strpos(strlower(citysale),"stratford")>0 | ///
	strpos(strlower(citysale),"heckler")>0 | ///
	strpos(strlower(citysale),"h&k")>0 | ///
	strpos(strlower(FFL),"iver johns")>0

	* Dropping manufacturers
	drop if manuf == 1

	* Standardizing city & state vars in English
replace citysale = strproper(citysale)
replace statesale = strproper(statesale)
replace statesale = "New Mexico" if statesale == "Nuevo Mexico"
replace statesale = "North Carolina" if statesale == "Carolina Del Norte"
replace statesale = "South Carolina" if statesale == "Carolina Del Sur"
replace statesale = "Mississippi" if statesale == "Misisisipi" | statesale == "Misisipi"
replace statesale = "Arkansas" if statesale == "Arkanzas"
replace statesale = "Louisiana" if statesale == "Luisiana"
replace statesale = "Missouri" if statesale == "Misuri"
replace statesale = "" if statesale == "N/D"
replace citysale = "" if citysale == "N/D"
replace statesale = "New York" if statesale == "Nueva York"
replace statesale = "New Hampshire" if statesale == "Nuevo Hampshire" | statesale == "Nueva Hampshire"
replace statesale = "Pennsylvania" if statesale == "Pensilvania"
replace statesale = "Tennessee" if statesale == "Tennesse"
replace statesale = "West Virginia" if statesale == "Virginia Occidental"
replace statesale = "North Dakota" if statesale == "Dakota Del Norte"
replace statesale = "South Dakota" if statesale == "Dakota Del Sur"
replace statesale = "Illinois" if statesale == "Iilinois"
replace statesale = "District of Columbia" if statesale == "Distrito De Columbia"
replace statesale = "Minnesota" if statesale == "Minesota"
replace statesale = "New Jersey" if statesale == "Nueva Jersey"
replace statesale = "Massachusetts" if statesale == "Massaschusetts"
replace statesale = "Idaho" if statesale == "Iadho"

statastates, n(statesale)
drop _m
replace statesale = strproper(statesale)
format daterecov %td

save "CENAPI.dta", replace

	* Calculating percentage of guns leaked from MX government
sum legal
di "Around " round(r(mean)*100, .01) "%"

	*Calculating number of years of the study period
use "CENAPI.dta", clear
sum daterecov
	global studyyears = (r(max) - r(min))/ 365
	di round($studyyears, .1) " study years"

* Getting missing FFL names
use "CENAPI.dta", clear
drop if FFL == ""
duplicates drop FFLaddress, force
keep FFL FFLaddress
rename FFL FFL2
save "CENAPI-FFLnames.dta", replace
use "CENAPI.dta", clear
merge m:1 FFLaddress using "CENAPI-FFLnames.dta", keepusing(FFL2)
drop _m
replace FFL = FFL2 if FFL2 != ""
drop FFL2
replace FFL = "<unknown>" if FFL == ""
replace FFL = strproper(FFL)

	/*
	drop FFLn
	*/
encode FFL, gen(FFLn)
	order FFLn, after(FFL)

erase "CENAPI-FFLnames.dta"

save "CENAPI.dta", replace

* Getting numbers of branches per FFL
use "CENAPI.dta", clear

	collapse (first) FFL, by(FFLaddress)
	gen branches = 1
	collapse (count) branches, by(FFL)
	labe var branches "Number of locations"
	save "cenapitemp.dta", replace
	use "CENAPI.dta", clear
	merge m:1 FFL using "cenapitemp.dta", keepusing(branches)
	drop if _m == 2
	drop _m
	erase "cenapitemp.dta"
save "CENAPI.dta", replace


*** FFL ANALYSIS GRAPHS

** FFLs graphed by CITY
	cd "G:\My Drive\Research\Firearms Economics\Conversation Report\"

	**  Obtaining City Populations for normalization
	clear
	/*
	*Getting city population figures

	import excel "G:\My Drive\Research\Firearms Economics\Conversation Report\us-city-pops-census-2020-2.xlsx", sheet("data") firstrow
	drop Base Pop2021 Pop2022
	rename CityName citysale
	gen statesale = strtrim(substr(citysale,strpos(citysale,",")+1,strlen(citysale)-strpos(citysale,",")+1))
	replace citysale = strtrim(substr(citysale,1,strpos(citysale,",")-1))
	replace citysale = substr(citysale,1,strlen(citysale)-5) if strpos(strlower(citysale)," city")>0
	order citysale statesale, first
	destring Rank, force replace
	drop if citysale == ""

	save "us-city-pops-census-2020.dta", replace
	*/

	use "CENAPI.dta", clear
		collapse (count) count, by(citysale statesale)
		merge m:1 citysale statesale using "us-city-pops-census-2020.dta", keepusing(Pop2020)
		keep if _m == 3
		drop _m

		labe var count "Count of guns"
			
		gen ctperpop = count/ Pop2020 * 100000 / $studyyears
		labe var ctperpop "Guns per 100k people per year"
		gen citystate = citysale + ", " + statesale

		gen statesale2 = subinstr(statesale," ","",.)
		levelsof statesale2, local(levels)
		foreach l of local levels {
			display "Processing level: `l'"
			gen ctperpop_`l' = 0
			replace ctperpop_`l' = ctperpop if statesale2 == "`l'"
			}

	save "CENAPI-city-collapse.dta", replace
		
		
	use "CENAPI-city-collapse.dta", clear

	/*
	drop axis*
	label drop axis*
	*/
		gen studystates = 0
		replace studystates = 1 if statesale == "Arizona" | ///
			statesale == "California" | statesale == "Florida" | ///
			statesale == "New Mexico" | statesale == "Texas" | ///
			statesale == "Washington"
			* I'm not including Georgia b/c that pulls up Smyrna, where Glock is located
			* Ditto for PA, which is apparently where SEDENA purchases weapons
		gsort -studystates -ctperpop
		/*
		gsort -ctperpop
		*/
		gen axis = _n
		labmask axis, values(citystate)
		label variable axis "City & State"
		label values axis axis

		graph hbar ///
			ctperpop_Arizona ctperpop_California ctperpop_Florida ///
			ctperpop_NewMexico ctperpop_Texas ctperpop_Washington ///
			if ctperpop > 10 & studystates == 1, ///
			over(axis, lab(angle(0) labsize(tiny))) ///
			bar(1, color(gold)) bar(2, color(blue)) bar(3, color(mint)) ///
			bar(4, color(yellow)) bar(5, color(red))  bar(6, color(green)) ///
			stack ytitle("Guns per 100k people per year") ylab(,labsize(small)) ///
			legend(col(3)order(1 "Arizona" 2 "California" 3 "Florida" 4 "New Mexico" 5 "Texas" 6 "Washington") ///
			subtitle("Legend", size(small)) size(vsmall)) graphregion(color(white))
		graph hbar ctperpop_Arizona ctperpop_California ctperpop_Florida ctperpop_NewMexico ctperpop_Texas ctperpop_Washington if ctperpop > 10, ///
			over(axis, lab(angle(0) labsize(tiny))) ///
			stack ytitle("Guns per 100k people per year") ylab(,labsize(small)) ///
			subtitle("Legend", size(small)) graphregion(color(white))

		gsort statesale - ctperpop
		gen axis2 = _n
		labmask axis2, values(citysale)
		label variable axis2 "City"
		label values axis2 axis2

		graph hbar ctperpop_Arizona ctperpop_California ctperpop_Florida ctperpop_NewMexico ctperpop_Texas ctperpop_Washington if ctperpop > 7, ///
			over(axis2, lab(angle(0) labsize(tiny))) ///
			bar(1, fcolor(orange) lwidth(none)) bar(2, fcolor(midblue) lwidth(none)) bar(3, fcolor(mint) lwidth(none))  bar(4, fcolor(yellow) lwidth(none))  bar(5, fcolor(red) lwidth(none))  bar(6, fcolor(dkgreen) lwidth(none)) ///
			stack ytitle("Guns per 100k people per year") ylab(,labsize(small)) legend(col(3)order(1 "Arizona" 2 "California" 3 "Florida" 4 "New Mexico" 5 "Texas" 6 "Washington") ///
			subtitle("Legend", size(small)) size(vsmall)) graphregion(color(white))


* FFLs graphed by ADDRESS
		use "CENAPI.dta", clear
		drop if strpos(strtrim(FFL), "31323") > 0
			* This FFL is long out of business now
		gen studystates = 0
		replace studystates = 1 if statesale == "Arizona" | ///
			statesale == "California" | statesale == "Florida" | ///
			statesale == "New Mexico" | statesale == "Texas" | ///
			statesale == "Washington"
			* I'm not including Georgia b/c that pulls up Smyrna, where Glock is located
		gen FFLcity = FFL + ", " + citysale + ", " + state_abbrev
		gen FFLaddresscity = FFLaddress + " " + citysale
		drop if citysale == ""
		sort FFLaddresscity

			drop if legal == 1 | manuf == 1
			drop manuf legal
			drop if FFL == "" | FFL == "N/D" | strlower(FFL) == "<unknown>"
			drop if statesale == "#" | statesale == "N/D"
			
		collapse (count) count (first) FFL FFLcity statesale studystates, by(FFLaddresscity)
			labe var count "Count of guns"
			labe var FFL "Retailer"
			labe var FFLcity "FFL and city"
			labe var statesale "State"
			
		gen statesale2 = subinstr(statesale," ","",.)
		levelsof statesale2, local(levels)
		foreach l of local levels {
			display "Processing level: `l'"
			gen count_`l' = 0
			replace count_`l' = count if statesale2 == "`l'"
			}
			
		save "CENAPI-FFLaddress-collapse.dta", replace

		use "CENAPI-FFLaddress-collapse.dta", clear
	/*
	drop axis*
	label drop axis*
	*/
		gsort - studystates - count statesale
		gen axis = _n
		/*
		labmask axis, values(FFL)
		*/
		label variable axis "Retailer"
		label values axis axis

		graph hbar ///
			count_Arizona count_California count_Florida count_NewMexico ///
			count_Texas count_Washington if count > 14 & studystates == 1, ///
			over(axis, lab(angle(0) labsize(tiny))) ///
			bar(1, color(gold)) bar(2, color(blue)) bar(3, color(mint))  bar(4, color(yellow))  bar(5, color(red))  bar(6, color(green)) ///
			stack ytitle("Guns Seized") ylab(,labsize(small)) legend(col(3)order(1 "Arizona" 2 "California" 3 "Florida" 4 "New Mexico" 5 "Texas" 6 "Washington") ///
			subtitle("Legend", size(small)) size(vsmall)) graphregion(color(white))


* Chi-Square: Gun type vs store type

cd "G:\My Drive\Research\Firearms Economics\Conversation Report\"
use "CENAPI.dta", clear

	
	* FFL retailer name standardizations
	replace FFL = "Wal-Mart" if strpos(strlower(FFL),"wal-mart")>0
	replace FFL = "Cabela's" if strpos(strlower(FFL),"cabela's")>0
	replace FFL = "Academy" if strpos(strlower(FFL),"academy")>0
	replace FFL = "First Cash Pawn" if strpos(strlower(FFL),"first cash pawn")>0
	replace FFL = "Gibson Discount" if strpos(strlower(FFL),"gibson discount")>0
	replace FFL = "EZPawn" if strpos(strlower(FFL),"ezpawn")>0
	replace FFL = "Turners Outdoorsman" if strpos(strlower(FFL),"turners outdoors")>0
	replace FFL = "Sprague's" if strpos(strlower(FFL),"sprague's")>0
	replace FFL = "Zeroed In Armory" if strpos(strlower(FFL),"zeroed in")>0
	replace FFL = "Andrews Sporting" if strpos(strlower(FFL),"andrews sporting")>0
	replace FFL = "Guns Unlimited" if strpos(strlower(FFL),"guns unlimited")>0
	replace FFL = "Western Firearms" if strpos(strlower(FFL),"western firearms")>0
	replace FFL = "Kmart" if strpos(strlower(FFL),"kmart corporation")>0
	replace FFL = "Big 5" if strpos(strlower(FFL),"big 5")>0
	replace FFL = "Superpawn" if strpos(strlower(FFL),"superpawn")>0
	replace FFL = "RG Industries" if strpos(strlower(FFL),"rg industries")>0
	replace FFL = "Superpawn" if strpos(strlower(FFL),"superpawn")>0

		drop if FFL == "" | FFL == "N/D" | strlower(FFL) == "<unknown>"
		drop if statesale == "#" | statesale == "N/D"
		
	gen chain = 0
	labe var chain "Chain retailer"
	replace chain = 1 if branches > 1
	replace chain = 1 if ///
		strpos(strlower(FFL), "bass")>0 | ///
		strpos(strlower(FFL), "target gun sales")>0 | ///
		strpos(strlower(FFL), "academy")>0 | ///
		strpos(strlower(FFL), "cabela")>0 | ///
		strpos(strlower(FFL), "wal-mart")>0 | ///
		strpos(strlower(FFL), "big 5")>0 | ///
		strpos(strlower(FFL), "kmart")>0 | ///
		strpos(strlower(FFL), "ezpawn")>0 | ///
		strpos(strlower(FFL), "oshman")>0 | ///
		strpos(strlower(FFL), "turners outdoor")>0 | ///
		strpos(strlower(FFL), "ezpawn")>0 | ///
		strpos(strlower(FFL), "ezpawn")>0
	replace chain = 0 if ///
		strpos(strlower(FFL), "gibson discount center")>0 | ///
		strpos(strlower(FFL), "lathrop")>0 | ///
		strpos(strlower(FFL), "zeroed in")>0 | ///
		strpos(strlower(FFL), "sprague")>0
	labe var count "Count: Guns sold & seized"


	gen ct_legal = count if legal == 1
	lab var ct_legal "Legally imported firearms"
	replace ct_legal = 0 if ct_legal == .
	gen ct_illegal = count if legal == 0
	lab var ct_illegal "Illegally imported firearms"
	replace ct_illegal = 0 if ct_illegal == .
	
	replace caliber = subinstr(caliber,"MM","mm",.)
	
	replace class = "Handgun" if class == "CORTA"
	replace class = "Long gun" if class == "LARGA"
	
	gen sniper50 = 0
	replace sniper50 = 1 if strpos(caliber,".50")>0
	labe var sniper50 ".50 caliber sniper rifle"
	
	gen cal762 = 0
	replace cal762 = 1 if strpos(caliber,"7.62")>0
	labe var cal762 "7.62 mm weapon"

	label define Binary 0 "No" 1 "Yes"
	label values chain sniper50 Binary
	
	tabulate class chain, chi2 column rowsort 
	tabulate type chain, chi2 column rowsort 
	tabulate sniper50 chain, chi2 column rowsort 
	tabulate cal762 chain, chi2 column rowsort 

* All FFLs collapsed by NAME 

cd "G:\My Drive\Research\Firearms Economics\Conversation Report\"
use "CENAPI.dta", clear

	
	* FFL retailer name standardizations
	replace FFL = "Wal-Mart" if strpos(strlower(FFL),"wal-mart")>0
	replace FFL = "Cabela's" if strpos(strlower(FFL),"cabela's")>0
	replace FFL = "Academy" if strpos(strlower(FFL),"academy")>0
	replace FFL = "First Cash Pawn" if strpos(strlower(FFL),"first cash pawn")>0
	replace FFL = "Gibson Discount" if strpos(strlower(FFL),"gibson discount")>0
	replace FFL = "EZPawn" if strpos(strlower(FFL),"ezpawn")>0
	replace FFL = "Turners Outdoorsman" if strpos(strlower(FFL),"turners outdoors")>0
	replace FFL = "Sprague's" if strpos(strlower(FFL),"sprague's")>0
	replace FFL = "Zeroed In Armory" if strpos(strlower(FFL),"zeroed in")>0
	replace FFL = "Andrews Sporting" if strpos(strlower(FFL),"andrews sporting")>0
	replace FFL = "Guns Unlimited" if strpos(strlower(FFL),"guns unlimited")>0
	replace FFL = "Western Firearms" if strpos(strlower(FFL),"western firearms")>0
	replace FFL = "Kmart" if strpos(strlower(FFL),"kmart corporation")>0
	replace FFL = "Big 5" if strpos(strlower(FFL),"big 5")>0
	replace FFL = "Superpawn" if strpos(strlower(FFL),"superpawn")>0
	replace FFL = "RG Industries" if strpos(strlower(FFL),"rg industries")>0
	replace FFL = "Superpawn" if strpos(strlower(FFL),"superpawn")>0

		drop if FFL == "" | FFL == "N/D" | strlower(FFL) == "<unknown>"
		drop if statesale == "#" | statesale == "N/D"
		
	collapse (sum) count (first) FFLn branches, by(FFL legal)
	gen chain = 0
	labe var chain "Chain retailer"
	replace chain = 1 if branches > 1
	replace chain = 1 if ///
		strpos(strlower(FFL), "bass")>0 | ///
		strpos(strlower(FFL), "target gun sales")>0 | ///
		strpos(strlower(FFL), "academy")>0 | ///
		strpos(strlower(FFL), "cabela")>0 | ///
		strpos(strlower(FFL), "wal-mart")>0 | ///
		strpos(strlower(FFL), "big 5")>0 | ///
		strpos(strlower(FFL), "kmart")>0 | ///
		strpos(strlower(FFL), "ezpawn")>0 | ///
		strpos(strlower(FFL), "oshman")>0 | ///
		strpos(strlower(FFL), "turners outdoor")>0 | ///
		strpos(strlower(FFL), "ezpawn")>0 | ///
		strpos(strlower(FFL), "ezpawn")>0
	replace chain = 0 if ///
		strpos(strlower(FFL), "gibson discount center")>0 | ///
		strpos(strlower(FFL), "lathrop")>0 | ///
		strpos(strlower(FFL), "zeroed in")>0 | ///
		strpos(strlower(FFL), "sprague")>0
	labe var count "Count: Guns sold & seized"


	gen ct_legal = count if legal == 1
	lab var ct_legal "Legally imported firearms"
	replace ct_legal = 0 if ct_legal == .
	gen ct_illegal = count if legal == 0
	lab var ct_illegal "Illegally imported firearms"
	replace ct_illegal = 0 if ct_illegal == .
	
	gsort - count
	gen axis = _n
	
	label drop _all
	
	* labmask axis, values(FFL)
	label variable axis "Retailer"
	label values axis axis

	gen ct_chain = count if chain == 1
	lab var ct_chain "Chain store sales"
	gen ct_single = count if chain == 0
	lab var ct_single "Individual store sales"

	* Gen branch stats

	gen ctperbranch = count/ branches
	labe var ctperbranch "Guns per branch"
	gen ct_chainperbrnch = count/branches if chain == 1
	lab var ct_chainperbrnch "Chain store guns per branch"
	gen ct_singleperbrnch = count/branches if chain == 0
	lab var ct_singleperbrnch "Individual store guns per branch"

save "CENAPI-FFL-collapse.dta", replace
	
	* Figure in "Analysis/Visualization" document labeled "Largest sources by FFL, over legal / illegally imported"
use "CENAPI-FFL-collapse.dta", clear
	sort count
	graph hbar ct_legal ct_illegal if count > 14 & count < 2000, ///
		over(axis, lab(angle(0) labsize(tiny))) ///
		bar(1, color(orange)) bar(2, color(midblue)) ///
		stack ylab(,labsize(small)) legend(col(1)order(1 "Legally imported" 2 "Illegally imported") ///
		subtitle("Legend", size(small)) size(vsmall)) graphregion(color(white))

* Illegal FFLs graphed by volume, labeled with NAME, 
	
cd "G:\My Drive\Research\Firearms Economics\Conversation Report\"
use "CENAPI.dta", clear

	* FFL retailer name standardizations
	replace FFL = "Wal-Mart" if strpos(strlower(FFL),"wal-mart")>0
	replace FFL = "Cabela's" if strpos(strlower(FFL),"cabela's")>0
	replace FFL = "Academy" if strpos(strlower(FFL),"academy")>0
	replace FFL = "First Cash Pawn" if strpos(strlower(FFL),"first cash pawn")>0
	replace FFL = "Gibson Discount" if strpos(strlower(FFL),"gibson discount")>0
	replace FFL = "EZPawn" if strpos(strlower(FFL),"ezpawn")>0
	replace FFL = "Turners Outdoorsman" if strpos(strlower(FFL),"turners outdoors")>0
	replace FFL = "Sprague's" if strpos(strlower(FFL),"sprague's")>0
	replace FFL = "Zeroed In Armory" if strpos(strlower(FFL),"zeroed in")>0
	replace FFL = "Andrews Sporting" if strpos(strlower(FFL),"andrews sporting")>0
	replace FFL = "Guns Unlimited" if strpos(strlower(FFL),"guns unlimited")>0
	replace FFL = "Western Firearms" if strpos(strlower(FFL),"western firearms")>0
	replace FFL = "Kmart" if strpos(strlower(FFL),"kmart corporation")>0
	replace FFL = "Big 5" if strpos(strlower(FFL),"big 5")>0
	replace FFL = "Superpawn" if strpos(strlower(FFL),"superpawn")>0
	replace FFL = "RG Industries" if strpos(strlower(FFL),"rg industries")>0
	replace FFL = "Superpawn" if strpos(strlower(FFL),"superpawn")>0
	
	
	drop if FFL == "" | FFL == "N/D" | strlower(FFL) == "<unknown>"
	drop if legal == 1
	collapse (sum) count (first) FFLn branches, by(FFL)
	gen chain = 0
	labe var chain "Chain retailer"
	replace chain = 1 if branches > 1
	replace chain = 1 if ///
		strpos(strlower(FFL), "bass")>0 | ///
		strpos(strlower(FFL), "target gun sales")>0 | ///
		strpos(strlower(FFL), "academy")>0 | ///
		strpos(strlower(FFL), "cabela")>0 | ///
		strpos(strlower(FFL), "wal-mart")>0 | ///
		strpos(strlower(FFL), "big 5")>0 | ///
		strpos(strlower(FFL), "kmart")>0 | ///
		strpos(strlower(FFL), "ezpawn")>0 | ///
		strpos(strlower(FFL), "oshman")>0 | ///
		strpos(strlower(FFL), "turners outdoor")>0 | ///
		strpos(strlower(FFL), "ezpawn")>0 | ///
		strpos(strlower(FFL), "ezpawn")>0
	replace chain = 0 if ///
		strpos(strlower(FFL), "gibson discount center")>0 | ///
		strpos(strlower(FFL), "lathrop")>0 | ///
		strpos(strlower(FFL), "zeroed in")>0 | ///
		strpos(strlower(FFL), "sprague")>0
	labe var count "Count: Guns sold & seized"

	gen ct_chain = count if chain == 1
	lab var ct_chain "Chain store sales"
	gen ct_single = count if chain == 0
	lab var ct_single "Individual store sales"

	* Gen branch stats

	gen ctperbranch = count/ branches
	labe var ctperbranch "Guns per branch"
	gen ct_chainperbrnch = count/branches if chain == 1
	lab var ct_chainperbrnch "Chain store guns per branch"
	gen ct_singleperbrnch = count/branches if chain == 0
	lab var ct_singleperbrnch "Individual store guns per branch"

save "CENAPI-FFL-collapse.dta", replace

	* Figure 5 in "First Draft" document
	use "CENAPI-FFL-collapse.dta", clear		
		replace chain = 1 if ///
		strpos(strlower(FFL), "bass")>0 | ///
		strpos(strlower(FFL), "target gun sales")>0 | ///
		strpos(strlower(FFL), "academy")>0 | ///
		strpos(strlower(FFL), "cabela")>0 | ///
		strpos(strlower(FFL), "wal-mart")>0 | ///
		strpos(strlower(FFL), "big 5")>0 | ///
		strpos(strlower(FFL), "kmart")>0 | ///
		strpos(strlower(FFL), "oshman")>0 | ///
		strpos(strlower(FFL), "turners outdoor")>0 | ///
		strpos(strlower(FFL), "cash america")>0 | ///
		strpos(strlower(FFL), "ezpawn")>0
	replace chain = 0 if ///
		strpos(strlower(FFL), "gibson")>0 | ///
		strpos(strlower(FFL), "lathrop")>0 | ///
		strpos(strlower(FFL), "zeroed")>0 | ///
		strpos(strlower(FFL), "sng tac")>0 | ///
		strpos(strlower(FFL), "sprague")>0

	gen legal = 0
		labe var legal "Firearm legally exported/ obtained from US"
		replace legal = 1 if strpos(strlower(FFL),"secretaria")>0 | ///
	strpos(strlower(FFL),"secreteria")>0 | ///
	strpos(strlower(FFL),"direccion")>0 | ///
	strpos(strlower(FFL),"comisariato")>0 | ///
	strpos(strlower(FFL),"secretaria")>0 | ///
	strpos(strlower(FFL),"sedena")>0 | ///
	strpos(strlower(FFL),"of mexico")>0 | ///
	strpos(strlower(FFL),"confort electrico")>0 | ///
	strpos(strlower(FFL),"mexican military")>0 | ///
	strpos(strlower(FFL),"state of")>0 | ///
	strpos(strlower(FFL),"consulate")>0 | ///
	strpos(strlower(FFL),"estado")>0 | ///
	strpos(strlower(FFL),"mexican state")>0 | ///
	strpos(strlower(FFL),"programa nacional")>0 | ///
	strpos(strlower(FFL),"embassy")>0 | ///
	strpos(strlower(FFL),"banco nacional")>0	
		
	/*
	drop axis*
	label drop _all
	*/
	gsort + legal - count
	gen axis = _n
	
	labmask axis, values(FFL)
	label variable axis "Retailer"
	label values axis axis
	destring FFL, gen(noFFLname)
	graph hbar ct_chain ct_single if ///
		legal == 0 & count > 14 & count < 2000 & ///
		strpos(strlower(FFL), "33-31323")==0  & strpos(strlower(FFL), "h and r")==0, ///
		over(axis, lab(angle(0) labsize(tiny))) ///
		bar(1, color(orange)) bar(2, color(midblue)) ///
		stack ylab(,labsize(small)) legend(col(1)order(1 "Chain sales" 2 "Independent sales") ///
		subtitle("Legend", size(small)) size(vsmall)) graphregion(color(white))

/* 
* Split out by manuf. If  want this, we need to bring
* in <manuf> into the collapse above

	sort count
	graph hbar ct_legal ct_illegal if count > 15 & manuf == 0, ///
		over(axis, lab(angle(0) labsize(tiny))) ///
		bar(1, fcolor(orange)) bar(2, fcolor(midblue)) ///
		stack ylab(,labsize(small)) legend(col(1)order(1 "Legally imported" 2 "Illegally imported") ///
		subtitle("Legend", size(small)) size(vsmall)) graphregion(color(white))

	graph hbar ct_legal if manuf == 0 & count > 0 & ct_legal != ., ///
		over(axis, lab(angle(0) labsize(tiny))) ///
		bar(1, fcolor(orange)) bar(2, fcolor(midblue)) ///
		stack ytitle("Firearms count") ylab(,labsize(small)) legend(col(1)order(1 "Legally imported") ///
		subtitle("Legend", size(small)) size(vsmall)) graphregion(color(white))
		
	graph hbar ct_chain ct_single if count > 15 & manuf == 0 & legal == 0, ///
		over(axis, lab(angle(0) labsize(tiny))) ///
		bar(1, fcolor(orange)) bar(2, fcolor(midblue)) ///
		stack ylab(,labsize(small)) legend(col(1)order(1 "Chain store" 2 "Individual store") ///
		subtitle("Legend", size(small)) size(vsmall)) graphregion(color(white))
		
	gsort - ctperbranch
	gen axis2 = _n
	labmask axis2, values(FFL)
	label variable axis2 "Retailer"
	label values axis2 axis2

	graph hbar ct_chainperbrnch ct_singleperbrnch if count > 15 & manuf == 0 & legal == 0 & ct_FFLbranches != ., ///
		over(axis2, lab(angle(0) labsize(tiny))) ///
		bar(1, fcolor(orange)) bar(2, fcolor(midblue)) ///
		stack ylab(,labsize(small)) legend(col(1)order(1 "Chain store" 2 "Individual store") ///
		subtitle("Legend", size(small)) size(vsmall)) graphregion(color(white))
		
	sum legal
*/

* Obtaining percentage of arms sold from independent vs chain stores
use "CENAPI.dta", clear

	drop if FFL == "" | FFL == "N/D" | strlower(FFL) == "<unknown>"
	drop if legal == 1
	gen chain = 0
	labe var chain "Chain retailer"
	replace chain = 1 if branches > 1
	replace chain = 1 if ///
		strpos(strlower(FFL), "bass")>0 | ///
		strpos(strlower(FFL), "target gun sales")>0 | ///
		strpos(strlower(FFL), "academy")>0 | ///
		strpos(strlower(FFL), "cabela")>0 | ///
		strpos(strlower(FFL), "wal-mart")>0 | ///
		strpos(strlower(FFL), "big 5")>0 | ///
		strpos(strlower(FFL), "kmart")>0 | ///
		strpos(strlower(FFL), "ezpawn")>0 | ///
		strpos(strlower(FFL), "oshman")>0 | ///
		strpos(strlower(FFL), "turners outdoor")>0 | ///
		strpos(strlower(FFL), "ezpawn")>0 | ///
		strpos(strlower(FFL), "ezpawn")>0
	replace chain = 0 if ///
		strpos(strlower(FFL), "gibson discount center")>0 | ///
		strpos(strlower(FFL), "lathrop")>0 | ///
		strpos(strlower(FFL), "zeroed in")>0 | ///
		strpos(strlower(FFL), "sprague")>0
	labe var count "Count: Guns sold & seized"
	
	sum chain
