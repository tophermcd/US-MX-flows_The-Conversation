				*** POLICE ARMS DATA COLLECTION 1 ***
/*
Using the "base calibre" dataset of Mexican police purchases
*/

cd "G:\My Drive\Research\Firearms Economics\Conversation Report\"
clear
import excel "C:\Users\tlm\Downloads\base calibre for stata.xlsx", sheet("para enviar 2009 2019") firstrow

gen StMun = State + " - " + Municipality
order StMun, after(Municipality)
gen StMunCal = State + " - " + Municipality + " + " + Caliber
order StMunCal, after(Caliber)
duplicates drop

reshape long Guns, i(StMunCal) j(Year)
drop if StMunCal == " -  + "
rename Guns guns
rename Year year
rename State state
replace state = (ustrregexra(ustrnormalize(state,"nfd"),"\p{Mark}",""))
rename Municipality municipality
replace municipality = (ustrregexra(ustrnormalize(municipality,"nfd"),"\p{Mark}",""))
rename Caliber caliber
replace caliber = "" if caliber == "SIN CALIBRE"
replace caliber = substr(caliber,1,strpos(caliber," MM.")-1) + " mm" if substr(caliber,-4,4) == " MM."
replace caliber = substr(caliber,1,strpos(caliber," mm.")-1) + " mm" if substr(caliber,-4,4) == " mm."
replace StMunCal = state + " - " + municipality + " + " + caliber

save "sedena seizure nos by caliber 2009-2018.dta", replace
use "sedena seizure nos by caliber 2009-2018.dta", clear
* date, state, municipality, caliber, guns, year
clear

* Manual corrections to file in year: "209"-->"2009"; "2915" --> "2015", "211" --> "2011"; item 2199 --> 6/28/2011; item 5554 --> 3/26/2013; entry 683 --> year = 2008;  
import excel "C:\Users\tlm\Downloads\ArmasPolicias2006.2018.master.xlsx", sheet("Consolidated Armas") firstrow

drop T - AM

rename Mes month
	labe var month "Order month"
rename Dia day
	labe var day "Order day"
rename Año year
	labe var year "Order year"
rename Fecha date
	labe var date "Order date"
rename NoPiezas guns
	labe var guns "Number of guns ordered"
rename Calibre caliber
	labe var caliber "Caliber"
	replace caliber = strtrim(caliber)
	replace caliber = "5.56 x 45 mm" if caliber == "5.56 x 45mm"
rename Estado state
	labe var state "State of purchaser"
	replace state = strupper(ustrregexra(ustrnormalize(state,"nfd"),"\p{Mark}",""))
	replace state = "ESTADO DE MEXICO" if state == "ESTADO MEXICO"
	replace state = "CIUDAD DE MEXICO" if state == "CDMX"
rename CorporaciónMunicipio municipalgov
	labe var municipalgov "Municipal Government"
rename Costo cost
	labe var cost "Cost"
	destring cost, force replace
	destring guns, force replace
	replace guns = -1 * guns if guns < 0
rename Pag page
	labe var page "Source page number"
rename Nombredocumento docnum
	labe var docnum "Source document number"
rename Personaqmetedatos coder
	labe var coder "Researcher/ coder name"
	replace coder = strtrim(coder)
	replace coder = "John Lindsay-Poland" if coder == "John"
	replace coder = "Laura Carlsen" if coder == "Laura"
