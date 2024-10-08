

*** Read in data ***
use "simres_normal", clear



*** Generate coverage and width ***
foreach VAR of newlist basic welch hc3 bsnormal bsbc {
	gen width_`VAR' = `VAR'_upper - `VAR'_lower
	gen coverage_`VAR' = `VAR'_lower < 0 & 0 < `VAR'_upper
}


gen ratio_sd = sd1 / sd2
replace ratio_sd = sd2 / sd1 if ratio_sd < 1

gen minsize = n1 if n1 <= n2
replace minsize = n2 if n2 <= n1

gen ratio_n = n1 / n2
replace ratio_n = n2 / n1 if ratio_n < 1

gen unequalsd = sdtest < 0.05
gen all = 1
sum width*
sum coverage*
sum ratio_n ratio_sd minsize unequalsd


ci prop coverage*
ci means width*


recode minsize (15/30 = 0) (31/75 = 1) (76/200 = 2), gen(minsize_cat)
label define minsize_cat 0 "15/30" 1 "31/75" 2 "76/200"
label values minsize_cat minsize_cat
fre minsize

recode ratio_sd (1/1.3 = 0) (1.3/2.2 = 1) (2.2/6.5 = 2), gen(ratio_sd_cat)
label define ratio_sd_cat 0 "1/1.3" 1 "1.3/2.2" 2 "2.2/6.5"
label values ratio_sd_cat ratio_sd_cat

recode ratio_n (1/1.5 = 0) (1.5/2.5 = 1) (2.5/15 = 2), gen(ratio_n_cat)
label define ratio_n_cat 0 "1/1.5" 1 "1.5/2.5" 2 "2.5/15"
label values ratio_n_cat ratio_n_cat

gen n_sd_cat = (ratio_n_cat + 1) * 10 + (ratio_sd_cat + 1)
fre minsize_cat ratio_sd_cat ratio_n_cat n_sd_cat


********************************************************************************
*** Descriptive statistics ***
********************************************************************************
label var mean1 "Mean 1"
label var mean2 "Mean 2"
label var sd1 "SD 1"
label var sd2 "SD 2"
label var n1 "Observations 1"
label var n2 "Observations 2"
label var ratio_sd "Ratio SD"
label var ratio_n "Ratio N"
label var unequalsd "Unequal SD"
eststo M1: estpost summarize mean1 mean2 sd1 sd2 n1 n2 ratio_sd ratio_n unequalsd, det
esttab M1 using "Deskription_normal.rtf", ///
	cells("mean(fmt(a2)) p50 sd min max skewness kurtosis") ///
	rtf replace label


********************************************************************************
*** Create Table overview Coverage + CIs ***
********************************************************************************
tempfile file
tempname name
postfile `name' str16 first str9 Basic1 str9 Basic2 ///
	str9 Welch1 str9 Welch2 str9 HC31 str9 HC32 ///
	str9 BSnormal1 str9 BSnormal2 str9 BSBC1 str9 BSBC2 ///
	using `file', replace
foreach VAR of varlist all unequalsd minsize_cat ratio_n_cat ratio_sd_cat n_sd_cat {
	levelsof `VAR', local(levels)
	foreach l of local levels {
		foreach TYPE of varlist coverage* {
			ci prop `TYPE' if `VAR' == `l'
			local mean_`TYPE' = r(proportion) * 100
			local l_`TYPE' = r(lb) * 100
			local u_`TYPE' = r(ub) * 100
			local n = r(N)
		}
		post `name' ("`VAR' = `l'") ("`mean_coverage_basic'") ("") ("`mean_coverage_welch'") ("") ///
			("`mean_coverage_hc3'") ("") ("`mean_coverage_bsnormal'") ("") ("`mean_coverage_bsbc'") ("")
		post `name' ("N = `n'") ("`l_coverage_basic'") ("`u_coverage_basic'") ///
		("`l_coverage_welch'") ("`u_coverage_welch'") ///
		("`l_coverage_hc3'") ("`u_coverage_hc3'") ///
		("`l_coverage_bsnormal'") ("`u_coverage_bsnormal'") ///
		("`l_coverage_bsbc'") ("`u_coverage_bsbc'")
	}
}
postclose `name'

*** Write results to Excel file ***
preserve
use `file', clear
list
export excel using "res_normal", replace firstrow(variables)
restore

********************************************************************************
*** Create Table overview Width + CIs ***
********************************************************************************
tempfile file
tempname name
postfile `name' str16 first str9 Basic1 str9 Basic2 ///
	str9 Welch1 str9 Welch2 str9 HC31 str9 HC32 ///
	str9 BSnormal1 str9 BSnormal2 str9 BSBC1 str9 BSBC2 ///
	using `file', replace
foreach VAR of varlist all unequalsd minsize_cat ratio_n_cat ratio_sd_cat n_sd_cat {
	levelsof `VAR', local(levels)
	foreach l of local levels {
		foreach TYPE of varlist width* {
			ci means `TYPE' if `VAR' == `l'
			local mean_`TYPE' = r(mean)
			local l_`TYPE' = r(lb)
			local u_`TYPE' = r(ub)
			local n = r(N)
		}
		post `name' ("`VAR' = `l'") ("`mean_width_basic'") ("") ("`mean_width_welch'") ("") ///
			("`mean_width_hc3'") ("") ("`mean_width_bsnormal'") ("") ("`mean_width_bsbc'") ("")
		post `name' ("N = `n'") ("`l_width_basic'") ("`u_width_basic'") ///
		("`l_width_welch'") ("`u_width_welch'") ///
		("`l_width_hc3'") ("`u_width_hc3'") ///
		("`l_width_bsnormal'") ("`u_width_bsnormal'") ///
		("`l_width_bsbc'") ("`u_width_bsbc'")
	}
}
postclose `name'

*** Write results to Excel file ***
preserve
use `file', clear
list
export excel using "res_width_normal", replace 
restore



*** Overall ***
graph bar coverage*, exclude0 ylabel(0.93(0.005)0.96) ///
	blabel(bar, format(%7.3f)) ///
	bar(1, color(%80)) bar(2, color(%80)) bar(3, color(%80)) bar(4, color(%80)) bar(5, color(%80)) ///
	legend(order(1 "T-Test" 2 "Welch" 3 "OLS" 4 "BSN" 5 "BSBC") position(6) row(1)) yline(.95) ///
	name(g1, replace) title("Normal distribution") ytitle("Coverage")
graph save "all_normal", replace
graph export "all_normal.png", replace width(2500)

	
