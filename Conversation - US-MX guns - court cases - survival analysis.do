*** Survival Analysis ***
* This doesn't yield sufficient obs yet:
* stset recoverytime, id(case) failure(capture) scale(1)
cd "G:\My Drive\Research\Firearms Economics\Conversation Report\"

use "courtcases.dta", clear
stset recoverytime_imp, failure(capture)
/*
* Imputed recovery times don't produce pretty KM graphs; probably useless
stset recoverytime2, failure(capture)
*/

sts graph, hazard
sts graph

	* Z-scores for PC

correlate zpc1 DEALERH RECORDSDEALER REPORTDEALER PURGE SECURITY FINGERPRINT AGE18LONGGUNSALE GUNSHOW BACKGROUNDPURGE MENTALHEALTH STATECHECKS COLLEGE CCBACKGROUND
correlate zpc2 DEALERH RECORDSDEALER REPORTDEALER PURGE SECURITY FINGERPRINT AGE18LONGGUNSALE GUNSHOW BACKGROUNDPURGE MENTALHEALTH STATECHECKS COLLEGE CCBACKGROUND
correlate zpc3 DEALERH RECORDSDEALER REPORTDEALER PURGE SECURITY FINGERPRINT AGE18LONGGUNSALE GUNSHOW BACKGROUNDPURGE MENTALHEALTH STATECHECKS COLLEGE CCBACKGROUND

** Cox Proportional Hazards & Coefficient Plots
stcox
stcox longgun

foreach i in gunlawslax DEALERH RECORDSDEALER REPORTDEALER PURGE SECURITY FINGERPRINT AGE18LONGGUNSALE GUNSHOW BACKGROUNDPURGE MENTALHEALTH STATECHECKS COLLEGE CCBACKGROUND {
	stcox `i'
	est store e`i'
	}
	* Multiple stcox w/ singlular and all-inclusive tests of laws deemed a priori plausible

		* Plain: No FE, prio, or strata
		/*
		drop *e_plain*
		*/
