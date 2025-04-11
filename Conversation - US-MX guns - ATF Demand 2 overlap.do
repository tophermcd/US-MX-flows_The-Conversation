cd "G:\My Drive\Research\Firearms Economics\Conversation Report\"

* Get Demand 2 letter data
	import excel "ATF Demand 2 Letters.xlsx", sheet("Full Data") firstrow clear

		* Cleaning address info in anticipation of merge
	foreach v of varlist FFLaddress FFLcity FFLstate {
		replace `v' = subinstr(strupper( strtrim(`v') ), ".", "", .)
		}
	foreach v of varlist FFLaddress {
		replace `v' = subinstr(strupper( strtrim(`v') ), ".", "", .)
		replace `v' = subinstr(`v',"ROAD","RD",.)
		replace `v' = subinstr(`v',"STREET", "ST",.)
		replace `v' = subinstr(`v',"DRIVE","DR",.)
		replace `v' = subinstr(`v',"BOULEVARD","BLVD",.)
		replace `v' = subinstr(`v',"HIGHWAY","HWY",.)
		replace `v' = subinstr(`v',"AVENUE","AVE",.)
		replace `v' = subinstr(`v',"NORTH","N",.)
		replace `v' = subinstr(`v',"SOUTH","S",.)
		replace `v' = subinstr(`v',"EAST","E",.)
		replace `v' = subinstr(`v',"WEST","W",.)
		replace `v' = subinstr(`v',"SUITE","STE",.)
		replace `v' = subinstr(`v',",","",.)
		replace `v' = subinstr(`v',"#","",.)
		}
	gen FFLaddress_match = subinstr(FFLaddress," ","",.)
	order FFLaddress_match, after(FFLaddress)
	drop if FFLaddress_match == "" | FFLaddress_match == "N/D"
	duplicates drop FFLaddress_match, force
	
	save "Demand2.dta", replace
	
use "CENAPI-USCourt-FFLaddress-collapse.dta", clear
		drop if FFLaddress_match == ""
		duplicates drop FFLaddress_match, force
		merge 1:1 FFLaddress_match using "Demand2.dta"

tab _merge
