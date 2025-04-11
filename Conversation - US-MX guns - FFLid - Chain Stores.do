* Independent FFLs graphed by ADDRESS
	cd "G:\My Drive\Research\Firearms Economics\Conversation Report\"

	
	* Getting US court case data
	use "courtcases.dta", clear
	rename yearsale year

		* Address cleaning
		rename address FFLaddress
		foreach v of varlist FFLaddress citysale{
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

	gen count = 1
	rename longgun ct_longguns
	gen ct_handguns = 0
	replace ct_handguns = 1 if strpos(strlower(type),"pistol") > 0 | ///
		strpos(strlower(type),"revolver") > 0
	/*
	drop if FFLaddress_match == ""
	drop if dblcnt_cenapi == 1
	drop dblcnt_cenapi
	*/
	
	/*
	*** Consider not dropping duplicates to avoid false duplicate dropping. ***
	duplicates drop year FFLaddress_match serialnumber, force
	*/
	
		* FFL name harmonization
		rename 	nameofdistibutor FFL
		replace FFL = strproper(FFL)
		
	save "courtcase_temp.dta", replace
	
	* Merging court cases and CENAPI datasets
	use "CENAPI.dta", clear
	rename state_abbrev state_abbr	
	*rename state_abbrev state_abbr
	
		* Address cleaning
		foreach v of varlist FFLaddress citysale{
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
		capture confirm variable FFLaddress_match
		if _rc == 0 {
			drop FFLaddress_match
			}
		else {
			}
		gen FFLaddress_match = subinstr(FFLaddress," ","",.)
		order FFLaddress_match, after(FFLaddress)
		/*
		rename serialno serialnumber
		rename yearrecov year
		*/
		drop if manuf == 1 | legal == 1

destring year, force replace
	/*
*** Using <append> instead. Possible double counting, but no false duplicate dropping. ***
	duplicates drop year FFLaddress_match serialnumber, force
	merge 1:1 year FFLaddress_match serialnumber using "CENAPI.dta"
	rename _merge merge_cenapi_courtcases
	*/
		append using "courtcase_temp.dta"
		
		* Harmonizing state IDs
		drop state_abbr state_fips
		replace statesale = strtrim(strproper(statesale))
		gen state = statesale
		statastates, n(state)
		drop state
		replace state_abbrev = "PR" if statesale == "Puerto Rico"
		replace state_fips = 72 if statesale == "Puerto Rico"
		drop if _m == 2
		drop _m
		order state_abbrev state_fips, after(statesale)
		
		* Harmonizing names

		replace FFL = "Cabela's" if strpos(strlower(FFL),"cabela")>0
		replace FFL = "Academy" if strpos(strlower(FFL),"academy")>0
		replace FFL = "Keith's Sporting Goods" if strpos(strlower(FFL),"keith's")>0
		replace FFL = "Big 5" if strpos(strlower(FFL),"big 5")>0
		replace FFL = "Zeroed In Armory" if strpos(strlower(FFL),"zeroed in")>0
		replace FFL = "Bass Pro" if strpos(strlower(FFL), "bass")>0
		replace FFL = "Turner's Outdoorsman" if strpos(strlower(FFL), "turner's")>0 | strpos(strlower(FFL), "turners")>0
		replace FFL = "Oshman Sporting" if strpos(strlower(FFL), "oshman")>0
		replace FFL = "Cash America Pawn" if strpos(strlower(FFL), "cash america")>0
		replace FFL = "Kmart" if strpos(strlower(FFL), "kmart")>0
		replace FFL = "Jumbosports" if strpos(strlower(FFL), "jumbosports")>0
		replace FFL = "El Paso Security Academy" if traceno == "T20190206072"
		replace FFL = "City of Columbus Police Training Academy" if traceno == "T20180434735"
		replace FFL = "Kmart" if traceno == "T20200281281"
	
		replace cenapi = 0 if cenapi == .
		replace count = 1
		
	save "CENAPI_UScourt.dta", replace
	erase "courtcase_temp.dta"
	* Collapsing to FFL
	
		* Creating branches and chain variables
		use "CENAPI_UScourt.dta", clear
			* Getting rid of legal imports and manufacturers
			drop if legal == 1 | manuf == 1
			drop manuf legal
			drop if FFL == "" | FFL == "N/D" | strlower(FFL) == "<unknown>" | strpos(strlower(FFL),"33-31323")>0
						* This FFL is long out of business now
			/*
			drop if statesale == "#" | statesale == "N/D"
			*/
			
			duplicates drop FFLaddress_match, force
				
		collapse (sum) count, by(FFL)
		drop if count == 0
		keep count FFL
		rename count branches
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
			strpos(strlower(FFL), "oshman")>0 | ///
			strpos(strlower(FFL), "turners")>0 | ///
			strpos(strlower(FFL), "cash america")>0 | ///
			strpos(strlower(FFL), "ezpawn")>0
		replace chain = 0 if ///
			strpos(strlower(FFL), "gibson discount center")>0 | ///
			strpos(strlower(FFL), "lathrop")>0 | ///
			strpos(strlower(FFL), "zeroed in")>0 | ///
			strpos(strlower(FFL), "sng tac")>0 | ///
			strpos(strlower(FFL), "sprague")>0

		save "CENAPI_UScourt_branches.dta", replace

		use "CENAPI_UScourt.dta", clear
		drop branches
			* Getting rid of legal imports and manufacturers
			drop if legal == 1 | manuf == 1
			drop manuf legal
			drop if FFL == "" | FFL == "N/D" | strlower(FFL) == "<unknown>" | strpos(strlower(FFL),"33-31323")>0
			/*
			drop if statesale == "#" | statesale == "N/D"
			*/

		merge m:1 FFL using "CENAPI_UScourt_branches.dta", keepusing(branches chain)
		drop _merge
		order branches chain, after(FFL)
		labe var count "Count: Guns sold & seized"
			
		* Replacing FFL codes
		encode FFL, gen(FFLnn)
		order FFLnn, after(FFLn)
		drop FFLn
		rename FFLnn FFLn
			
		save "CENAPI_UScourt.dta", replace

		use "CENAPI_UScourt.dta", clear

		gen studystates = 0
		replace studystates = 1 if statesale == "Arizona" | ///
			statesale == "California" | statesale == "Florida" | ///
			statesale == "New Mexico" | statesale == "Texas" | ///
			statesale == "Washington"
			* I'm not including Georgia b/c that pulls up Smyrna, where Glock is located
		gen FFLcity = FFL + ", " + citysale + ", " + state_abbrev
		gen FFLaddresscity = FFLaddress + " " + citysale
		/*
		drop if citysale == ""
		*/
		sort FFLaddresscity
		rename statesale FFLstate

		collapse (count) count (first) studystates chain FFLaddress FFLaddress_match FFLcity FFLaddresscity FFLstate, by(FFL)
			labe var count "Count of guns"
			labe var FFL "Retailer"
				
		save "CENAPI-USCourt-FFLaddress-collapse-chain.dta", replace
			
		** Graph for Chain Stores **
		use "CENAPI-USCourt-FFLaddress-collapse-chain.dta", clear
		/*
		drop axis*
		*/
		label drop _all
			gsort - chain - count
			gen axis2 = _n
			/*
			labmask axis2, values(FFL)
			*/
			label variable axis2 "Retailer"
			label values axis2 axis2
		
			graph hbar ///
				count if count > 14 & chain == 1, ///
				over(axis, lab(angle(0) labsize(small))) ///
				ytitle("Guns Seized") ylab(,labsize(small)) graphregion(margin(l=40) color(white))
