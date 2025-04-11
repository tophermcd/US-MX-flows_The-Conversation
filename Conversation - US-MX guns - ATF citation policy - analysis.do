* Analyzing numbers of traced guns (y) as a function of ATF citations (x)
* Generating basic findings, years 2015 - 2018 (limited by Brady violations data)
	* Note on dates: Brady has suggested excluding 2014
cd "G:\My Drive\Research\Firearms Economics\Conversation Report\"
use "Citation_trace_merge.dta", clear
xtset FFLaddressi year, yearly

/*
* Side analysis: What percentage of FFLs in our data show up in Brady records?
collapse (first) merge_citation_court (sum)freq_court freq_cenapi, by(FFLaddress_match)
	* This merge variable originally came from this command using combined 
	* cenapi/ US court case data
	* (Conversation - US-MX guns - ATF citation policy - data creation.do):
		* merge 1:1 year FFLaddress_match using "Citation policy.dta"
	* Therefore:
label values merge_citation_court _merge
tab merge_citation_court if merge_citation_court != 2
	* Yields: 7.5%
*/
	
	* Percentage of FFLs cited by the ATF in any given year:
	sum cited if year > 2014 & year < 2019 & revoked == 0
	sum numberofviolations if year > 2014 & year < 2019 & revoked == 0 & cited == 1

	* Chi-square test
	tabulate cited tracedguns if year > 2014 & year < 2019 & revoked == 0, chi2 row exact

	
	* FE Models (can't be lagged)
		* Logistic regression w/ FE
		xtlogit tracedguns cited if year > 2014 & year < 2019 & revoked == 0, fe
			* Attempted to account for pw, despite statistical limitations on
			* using pweights that differ across FE groups. Not concave:
			* xtlogit tracedguns cited c.freq_cenapi##c.freq_court if year > 2014 & year < 2019, fe
			outreg2 using citationregfe, label addstat(Pseudo R-squared, `e(r2_p)') excel replace

		* Negative binomial regression w/ FE
		xtnbreg ct_allguns numberofviolations if year > 2014 & year < 2019 & revoked == 0, fe
			* Attempted to account for pw, despite statistical limitations on
			* using pweights that differ across FE groups. No effect:
			* xtnbreg ct_allguns numberofviolations c.freq_cenapi##c.freq_court if year > 2014 & year < 2019, fe
			outreg2 using citationregfe, label excel append
			
			/*
			* Querying data:
			sum numberofviolations if year > 2014 & year < 2019 & cited == 1
			sum numberofviolations if year > 2014 & year < 2019, detail
			sum cited if year > 2014 & year < 2019
			*/
			
		* Log-log w/ FE
		xtreg ct_allguns_ln numberofviolations_ln if year > 2014 & year < 2019 & revoked == 0, fe
			outreg2 using citationregfe, label excel append

		* Re-do with only Academy stores?
		/*
		Attempted (using added condition: <& strpos(strlower( businessname ),"bass")>0>
		But there is no variation within groups
		*/
			
			
	* Non-FE Models (can be lagged)
	* Logistic regression w/ FE
	xtlogit tracedguns cited if year > 2014 & year < 2019 & revoked == 0
		outreg2 using citationreg, label excel replace
	xtlogit tracedguns cited l.cited year if year > 2014 & year < 2019 & revoked == 0
		outreg2 using citationreg, label excel append

	* Negative binomial regression w/ FE
	xtnbreg ct_allguns numberofviolations if year > 2014 & year < 2019 & revoked == 0
		outreg2 using citationreg, label excel append
	nbreg ct_allguns numberofviolations l.numberofviolations if year > 2014 & year < 2019 & revoked == 0															
		outreg2 using citationreg, label excel append
		
	* Log-log w/ FE
	xtreg ct_allguns_ln numberofviolations_ln if year > 2014 & year < 2019 & revoked == 0
		outreg2 using citationreg, label excel append
	reg ct_allguns_ln numberofviolations_ln l.numberofviolations_ln if year > 2014 & year < 2019 & revoked == 0
		outreg2 using citationreg, label excel append
		
		
	
	* Generating log-log coefficients for each of the top 10 most common citations
	* sum cit_18usc923g5a - cit_27cfr478122
	foreach v of varlist cit_27cf~4c1 cit_2~47821a cit_~478125e cit_27cf~3iv ///
		cit_27cfr~3i cit_27cf~4c5 cit_~478126a cit_27cf~4c4 cit_~478102a cit_~478124a {
		xtnbreg ct_allguns `v', fe
		local name = subinstr("`v'","~","",.)
		est store `name'
		}
	* Labeling population citations
	labe var _est_cit_27cfr478124c1 "1. Record purchaser data"
	labe var _est_cit_27cfr47821a "2. Record all required data"
	labe var _est_cit_27cfr478125e "3. Maintain records of receipt and disposition"
	labe var _est_cit_27cfr478124c3iv "4. Record date and response of NICS background check"
	labe var _est_cit_27cfr478124c3i "5. Proper identification of purchaser"
	labe var _est_cit_27cfr478124c5 "6. Purchaser signature"
	labe var _est_cit_27cfr478126a "7. Report multiple purchases w/in 5 business days"
	labe var _est_cit_27cfr478124c4 "8. Record firearm data (incl. serial number)"
	labe var _est_cit_27cfr478102a "9. Conduct NICS background check before sale"
	labe var _est_cit_27cfr478124a "10. Record the transfer of a firearm"
	
	coefplot ///
		(cit_27cfr478124c1) ///
		(cit_27cfr47821a) ///
		(cit_27cfr478125e) ///
		(cit_27cfr478124c3iv) ///
		(cit_27cfr478124c3i) ///
		(cit_27cfr478124c5) ///
		(cit_27cfr478126a) ///
		(cit_27cfr478124c4) ///
		(cit_27cfr478102a) ///
		(cit_27cfr478124a) ///
		, drop(_cons) ///
		||, xline(0) eform graphregion(color(white)) byopts(xrescale) levels(90) legend(off) xtitle("Negative Binomial Coefficients",size(small)) ///
		xlabel(,labsize(2)) ylabel(,labsize(2)) fxsize(75) title("Effect of ATF citations on future trafficking sales",size(small))
