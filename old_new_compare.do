/*==================================================
project:       compare old and new comparability data
Author:        David L. Vargas M. 
E-email:       dvargasm@worldbank.org
url:           
Dependencies:  The World Bank | PovcalNet
----------------------------------------------------
Creation Date:    26 Jun 2020 - 09:29:49
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

/*==================================================
              0: Program set up
==================================================*/
drop _all

/*** Detemine paths ***/ 

if (lower("`c(username)'") == "wb384996") {
	cd "c:\Users\wb384996\OneDrive - WBG\WorldBank\DECDG\PovcalNet Team\GMD_time_comparability"
}
if (lower("`c(username)'") == "wb562350") {
	
	cd "C:\Users\wb562350\OneDrive - WBG\Documents\Git\Povcalnet\GMD_time_comparability"
}

/*==================================================
              1: load and clean data
==================================================*/

qui{

	import delimited using "data/povcalnet_comparability_old.csv", clear

	duplicates tag countrycode year datatype coverage, g(dupli)

	gen old_comparability = comparability
	gen old_survname = survname

	tempfile old
	save `old', replace

	use "data/povcalnet_comparability.dta", clear

	gen new_comparability = comparability
	gen new_survname = survname

	merge 1:m countrycode year datatype coverage using `old', update


	/*==================================================
				  2: Define points status and changes
	==================================================*/

	gen status = "new" if _merge == 1
	replace status = "dropped" if _merge == 2
	replace status = "unchanged" if _merge == 3
	replace status = "new missing" if _merge == 4 // does not happen but just be sure

	/*** status changed points ***/
	replace status = "changed" if _merge == 5
	gen change_source = ""
	replace change_source = "survey change" if new_survname != old_survname & (_merge ==5 | _merge ==4)
	replace change_source = "updated comparability" if new_comparability != old_comparability &( _merge ==5 | _merge ==4) & change_source == ""
	replace change_source = "survey & updated comparability" if new_comparability != old_comparability &( _merge ==5 | _merge ==4) & change_source == "survey change"

	loc keepers "countrycode year datatype coverage dupli status change_source old_comparability new_comparability old_survname new_survname"

	keep `keepers'
	order `keepers'
	sort countrycode year

	/*==================================================
				  3: report in console
	==================================================*/

	noi di "The status of the points are"
	noi tab status
	noi di "The changed points are"
	noi cl country year datatype coverage change_source dupli if status == "changed"

} // end qui


exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:


