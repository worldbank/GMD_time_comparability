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


keep countrycode year survname coveragetype datatype comparability
sort countrycode year coveragetype coveragetype

save "data/povcalnet_comparability.dta"
export delimited using "data/povcalnet_comparability.csv", replace


exit

/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.

