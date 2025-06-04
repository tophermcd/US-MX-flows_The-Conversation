## Note from Topher Mcdougal, Professor of Economic Development & Peacebuilding at the University of San Diego:

This repository of STATA .do files are part of the research I did for The Conversation story [Mexican drug cartels use hundreds of thousands of guns bought from licensed US gun shops – fueling violence in Mexico, drugs in the US and migration at the border](https://stories.theconversation.com/mexican-drug-cartels-use-hundreds-of-thousands-of-guns-bought-from-licensed-us-gun-shops-fueling-violence-in-mexico-drugs-in-the-u-s-and-migration-at-the-border/index.html), which I wrote with investigative journalist Sean Campbell.

This repository is intended to help readers with an interest in digging deeper into how I got the numbers we described in this story.  

Sean and I also wrote a [methodological note](https://www.documentcloud.org/documents/25906369-us-mx-firearms-methodology-v8-final/) that details the research.

The data these .do files were designed to operate on are publicly available.


## The data we used:



1. [The Guacamaya, or CENAPI dataset](https://stopusarmstomexico.org/wp-content/uploads/2024/05/ARMAS-RASTREADAS-DE-EUA_31-12-2018_25-11-2020.xlsx): 24,000 detailed records of firearms compiled by The Mexican National Center for Planning, Analysis and Information for Combating Crime	(CENAPI) from December 2018 through November 2020 and compiled by Mexico’s Attorney General office (FGR). The U.S. ATF had traced around 15,000 of these to origins in the U.S., including 7,000 to a specific gun dealer.


	Source: Emails obtained by Mexican authorities and leaked by the hacktivist organization Guacamaya in September 2022. The data is available through the non-profit repository of hacked and leaked data [Distributed Denial of Secrets](https://ddosecrets.com/article/secretaria-de-la-defensa-nacional-de-mexico) and is also [posted by Stop U.S. Arms to Mexico](https://stopusarmstomexico.org/wp-content/uploads/2024/05/ARMAS-RASTREADAS-DE-EUA_31-12-2018_25-11-2020.xlsx).

2. [The SEDENA dataset](https://docs.google.com/spreadsheets/d/1Bm5ROCheEB5pex2l3yaVT0g2jU_6M7WW/edit?usp=drive_link&ouid=100832007414273366079&rtpof=true&sd=true): 142,000 detailed records of firearms seized by Mexico’s Secretariat of National Defence, or Army, known as SEDENA, from January 2010 through  March 1, 2023.

	Source: acquired by Stop U.S. Arms to Mexico through an information request to SEDENA

3. [Court Case dataset](https://github.com/tophermcd/US-MX-flows_The-Conversation/blob/main/Court%20case%20dataset.csv): information compiled from one hundred court cases that involved gun trafficking from the U.S. to Mexico in 2008-2024

	Source: Sean Campbell

4. Receipts datasets: receipts for firearms that were transferred to state and local police in Mexico from [2006 - 2018](https://stopusarmstomexico.org/wp-content/uploads/2020/12/Armas_Policias_Mexico.xlsx) and [Dec. 1, 2018 - Nov. 6, 2023](https://stopusarmstomexico.org/wp-content/uploads/2024/06/Facturas-SEDENA-2019-2023-web.xlsx)

	Source: acquired by Stop U.S. Arms to Mexico through an information request to SEDENA

5. [Federal Firearms Licensees](https://www.atf.gov/firearms/listing-federal-firearms-licensees) from 2014 – 2023

	Source: U.S. Bureau of Alcohol, Tobacco, Firearms and Explosives (ATF)

6. ATF [Violations data 2015-2018](https://projects.thetrace.org/inspections/violation/)

	Source: The Trace compilation of data acquired by the nonprofit Brady: United Against Gun Violence through a lawsuit

7. Firearms Manufacturers and Export Reports 1993 - 2022

	[https://www.atf.gov/resource-center/docs/report/2021-firearms-commerce-report/download](https://www.atf.gov/resource-center/docs/report/2021-firearms-commerce-report/download)


	[https://www.atf.gov/firearms/docs/report/2022-final-afmer/download](https://www.atf.gov/firearms/docs/report/2022-final-afmer/download)


	Source: ATF

8. ATF Trace Data, 2014 – 2022

	[https://www.atf.gov/resource-center/data-statistics](https://www.atf.gov/resource-center/data-statistics)


	[https://www.atf.gov/file/144886/download](https://www.atf.gov/file/144886/download)


	[https://www.atf.gov/resource-center/firearms-trace-data-mexico-2015-2020](https://www.atf.gov/resource-center/firearms-trace-data-mexico-2015-2020)


	[https://www.atf.gov/resource-center/firearms-trace-data-mexico-2017-2022](https://www.atf.gov/resource-center/firearms-trace-data-mexico-2017-2022)


	[https://www.atf.gov/resource-center/firearms-trace-data-mexico-2018-2023](https://www.atf.gov/resource-center/firearms-trace-data-mexico-2018-2023)



## Our findings:


### Total flow

We used the capture-recapture method to estimate that the flow of guns trafficked from the U.S. to Mexico in 2022 was 84,000, then combined that with other estimates for a middle estimate of 134,000.

**Analysis files for this:**

* Conversation - US-MX guns - capture-recapture - analysis.do


### Provenance

We used simple frequency (i.e. count) analysis to show that the most destructive weapons are more likely to come from independent gun dealers than large chain stores. We found that independent dealers sell 16 times as many assault-style weapons and 60 times as many sniper rifles to people.

**Analysis files for this:**



* Conversation - US-MX guns - FFLid - Chain Stores.do
* Conversation - US-MX guns - FFLid - Cities.do
* Conversation - US-MX guns - FFLid.do
* Conversation - US-MX guns - FFLid - Ind Stores.do
* Conversation - US-MX guns - graphs by gun type and caliber.do


### Homicides

We used log-log OLS and Poisson regression analysis to show that an increase in guns trafficked to Mexico from the U.S. is directly related to a significant increase in Mexico’s homicide rate.

**Analysis files for this:**



* Conversation - US-MX guns - homicides & guns - analysis.do


### Arms race

We used 2-stage least squares regression analysis to show that the flow drives an arms race between criminals and Mexican law enforcement to the benefit of a U.S. gun industry that profits on sales from both ends.

**Analysis files for this:**



* Conversation - US-MX guns - police orders base caliber - data cleaning.do
* Conversation - US-MX guns - police orders base caliber - analysis.do


### Recovery times

We used survival analysis to show that state-level firearms sales laws can speed up the recovery of trafficked weapons.

**Analysis files for this:**



* Conversation - US-MX guns - court cases - survival analysis.do


### ATF enforcement effects

We used logistics, negative binomial, and log-log regression approaches to show that ATF oversight of dealers reduces the likelihood their guns are resold on the illicit market.

**Analysis files for this:**



* Conversation - US-MX guns - ATF Demand 2 overlap.do
* Conversation - US-MX guns - ATF citation policy - analysis.do


### Notes on using the .do files:

Run the six data creation / cleaning files first and preferably in the following order:



1. Conversation - US-MX guns - SEDENA - data cleaning.do
2. Conversation - US-MX guns - Cenapi - data creation.do
3. Conversation - US-MX guns - ATF citation policy - data creation.do
4. Conversation - US-MX guns - court cases - data creation.do
5. Conversation - US-MX guns - police orders base caliber - data cleaning.do
6. Conversation - US-MX guns - capture-recapture - data creation.do

The following file will be invoked by the data creation and cleaning files to standardized major manufacturer names, but need not be run separately:



* Conversation - US-MX guns - manufcorrect.do

Then run analysis files as needed.



* Conversation - US-MX guns - ATF citation policy - analysis.do
* Conversation - US-MX guns - ATF coverage.do
* Conversation - US-MX guns - ATF Demand 2 overlap.do
* Conversation - US-MX guns - ATF traces JLP - bystate.do
* Conversation - US-MX guns - capture-recapture - analysis.do
* Conversation - US-MX guns - Counts.do
* Conversation - US-MX guns - court cases - survival analysis.do
* Conversation - US-MX guns - FFL type trends.do
* Conversation - US-MX guns - FFLid - Chain Stores.do
* Conversation - US-MX guns - FFLid - Cities.do
* Conversation - US-MX guns - FFLid.do
* Conversation - US-MX guns - FFLid - Ind Stores.do
* Conversation - US-MX guns - graphs by gun type and caliber.do
* Conversation - US-MX guns - homicides & guns - analysis.do
* Conversation - US-MX guns - legal leakage.do
* Conversation - US-MX guns - police orders base caliber - analysis.do

