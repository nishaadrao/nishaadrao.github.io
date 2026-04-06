clear all
set maxvar 30000
set more off

cd R:\mfa\raon\datasets\psid\clean_data

local version = 2023

use crossfam`version', clear

local stubs "bf bm af am"

foreach j in `stubs'{

	preserve

	forval i = 1999(2)`version'{
	
		rename *`i' *_`j'`i'
	}
	
	forval i = 1968/1997{
	
		rename *`i' *_`j'`i'
	}

	rename rauid rauid_`j' 

	save crossfam`version'_`j', replace  

	restore 

}

merge 1:1 rauid using fims_psid, keep(match master) nogen 

foreach j in `stubs'{

	merge m:1 rauid_`j' using crossfam`version'_`j', keep(match master) nogen 

}

save crossfam`version'_ig, replace 

