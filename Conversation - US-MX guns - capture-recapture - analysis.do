				*** Capture - Recapture Analysis ***
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
	
	** Cenapi - Sedena analysis
tabulate sedena uscourt if CSstudyperiod == 1, column row

	* Direction 1
	sum cenapi if sedena == 1 & CSstudyperiod == 1
		global ratio1 = r(mean)
		global Tc = r(N)
	sum cenapi if cenapi == 1 & sedena == 1 & CSstudyperiod == 1
		global s_c = r(N)
	sum sedena if sedena == 1 & CSstudyperiod == 1
		global s = r(N)
		* $ratio1 is equivalent to x/y here (https://online.stat.psu.edu/stat506/lesson/12/12.1) ///
		* or s_c/s in our methods section

		* Generate estimate 1
		sum sedena if CSstudyperiod == 1
		global total1 = ($ratio1)^-1 * r(N)/ $CSstudyyears
		di $total1
		* Generate variance 1
		global var1 = ($Tc * $s * ($Tc - $s_c) * ($s - $s_c))/($s_c)^3
		di $var1
		* Generate CIs
		global CI1min = ((($ratio1 )^-1 * r(N)) - ( $var2 )^.5) / $CSstudyyears
		global CI1max = ((($ratio1 )^-1 * r(N)) - ( $var2 )^.5) / $CSstudyyears
	
	* Direction 2
	sum sedena if cenapi == 1 & CSstudyperiod == 1
		global ratio2 = r(mean)
		global Ts = r(N)
	sum sedena if cenapi == 1 & sedena == 1 & CSstudyperiod == 1
		global c_s = r(N)
	sum cenapi if cenapi == 1 & CSstudyperiod == 1
		global c = r(N)
		* $ratio is equivalent to x/y here (https://online.stat.psu.edu/stat506/lesson/12/12.1) ///
		* or c_s/c in our methods section

		* Generate annual estimate 2
		sum cenapi if CSstudyperiod == 1
		global total2 = (($ratio2 )^-1 * r(N))/ $CSstudyyears
		di $total2
		* Generate variance 2
		global var2 = ($Ts * $c * ($Ts - $c_s) * ($c - $c_s))/($c_s)^3
		di $var2
		* Generate annual CIs
		global CI2min = ((($ratio2 )^-1 * r(N)) - ( $var2 )^.5)/ $CSstudyyears
		global CI2max = (($ratio2 )^-1 * r(N)) + ($var2)^.5 / $CSstudyyears
	
	* Calculate the averages
global totalavg = ($total1 + $total2) / 2
	di $totalavg
	* Weighting variances by the relative DFs
sum cenapi if sedena == 1 & CSstudyperiod == 1
	global DF1 = r(N)
sum sedena if cenapi == 1 & CSstudyperiod == 1
	global DF2 = r(N)
	global varavg = (($var1 * $DF1)+($var2 * $DF2))/($DF1 + $DF2)
	* Generate annual average CIs
	global CIavgmin = $totalavg - ( $varavg )^.5
	global CIavgmax = $totalavg + ($varavg)^.5

/*
program drop tabest 
*/
program tabest
	di _skip(3)"Reference Dataset" _skip(2) "|" _skip(2) "Estimate" _skip(2) "|" _skip(2) "Lower Bound" _skip(2) "|" _skip(2) "Upper Bound" _skip(5)
	di "{hline 30}"
	di _skip(3) "SEDENA" _skip(13) "|" _skip(2) $total1 _skip(1) "|" _skip(2) $CI1min _skip(4) "|" _skip(2) $CI1max
	di _skip(3) "CENAPI" _skip(13) "|" _skip(2) $total2 _skip(1) "|" _skip(2) $CI2min _skip(4) "|" _skip(2) $CI2max
	di _skip(3) "Average" _skip(12) "|" _skip(2) $totalavg _skip(1) "|" _skip(2) $CIavgmin _skip(4) "|" _skip(2) $CIavgmax
	end

tabest

sum daterecov
local min_date = r(min)
local max_date = r(max)
display "Minimum date: " %td `min_date'
display "Maximum date: " %td `max_date'
