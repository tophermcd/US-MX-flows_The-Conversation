	** Importing SEDENA/ Armas Entregar
clear

import excel "G:\My Drive\Research\Firearms Economics\Conversation Report\ArmasAseguradasSEDENA2010.1marzo2023.xlsx", sheet("ARMAS ENTREGAR") firstrow clear

* Rename variables
rename DATE daterecov
rename MONTH monthrecov
rename DAY dayrecov
rename YEAR yearrecov
rename STATE staterecov
rename MUNICIPALITY municrecov
rename TYPE type
rename CALIBER caliber
rename MAKE make
rename SERIALNO serialno
rename CANTIDAD quantity
rename MODELO model
rename FOLIO folio
rename ASSAULTWEAPONCalifDefinitio assaultCA
rename Cityofproduction2017 municmanuf
rename State statemanuf
rename Zip zipmanuf
rename Countryofproduction countrymanuf
rename Companywebsitesource corpsite
rename dCityofproduction municmanuf2
rename dStateofProduction statemanuf2
rename dZipofproduction zipmanuf2
rename dcountryofproduction countrymanuf2
drop MaketypecaliberinSEDENAcata
drop ImporterDistributer
rename Comment comment
drop FuentesSolicitudesaSEDENAF

/*
* To see how many records drop in the "Relas Armas" study period
* (03 January 2014 - 31 March 2016):
drop if daterecov < date("1/3/2014","MDY",2050) | daterecov > date("3/31/2016","MDY",2050)
*/

drop if serialno == "NO ESPECIFICADO" | serialno == "SIN MATRICULA" | serialno == "SIN AV. PREV." | serialno == "IN MATRICULA" | serialno == "SIN MATRCULA" | serialno == "SIN MATRICULAS" | serialno == "ILEGIBLE" | serialno == ""
duplicates drop staterecov municrecov serialno caliber make type daterecov, force
save "sedena-recovery_2010-2021.dta", replace

* SEDENA dataset
use "sedena-recovery_2010-2021.dta", clear

	* Manufacturer standardizations
do "Conversation - US-MX guns - manufcorrect.do"


	replace caliber = "" if strpos(strlower(caliber),"sin calibre")>0

* Generating string date to concatenate with serial no. to create matching id variable
	tostring daterecov, gen(daterecov2)
	format daterecov %td

	drop yearrecov
	gen yearrecov = year(daterecov)
	tostring yearrecov, force replace

	gen gunid = serialno + " - " + yearrecov
	drop if serialno == "" | make == "" | yearrecov == ""
	duplicates r gunid

	gen gunid2 = serialno + " - " + make + " - " + daterecov2
	duplicates r gunid2

gen sedena = 1

save "SEDENA.dta", replace

* Get Sedena dataset, create specific gun IDs for matching with Cenapi
/*
do "Conversation - US-MX guns - Sedena- data creation.do"
*/
cd "G:\My Drive\Research\Firearms Economics\Conversation Report\"

use "SEDENA.dta", clear
duplicates drop gunid, force
save "sedena_gunid.dta", replace

use "SEDENA.dta", clear
duplicates drop gunid2, force
save "sedena_gunid2.dta", replace

/*
Looking at SEDENA seizures by year:
use "SEDENA.dta", clear
collapse (sum) quantity, by(staterecov yearrecov)
destring year, force replace
fillin yearrecov staterecov
encode staterecov, gen(stateid)
xtset stateid yearrecov, yearly
replace quantity = 0 if quantity == .
gen qty100 = 100 if year == 2010
forval i = 1/11 {
	replace qty100 = (quantity/ l`i'.quantity) * l`i'.qty100 if l`i'.qty100 != . & qty100 == .
	}
sum stateid
local statenum = r(max)
twoway ///
	(line qty100 yearrecov if stateid == 1, sort) ///
	(line qty100 yearrecov if stateid == 2, sort) ///
	(line qty100 yearrecov if stateid == 3, sort) ///
	(line qty100 yearrecov if stateid == 4, sort) ///
	(line qty100 yearrecov if stateid == 5, sort) ///
	(line qty100 yearrecov if stateid == 6, sort) ///
	(line qty100 yearrecov if stateid == 7, sort) ///
	(line qty100 yearrecov if stateid == 8, sort) ///
	(line qty100 yearrecov if stateid == 9, sort) ///
	(line qty100 yearrecov if stateid == 10, sort) ///
	(line qty100 yearrecov if stateid == 11, sort) ///
	(line qty100 yearrecov if stateid == 12, sort) ///
	(line qty100 yearrecov if stateid == 13, sort) ///
	(line qty100 yearrecov if stateid == 14, sort) ///
	(line qty100 yearrecov if stateid == 15, sort) ///
	(line qty100 yearrecov if stateid == 16, sort) ///
	(line qty100 yearrecov if stateid == 17, sort) ///
	(line qty100 yearrecov if stateid == 18, sort) ///
	(line qty100 yearrecov if stateid == 19, sort) ///
	(line qty100 yearrecov if stateid == 20, sort) ///
	(line qty100 yearrecov if stateid == 21, sort) ///
	(line qty100 yearrecov if stateid == 22, sort) ///
	(line qty100 yearrecov if stateid == 23, sort) ///
	(line qty100 yearrecov if stateid == 24, sort) ///
	(line qty100 yearrecov if stateid == 25, sort) ///
	(line qty100 yearrecov if stateid == 26, sort) ///
	(line qty100 yearrecov if stateid == 27, sort) ///
	(line qty100 yearrecov if stateid == 28, sort) ///
	(line qty100 yearrecov if stateid == 29, sort) ///
	(line qty100 yearrecov if stateid == 30, sort) ///
	(line qty100 yearrecov if stateid == 31, sort) ///
	(line qty100 yearrecov if stateid == 32, sort)
	
*/
