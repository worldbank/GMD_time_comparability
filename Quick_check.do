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

if (lower("`c(username)'") == "wb384996") {
	cd "c:\Users\wb384996\OneDrive - WBG\WorldBank\DECDG\PovcalNet Team\GMD_time_comparability"
}
if (lower("`c(username)'") == "wb562350") {
	cd "C:\Users\wb562350\OneDrive - WBG\Documents\Git\Povcalnet\GMD_time_comparability"
}


drop _all

povcalnet, clear
keep countrycode year coveragetype datatype

preserve
drop _all
tempfile comparability
*import delimited "data/DDH_versions/povcalnet_comparability_14052020.csv"
import delimited "data/povcalnet_comparability.csv"
save `comparability'
restore

merge 1:1 countrycode year coveragetype datatype using "`comparability'"

exit

/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.