rename TipoPistolaRevolverRifleFus type
	labe var type "Firearm type"
	replace type = "Assault rifle" if strpos(strlower(type),"fusil de asalto") > 0
	replace type = "Tactical rifle" if strpos(strlower(type),"fusil tactico") > 0
	replace type = "Sniper rifle" if strpos(strlower(type),"fusil sniper") > 0
	replace type = "Rifle" if strpos(strlower(type),"fusil") > 0 | strpos(strlower(type),"rifle") > 0
	replace type = "Machine pistol" if strpos(strlower(type),"pistola ametrall") > 0
	replace type = "Submachine pistol" if strpos(strlower(type),"pistola subametrall") > 0
	replace type = "Pistol" if strpos(strlower(type),"pistol") > 0
	replace type = "Carbine" if strpos(strlower(type),"carabin") > 0
	replace type = "Submachine gun" if strpos(strlower(type),"submetralleta") > 0 | strpos(strlower(type),"subametrall") > 0
	replace type = "Machine gun" if strpos(strlower(type),"metralleta") > 0
	replace type = "Shotgun" if strpos(strlower(type),"escopeta") > 0
	replace type = "Revolver" if strpos(strlower(type),"revolver") > 0
	replace type = "Grenade launcher" if strpos(strlower(type),"lanza de grana") > 0
	replace type = "Multiple launcher" if strpos(strlower(type),"multilanzador") > 0
	replace type = "Single launcher" if strpos(strlower(type),"lanzador") > 0

export excel using "G:\My Drive\Research\Firearms Economics\Conversation Report\sedena arms counts.xlsx", firstrow(variables) replace

save "police arms ordered.dta", replace

	* Bringing in Stop U.S. Arms to Mexico's new data (2019 - 2023)
import excel "Facturas-SEDENA-2019-2023-web.xlsx", sheet("FacturasReceipts") firstrow clear
	foreach var of varlist * {
	  rename `var' `=strlower("`var'")'
	}

/*
	MERGE with SEDENA (state-year UoA)
	
	This approach only allows us to relate police orders to seizures by date of
	arms purchased in the former case to date of arms seized in the latter.
	The CENAPI also doesn't permit such a merge. The court cases dataset would,
	but is too small to all for this analysis.
*/

/*
use "police arms ordered.dta", clear
* date, state, brand, type, number, caliber, date
* common fields: state, year, caliber, cost
export excel using "G:\My Drive\Research\Firearms Economics\Conversation Report\police arms ordered.xlsx", firstrow(variables) replace
*/

use "police arms ordered.dta", clear
collapse (sum) guns (mean) cost, by(state year)
drop if state == ""
save "policeNos_styr.dta", replace

use "sedena seizure nos by caliber 2009-2018.dta", clear
rename guns seizures
collapse (sum) seizures, by(state year)
save "seizures_styr.dta", replace

merge 1:1 state year using "policeNos_styr.dta", keepusing(guns cost)
* matched n of 280
encode state, gen(stateid)
replace guns = 0 if guns == . & year > 2005 & year < 2018
replace cost = 0 if cost == . & year > 2005 & year < 2018
rename guns pguns
rename cost pguncost
replace seizures = 0 if seizures == . & year > 2008 & year < 2019

gen lpguns = ln(pguns + 1)
gen lpguncost = ln(pguncost + 1)
gen lseizures = ln(seizures + 1)

/* Other variables:
encode caliber, type, etc before collapsing?
 */

* Generating IV after Viridiana Rios
* National presidential political control variable
gen partyp = "PAN"
replace partyp = "PRI" if year > 2012 & year < 2019
replace partyp = "MORENA" if year > 2018

save "seizures_styr.dta", replace

* State-level gubernatorial political control variable
import excel "MX-political-parties.xlsx", sheet("Gubernatorial") firstrow clear
rename State state
reshape long gub, i(state) j(year)
labe var gub "Gubernatorial control"

save "st-gov-parties.dta", replace

use "seizures_styr.dta", clear

capture confirm variable _merge
if !_rc {
                       drop _merge
               }
               else {
                       
               }

merge 1:1 state year using "st-gov-parties.dta", keepusing(gub)
drop if _m == 2

rename gub partyg

gen partyconflict = 1
replace partyconflict = 0 if partyp == partyg
replace partyconflict = 0 if partyp == "PAN" & partyg == "PRD"
labe var partyconflict "National/state party split"

encode partyg, gen(partygn)
encode partyp, gen(partypn) label(partygn)

save "seizures_styr.dta", replace
