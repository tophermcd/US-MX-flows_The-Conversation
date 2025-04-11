				*** Gun Type / Caliber by Year Graphs ***
* Datasets used:
	* gunid.dat 
	* Court cases?
	/*
	It seems to me that since basis of selection for US court cases is independent
	from those SEDENA or CENAPI, but the latter are not independent of one another,
	*/
cd "G:\My Drive\Research\Firearms Economics\Conversation Report\"

	*Calculating number of years of each study period
use "gunid.dta", clear
	sum daterecov if CSstudyperiod == 1
		global CSstudyyears = (r(max) - r(min))/ 365
		di $CSstudyyears

	*Cleaning <type>
	labe var type "Firearm type"
	replace type = "Assault Rifle" if strpos(strlower(type),"fusil de asalto") > 0
	replace type = "Tactical Rifle" if strpos(strlower(type),"fusil tactico") > 0
	replace type = "Sniper Rifle" if strpos(strlower(type),"fusil sniper") > 0
	replace type = "Rifle" if strpos(strlower(type),"fusil") > 0 | strpos(strlower(type),"rifle") > 0
	replace type = "Machine Pistol" if strpos(strlower(type),"pistola ametrall") > 0
	replace type = "Submachine Pistol" if strpos(strlower(type),"pistola subametrall") > 0
	replace type = "Pistol" if strpos(strlower(type),"pistol") > 0
	replace type = "Carbine" if strpos(strlower(type),"carabin") > 0
	replace type = "Submachine Gun" if strpos(strlower(type),"submetralleta") > 0 | strpos(strlower(type),"subametrall") > 0
	replace type = "Machine Gun" if strpos(strlower(type),"metralleta") > 0 | strpos(strlower(type),"ametrall")
	replace type = "Shotgun" if strpos(strlower(type),"escopeta") > 0
	replace type = "Revolver" if strpos(strlower(type),"revolver") > 0
	replace type = "Grenade Launcher" if strpos(strlower(type),"lanzacoh") | strpos(strlower(type),"lanzagr") > 0
	replace type = "Rocket Launcher" if strpos(strlower(type),"multilanzador") > 0
	replace type = "Multiple Launcher" if strpos(strlower(type),"multilanzador") > 0 | strtrim(strlower(type)) == "multi"
	replace type = "Single Launcher" if strpos(strlower(type),"lanzador") > 0
	replace type = "Howitzer" if strpos(strlower(type),"obuse") > 0
	replace type = "Canon" if strpos(strlower(type),"canon") > 0 | strpos(strlower(type),"caÑon")
	replace type = "Firearms Part" if strpos(strlower(type),"frame") > 0 | strpos(strlower(type),"receiver") | strpos(strlower(type),"reciever")
	replace type = "N/D" if strpos(strlower(type),"no especif") > 0
	
	*Cleaning <caliber>
	replace caliber = "N/A" if strpos(strlower(caliber),"n/a") > 0 | strtrim(strlower(caliber)) == "na"  ///
		| strtrim(strlower(caliber)) == "multi" | strpos(strlower(caliber),"does not have") > 0 
	replace caliber = "N/D" if strpos(strlower(caliber),"unknown") > 0 | ///
		strpos(strlower(caliber),"none stated") > 0 | strpos(strlower(caliber),"not provided") > 0 | ///
		strpos(strlower(caliber),"no especif") > 0 | strpos(strlower(caliber),"ilegible") > 0 | ///
		strpos(strlower(caliber),"zz") > 0
	replace caliber = "N/A" if strpos(strlower(caliber),"n/a") > 0
	replace caliber = "N/A" if strpos(strlower(caliber),"n/a") > 0
	replace caliber = "N/A" if strpos(strlower(caliber),"n/a") > 0
	replace caliber = "N/A" if strpos(strlower(caliber),"n/a") > 0
	replace caliber = "N/A" if strpos(strlower(caliber),"n/a") > 0
	replace caliber = subinstr(caliber,"MM","mm",.)
	replace caliber = subinstr(caliber,"mm.","mm",.)
	replace caliber = subinstr(caliber,"mm"," mm",.)
	replace caliber = subinstr(caliber,"  mm"," mm",.)
	replace caliber = subinstr(caliber,"..",".",.)
	replace caliber = subinstr(caliber,"ESPECIAL","SPECIAL",.)
	replace caliber = "5.56 mm" if strtrim(strlower(caliber)) == "5.56"
	replace caliber = "5.7x28 mm" if strtrim(strlower(caliber)) == "5.7Ã28 mm"
	replace caliber = "7.62x39 mm" if strtrim(strlower(caliber)) == "7.62x39"
	replace caliber = "7.62x51 mm" if strtrim(strlower(caliber)) == "7.62x51"
	replace caliber = "7.62 mm" if strtrim(strlower(caliber)) == "7.62"
	replace caliber = "10 G.A." if strpos(strlower(caliber),"10 ga") > 0 | strtrim(strlower(caliber)) == "10" | ///
		strtrim(strlower(caliber)) == "10-gauge" | strpos(strlower(caliber),"10 gauge") > 0 | strpos(strlower(caliber),"10 guage") > 0
	replace caliber = "12 G.A." if strpos(strlower(caliber),"12 ga") > 0 | strtrim(strlower(caliber)) == "12" | ///
		strtrim(strlower(caliber)) == "12-gauge" | strpos(strlower(caliber),"12 gauge") > 0 | strpos(strlower(caliber),"12 guage") > 0
	replace caliber = "16 G.A." if strpos(strlower(caliber),"16 ga") > 0 | strtrim(strlower(caliber)) == "16" | ///
		strtrim(strlower(caliber)) == "16-gauge" | strpos(strlower(caliber),"16 gauge") > 0 | strpos(strlower(caliber),"16 guage") > 0
	replace caliber = "20 G.A." if strpos(strlower(caliber),"20 ga") > 0 | strtrim(strlower(caliber)) == "20" | ///
		strtrim(strlower(caliber)) == "20-gauge" | strpos(strlower(caliber),"20 gauge") > 0 | strpos(strlower(caliber),"20 guage") > 0

	* Ordering variables
	replace monthrecov = month(daterecov)
	replace dayrecov = day(daterecov)
	order yearrecov, before(monthrecov)
	rename yearrecov yearrecov_str
	gen yearrecov = year(daterecov)
	order yearrecov, before(monthrecov)
	gen fid = _n
	order fid, first
	drop if type == "N/D" | type == ""
	drop if yearrecov < 2009 | yearrecov > 2022

	* Simplifying categories
	replace type = "Rifle" if strpos(strlower(type),"machine gun") > 0 | strpos(strlower(type),"carbine") > 0
	replace type = "Handgun" if strpos(strlower(type),"revolver") > 0 | strpos(strlower(type),"pistol") > 0
	replace type = "Other arms" if strpos(strlower(type),"handgun") == 0 & ///
		strpos(strlower(type),"rifle") == 0 & ///
		strpos(strlower(type),"shotgun") == 0 & ///
		strpos(strlower(type),"n/d") == 0
	
	save "gunid2.dta", replace

	*Calculating type percentages
		*Getting total gun numbers for a denominator
		use "gunid2.dta", clear
			collapse (count) fid, by(yearrecov)
			rename fid totguns
		save "totguns_by_year.dta",	 replace

		*Getting gun numbers by type for a numerator and calculating percentages
		use "gunid2.dta", clear
			collapse (count) fid, by(yearrecov type)
			rename fid ct_guns
			merge m:1 yearrecov using "totguns_by_year.dta", keepusing(totguns)
			gen perc = ct_guns / totguns * 100
			drop _m
		save "totguns_by_type_year.dta", replace

