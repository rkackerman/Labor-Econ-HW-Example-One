clear
clear matrix
set mem 50m
capture cd "C:\My documents\UNC teaching\Labor\PSID\Workfiles"
capture cd "/Users/robertackerman/Desktop/School/Labor Econ I/HW/Homework # 1"

log using "HW1_Ackerman.log", replace

use PSID2003.dta, clear
keep ER21002 ER21017 ER21018 ER21023 ER21123 ER21928 ER21929 ER21020 ER23450 ER23434 ER23446 ER23454 ER24179
gen  indid2003=ER21002*100+1
sort indid2003
save psid2003w.dta, replace

use PSID2005.dta, clear
keep ER25002 ER25017 ER25018 ER25020 ER25023 ER25104 ER25909 ER25910 ER27401 ER27413 ER27417 ER27421 ER28078 ER27704
gen indid2005=ER25002*100+1
sort indid2005
save psid2005w.dta, replace

use hhlink_ex.dta
keep indid2003 indid2005
sort indid2003
save psidlink.dta, replace

use psid2003w.dta, clear
merge 1:1 indid2003 using psidlink.dta
sort indid2003
save psidmerged.dta, replace

use hhlink_ex.dta, clear
keep indid2003 indid2005
drop if indid2005==0
sort indid2005
save psidlink2.dta, replace

use psid2005w.dta, clear
joinby indid2005 using psidlink2.dta
save psid2005w.dta, replace

use psidmerged.dta, clear
merge 1:1 indid2005 indid2003 using psid2005w.dta, gen(_merge3)
save psidmergedfinal.dta, replace

count if indid2005==0

rename ER21017 age2003
rename ER21018 female2003
rename ER21023 married2003
rename ER21123 wrknow2003
rename ER21928 wagdum2003
rename ER21929 wagamt2003
rename ER21020 numkid2003
rename ER24179 weight2003

rename ER25017 age2005
rename ER25018 female2005
rename ER25020 numkid2005
rename ER25023 married2005
rename ER25104 wrknow2005
rename ER25909 wagdum2005
rename ER25910 wagamt2005
rename ER28078 weight2005
rename ER27704 train2005

mvdecode age2003, mv(999=.) 
mvdecode married2003, mv(9=.)
mvdecode wagdum2003, mv(8,9=.) 
mvdecode wagamt2003, mv(9999998,9999999=.)
mvdecode wrknow2003, mv(2,4,5,6,7,8,99,0,22=.)
mvdecode wagdum2005, mv(8,9,2,4=.)
mvdecode wagamt2005, mv(9999998,9999999=.) 
mvdecode wrknow2005, mv(2,4,5,6,7,8,99,0=.)
mvdecode train2005, mv(0,9=.)

replace female2003=0 if female2003==1
replace female2003=1 if female2003==2
replace female2005=0 if female2005==1
replace female2005=1 if female2005==2

replace married2003=0 if married2003==2
replace married2003=0 if married2003==3
replace married2003=0 if married2003==4
replace married2003=0 if married2003==5
replace married2005=0 if married2005==2
replace married2005=0 if married2005==3
replace married2005=0 if married2005==4
replace married2005=0 if married2005==5

replace numkid2003=1 if numkid2003==1 |numkid2003==2
replace numkid2003=2 if numkid2003>=3
replace numkid2005=1 if numkid2005==1 |numkid2005==2
replace numkid2005=2 if numkid2005>=3
replace numkid2005=. if _merge3==1

replace wagdum2003=0 if wagdum2003==5
replace wagdum2005=0 if wagdum2005==5

replace train2005=0 if train2005==5

replace wrknow2003=0 if wrknow2003==3
replace wrknow2005=0 if wrknow2005==3

sum indid2003 indid2005 age2003 numkid2003 married2003 wagdum2003 wagamt2003 weight2003 female2003 wrknow2003 age2005 numkid2005 married2005 wagdum2005 wagamt2005 weight2005 female2005 wrknow2005

gen college2003=.

replace college2003=1  if ER23450== 1
replace college2003=0  if ER23450==5
replace college2003=1  if ER23450==0 & ER23454>=16 & ER23454<99 & ER23434==2
replace college2003=0  if ER23450==0 & ER23434==2 & ER23454<16
replace college2003=0  if ER23450==0 & ER23446==5
replace college2003=0  if ER23434==5

gen college2005=.

replace college2005=1  if ER27417== 1
replace college2005=0  if ER27417==5
replace college2005=1  if ER27417==0 & ER27421>=16 & ER27421<99 & ER27401==2
replace college2005=0  if ER27417==0 & ER27401==2 & ER27421<16
replace college2005=0  if ER27417==0 & ER27413==5
replace college2005=0  if ER27401==5

mean age2003 numkid2003 married2003 wagdum2003 wagamt2003 female2003 wrknow2003 college2003 [pweight=weight2003] 
mean age2005 numkid2005 married2005 wagdum2005 wagamt2005 female2005 wrknow2005 college2005 [pweight=weight2005]

reshape long age numkid married wagdum wagamt weight female wrknow college, i(indid2003) j(year)

xtset indid2003 year

xttrans wrknow
/* alternatively:
gen unemp==ll.wrknow
tab wrknow unemp, col*/

probit wrknow age numkid married female college if year==2005 & ll.wrknow==0, robust
margins, dydx(*) atmean
probit wrknow age numkid married female college train2005 if year==2005 & ll.wrknow==0, robust
margins, dydx(*) atmean

drop if weight==0
gen lwag=ln(wagamt)
gen yrdum=1 if year==2005
replace yrdum=0 if year==2003
reg lwag female age college yrdum, robust
reg lwag female age college yrdum [pweight=weight]

probit wagdum female age numkid married yrdum
predict p
reg lwag female age college yrdum [pweight=1/p]


erase psid2003w.dta
erase psid2005w.dta

log close
