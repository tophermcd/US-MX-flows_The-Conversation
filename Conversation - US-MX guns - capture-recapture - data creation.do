				*** Dataset Creation: gunid.dta ***
* Datasets used:
	* Sedena [Copia de 698_0001700205819_Armas_2010 al 31 May 2019.xlsx]
	* Cenapi (FGR) [Is this what John refers to as the Fiscalia dataset?]
		* [Armas Rastreadas en territorio nacional 011218 a 201019 SEDENA.xlsx Tab: Pais de Fabricacion EUA]
		* [Armas Rastreadas en territorio nacional 011218 a 201019 SEDENA.xlsx Tab: Importacion Estados Unidos]
	* Court cases?
	/*
	It seems a priori that since basis of selection for US court cases is independent
	from those SEDENA or CENAPI, but the latter are not independent of one another,
	US court cases should be used on both the MX datasets.
	
	However, there is only one matching record between SEDENA and the US Court Case 
	data, making that very unreliable.
	
	*/
cd "G:\My Drive\Research\Firearms Economics\Conversation Report\"

* Court dataset (must have already run the Survival Analysis data prep above!!)
use "courtcases.dta", clear

	* Serial numbers only
		replace serialnumber = "" if strpos(serialnumber,"removed")>0 | strpos(serialnumber,"obliter")>0 | strpos(serialnumber,"altered")>0
		replace serialnumber = "" if strpos(serialnumber,"nknown")>0
	* Manufacturer standardizations
do "Conversation - US-MX guns - manufcorrect.do"
		
	* Generate gun ID
		tostring daterecov, gen(daterecov2)
		format daterecov %td
		gen yearrecov = year(daterecov)
		tostring yearrecov, force replace
		gen gunid = serialnumber + " - " + yearrecov
		drop if serialnumber == ""
		drop if daterecov2 == "" | daterecov2 == "."
		duplicates drop gunid, force
		
	gen uscourt = 1

save "court_gunid.dta", replace
	
* Capture - recapture analysis

use "sedena_gunid.dta", clear
merge 1:1 gunid using "cenapi_gunid.dta"
	replace cenapi = 0 if cenapi != 1
	replace sedena = 0 if sedena != 1
drop _m
merge 1:1 gunid using "court_gunid.dta"
	replace uscourt = 0 if uscourt != 1

order sedena cenapi uscourt, last

sum daterecov if cenapi == 1
	global cenapimin = r(min)
	global cenapimax = r(max)

display "Minimum CENAPI date: " %td $cenapimin
display "Maximum CENAPI date: " %td $cenapimax

sum daterecov if sedena == 1
	global sedenamin = r(min)
	global sedenamax = r(max)

display "Minimum SEDENA date: " %td $sedenamin
display "Maximum SEDENA date: " %td $sedenamax

sum daterecov if uscourt == 1
	global uscourtmin = r(min)
	global uscourtmax = r(max)

display "Minimum US court date: " %td $uscourtmin
display "Maximum US court date: " %td $uscourtmax

	* Cenapi - US Court (CUS) analysis
	global CUSmaxmin = max($cenapimin, $uscourtmin)
	global CUSminmax = min($cenapimax, $uscourtmax)

	gen CUSstudyperiod = 0
	replace CUSstudyperiod = 1 if daterecov > $CUSmaxmin & daterecov < $CUSminmax

	* Sedena - US Court (SUS) analysis
	global SUSmaxmin = max($cenapimin, $uscourtmin)
	global SUSminmax = min($cenapimax, $uscourtmax)

	gen SUSstudyperiod = 0
	replace SUSstudyperiod = 1 if daterecov > $SUSmaxmin & daterecov < $SUSminmax

	* Cenapi - Sedena (CS) analysis
	global CSmaxmin = max($cenapimin, $sedenamin)
	global CSminmax = min($cenapimax, $sedenamax)

	gen CSstudyperiod = 0
	replace CSstudyperiod = 1 if daterecov > $CSmaxmin & daterecov < $CSminmax

save "gunid.dta", replace
