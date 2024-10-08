


clear
quietly do "Programs.do"


sleep 9000					//9 sec pause to abort if misclick
global reps = 75000          //75000
global bootreps = 7000      //7000
global threads = 15



*** NORMAL ***
clear
plstart, threads($threads) seed(8389)
return list
parallel sim, exp(mean1=r(mean1) mean2=r(mean2) sd1=r(sd1) sd2=r(sd2) n1=r(n1) n2=r(n2) ///
	sdtestp=r(sdtestp) skew1=r(skew1) skew2=r(skew2) kurt1=r(kurt1) kurt2=r(kurt2) ///
	basic_lower=r(basic_lower) basic_upper=r(basic_upper) ///
	welch_lower=r(welch_lower) welch_upper=r(welch_upper) ///
	hc3_lower=r(hc3_lower) hc3_upper=r(hc3_upper) ///
	bsnormal_lower=r(bsnormal_lower) bsnormal_upper=r(bsnormal_upper) ///
	bsbc_lower=r(bsbc_lower) bsbc_upper=r(bsbc_upper) ///	
	) programs(comp) ///
	reps($reps) seed(`r(plseeds)') saving("simres_normal", replace every(500)): ///
		computecis, bsreps($bootreps) type(normal)	
	
*** UNIFORM ***
clear
plstart, threads($threads) seed(3464)
parallel sim, exp(mean1=r(mean1) mean2=r(mean2) sd1=r(sd1) sd2=r(sd2) n1=r(n1) n2=r(n2) ///
	sdtestp=r(sdtestp) skew1=r(skew1) skew2=r(skew2) kurt1=r(kurt1) kurt2=r(kurt2) ///
	basic_lower=r(basic_lower) basic_upper=r(basic_upper) ///
	welch_lower=r(welch_lower) welch_upper=r(welch_upper) ///
	hc3_lower=r(hc3_lower) hc3_upper=r(hc3_upper) ///
	bsnormal_lower=r(bsnormal_lower) bsnormal_upper=r(bsnormal_upper) ///
	bsbc_lower=r(bsbc_lower) bsbc_upper=r(bsbc_upper) ///	
	) programs(comp) ///
	reps($reps) seed(`r(plseeds)') saving("simres_uniform", replace every(500)): ///
		computecis, bsreps($bootreps) type(uniform)		
		
*** BETA ***
clear
plstart, threads($threads) seed(77445)
parallel sim, exp(mean1=r(mean1) mean2=r(mean2) sd1=r(sd1) sd2=r(sd2) n1=r(n1) n2=r(n2) ///
	sdtestp=r(sdtestp) skew1=r(skew1) skew2=r(skew2) kurt1=r(kurt1) kurt2=r(kurt2) ///
	a=r(a) b=r(b) ///
	basic_lower=r(basic_lower) basic_upper=r(basic_upper) ///
	welch_lower=r(welch_lower) welch_upper=r(welch_upper) ///
	hc3_lower=r(hc3_lower) hc3_upper=r(hc3_upper) ///
	bsnormal_lower=r(bsnormal_lower) bsnormal_upper=r(bsnormal_upper) ///
	bsbc_lower=r(bsbc_lower) bsbc_upper=r(bsbc_upper) ///	
	) programs(comp) ///
	reps($reps) seed(`r(plseeds)') saving("simres_beta", replace every(500)): ///
		computecis, bsreps($bootreps) type(beta)
		
		
*** BASELINE ***
/*This part of the simulation has been run on another system later, hence the lower
number of threads*/
clear
plstart, threads(5) seed(22332)
parallel sim, exp(mean1=r(mean1) mean2=r(mean2) sd1=r(sd1) sd2=r(sd2) n1=r(n1) n2=r(n2) ///
	sdtestp=r(sdtestp) skew1=r(skew1) skew2=r(skew2) kurt1=r(kurt1) kurt2=r(kurt2) ///
	a=r(a) b=r(b) ///
	basic_lower=r(basic_lower) basic_upper=r(basic_upper) ///
	welch_lower=r(welch_lower) welch_upper=r(welch_upper) ///
	hc3_lower=r(hc3_lower) hc3_upper=r(hc3_upper) ///
	bsnormal_lower=r(bsnormal_lower) bsnormal_upper=r(bsnormal_upper) ///
	bsbc_lower=r(bsbc_lower) bsbc_upper=r(bsbc_upper) ///	
	) programs(comp) ///
	reps(75000) seed(`r(plseeds)') saving("simres_baseline", replace every(500)): ///
		baseline, bsreps(7500) type(normal)	

		
		
cap log close

