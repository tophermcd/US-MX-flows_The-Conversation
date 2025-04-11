	** POLICE PURCHASE ANALYSIS 1 **
cd "G:\My Drive\Research\Firearms Economics\Conversation Report\"
use "seizures_styr.dta", clear

xtset stateid year, yearly

* Endogeneity tests
xtreg lseizures l2.lpguns l.lseizures, fe
predict lseizres, res
xtreg lseizures l2.lpguns l.lseizures l.lseizres, fe
	* endogenous

xtreg lpguns l.lseizures l.lpguns, fe
predict lpgunres, res
xtreg lpguns l.lseizures l.lpguns l.lpgunres, fe
	* endogenous


* Endogeneity controls testing (successful)
xtreg lseizures l.lseizures i.partyconflict, fe
predict lseizres2, res
	* marginally relevant
xtreg lpguns l.lpguns i.partyconflict, fe
	* not exogenous for this direction
xtreg lseizures l.lseizures lpguns lseizres2, fe
	* Relevant, pushing lpguns out of significance

	
	
	xtreg lseizures l.lpguns l.lseizures, fe
	outreg2 using "3sls-pol-l1.xml", label excel replace

	xtreg lpguns l.lseizures l.lpguns, fe
	outreg2 using "3sls-pol-l1.xml", label excel append

	xtreg lseizures l.lpguns l.lseizures i.partyconflict, fe
	outreg2 using "3sls-pol-l1.xml", label excel append

	xtreg lpguns l.lseizures l.lpguns i.partyconflict, fe
	outreg2 using "3sls-pol-l1.xml", label excel append

	global pol2guns "(pol2guns: lseizures l.lpguns)"
	global guns2pol "(guns2pol: lpguns l.lseizures)"
	/* EXOGENOUS VARIABLES NEEDED */
	reg3 $pol2guns $guns2pol, endog(lseizures lpguns) 3sls
	* estimates store Uncontrolled
	outreg2 using "3sls-pol-l1.xml", label excel append

	global pol2guns "(pol2guns: lseizures l.lpguns i.partyconflict)"
	global guns2pol "(guns2pol: lpguns l.lseizures i.partyconflict)"
	/* EXOGENOUS VARIABLES NEEDED */
	reg3 $pol2guns $guns2pol, endog(lseizures lpguns) 3sls
	* estimates store Uncontrolled
	outreg2 using "3sls-pol-l1.xml", label excel append

