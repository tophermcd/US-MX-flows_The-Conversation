cd "G:\My Drive\Research\Firearms Economics\Conversation Report\"

use "CENAPI_UScourt.dta", clear

encode FFL, gen(FFLnn)
order FFLnn, after(FFLn)
drop FFLn
rename FFLnn FFLn

gen countFFL = 1
replace countFFL = 0 if FFL == ""
replace countFFL = 0 if FFLaddress == ""
replace countFFL = 0 if statesale == ""
replace countFFL = 0 if citysale == ""


gen MXpurchase = 0
replace MXpurchase = 1 if strpos(strlower(FFL),"mexican")>0

sum countFFL if countFFL == 1
sum countFFL if FFLaddress != ""
sum countFFL if MXpurchase == 0 & countFFL == 1

sum MXpurchase
