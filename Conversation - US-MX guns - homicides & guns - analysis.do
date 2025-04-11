/*
This is a shallow analysis of time-series data at the country-level in MX
It assesses the relationship between:
	- Homicide rate (1990 - 2021)
	  Source: UNODC via the World Bank
	  https://data.worldbank.org/indicator/VC.IHR.PSRC.P5?locations=MX
	- Our "meta-estimates" of US-MX small arms flows
	  G:\My Drive\Research\Firearms Economics\Conversation Report\US-MX arms writeup tables.xlsx
	  Tab: "Flow Estimates"
	  
	These are manually copied-and-pasted into STATA
*/
cd "G:\My Drive\Research\Firearms Economics\Conversation Report\"

rename low flowest_low
rename med flowest_med
rename high flowest_high
rename httpsdataworldbankorgindicatorvc homiciderate

labe var flowest_low "US-MX trafficking meta-estimate, low"
labe var flowest_med "US-MX trafficking meta-estimate, medium"
labe var flowest_high "US-MX trafficking meta-estimate, high"
labe var homiciderate "Homicide rate (per 100k per year)"

order year, first
destring year, force replace
tsset year, yearly

foreach v of varlist flowest_low flowest_med flowest_high homiciderate {
	gen d_`v' = (`v' - l.`v')/l.`v'
	order d_`v', after(`v')
	local lbl : variable label `v'
	label var d_`v' `"%-age diff in `lbl'"' 
	}
	
foreach v of varlist flowest_low flowest_med flowest_high homiciderate {
	gen l_`v' = ln(`v')
	order l_`v', after(d_`v')
	local lbl : variable label `v'
	label var l_`v' `"Log `lbl'"' 
	}
	
save "homicide-guns.dta", replace

* Regression analysis
use "homicide-guns.dta", clear
tsset year, yearly

	* Straight regressions
reg homiciderate flowest_low
	outreg2 using homicides, label excel replace
reg homiciderate flowest_med
	outreg2 using homicides, label excel append
reg homiciderate flowest_high
	outreg2 using homicides, label excel append

reg homiciderate flowest_low l.homiciderate
	outreg2 using homicides, label excel append
reg homiciderate l.flowest_low l.homiciderate
	outreg2 using homicides, label excel append
reg homiciderate f.flowest_low l.homiciderate
	outreg2 using homicides, label excel append
reg homiciderate l.flowest_low f.flowest_low l.homiciderate
	outreg2 using homicides, label excel append
	
reg flowest_low homiciderate l.flowest_low
	outreg2 using flows, label excel append
reg flowest_low l.homiciderate l.flowest_low
	outreg2 using flows, label excel append
reg flowest_low f.homiciderate l.flowest_low
	outreg2 using flows, label excel append
reg flowest_low l.homiciderate f.homiciderate l.flowest_low
	outreg2 using flows, label excel append
	

	* Log-log regressions
reg l_homiciderate l_flowest_low
	outreg2 using l_homicides, label excel replace
reg l_homiciderate l_flowest_med
	outreg2 using l_homicides, label excel append
reg l_homiciderate l_flowest_high
	outreg2 using l_homicides, label excel append

reg l_homiciderate l_flowest_low l.l_homiciderate
	outreg2 using l_homicides, label excel append
reg l_homiciderate l.l_flowest_low l.l_homiciderate
	outreg2 using l_homicides, label excel append
reg l_homiciderate f.l_flowest_low l.l_homiciderate
	outreg2 using l_homicides, label excel append
reg l_homiciderate l.l_flowest_low f.l_flowest_low l.l_homiciderate
	outreg2 using l_homicides, label excel append
	
reg l_flowest_low l_homiciderate l.l_flowest_low
	outreg2 using l_flows, label excel append
reg l_flowest_low l.l_homiciderate l.l_flowest_low
	outreg2 using l_flows, label excel append
reg l_flowest_low f.l_homiciderate l.l_flowest_low
	outreg2 using l_flows, label excel append
reg l_flowest_low l.l_homiciderate f.l_homiciderate l.l_flowest_low
	outreg2 using l_flows, label excel append
	
	* 3SLS regressions
	* IV: Assault weapons ban
gen awb = 0
replace awb = 1 if year > 1994 & year < 2004

	* Endogeneity controls testing (successful)
reg l_homiciderate l.l_flowest_low
predict lflowres0, res
reg l_homiciderate lflowres0


	* Endogeneity controls testing (successful)
reg l_homiciderate l_flowest_low i.awb
	* Relevant(!):
reg l_flowest_low l_homiciderate i.awb
	predict lflowres, res

reg l_homiciderate l_flowest_low lflowres l.l_homiciderate
	outreg2 using l_homicides, label excel append

	* Relevant, pushing lpguns out of significance