* Getting US-MX trafficking flow estimates
import delimited "G:\My Drive\Research\Firearms Economics\Conversation Report\US-MX flow estimates.csv", varnames(1) clear
foreach v of varlist traffic_low traffic_med traffic_high {
	replace `v' = strtrim(subinstr(`v',",","",.))
	}
destring traffic*, force replace
rename ïyear year
save "US-MX flow estimates.dta", replace


use "totguns_by_type_year.dta", clear

gen type2 = subinstr(type," ","",.)
keep perc yearrecov type2
rename yearrecov year
reshape wide perc, i(year) j(type2, string)
foreach v of varlist percHandgun - percShotgun {
	replace `v' = 0 if `v' == .
	}
	
merge 1:1 year using "US-MX flow estimates.dta", keepusing(traffic_low traffic_med traffic_high)
sort year
drop _m

foreach v of varlist percHandgun - percShotgun {
	local newname = "abs" + subinstr("`v'", "perc", "", .)
	gen `newname'_low = `v' * traffic_low / 100
	gen `newname'_med = `v' * traffic_med / 100
	gen `newname'_high = `v' * traffic_high / 100
	}

drop if year < 2010 | year > 2022
	
*Stacked area chart: Percentages
	* Generating cumulative percentages for stacked area chart
	/*
		labe var percCanon "Canons"
	gen percCarbineA = percCanon + percCarbine
		labe var percCarbineA "Carbines"
	gen percDestructivedeviceA = percDestructivedevice + percCarbineA
		labe var percDestructivedeviceA "Destructive devices"
	gen percFirearmspartA = percFirearmspart + percDestructivedeviceA
		labe var percFirearmspartA "Firearms parts"
	gen percGrenadelauncherA = percGrenadelauncher + percFirearmspartA
		labe var percGrenadelauncherA "Grenade launchers"
	*/
	
		labe var percHandgun "Handguns"
	/*
	gen percHowitzerA = percHowitzer + percHandgunA
		labe var percHowitzerA "Howitzers"
	gen percMachinegunA = percMachinegun + percHowitzerA
		labe var percMachinegunA "Machine guns"
	gen percMultiplelauncherA = percMultiplelauncher + percMachinegunA
		labe var percMultiplelauncherA "Multiple launchers"
	gen percPistolA = percPistol + percMultiplelauncherA
		labe var percPistolA "Pistols"
	gen percRevolverA = percRevolver + percPistolA
		labe var percRevolverA "Revolvers"
	*/
	gen percRifleA = percRifle + percHandgun
		labe var percRifleA "Rifles"
	gen percShotgunA = percShotgun + percRifleA
		labe var percShotgunA "Shotguns"
	/*
	gen percSubmachinegunA = percSubmachinegun + percShotgunA
		labe var percSubmachinegunA "Submachine guns"
	*/
	gen percOtherarmsA = percOtherarms + percShotgunA
		labe var percOtherarmsA "Other arms"
	

twoway ///
	(area percOtherarmsA year, sort graphregion(color(white))) ///
	(area percShotgunA year, sort) ///
	(area percRifleA year, sort) ///
	(area percHandgun year, sort)
	
*Stacked area chart: Absolute values
	* Generating cumulative percentages for stacked area chart
	gen absHandgunA_med = absHandgun_med
		labe var absHandgunA_med "Handguns"
	gen absRifleA_med = absRifle_med + absHandgunA_med
		labe var absRifleA_med "Rifles"
	gen absShotgunA_med = absShotgun_med + absRifleA_med
		labe var absShotgunA_med "Shotguns"
	gen absOtherarmsA_med = absOtherarms_med + absShotgunA_med
		labe var absSubmachinegunA_med "Submachine guns"

twoway ///
	(area absOtherarmsA_med year, sort graphregion(color(white))) ///
	(area absShotgunA_med year, sort) ///
	(area absRifleA_med year, sort) ///
	(area absHandgunA_med year, sort)
