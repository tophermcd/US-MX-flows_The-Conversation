/*
ATF Citation Prediction Analysis:

RQ: Do ATF citations predict which FFLs will contribute to the US-MX arms trade,
and if so, which citation types?

Datasets [unit of analysis: FFL-month]
	ATF FFLs (types 01, 02, and 07)
	ATF Citations (obtained by Brady)
		Citation codes were tabulated separately by The Trace:
			https://projects.thetrace.org/inspections/violation/
	ATF Demand 2 letters (obtained by Brady; not included here)
	CENAPI (effectively December 2018 - October 2022 [though it runs through 11/25/22])
	Court case data
*/

/*
The following code retrieves the dataset of all ATF FFLs

Retrieved monthly (downloaded by year) FFL numbers from the ATF:
https://www.atf.gov/firearms/listing-federal-firearms-licensees

It may not be necessary for our purposes: If we are predicting numbers of
guns seized based on number of citations issued, we may not need any further
data from the FFL registry.
*/

	cd "C:\Users\tlm\Downloads\"
	import delimited "1223-ffl-list.csv", clear varnames(1)
		foreach var of varlist _all {
				local newvar = subinstr("`var'", "_", "", .)
				rename `var' `newvar'
			}
		gen year = .
		gen month = ""
		drop if _n > 0
		save "FFLs.dta", replace
		clear

	forval y = 18/22 {
		foreach m in "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12" {
			if fileexists("`m'`y'-ffl-list.csv") {
				import delimited "`m'`y'-ffl-list.csv", varnames(1)
				
				capture confirm variable year, exact
					if !_rc {
						drop year
						}
					else {
						}
				
				capture confirm variable month, exact
					if !_rc {
						drop month
						}
					else {
						}			
				
				gen year = 2000 + `y'
				gen month = "`m'"

				foreach var of varlist _all {
						local newvar = subinstr("`var'", "_", "", .)
						rename `var' `newvar'
					}
				capture confirm variable lictype, exact
					if !_rc {
						drop if lictype != 1 & lictype != 2 & lictype != 7
						}
					else {
						}
				
				capture confirm variable applictype, exact
					if !_rc {
						rename applictype lictype
						}
					else {
						}
				
				capture confirm variable ïlicregn, exact
					if !_rc {
						rename ïlicregn licregn
						}
					else {
						}
						
				save "FFL_`y'`m'.dta", replace
				use "FFLs.dta", clear
				append using "FFL_`y'`m'.dta", force
				save "FFLs.dta", replace
				erase "FFL_`y'`m'.dta"
				clear
				}
			else
			}
		}
		* Cleaning address info in anticipation of merge
	use "FFLs.dta", clear
	rename premisestreet FFLaddress
	rename premisecity city
	rename premisestate state_abbrev
	rename premisezipcode zip
		* Cleaning address info in anticipation of merge
	foreach v of varlist FFLaddress city state zip {
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
	replace zip = "0" + zip if strlen(zip)==4
	replace zip = substr(zip,1,5) if strlen(zip) > 5

	save "FFLs.dta", replace

	collapse (first) licdist liccnty businessname city state_abbrev licregn (first) lictyp, ///
		by(year FFLaddress_match) // from 3.6m to 404K observations
	drop if FFLaddress_match == "" | FFLaddress_match == "N/D"

	save "FFLs-yr.dta", replace


* Getting Brady's (Gun Safety Transparency Project) GSTP-provided ATF inspection reports
	cd "C:\Users\tlm\Downloads\"
	clear
	import delimited "Working-GSTP Data May 2024 with Links copy.csv", varnames(1) clear

		* Variable cleanup
	rename ïaddressid addressid
	drop v2

	rename dateofmostrecentpreviousinspecti date_previnspec1
	rename dateofotherpreviousinspections_1 date_previnspec2
	rename dateofotherpreviousinspections_2 date_previnspec3

	forval i = 1/3 {
		tostring date_previnspec`i', force replace
		replace date_previnspec`i' = substr(date_previnspec`i',1,4)
		destring date_previnspec`i', force replace
		rename date_previnspec`i' year_previnspec`i'
		}
	rename yearinspected year

		* Renaming all citation variables from their lables (some were misnamed) and shortening
	foreach v of varlist citation18usc923g5a - citation27cfr478122 {
		local label : variable label `v'
		if "`label'" != "" {
			capture rename `v' `=strlower("`label'")'
			}
		}
	foreach v of varlist citation18usc923g5a - citation27cfr478122 {
		rename `v' `=subinstr("`v'","citation","cit_",.)'
		}
		* Generating previous inspection counts
	forval i = 1/3 {
		gen previnspec`i' = 0
		replace previnspec`i' = 1 if year_previnspec`i' != .
		}
	gen previnspec_ct = previnspec1 + previnspec2 + previnspec3
	forval i = 1/3 {
		drop previnspec`i'
		}
	order previnspec_ct, before(year)

		* Cleaning address info in anticipation of merge
	foreach v of varlist streetaddress city state zip {
		replace `v' = subinstr(strupper( strtrim(`v') ), ".", "", .)
		}
	foreach v of varlist streetaddress {
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
	rename streetaddress FFLaddress
	gen FFLaddress_match = subinstr(FFLaddress," ","",.)
	order FFLaddress_match, after(FFLaddress)
	replace zip = "0" + zip if strlen(zip)==4
	replace zip = substr(zip,1,5) if strlen(zip) > 5
	
		* Getting revocations
	encode finaldisposition, gen(findispi)
	gen revoked = 0
	replace revoked = 1 if findispi == 10

		* Collapsing to ensure single entries for merging while not losing citations
		* for possible double-inspections
	collapse (first) addressid recordid link operatorname FFLaddress city state ///
		(max) previnspec_ct (sum) numberofviolations cit_18usc923g5a - cit_27cfr478122 revoked, ///
		by(year FFLaddress_match zip)
	duplicates drop FFLaddress_match year, force
	drop if FFLaddress_match == "" | FFLaddress_match == "N/D"
 	replace revoked = 1 if revoked > 1
	
	statastates, n(state)
	replace state = strproper(strtrim(state))
	replace state_abbrev = "PR" if state == "Puerto Rico"
	replace state_fips = 72 if state == "Puerto Rico"
	drop if _m == 2
	drop _m
	save "GSTP.dta", replace

	* Identifying the citation types
	use "GSTP.dta", clear
	sum cit_18usc923g5a - cit_27cfr478122

	
* Merging ATF records with GSTP (so that we have a full universe of FFLs and no selection bias for the analyses)
* This may be unnecessary depending on the analysis (see note above).
use "FFLs-yr.dta", clear
merge m:1 year FFLaddress_match using "GSTP.dta" // N = 408k
rename _merge merge_FFL_GSTP
	drop state state_fips
	statastates, a(state_abbrev)
	rename state_name state
	replace state = strproper(strtrim(state))
	replace state = "Puerto Rico" if state_abbrev == "PR"
	replace state_fips = 72 if state_abbrev == "PR"
	drop if _m == 2
	drop _m
save "Citation policy.dta", replace


* Getting counts of CENAPI traces by FFL-year

	use "G:\My Drive\Research\Firearms Economics\Conversation Report\CENAPI.dta", clear
	gen ct_allguns = 1
	gen ct_longguns = 0
	replace ct_longguns = 1 if strpos(strlower(type),"carbine") > 0 | ///
		strpos(strlower(type),"machine gun") > 0 | ///
		strpos(strlower(type),"rifle") > 0 | ///
		strpos(strlower(type),"shotgun") > 0
	gen ct_handguns = 0
	replace ct_handguns = 1 if strpos(strlower(type),"pistol") > 0 | ///
		strpos(strlower(type),"revolver") > 0
	rename yearrecov year
	destring year, force replace

	rename citysale city
	rename statesale state
	drop if state == "" | state == "Mx" | state == "Ciudad De Mexico" 

		* Cleaning address info in anticipation of merge
	foreach v of varlist FFLaddress city state {
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

	collapse (first) FFLaddress city state state_fips state_abbrev (sum) ct_allguns ct_longguns ct_handguns, by(year FFLaddress_match) // N = 5,744
	save "cenapi_cts.dta", replace

* Getting counts of court traces traces by FFL-year
	use "G:\My Drive\Research\Firearms Economics\Conversation Report\courtcases.dta", clear

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

	gen ct_allguns = 1
	rename longgun ct_longguns
	gen ct_handguns = 0
	replace ct_handguns = 1 if strpos(strlower(type),"pistol") > 0 | ///
		strpos(strlower(type),"revolver") > 0
	drop if FFLaddress_match == ""
	collapse (first) FFLaddress statesale state_abbr state_fips (sum) ct_allguns ct_longguns ct_handguns, by(year FFLaddress_match) // N = 229
	rename statesale state
	save "courtcase_cts.dta", replace

* Merging court case data with ATF/GTSP citations
clear

use "courtcase_cts.dta", clear
cd "C:\Users\tlm\Downloads\"

merge 1:1 year FFLaddress_match using "cenapi_cts.dta", keepusing(ct_allguns ct_longguns ct_handguns state state_fips state_abbrev)
rename _merge merge_cenapi_courtcases

	drop state_abbr state_fips
	replace state = strtrim(strproper(state))
	statastates, n(state)
	replace state_abbrev = "PR" if state == "Puerto Rico"
	replace state_fips = 72 if state == "Puerto Rico"
	drop if _m == 2
	drop _m
	order state_abbrev state_fips, after(state)

merge 1:1 year FFLaddress_match using "Citation policy.dta"
rename _merge merge_citation_court
	drop state_abbr state_fips
	replace state = strtrim(strproper(state))
	statastates, n(state)
	replace state_abbrev = "PR" if state == "Puerto Rico"
	replace state_fips = 72 if state == "Puerto Rico"
	drop if _m == 2
	drop _m
	order state_abbrev state_fips, after(state)
	
foreach v of varlist ct_allguns ct_longguns ct_handguns {
	replace `v' = 0 if `v' == .
	}
foreach v of varlist cit_18usc923g5a - cit_27cfr478122 {
	replace `v' = 0 if `v' == .
	}
foreach v of varlist cit_18usc923g5a - cit_27cfr478122 {
	replace `v' = 0 if `v' == .
	}
egen numberofviolations2 = rowtotal(cit_18usc923g5a - cit_27cfr478122)
replace numberofviolations = numberofviolations2
drop numberofviolations2
gen cited = 0
replace cited = 1 if numberofviolations >= 1
order cited, after(numberofviolations)
gen numberofviolations_ln = ln(numberofviolations + 1)
order numberofviolations_ln, after(numberofviolations)

gen ct_allguns_ln = ln(ct_allguns + 1)
order ct_allguns_ln, after(ct_allguns)

gen tracedguns = 0
replace tracedguns = 1 if ct_allguns >= 1
order tracedguns, after(ct_allguns_ln)

drop if year == .

save "Citation_trace_merge.dta", replace

	* Encoding address, since there are too many for the <encode> command
use "Citation_trace_merge.dta", clear
collapse (count) year, by(FFLaddress_match)
gen FFLaddressi = _n
drop year
save "Citation_trace_addressencode.dta", replace

use "Citation_trace_merge.dta", clear
merge m:1 FFLaddress_match using "Citation_trace_addressencode.dta", keepusing(FFLaddressi)
drop _merge
order FFLaddressi, after(FFLaddress_match)
xtset FFLaddressi year, yearly

	* Labeling population citations
	labe var cit_27cfr478124c1 "Record purchaser data"
	labe var cit_27cfr47821a "Record all required data"
	labe var cit_27cfr478125e "Maintain records of receipt and disposition"
	labe var cit_27cfr478124c3iv "Record date and response of NICS background check"
	labe var cit_27cfr478124c3i "Proper identification of purchaser"
	labe var cit_27cfr478124c5 "Purchaser signature"
	labe var cit_27cfr478126a "Report multiple purchases w/in 5 business days"
	labe var cit_27cfr478124c4 "Record firearm data (incl. serial number)"
	labe var cit_27cfr478102a "Conduct NICS background check before sale"
	labe var cit_27cfr478124a "Record the transfer of a firearm"
	
	replace state = strtrim(strproper(state))

	save "Citation_trace_merge.dta", replace

/*
	* Filling in missing citation data (with zeroes for citations and traced guns)
		/*
		This is a fraught issue. We provide the code here, but did not report on
		results using the resulting data. Here was the rationale:
		
		Pros:
		
		We ensure that all the stores that were neither cited nor recorded
		as contributing to the traffic are accounted for. This will "balance" things
		back towards the "good actors."
		
		
		Cons:
		
		Cited FFLs must also have been audited in the first place. If 
		the ATF audits randomly, then comparing cited versus non-cited FFLs 
		would not be objectionable. But if they audit based on having cause to 
		suspect something, then filling in zeroes for all these missing entries 
		will compare (presumably) good actors to (allegedly) bad one. A third 
		variable will not have been controlled for. We are unable to control for 
		reasons that prompt auditing (nor even the auditing itself). For this 
		reason, when we tried filling in the data, citations predict more traced 
		guns, rather than fewer traced guns, in a kind of Simpson’s Paradox.
		
		Moreover, we already merged the ATF citations data to the original 
		ATF FFL list – the only authoritative list. If we fill in data based on 
		every possible combination of FFL and year, we will likely be adding 
		observations that never existed: FFLs that exist in our data for years 
		before their founding or after they went out of business.
		
		Finally, the merge process was imperfect. This fillin process will then
		attribute zeroes to all stores whose addresses failed to match perfectly.
		
		All things considered, we have therefore chosen not to use <fillin>.
		*/
		
fillin FFLaddressi year
replace cited = 0 if cited == . & year > 2013 & year < 2019
replace tracedguns = 0 if tracedguns == . & year > 2013 & year < 2019
replace numberofviolations = 0 if numberofviolations == . & year > 2013 & year < 2019
replace numberofviolations_ln = 0 if numberofviolations_ln == . & year > 2013 & year < 2019
foreach v of varlist ///
	cit_27cfr478124c1 cit_27cfr47821a cit_27cfr478125e ///
	cit_27cfr478124c3iv cit_27cfr478124c3i cit_27cfr478124c5 cit_27cfr478126a ///
	cit_27cfr478124c4 cit_27cfr478102a cit_27cfr478124a {
	
	replace `v' = 0 if `v' == . & year > 2013 & year < 2019
	}
*/

	* Deriving p weights
use "Citation_trace_merge.dta", clear
	*Switching drives to the cloud, now that the heavy lifting is done
cd "G:\My Drive\Research\Firearms Economics\Conversation Report\"

rename state statesale
order statesale state_fips, after(state_abbrev)

merge m:1 statesale using "cenapi_f.dta", keepusing(freq_cenapi)
drop if _m == 2
drop _m

merge m:1 statesale using "courtcases_f.dta", keepusing(freq_court)
drop if _m == 2
drop _m

drop if statesale == "#"

gen pw = freq_cenapi /freq_court
labe var pw "Population Weight"

replace revoked = 0 if revoked == . & year > 2014 & year < 2019

save "Citation_trace_merge.dta", replace

