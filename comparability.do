/*==================================================
project:       create comparability database
Author:        R.Andres Castaneda
E-email:       acastanedaa@worldbank.org
url:
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:     2020-03-27  
Do-file version:    01
References:
Output:
==================================================*/

//========================================================
// Load latest data on datalibweb
//========================================================

*##s
drop _all
if ("`cpivin'" == "") {
	local cpipath "c:\ado\personal\Datalibweb\data\GMD\SUPPORT\SUPPORT_2005_CPI"
	local cpidirs: dir "`cpipath'" dirs "*CPI_*_M"
	
	local cpivins "0"
	foreach cpidir of local cpidirs {
		if regexm("`cpidir'", "cpi_v([0-9]+)_m") local cpivin = regexs(1)
		local cpivins "`cpivins', `cpivin'"
	}
	local cpivin = max(`cpivins')
} // if no cpi vintage is selected

if wordcount("`cpivin'") == 1 {
	local cpivin = "0`cpivin'"
}

cap datalibweb, country(Support) year(2005) type(GMDRAW) fileserver /*
*/	surveyid(Support_2005_CPI_v`cpivin'_M) filename(Survey_price_framework.dta)

* Country Code
rename code countrycode

* Coverage type
replace survey_coverage = lower(survey_coverage)

gen coveragetype = cond(survey_coverage == "u", 2, /*
                */ cond(survey_coverage == "r", 1 , 3))

replace coveragetype = 4 if inlist(countrycode, "IND", "IDN", "CHN")  /* 
                           */ & coveragetype == 3


* Data type
replace datatype = cond(lower(datatype) == "i", "2", "1")
destring datatype, replace


* Manual cases
keep if !(countrycode == "BRA" & survname == "PNAD" & inrange(year, 2012, 2015))
keep if !(countrycode == "GEO" & survname == "SGH"  & year  == 1997)
keep if !(countrycode == "RUS" & survname == "RLMS"  & year  == 2001)

// fix for EU-SILC countries. 
replace year = year - 1 if survname == "EU-SILC"
replace year = year - 1 if survname == "SILC-C"

// Armonise coveragetypes 
replace coveragetype = 3 if countrycode == "URY" & year <= 2005
replace coveragetype = 3 if countrycode == "BOL" & year == 1992 // Unsure of this one
replace coveragetype = 2 if countrycode == "ECU" & year == 1998 // Unsure of this one

// Hardcoded cleaning
replace year = year - 1 if countrycode == "MYS" & year >= 2009
replace year = year - 1 if countrycode == "TZA" & year == 2018
replace year = 2014 if     countrycode == "COM" & year == 2013


// countries with income and consumption
tempvar exp 
expand 2 if countrycode  == "PHL" & year >= 2000, gen(`exp')
replace datatype = 2 if `exp' == 1 

tempvar exp 
expand 2 if countrycode  == "MEX" & year >= 1992, gen(`exp')
replace datatype = 1 if `exp' == 1

tempvar exp 
expand 2 if countrycode  == "NIC", gen(`exp')
replace datatype = 1 if `exp' == 1

tempvar exp 
expand 2 if countrycode  == "HTI" & year == 2012 , gen(`exp')
replace datatype = 2 if `exp' == 1

keep countrycode year survname coveragetype datatype comparability
sort countrycode year coveragetype coveragetype


* save "data/povcalnet_comparability.dta"
* export delimited using "data/povcalnet_comparability.csv", replace



tempfile metadata
save `metadata'


povcalnet, clear
merge 1:1 countrycode year coveragetype datatype using "`metadata'"
drop if _merge == 2


exit

/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.
