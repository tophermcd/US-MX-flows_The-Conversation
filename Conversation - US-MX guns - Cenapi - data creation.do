/*
The CENAPI datset contains trace information on guns seized by MX authorities
and traced by the ATF to US FFLs
	* Cenapi (FGR) [Is this what John refers to as the Fiscalia dataset?]. Here, we combine:
		* [Armas Rastreadas en territorio nacional 011218 a 201019 SEDENA.xlsx Tab: Pais de Fabricacion EUA]
		* [Armas Rastreadas en territorio nacional 011218 a 201019 SEDENA.xlsx Tab: Importacion Estados Unidos]
	*/

cd "G:\My Drive\Research\Firearms Economics\Conversation Report\"

clear
import delimited "CENAPI-usmanuf.csv", delimiter(comma) varnames(1) clear


save "CENAPI-usmanuf.dta", replace

clear
import delimited "CENAPI-usimp.csv", delimiter(comma) varnames(1) clear
append using "CENAPI-usmanuf.dta"

save "CENAPI.dta", replace


use "CENAPI.dta", clear

drop v*
	* Translating variable names
rename numeroderastreo traceno
	labe var traceno "Trace number"
rename numerodeserie serialno
	labe var serialno "Serial number"
	replace serialno = "" if strpos(strlower(serialno),"none")>0
rename calibres caliber
	labe var caliber "Caliber"
rename modelo model
	labe var model "Weapon model"
rename fabricanteomarca make
	labe var make "Make"
rename tipo type
	labe var type "Firearm type"
	replace type = "Assault rifle" if strpos(strlower(type),"fusil de asalto") > 0
	replace type = "Tactical rifle" if strpos(strlower(type),"fusil tactico") > 0
	replace type = "Sniper rifle" if strpos(strlower(type),"fusil sniper") > 0
	replace type = "Rifle" if strpos(strlower(type),"fusil") > 0 | strpos(strlower(type),"rifle") > 0
	replace type = "Machine pistol" if strpos(strlower(type),"pistola ametrall") > 0
	replace type = "Submachine pistol" if strpos(strlower(type),"pistola subametrall") > 0
	replace type = "Pistol" if strpos(strlower(type),"pistol") > 0 | strpos(strlower(type),"derringer") > 0
	replace type = "Carbine" if strpos(strlower(type),"carabin") > 0
	replace type = "Submachine gun" if strpos(strlower(type),"submetralleta") > 0 | strpos(strlower(type),"subametrall") > 0
	replace type = "Machine gun" if strpos(strlower(type),"metralleta") > 0 | strpos(strlower(type),"ametralladora")
	replace type = "Shotgun" if strpos(strlower(type),"escopeta") > 0
	replace type = "Revolver" if strpos(strlower(type),"revolver") > 0
	replace type = "Grenade launcher" if strpos(strlower(type),"lanza") > 0
	replace type = "Multiple launcher" if strpos(strlower(type),"multilanzador") > 0
	replace type = "Frame" if strpos(strlower(type),"armazon") > 0
	replace type = "Destructive device" if strpos(strlower(type),"aparato destructor") > 0
	replace type = "N/D" if strpos(strlower(type),"tipo descon") > 0
rename clasificación class
	labe var class "Weapon class"
rename paísdeorigendelarma countryoforigin
	labe var countryoforigin "Country of origin"
rename ciudaddeldistribuidor citysale
	labe var citysale "US city of sale"
rename estadodeldistribuidor statesale
	labe var statesale "US state of sale"
	replace statesale = strproper(strtrim(statesale))
rename paísdeldistribuidor countrysale
	labe var countrysale "Country of sale"
	replace countrysale = "USA"
rename fechaderecuperación daterecov
	labe var daterecov "Date of recovery"
rename importador importer
	labe var importer "Importer"
rename nombredeldistribuidor FFL
	labe var FFL "Retailer Name"
rename calledelconcecionario FFLaddress
	labe var FFLaddress "Retailer Address"

	* Manufacturer standardizations
do "Conversation - US-MX guns - manufcorrect.do"

replace serialno = "" if strpos(strlower(serialno),"none")>0

* Generating firearm/ gun ID
gen daterecov2 = date(daterecov,"MDY",2024)
format daterecov2 %td
drop daterecov
rename daterecov2 daterecov

tostring daterecov, gen(daterecov2)

gen yearrecov = year(daterecov)
tostring yearrecov, force replace

gen gunid = serialno + " - " + yearrecov
drop if serialno == "" | make == "" | yearrecov == ""
duplicates r gunid

gen gunid2 = serialno + " - " + make + " - " + daterecov2
duplicates r gunid2

gen cenapi = 1

save "CENAPI.dta", replace

* Get Cenapi dataset, create specific gun IDs for matching with Sedena
	
use "CENAPI.dta", clear
duplicates drop gunid, force
save "cenapi_gunid.dta", replace

use "CENAPI.dta", clear
duplicates drop gunid2, force
save "cenapi_gunid2.dta", replace



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
	replace FFL = "Kmart" if strpos(strlower(FFL),"kmart")>0
	replace FFL = "Big 5" if strpos(strlower(FFL),"big 5")>0
	replace FFL = "Superpawn" if strpos(strlower(FFL),"superpawn")>0
	replace FFL = "RG Industries" if strpos(strlower(FFL),"rg industries")>0
	replace FFL = "Superpawn" if strpos(strlower(FFL),"superpawn")>0
	replace FFL = "El Paso Security Academy" if traceno == "T20190206072"
	replace FFL = "City of Columbus Police Training Academy" if traceno == "T20180434735"
	replace FFL = "Kmart" if traceno == "T20200281281"

	
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
