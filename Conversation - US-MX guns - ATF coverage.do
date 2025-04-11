/*
This analysis examines (y) number of Mexican guns coming from US ATF divisions
as a function of (a) number of ATF inspection offices, and (b) FFLs per division


Could nab <Conversation - US-MX guns - FFLid - Ind Stores.do>
HOWEVER: Neither CENAPI nor the US Court Case dataset have counties.

Therefore, we may have to use <atf div by county foia request pde 8-1-24 v3.csv>
to correspond to counties (though they won't have ATF inspection offices in all
municipalities)

They will need to be joined, though, on the basis of cities, because CENAPI
and US Court Case data don't have counties. Then the ATF division file will allow
us to collapse by region
*/
cd "G:\My Drive\Research\Firearms Economics\Conversation Report\"

	
	* FIPS Translator
		import delimited "fips-by-state.csv", varnames(1) clear
		tostring fips, force replace
		replace fips = "0" + fips if length(fips)==4
		gen state_fips = substr(fips,1,2)
		gen cnty_fips = substr(fips,3,3)
		rename state state_abbrev
		rename name cnty_name
		save "fips.dta", replace
		
		/*
		use "fips.dta", clear
		*/
		
		collapse (first) state_abbrev, by(state_fips)
		insobs 1
		replace state_abbrev = "PR" in 52
		replace state_fips = "72" in 52
		save "state_fips.dta", replace

	* CONTROL: FFLs (as a proxy for sales)
		import excel "C:\Users\tlm\Downloads\0124-ffl-list-complete.xlsx", sheet("Sheet1") firstrow clear
		keep if LIC_TYPE == "01" | LIC_TYPE == "02"
		rename LIC_CNTY cnty_fips
		rename PREMISE_STATE state_abbrev
		rename PREMISE_CITY city
		merge m:1 state_abbrev using "st_fips.dta", keepusing(state_fips)
		drop if _m == 2
		drop _m
		order state_fips, after(state_abbrev)

		merge m:1 state_fips cnty_fips using "fips.dta", keepusing(cnty_name)
		drop if _m == 2
		drop _m
		order cnty_name, before(cnty_fips)
		save "FFLs_2024.dta", replace
		
		/*
		use "FFLs_2024.dta", clear
		*/
		
		* Collapsing to get numbers of FFLs per county
		gen FFLs = 1
		collapse (sum) FFLs (first) LIC_REGN LIC_DIST cnty_name state_abbrev, by(state_fips cnty_fips)
		save "CountyFFLs_2024.dta", replace


	* PREDICTOR: ATF field offices
		import delimited "atf div by county foia request pde 8-1-24 v3.csv", varnames(1) clear
		drop v5
		replace state = "California" if strpos(county,"Los Angeles") > 0
		replace state = "New York" if state == "NewYork"
		statastates, n(state)
		replace state_abbrev = "PR" if strlower(state) == "puerto rico"
		replace state_fips = 72 if strlower(state) == "puerto rico"
		replace state = strproper(state)
		drop _m
		order state_abbrev state_fips county atfceoffice, after(state)
		rename county cnty_name
		replace atfceoffice = "WILKES-BARRE" if atfceoffice == "WILKESâBARRE"
		replace atfceoffice = "WORCESTER" if atfceoffice == "WORCHESTER"

		gen atfoffices = 1
		gen length1 = length(atfceoffice)
		gen noamp = subinstr(atfceoffice, "&", "", .)
		generate length2 = length(noamp)
		gen ampcount = length1 - length2
		replace atfoffices = atfoffices + ampcount
		drop length1 noamp length2 ampcount
		
		replace atfdivision = strproper(atfdivision)
		replace atfceoffice = strproper(atfceoffice)
		
		replace atfceoffice = subinstr(atfceoffice,"1"," I",.)
		replace atfceoffice = subinstr(atfceoffice," Iii"," III",.)
		replace atfceoffice = subinstr(atfceoffice," Ii"," II",.)
		replace atfceoffice = subinstr(atfceoffice," i"," I",.)
		replace atfceoffice = subinstr(atfceoffice," Iv"," IV",.)
		replace atfceoffice = subinstr(atfceoffice," Viii"," VIII",.)			
		replace atfceoffice = subinstr(atfceoffice," Vii"," VII",.)			
		replace atfceoffice = subinstr(atfceoffice," Vi"," VI",.)			
		replace atfceoffice = substr(atfceoffice,1,length(atfceoffice) - 1) if substr(atfceoffice,-1,1)== "v"
		replace atfceoffice = substr(atfceoffice,1,strpos(atfceoffice,"&")-1) if strpos(atfceoffice,"&")>0
		replace atfceoffice = strtrim(atfceoffice)
		replace atfceoffice = "Kansas City I" if atfceoffice == "Kansas Cityl"
		replace atfceoffice = "Kansas City III" if atfceoffice == "Kansas Cityiii"
		replace atfceoffice = "Phoenix I" if atfceoffice == "Phoenixl"
		replace atfceoffice = "New York VI" if atfceoffice == "Newyorkvi"
		replace atfceoffice = "Lubbock I" if atfceoffice == "Lubbockl"
		replace atfceoffice = "Lubbock I" if atfceoffice == "Lubbocki"
		replace atfceoffice = "Fort Myers" if atfceoffice == "Ft Myers"
		replace atfceoffice = "El Paso" if atfceoffice == "El Paso" | atfceoffice == "Eipaso I"
		replace atfdivision = "Kansas City" if strpos(atfdivision,"Kansas City")>0
		
		tostring state_fips, force replace
		replace state_fips = "0" + state_fips if length(state_fips)== 1
		merge m:1  state_fips cnty_name using "fips.dta", keepusing(cnty_fips)
		drop if _m == 2
		drop _m
		order cnty_fips, after(cnty_name)
		
		save "atf_div_county_office.dta", replace

		
		* Collapsing to get number of offices per ATF division
		use "atf_div_county_office.dta", clear
		duplicates drop atfceoffice, force
		encode atfceoffice, gen(atfceofficen)
		collapse (count) atfceofficen , by(atfdivision)
		rename atfceofficen atfoffices
		labe var atfoffices "Number of ATF Field Offices"
		
		save "ATF_offices_by_division.dta", replace
		
		* Collapsing by county to get 1:1 ATF division to county
		use "atf_div_county_office.dta", clear
		duplicates drop state_fips cnty_fips, force
		
		save "Counties_by_ATF_Division.dta", replace
	
		* Merging county-wise FFLs with ATF divisions above
		use "CountyFFLs_2024.dta", clear
			drop if state_fips == ""
			* Get division by county from above
		merge 1:1 state_fips cnty_fips using "Counties_by_ATF_Division.dta", keepusing(atfdivision)
			drop if _m == 2
			drop _m
		save "CountyFFLs_2024_ATFdiv.dta", replace
		
		
		
	* OUTCOME: Bringing in "CENAPI_UScourt.dta" for merging via the above with counties (still via cities for now)

			* Collapsing ATF office data by city to get 1:1 county to city
			use "atf_div_county_office.dta", clear
				replace atfceoffice = subinstr(atfceoffice," I","",.)
				replace atfceoffice = subinstr(atfceoffice," III","",.)
				replace atfceoffice = subinstr(atfceoffice," II","",.)
				replace atfceoffice = subinstr(atfceoffice," I","",.)
				replace atfceoffice = subinstr(atfceoffice," IV","",.)
				replace atfceoffice = subinstr(atfceoffice," VIII","",.)			
				replace atfceoffice = subinstr(atfceoffice," VII","",.)			
				replace atfceoffice = subinstr(atfceoffice," VI","",.)			
			
			duplicates drop state_fips cnty_fips atfceoffice, force
			rename atfceoffice city

			save "ATF_city_county.dta", replace
	
			use "CENAPI_UScourt.dta", clear
				* Use only after having created this via "Conversation - US-MX guns - FFLid - Ind Stores.do"
			replace citysale = strproper(citysale)
			rename citysale city
			collapse (sum) count (first) statesale state_abbrev state_fips, by(city)
			rename count guns
			tostring state_fips, force replace
			replace state_fips = "0" + state_fips if length(state_fips)== 1
			
			save "gunsbycity.dta", replace
			
			use "ATF_city_county.dta", clear
				drop if city == ""
				drop if cnty_fips == ""
				drop if state_fips == ""
			duplicates drop city state_fips, force
			merge 1:1 city state_fips using "gunsbycity.dta", keepusing(guns statesale state_abbrev state_fips)
			drop if _m != 3
			drop _m
			order guns atfoffices, first
			
			save "atf_coverage.dta", replace

		* Collapsing by ATF Division
			use "atf_coverage.dta", clear
			merge m:1 state_fips cnty_fips using "CountyFFLs_2024_ATFdiv.dta", keepusing(FFLs LIC_REGN LIC_DIST)
			rename _m merge_coverage_FFLs		
			collapse (sum) guns atfoffices FFLs (first) LIC_REGN LIC_DIST, by(atfdivision)

			gen lguns = ln(guns + 1)
			gen latfoffices = ln(atfoffices + 1)
			gen lFFLs = ln(FFLs + 1)
			
			xtile quart_FFL = FFLs, nq(4)
			xtile quart_ATF = atfoffices, nq(4)
			xtile bin_FFL = FFLs, nq(2)
			xtile bin_ATF = atfoffices, nq(2)

			drop if atfdivision == ""
			
			gen proximityrank = 4
			replace proximityrank = 1 if atfdivision == "Los Angeles" | ///
				atfdivision == "Phoenix" | ///
				atfdivision == "Dallas" | ///
				atfdivision == "Houston"
			replace proximityrank = 2 if atfdivision == "San Francisco" | ///
				atfdivision == "Denver" | ///
				atfdivision == "Kansas City" | ///
				atfdivision == "New Orleans"
			replace proximityrank = 3 if atfdivision == "Seattle" | ///
				atfdivision == "St Paul" | ///
				atfdivision == "Chicago" | ///
				atfdivision == "Columbus" | ///
				atfdivision == "Louisville" | ///
				atfdivision == "Nashville"
				
			gen ratio_FFLs_ATF = FFLs/ atfoffices
			destring LIC_REGN, force replace
			
			labe var atfdivision "ATF Division"
			labe var guns "Number of Firearms Recovered in US-Mexico Traffic"
			labe var atfoffices "Number of ATF Field Offices"
			labe var FFLs "Number of Firearms Retailers"
			labe var LIC_REGN "ATF Region Number"
			labe var LIC_DIST "ATF District"
			labe var lguns "Log Firearms Recovered in US-Mexico Traffic"
			labe var latfoffices "Log Number of ATF Field Offices"
			labe var lFFLs "Log Number of Firearms Retailers"
			labe var proximityrank "Geographic Proximity Rank to Mexico"
			
			save "atf_coverage_divisions.dta", replace

		/*
		* Collapsing by ATF Regions
			use "atf_coverage.dta", clear
			merge m:1 state_fips cnty_fips using "CountyFFLs_2024.dta", keepusing(FFLs LIC_REGN LIC_DIST)
			rename _m merge_coverage_FFLs		
			collapse (sum) guns atfoffices FFLs, by(LIC_REGN)
			drop if LIC_REGN == ""
			
			gen lguns = ln(guns + 1)
			gen latfoffices = ln(atfoffices + 1)
			gen lFFLs = ln(FFLs + 1)
								
			drop if LIC_REGN == ""
 			save "atf_coverage_regions.dta", replace
		*/
			
	*** Analysis? ***
		* By ATF Divisions
			use "atf_coverage_divisions.dta", clear
			
			twoway ///
				(scatter guns proximityrank, ytitle("Number of firearms", margin(l=-5))) ///
				(lowess guns proximityrank), ///
				xlabel(,labsize(small)) ylabel(,labsize(small)) graphregion(margin(l=10)color(white)) legend(size(vsmall))
			
			
			scatter guns atfoffices if proximityrank == 1
			scatter guns FFLs if proximityrank == 1
			scatter guns proximityrank

			nbreg guns proximity
				outreg2 using nb_atfcoverage, label addstat(Pseudo R-squared, `e(r2_p)') excel replace
			nbreg guns FFLs proximity
				outreg2 using nb_atfcoverage, label addstat(Pseudo R-squared, `e(r2_p)') excel append
			nbreg guns atfoffices proximity
				outreg2 using nb_atfcoverage, label addstat(Pseudo R-squared, `e(r2_p)') excel append
			nbreg guns atfoffices FFLs proximity
				outreg2 using nb_atfcoverage, label addstat(Pseudo R-squared, `e(r2_p)') excel append
			nbreg guns c.atfoffices##c.FFLs proximity
				outreg2 using nb_atfcoverage, label addstat(Pseudo R-squared, `e(r2_p)') excel append

			margins, at(FFLs = (0(50)600)) over(bin_ATF)
			marginsplot
				
				
				
			reg lguns proximity
				outreg2 using lnatfcoverage, label excel replace
			reg lguns lFFLs proximity
				outreg2 using lnatfcoverage, label excel append
			reg lguns latfoffices proximity
				outreg2 using lnatfcoverage, label excel append
			reg lguns latfoffices lFFLs proximity
				outreg2 using lnatfcoverage, label excel append
			reg c.lguns##c.latfoffices lFFLs proximity
				outreg2 using lnatfcoverage, label excel append
	
			margins, at(lFFLs = (1.75(.25)6.25)) over(bin_ATF)
			marginsplot, ytitle("Predicted Log Firearms") graphregion(color(white))