stcox RECORDSDEALER pw, nohr vce(robust)
	outreg2 using stcox_plain, label addstat(Pseudo R-squared, `e(r2_p)') excel replace
	est store e_plain_RECORDSDEALER
foreach v in REPORTDEALER PURGE SECURITY FINGERPRINT GUNSHOW BACKGROUNDPURGE STATECHECKS LAWTOTAL {
	stcox `v' pw, nohr vce(robust)
	outreg2 using stcox_plain, label addstat(Pseudo R-squared, `e(r2_p)') excel append
	est store e_plain_`v'
	}
stcox RECORDSDEALER REPORTDEALER PURGE SECURITY FINGERPRINT GUNSHOW BACKGROUNDPURGE STATECHECKS LAWTOTAL pw, nohr vce(robust)
	outreg2 using stcox_plain, label addstat(Pseudo R-squared, `e(r2_p)') excel append
	est store e_plain_all

		/*
		Coef plot for plain
		graph drop plain
		graph drop plain_all
		*/
coefplot (e_plain_RECORDSDEALER) (e_plain_REPORTDEALER) (e_plain_PURGE) ///
	(e_plain_SECURITY) (e_plain_FINGERPRINT) (e_plain_GUNSHOW) ///
	(e_plain_BACKGROUNDPURGE) (e_plain_STATECHECKS), ///
	||, eform xline(1) graphregion(color(white)) byopts(xrescale) levels(90) legend(off) xtitle("Hazard Ratio",size(small)) ///
	xlabel(,labsize(2)) ylabel(1 "RECORDSDEALER" 2 "REPORTDEALER" 3 "PURGE" ///
	4 "SECURITY" 5 "FINGERPRINT" 6 "GUNSHOW" 7 "BACKGROUNDPURGE" 8 "STATECHECKS" ///
	,labsize(2)) fxsize(75) title("No Controls",size(small)) name(plain)

coefplot (e_plain_all), ///
	||, eform xline(1) graphregion(color(white)) byopts(xrescale) levels(90) legend(off) xtitle("Hazard Ratio",size(small)) ///
	xlabel(,labsize(2)) ylabel(1 "RECORDSDEALER" 2 "REPORTDEALER" 3 "PURGE" ///
	4 "SECURITY" 5 "FINGERPRINT" 6 "GUNSHOW" 7 "BACKGROUNDPURGE" 8 "STATECHECKS" ///
	,labsize(2)) fxsize(75) title("No Controls",size(small)) name(plain_all)

	* State FE
		/*
		drop *e_stfe*
		*/
stcox RECORDSDEALER pw i.state_fips yearsale, nohr vce(robust)
	outreg2 using stcox_stfe, label addstat(Pseudo R-squared, `e(r2_p)') excel replace
	est store e_stfe_RECORDSDEALER
foreach v in REPORTDEALER PURGE SECURITY FINGERPRINT GUNSHOW BACKGROUNDPURGE STATECHECKS LAWTOTAL {
	stcox `v' pw i.state_fips yearsale, nohr vce(robust)
	outreg2 using stcox_stfe, label addstat(Pseudo R-squared, `e(r2_p)') excel append
	est store e_stfe_`v'
	}
stcox RECORDSDEALER REPORTDEALER PURGE SECURITY FINGERPRINT GUNSHOW BACKGROUNDPURGE STATECHECKS LAWTOTAL pw i.state_fips yearsale, nohr vce(robust)
	outreg2 using stcox_stfe, label addstat(Pseudo R-squared, `e(r2_p)') excel append
	est store e_stfe_all

		/*
		Coef plot for stfe
		graph drop stfe
		graph drop stfe_all
		*/
coefplot (e_stfe_RECORDSDEALER) (e_stfe_REPORTDEALER) (e_stfe_PURGE) ///
	(e_stfe_SECURITY) (e_stfe_FINGERPRINT) (e_stfe_GUNSHOW) ///
	(e_stfe_BACKGROUNDPURGE) (e_stfe_STATECHECKS), ///
	||,  keep(RECORDSDEALER REPORTDEALER PURGE SECURITY FINGERPRINT GUNSHOW BACKGROUNDPURGE STATECHECKS) ///
	eform xline(1) graphregion(color(white)) byopts(xrescale) levels(90) legend(off) xtitle("Hazard Ratio",size(small)) ///
	xlabel(,labsize(2)) ylabel(,labsize(2)) ylabel(1 "RECORDSDEALER" 2 "REPORTDEALER" 3 "PURGE" ///
	4 "SECURITY" 5 "FINGERPRINT" 6 "GUNSHOW" 7 "BACKGROUNDPURGE" 8 "STATECHECKS" ///
	,labsize(2)) fxsize(75) title("State Fixed-Effects",size(small)) name(stfe)

coefplot (e_stfe_all), ///
	||,  keep(RECORDSDEALER REPORTDEALER PURGE SECURITY FINGERPRINT GUNSHOW BACKGROUNDPURGE STATECHECKS) ///
	eform xline(1) graphregion(color(white)) byopts(xrescale) levels(90) legend(off) xtitle("Hazard Ratio",size(small)) ///
	xlabel(,labsize(2)) ylabel(,labsize(2)) ylabel(1 "RECORDSDEALER" 2 "REPORTDEALER" 3 "PURGE" ///
	4 "SECURITY" 5 "FINGERPRINT" 6 "GUNSHOW" 7 "BACKGROUNDPURGE" 8 "STATECHECKS" ///
	,labsize(2)) fxsize(75) title("State Fixed-Effects",size(small)) name(stfe_all)

*PRIO Weapons Type FE
		/*
		drop *e_prio*
		*/
stcox RECORDSDEALER pw i.priotypecode, nohr vce(robust)
	outreg2 using stcox_prio, label addstat(Pseudo R-squared, `e(r2_p)') excel replace
	est store e_prio_RECORDSDEALER
foreach v in REPORTDEALER PURGE SECURITY FINGERPRINT GUNSHOW BACKGROUNDPURGE STATECHECKS LAWTOTAL {
	stcox `v' pw i.priotypecode, nohr vce(robust)
	outreg2 using stcox_prio, label addstat(Pseudo R-squared, `e(r2_p)') excel append
	est store e_prio_`v'
	}
stcox RECORDSDEALER REPORTDEALER PURGE SECURITY FINGERPRINT GUNSHOW BACKGROUNDPURGE STATECHECKS LAWTOTAL pw i.priotypecode, nohr vce(robust)
	outreg2 using stcox_prio, label addstat(Pseudo R-squared, `e(r2_p)') excel append
	est store e_prio_all
	
	
		/*
		Coef plot for prio
		graph drop prio
		graph drop prio_all
		*/
coefplot (e_prio_RECORDSDEALER) (e_prio_REPORTDEALER) (e_prio_PURGE) ///
	(e_prio_SECURITY) (e_prio_FINGERPRINT) (e_prio_GUNSHOW) ///
	(e_prio_BACKGROUNDPURGE) (e_prio_STATECHECKS), ///
	||,  keep(RECORDSDEALER REPORTDEALER PURGE SECURITY FINGERPRINT GUNSHOW BACKGROUNDPURGE STATECHECKS) ///
	eform xline(1) graphregion(color(white)) byopts(xrescale) levels(90) legend(off) xtitle("Hazard Ratio",size(small)) ///
	xlabel(,labsize(2)) ylabel(,labsize(2)) ylabel(1 "RECORDSDEALER" 2 "REPORTDEALER" 3 "PURGE" ///
	4 "SECURITY" 5 "FINGERPRINT" 6 "GUNSHOW" 7 "BACKGROUNDPURGE" 8 "STATECHECKS" ///
	,labsize(2)) fxsize(75) title("PRIO Weapon Category Fixed-Effects",size(small)) name(prio)

coefplot (e_prio_all), ///
	||,  keep(RECORDSDEALER REPORTDEALER PURGE SECURITY FINGERPRINT GUNSHOW BACKGROUNDPURGE STATECHECKS) ///
	eform xline(1) graphregion(color(white)) byopts(xrescale) levels(90) legend(off) xtitle("Hazard Ratio",size(small)) ///
	xlabel(,labsize(2)) ylabel(,labsize(2)) ylabel(1 "RECORDSDEALER" 2 "REPORTDEALER" 3 "PURGE" ///
	4 "SECURITY" 5 "FINGERPRINT" 6 "GUNSHOW" 7 "BACKGROUNDPURGE" 8 "STATECHECKS" ///
	,labsize(2)) fxsize(75) title("PRIO Weapon Category Fixed-Effects",size(small)) name(prio_all)
	
*PRIO Weapons Type FE + LISAs
		/*
		drop *e_prio*
		*/
stcox RECORDSDEALER pw i.priotypecode guncountLISA LAWTOTALLISA, nohr vce(robust)
	outreg2 using stcox_prioLISA, label addstat(Pseudo R-squared, `e(r2_p)') excel replace
	est store e_prioLISA_RECORDSDEALER
foreach v in REPORTDEALER PURGE SECURITY FINGERPRINT GUNSHOW BACKGROUNDPURGE STATECHECKS LAWTOTAL {
	stcox `v' pw i.priotypecode guncountLISA LAWTOTALLISA, nohr vce(robust)
	outreg2 using stcox_prioLISA, label addstat(Pseudo R-squared, `e(r2_p)') excel append
	est store e_prioLISA_`v'
	}
stcox RECORDSDEALER REPORTDEALER PURGE SECURITY FINGERPRINT GUNSHOW BACKGROUNDPURGE STATECHECKS LAWTOTAL pw i.priotypecode guncountLISA LAWTOTALLISA, nohr vce(robust)
	outreg2 using stcox_prioLISA, label addstat(Pseudo R-squared, `e(r2_p)') excel append
	est store e_prioLISA_all
	
	
		/*
		Coef plot for priolisa
		graph drop prioLISA
		graph drop prioLISA_all
		*/
coefplot (e_prioLISA_RECORDSDEALER) (e_prioLISA_REPORTDEALER) (e_prioLISA_PURGE) ///
	(e_prioLISA_SECURITY) (e_prioLISA_FINGERPRINT) (e_prioLISA_GUNSHOW) ///
	(e_prioLISA_BACKGROUNDPURGE) (e_prioLISA_STATECHECKS), ///
	||,  keep(RECORDSDEALER REPORTDEALER PURGE SECURITY FINGERPRINT GUNSHOW BACKGROUNDPURGE STATECHECKS) ///
	eform xline(1) graphregion(color(white)) byopts(xrescale) levels(90) legend(off) xtitle("Hazard Ratio",size(small)) ///
	xlabel(,labsize(2)) ylabel(,labsize(2)) ylabel(1 "RECORDSDEALER" 2 "REPORTDEALER" 3 "PURGE" ///
	4 "SECURITY" 5 "FINGERPRINT" 6 "GUNSHOW" 7 "BACKGROUNDPURGE" 8 "STATECHECKS" ///
	,labsize(2)) fxsize(75) title("PRIO Fixed-Effects + LISAs",size(small)) name(prioLISA)

coefplot (e_prioLISA_all), ///
	||,  keep(RECORDSDEALER REPORTDEALER PURGE SECURITY FINGERPRINT GUNSHOW BACKGROUNDPURGE STATECHECKS) ///
	eform xline(1) graphregion(color(white)) byopts(xrescale) levels(90) legend(off) xtitle("Hazard Ratio",size(small)) ///
	xlabel(,labsize(2)) ylabel(,labsize(2)) ylabel(1 "RECORDSDEALER" 2 "REPORTDEALER" 3 "PURGE" ///
	4 "SECURITY" 5 "FINGERPRINT" 6 "GUNSHOW" 7 "BACKGROUNDPURGE" 8 "STATECHECKS" ///
	,labsize(2)) fxsize(75) title("PRIO Fixed-Effects + LISAs",size(small)) name(prioLISA_all)

		/*
		And for just the last, most highly controlled model (preferable to the
		combined graph below? Simpler, at least.)
				graph drop plain_all
				graph drop stfe_all
				graph drop prio_all
				graph drop prioLISA_all

		*/


graph combine plain_all stfe_all prio_all prioLISA_all

	
/* This is too granular an analysis for our data
* Case strata
		/*
		drop *e_case*
		*/
stcox RECORDSDEALER, strata(case) nohr vce(robust)
	outreg2 using stcox_case, label addstat(Pseudo R-squared, `e(r2_p)') excel replace
	est store e_case_RECORDSDEALER
foreach v in REPORTDEALER PURGE SECURITY FINGERPRINT GUNSHOW BACKGROUNDPURGE STATECHECKS LAWTOTAL {
	stcox `v', strata(case) nohr vce(robust)
	outreg2 using stcox_case, label addstat(Pseudo R-squared, `e(r2_p)') excel append
	est store e_case_`v'
	}
stcox RECORDSDEALER REPORTDEALER PURGE SECURITY FINGERPRINT GUNSHOW BACKGROUNDPURGE STATECHECKS LAWTOTAL, strata(case) nohr vce(robust)
	outreg2 using stcox_case, label addstat(Pseudo R-squared, `e(r2_p)') excel append
	est store e_case_all

stcox RECORDSDEALER REPORTDEALER PURGE SECURITY FINGERPRINT GUNSHOW BACKGROUNDPURGE STATECHECKS c.LAWTOTAL##c.casecount, strata(case) nohr vce(robust)
	outreg2 using stcox_case, label addstat(Pseudo R-squared, `e(r2_p)') excel append
	est store e_case_all2

	
		/*
		Coef plot for case
		graph drop case
		*/
coefplot (e_case_RECORDSDEALER) (e_case_REPORTDEALER) (e_case_PURGE) ///
	(e_case_SECURITY) (e_case_FINGERPRINT) (e_case_GUNSHOW) ///
	(e_case_BACKGROUNDPURGE) (e_case_STATECHECKS), ///
	||, keep(RECORDSDEALER REPORTDEALER PURGE SECURITY FINGERPRINT GUNSHOW BACKGROUNDPURGE STATECHECKS) ///
	eform xline(1) graphregion(color(white)) byopts(xrescale) levels(90) legend(off) xtitle("Hazard Ratio",size(small)) ///
	xlabel(,labsize(2)) ylabel(,labsize(2)) ylabel(1 "RECORDSDEALER" 2 "REPORTDEALER" 3 "PURGE" ///
	4 "SECURITY" 5 "FINGERPRINT" 6 "GUNSHOW" 7 "BACKGROUNDPURGE" 8 "STATECHECKS" ///
	,labsize(2)) fxsize(75) title("Stratified by Case",size(small)) name(case)
*/
	
graph combine plain stfe prio prioLISA
	
** Robustness Checks **

		* PRIO Weapons Type
stcox LAWTOTAL i.priotypecode, nohr vce(robust)

		* Case-stratified
stcox LAWTOTAL, strata(case) nohr vce(robust)
	outreg2 using stcox_strata, label addstat(Pseudo R-squared, `e(r2_p)') excel replace
	est store e_strata_LAWTOTAL
* stcox LAWTOTAL i.case, nohr vce(robust) // doesn't compute

		* PRIO + Case
stcox LAWTOTAL i.priotypecode, strata(case) nohr vce(robust)

	* State STFE seems problematic for laws
		* State FE (yearsale is included to avoid incalculability)
			/*
			drop *e_stfe*
			*/
		* State FE
stcox LAWTOTAL, strata(state_fips) nohr vce(robust)
stcox LAWTOTAL i.state_fips, nohr vce(robust)
		* Most highly controlled, general model:
stcox LAWTOTAL i.state_fips i.priotypecode guncountLISA LAWTOTALLISA, nohr vce(robust)

stcox RECORDSDEALER i.state_fips yearsale, nohr vce(robust)
	outreg2 using stcox_stfe, label addstat(Pseudo R-squared, `e(r2_p)') excel replace
	est store e_stfe_RECORDSDEALER
foreach v in REPORTDEALER PURGE SECURITY FINGERPRINT GUNSHOW BACKGROUNDPURGE STATECHECKS LAWTOTAL {
	stcox `v' i.state_fips yearsale, nohr vce(robust)
	outreg2 using stcox_stfe, label addstat(Pseudo R-squared, `e(r2_p)') excel append
	est store e_stfe_`v'
	}
stcox RECORDSDEALER REPORTDEALER PURGE SECURITY FINGERPRINT GUNSHOW BACKGROUNDPURGE STATECHECKS LAWTOTAL i.state_fips yearsale, nohr vce(robust)
	outreg2 using stcox_stfe, label addstat(Pseudo R-squared, `e(r2_p)') excel append
	est store e_stfe_all

			* State STFE + Case
	stcox LAWTOTAL pw, strata(state_fips case) nohr vce(robust)
	stcox LAWTOTAL pw i.state_fips i.case, nohr vce(robust)
			* State STFE + PRIO
	stcox LAWTOTAL pw, strata(state_fips priotypecode) nohr vce(robust)
	stcox LAWTOTAL  pwi.state_fips i.priotypecode, nohr vce(robust)
			* State STFE + PRIO + Case
	stcox LAWTOTAL pw, strata(state_fips priotypecode case) nohr vce(robust)
	stcox LAWTOTAL i.state_fips i.priotypecode i.case, strata(case) nohr vce(robust) // and this is only unproblematic because all states have been omitted


** Manufacturer Analysis by itself **
graph box recoverytime, horizontal over(longgun) graphregion(color(white))
reg recoverytime longgun
gen lrecoverytime = ln(recoverytime + 1)
graph box lrecoverytime, horizontal over(gunlawslax) graphregion(color(white))
graph box lrecoverytime, horizontal over(BACKGROUNDPURGE) graphregion(color(white))
graph box lrecoverytime, horizontal over(CCBACKGROUND) graphregion(color(white))

graph box recoverytime, horizontal over(make) graphregion(color(white))

/*
graph drop b
*/
coefplot (ezpc1)(ezpc2) (ezpc3), ///
	||, xline(1) eform graphregion(color(white)) byopts(xrescale) levels(90) legend(off) ylabel(,labsize(2)) fxsize(75) title("Gun Law Principal Components",size(small)) name(b)
* (estgunlawslax) 
graph combine a b, cols(2) imargin(zero) graphregion(color(white)) b1(Proportional Hazards)
	*  xtitle("Relationship strength (SDs of SDG per 1 SD of SII)")
	* xcommon

	
* Kaplan-Meier Graphs

	* Type of weapon seems to make a difference
sts graph, by(longgun) legend(rows(2)) graphregion(color(white))
sts graph, by(sniper) legend(rows(2)) graphregion(color(white))
sts graph, by(milgrade) legend(rows(2)) graphregion(color(white))

	* Regulations in the state of sale do, though -- Background purge laws in particular
sts graph, by(gunlawslax) legend(rows(2)) graphregion(color(white))
	sts test gunlawslax
sts graph, by(DEALERH) legend(rows(2)) graphregion(color(white))
sts graph, by(RECORDSDEALER) legend(rows(2)) graphregion(color(white))
sts graph, by(REPORTDEALER) legend(rows(2)) graphregion(color(white))
		* Figure 4
sts graph, by(PURGE) legend(rows(2)) title("") xline(60) graphregion(color(white))
	sts test PURGE
sts graph, by(SECURITY) legend(rows(2)) graphregion(color(white))
sts graph, by(FINGERPRINT) legend(rows(2)) graphregion(color(white))
sts graph, by(AGE18LONGGUNSALE) legend(rows(2)) graphregion(color(white))
sts graph, by(GUNSHOW) legend(rows(2)) graphregion(color(white))
sts graph, by(BACKGROUNDPURGE) legend(rows(2)) xline(60) graphregion(color(white))
	sts test BACKGROUNDPURGE
sts graph, by(MENTALHEALTH) legend(rows(2)) graphregion(color(white))
sts graph, by(STATECHECKS) legend(rows(2)) graphregion(color(white))
sts graph, by(COLLEGE) legend(rows(2)) graphregion(color(white))
	sts test COLLEGE
sts graph, by(CCBACKGROUND) legend(rows(2)) graphregion(color(white))
	sts test CCBACKGROUND

* 
sum recoverytime if state_abbr == "CA" | state_abbr == "AZ" | state_abbr == "NM" | state_abbr == "TX"
sum recoverytime if state_abbr == "CA" | state_abbr == "AZ" | state_abbr == "NM" | state_abbr == "TX" | ///
	gunlawsstrict == 1
sum recoverytime if state_abbr == "CA" | state_abbr == "AZ" | state_abbr == "NM" | state_abbr == "TX" | ///
	gunlawsstrict == 0
xtnbreg recoverytime PURGE

