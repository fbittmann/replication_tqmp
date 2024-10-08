


*Felix Bittmann, 2024
*felix.bittmann@lifbi.de


clear all
version 16.1
cd ""



*** Required Stata Ados ***
ssc install fre, replace
ssc install blindschemes, replace
ssc install estout, replace
net install plstart, from("https://raw.github.com/fbittmann/plstart/stable") replace
net install parallel, from("https://raw.github.com/gvegayon/parallel/stable/") replace
mata mata mlib index



*** Order of analysis ***
1. Master.do
2. Programs.do
3. Simulation.do
4. Analysis_baseline.do
5. Analysis_normal.do
6. Analysis_uniform.do
7. Analysis_beta.do
