


*Felix Bittmann, 2024

cap program drop comp
program define comp, rclass
	/* Computes the mean of two groups as fast as possible*/
	syntax varlist, g(string)
	qui summarize `varlist' if `g' == 0, meanonly
	local m1 = r(mean)
	qui summarize `varlist' if `g' == 1, meanonly
	local m2 = r(mean)
	return scalar diff = `m2' - `m1'
end


*** Conduct simulation ***
cap program drop computecis
program define computecis, rclass
	/*Computes 95% CIs with various methods*/
	syntax, type(string) bsreps(integer)
	clear
	*** Set random parameters ***
	local n1 = runiformint(15, 200)
	local n2 = runiformint(15, 200)
	local ntotal = `n1' + `n2'
	local sd1 = runiform(0.4, 1.6)
	local sd2 = runiform(0.4, 1.6)
		
	*** Apply treatment ***
	set obs `ntotal'
	gen group = 0 in 1/`n1'
	replace group = 1 if missing(group)
	
	if "`type'" == "normal" {
		gen outcome = rnormal(0, `sd1') if group == 0
		replace outcome = rnormal(0, `sd2') if group == 1
	}
	if "`type'" == "uniform" {
		local a1 = 0
		local b1 = sqrt(12 * (`sd1'^2)) + `a1'
		local mid1 = (`b1' - `a1') / 2
		gen outcome = runiform(`a1', `b1') if group == 0
		local a2 = 0
		local b2 = sqrt(12 * (`sd2'^2)) + `a2'
		local mid2 = (`b2' - `a2') / 2
		local shift = `mid2' - `mid1'
		local a2 = `a2' - `shift'
		local b2 = `b2' - `shift'		
		replace outcome = runiform(`a2', `b2') if group == 1
	}
	if "`type'" == "beta" {
		local a = runiform(1.5, 4)
		local b = runiform(5, 9)
		gen outcome = rbeta(`a', `b') if group == 0
		replace outcome = rbeta(`a', `b') if group == 1
		return scalar a = `a'
		return scalar b = `b'
	}
	if !inlist("`type'", "normal", "uniform", "beta") {
		di as error "ERROR! Wrong specification type!"
		return error 1
	}
	
	*** Return simulation specifications ***
	sum outcome if group == 0, det
	return scalar mean1 = r(mean)
	return scalar sd1 = r(sd)
	return scalar n1 = r(N)
	return scalar skew1 = r(skewness)
	return scalar kurt1 = r(kurtosis)
	
	sum outcome if group == 1, det
	return scalar mean2 = r(mean)
	return scalar sd2 = r(sd)
	return scalar n2 = r(N)
	return scalar skew2 = r(skewness)
	return scalar kurt2 = r(kurtosis)
	
	
	*** SD-Test ***
	sdtest outcome, by(group)
	return scalar sdtestp = r(p)
	
	*** Normal ***
	ttest outcome, by(group)
	local tcrit = invt(r(df_t), 0.975)
	local diff = r(mu_2) - r(mu_1)
	local lower = `diff' - `tcrit' * r(se)
	local upper = `diff' + `tcrit' * r(se)
	return scalar basic_lower = `lower'
	return scalar basic_upper = `upper'
	
	*** Welch ***
	ttest outcome, by(group) welch
	local tcrit = invt(r(df_t), 0.975)
	local lower = `diff' - `tcrit' * r(se)
	local upper = `diff' + `tcrit' * r(se)
	return scalar welch_lower = `lower'
	return scalar welch_upper = `upper'
	
	*** Robust ***
	reg outcome group, vce(hc3)
	return scalar hc3_lower = r(table)[5,1]
	return scalar hc3_upper = r(table)[6,1]
	
	*** Bootstrap ***
	bootstrap r(diff), nowarn nodots reps(`bsreps'): comp outcome, g(group)
	estat bootstrap, normal bc
	return scalar bsnormal_lower = e(ci_normal)[1,1]
	return scalar bsnormal_upper = e(ci_normal)[2,1]
	return scalar bsbc_lower = e(ci_bc)[1,1]
	return scalar bsbc_upper = e(ci_bc)[2,1]
end






*** Conduct BASELINE simulation ***
cap program drop baseline
program define baseline, rclass
	/*Computes 95% CIs with various methods*/
	syntax, type(string) bsreps(integer)
	clear
	*** Set random parameters ***
	local n1 = 100
	local n2 = 100
	local ntotal = `n1' + `n2'
	local sd1 = 1
	local sd2 = 1
		
	*** Apply treatment ***
	set obs `ntotal'
	gen group = 0 in 1/`n1'
	replace group = 1 if missing(group)
	
	if "`type'" == "normal" {
		gen outcome = rnormal(0, `sd1') if group == 0
		replace outcome = rnormal(0, `sd2') if group == 1
	}
	if "`type'" == "uniform" {
		local a1 = 0
		local b1 = sqrt(12 * (`sd1'^2)) + `a1'
		local mid1 = (`b1' - `a1') / 2
		gen outcome = runiform(`a1', `b1') if group == 0
		local a2 = 0
		local b2 = sqrt(12 * (`sd2'^2)) + `a2'
		local mid2 = (`b2' - `a2') / 2
		local shift = `mid2' - `mid1'
		local a2 = `a2' - `shift'
		local b2 = `b2' - `shift'		
		replace outcome = runiform(`a2', `b2') if group == 1
	}
	if "`type'" == "beta" {
		local a = runiform(1.5, 4)
		local b = runiform(5, 9)
		gen outcome = rbeta(`a', `b') if group == 0
		replace outcome = rbeta(`a', `b') if group == 1
		return scalar a = `a'
		return scalar b = `b'
	}
	if !inlist("`type'", "normal", "uniform", "beta") {
		di as error "ERROR! Wrong specification type!"
		return error 1
	}
	
	*** Return simulation specifications ***
	sum outcome if group == 0, det
	return scalar mean1 = r(mean)
	return scalar sd1 = r(sd)
	return scalar n1 = r(N)
	return scalar skew1 = r(skewness)
	return scalar kurt1 = r(kurtosis)
	
	sum outcome if group == 1, det
	return scalar mean2 = r(mean)
	return scalar sd2 = r(sd)
	return scalar n2 = r(N)
	return scalar skew2 = r(skewness)
	return scalar kurt2 = r(kurtosis)
	
	
	*** SD-Test ***
	sdtest outcome, by(group)
	return scalar sdtestp = r(p)
	
	*** Normal ***
	ttest outcome, by(group)
	local tcrit = invt(r(df_t), 0.975)
	local diff = r(mu_2) - r(mu_1)
	local lower = `diff' - `tcrit' * r(se)
	local upper = `diff' + `tcrit' * r(se)
	return scalar basic_lower = `lower'
	return scalar basic_upper = `upper'
	
	*** Welch ***
	ttest outcome, by(group) welch
	local tcrit = invt(r(df_t), 0.975)
	local lower = `diff' - `tcrit' * r(se)
	local upper = `diff' + `tcrit' * r(se)
	return scalar welch_lower = `lower'
	return scalar welch_upper = `upper'
	
	*** Robust ***
	reg outcome group, vce(hc3)
	return scalar hc3_lower = r(table)[5,1]
	return scalar hc3_upper = r(table)[6,1]
	
	*** Bootstrap ***
	bootstrap r(diff), nowarn nodots reps(`bsreps'): comp outcome, g(group)
	estat bootstrap, normal bc
	return scalar bsnormal_lower = e(ci_normal)[1,1]
	return scalar bsnormal_upper = e(ci_normal)[2,1]
	return scalar bsbc_lower = e(ci_bc)[1,1]
	return scalar bsbc_upper = e(ci_bc)[2,1]
end

