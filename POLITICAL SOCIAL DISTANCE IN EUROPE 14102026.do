*******************************************************
* Political Social Distance Analysis - Redirect Survey
* Authors: Marco Improta & Elisabetta Mannoni
*******************************************************

* -----------------------------
* 1. Load dataset and clean data
* -----------------------------
use "POLITICAL SOCIAL DISTANCE IN EUROPE.dta", clear   // load dataset
drop if interview==2                                   // drop speeders (interview==2)
recode sdistance1 sdistance2 sdistance3 sdistance4 (98 99=.)

  // recode DK/NA (98,99) to missing
  
* ---------------------------------------------------
* Cleaning sociodemographic variables
* ---------------------------------------------------

* Gender (drop DK/Other codes if present)
recode gndr (97/99=.)   // set DK/NA/non-binary codes to missing

* Age (drop implausible values)
replace age = . if age<18 | age>99   // keep only realistic ages

* Education (ISCED levels)
recode ISCED (97/99=.)   // set DK/NA to missing

* Employment status
recode employment_status_harmonized (97/99=.)   // set DK/NA to missing
drop if employment_status_harmonized == 955
drop if employment_status_harmonized == 999

* Urbanization
recode urban_harmonized (97/99=.)   // set DK/NA to missing
 drop if urban_harmonized == 95

* ---------------------------------------------------
* Cleaning political variables
* ---------------------------------------------------

* Left-right self-placement
recode lr (97/99=.)   // DK/NA to missing

* Past vote (country-specific variables: e.g., pastvote_IT, etc.)
foreach var of varlist pastvote_* {
    recode `var' (97/99=.)
}


* ---------------------------------------------------
* Cleaning attitudinal variables
* ---------------------------------------------------

* Social trust
recode socialtrust (97/99=.)

* Authoritarian values
recode auth1 auth2 auth3 auth4 (97/99=.)

* Populist attitudes
foreach var of varlist pop1-pop6 {
    recode `var' (97/99=.)
}

* Perception of corruption
recode corr1 (97/99=.)

* Economic satisfaction
recode sateco (97/99=.)

* ---------------------------------------------------
* Post-cleaning checks for key variables
* ---------------------------------------------------

* Gender
tab gndr, missing   // should only show Male/Female (no DK/NA)

* Age
summ age, detail    // check min, max, mean after trimming outliers

* Education
tab ISCED, missing   // should only show low/medium/high (no DK/NA)

* Employment status
tab employment_status_harmonized, missing   // check categories, no DK/NA

* Urbanization
tab urban_harmonized, missing   // check categories, no DK/NA

* Left-right scale
summ lr, detail     // check distribution (min, max, mean), no DK/NA

* Social trust
summ socialtrust, detail   // check valid range (1–10 or 0–10 depending on codebook)

* Authoritarian values
summ auth1 auth2 auth3 auth4   // check valid range (Likert 1–5), no DK/NA

* Populism items
summ pop1-pop6   // check valid ranges (Likert 1–5), no DK/NA

* Corruption and economic satisfaction
summ corr1 sateco   // check valid ranges, no DK/NA


* -----------------------------
* 2. Create index of social distance
* -----------------------------
alpha sdistance1 sdistance2 sdistance3 sdistance4      // check reliability (Cronbach's alpha) // We assessed the internal consistency of the four social distance items (friends, neighbours, marriage, co-workers). 
* The scale shows excellent reliability (Cronbach's alpha = 0.94), well above conventional thresholds. 
* This high level of consistency indicates that the items capture a coherent latent construct, allowing us to combine them into a single index of political social distance.

egen sdistance_index = rowmean(sdistance1 sdistance2 sdistance3 sdistance4)   // create index as row mean of 4 items

* -----------------------------
* 3. Descriptive statistics
* -----------------------------
tab1 sdistance1 sdistance2 sdistance3 sdistance4, missing   // frequency tables of all items
summ sdistance_index [aw=wgt_excl_spe_incl_edu]              // summary statistics of the index (with weights)
hist sdistance_index, bin(20) percent title("Distribution of Social Distance Index") xtitle("Index") ytitle("Percent")   // histogram of the index
// After recoding, each of the four social distance items has about 22–25% missing values 
* (corresponding to "Don't know" and "Prefer not to answer"), which is common in cross-national surveys. 
* The distributions are consistent across items: 
* - A majority of respondents position themselves on the "discomfort" side ("not at all" + "not too comfortable"). 
* - Only 8–10% declare to be "extremely comfortable" with outgroup supporters. 
* - Around 18–24% choose "somewhat comfortable," reflecting intermediate attitudes. 
*
* The composite index of social distance (Cronbach's alpha = 0.94) has:
* - N = 12,339 valid cases
* - Mean = 2.24 (on a 1–4 scale), closer to "not too comfortable" than to "somewhat comfortable"
* - SD = 0.90, indicating substantial variation across respondents
* - Full range 1–4, confirming that all response categories are used
*
* Overall interpretation: high social distance in the population, 
* with the majority leaning towards discomfort with outgroup supporters.

* -----------------------------
* 4. Country-level comparison
* -----------------------------
tab country                                                 // number of respondents by country
tabstat sdistance_index [aw=wgt_excl_spe_incl_edu], by(country) stat(mean sd)   // mean and sd of index by country
oneway sdistance_index country [aw=wgt_excl_spe_incl_edu]   // ANOVA test for country differences
graph box sdistance_index, over(country) title("Social Distance Index by Country") ytitle("Index")   // boxplot by country
* -----------------------------
* Comments on country comparison
* -----------------------------
* Sample sizes are well balanced across most countries (≈13% each), with the exception of Norway (≈7%).
*
* The mean social distance index varies substantially across countries:
* - Lowest in Germany (mean ≈1.71, SD=0.72), clearly below the overall mean (2.24).
* - Highest in Norway (mean ≈2.72, SD=0.89) and the UK (mean ≈2.53, SD=0.98).
* - Italy (≈2.39) and Belgium (≈2.35) also above the total mean.
* - France (≈2.13) and Hungary (≈2.04) below the mean, but not as low as Germany.
* - Poland sits close to the overall mean (≈2.23).
*
* The boxplot confirms these differences:
* - Germany shows the lowest median and a compressed distribution (less variance).
* - Norway and the UK display higher medians and longer upper tails, indicating more respondents comfortable with outgroup supporters.
* - Italy and Belgium also skewed towards higher comfort, whereas France and Hungary are closer to the discomfort side.
*
* The ANOVA test is highly significant (F=186.1, p<0.001), rejecting the null hypothesis of equal means across countries.
* Bartlett's test (p<0.001) indicates heterogeneity of variances, which is common in cross-national survey data.
*
* Overall interpretation:
* Political social distance is not uniform across Europe. It is particularly high (less comfort) in Germany and, to a lesser extent, Hungary and France, while Norway, the UK, Italy and Belgium report lower levels of discomfort. These differences are both statistically significant and substantively meaningful.


* -----------------------------
* 5. Socio-demographic predictors
* -----------------------------
reg sdistance_index i.gndr c.age i.ISCED i.employment_status_harmonized i.urban_harmonized [aw=wgt_excl_spe_incl_edu]   // OLS regression with socio-demographic predictors
* Sociodemographic predictors explain only a small share of variation in political social distance (R2=0.017).
* Women and older citizens report slightly greater discomfort with outgroup supporters.
* Higher education is unexpectedly associated with greater distance, not tolerance.
* Being outside stable full-time employment (students, retired, unemployed) correlates with higher discomfort.
* Suburban and rural residents are significantly more comfortable than those in urban centers.
* Overall, sociodemographics matter, but substantive differences are modest.
*
* The negative effect of education and urban residence should not be seen as paradoxical: 
* more educated and urban citizens may perceive the outgroup's opinions and positions as less sophisticated or less legitimate compared to their own. 
* In this sense, higher cultural capital and cosmopolitan settings can increase critical distance rather than reduce it.
* Margins by education and gender
margins ISCED#gndr

* Interaction plot
marginsplot, ///
    title("Education and gender differences in social distance") ///
    ytitle("Predicted Social Distance Index") ///
    xtitle("Education level (ISCED)") ///
    by(gndr) ///
    recast(line)  ///
    yline(2.25, lcolor(gs8) lpattern(dash))
	

* -----------------------------
drop if demimp == 98
drop if demimp == 99
drop if satdem == 98
drop if satdem == 99

drop if lr == 96
drop if lr == 98
drop if lr == 99

//6. Political predictors

reg sdistance_index c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 [aw=wgt_excl_spe_incl_edu]   // OLS regression with ideology, populist attitudes, democratic importance, satisfaction with democracy, and other attitudes

* Political and democratic attitudes significantly predict political social distance (R2=0.054).
* Ideology: moving right increases comfort with outgroup supporters.
* Social trust: strongest positive predictor of comfort, confirming the link between generalized trust and tolerance.
* Populism: mixed effects; pop1 not significant, pop6 positive and significant, indicating some populist dimensions reduce distance.
* Democratic importance: negative effect, suggesting that those who value democracy highly are less comfortable with outgroups—likely due to perceptions that outgroups threaten democracy.
* Satisfaction with democracy: positive effect, citizens satisfied with democratic performance show more openness.
* Economic satisfaction: also positive, linking optimism with greater comfort.
* Corruption perceptions: not significant.
* Overall: generalized trust, satisfaction with democracy and the economy consistently lower social distance, while certain political attitudes (ideology, populism, democratic importance) structure asymmetries in openness.

* Predicted values of social distance by ideology (0-10 scale)
margins, at(lr=(0(1)10))

* Plot with CI
marginsplot, ///
    title("Predicted comfort across the left-right scale") ///
    ytitle("Predicted Social Distance Index") ///
    xtitle("Ideological self-placement (0=Left, 10=Right)") ///
    ylabel(1(0.5)4) ///
    recast(line) recastci(rcap) ///
    plotopts(lcolor(blue) lwidth(medthick)) ///
    ciopts(lcolor(blue%60))

//Modello pooled:
reg sdistance_index i.gndr c.age i.ISCED i.employment_status_harmonized i.urban_harmonized c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 [aw=wgt_excl_spe_incl_edu]


* Predicted values of social distance by social trust (1–10 scale)
margins, at(satdem=(1(1)10))

* Marginsplot
marginsplot, ///
    recast(line) recastci(rcap) ///
    title("Predicted comfort across satdem") ///
    ytitle("Predicted Social Distance Index") ///
    xtitle("satdem (1=Low, 10=High)") ///
    ylabel(1(0.5)4) ///
    plotopts(lcolor(forest_green) lwidth(medthick)) ///
    ciopts(lcolor(forest_green%60))


* Run and store each model
reg sdistance_index i.gndr c.age i.ISCED i.employment_status_harmonized i.urban_harmonized [aw=wgt_excl_spe_incl_edu]
est store M1

reg sdistance_index c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 [aw=wgt_excl_spe_incl_edu]
est store M2

reg sdistance_index i.gndr c.age i.ISCED i.employment_status_harmonized i.urban_harmonized ///
    c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 [aw=wgt_excl_spe_incl_edu]
est store M3

* Forest plot comparing coefficients
coefplot M1 M2 M3, ///
    drop(_cons) ///
    xline(0, lcolor(red) lpattern(dash)) ///
    legend(order(1 "Model 1: Socio-demographics" 2 "Model 2: Political attitudes" 3 "Model 3: Full")) ///
    xlabel(-0.5(0.25)0.5) ///
    xtitle("Coefficient estimates with 95% CI") ///
    title("Determinants of Political Social Distance") ///
    scheme(s1color)

* ---------------------------------------------------
* Country-specific models: socio-demographic and political
* ---------------------------------------------------
* Italy (code = 5)
reg sdistance_index i.gndr c.age i.ISCED i.employment_status_harmonized i.urban_harmonized if country==5 [aw=wgt_excl_spe_incl_edu]
reg sdistance_index c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ib2.pastvote_IT if country==5 [aw=wgt_excl_spe_incl_edu]

reg sdistance_index i.gndr c.age i.ISCED i.employment_status_harmonized i.urban_harmonized c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 if country==5 [aw=wgt_excl_spe_incl_edu]
est store M1


* Italy sociodemographic model
reg sdistance_index i.gndr c.age i.ISCED i.employment_status_harmonized i.urban_harmonized ///
    if country==5 [aw=wgt_excl_spe_incl_edu]
est store IT_soc

* Italy political/attitudinal + past vote model
reg sdistance_index c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ///
    ib2.pastvote_IT if country==5 [aw=wgt_excl_spe_incl_edu]
est store IT_pol

coefplot IT_soc, label("Sociodemographic") || ///
         IT_pol, label("Political/Attitudinal") || , ///
    keep(gndr age ISCED* employment_status_harmonized* urban_harmonized* ///
         lr socialtrust pop1 pop6 demimp satdem sateco corr1 pastvote_IT*) ///
    drop(_cons) ///
    xline(0, lcolor(red)) ///
    legend(order(1 "Sociodemographic" 2 "Political/Attitudinal")) ///
    title("Italy – Predictors of social distance") ///
    xlabel(-1(0.5)1) ///
    scheme(s1mono)


* Italy - Political model with Lega as baseline
* R2 = 0.15, indicating that political and attitudinal variables explain much more variance than sociodemographics.
* Ideology (right self-placement) and social trust are significant positive predictors of comfort with outgroup supporters.
* Satisfaction with democracy also increases comfort, while populism, democratic importance, economic satisfaction, and corruption are not significant.
* Compared to Lega:
* - Radical left (AVS) voters are much less comfortable (strongly negative effect).
* - PD and M5S voters are also less comfortable than Lega supporters.
* - +Europe and People's Union show similar negative trends, though weaker.
* - Voters of Go Italy!, Brothers of Italy, Azione-IV, Italexit, and Sovranists are not significantly different from Lega.
* Overall: in Italy, political social distance is structured along partisan lines, with the left (and M5S) more exclusionary than the Lega and its allies.
* Marginsplot of predicted comfort by past vote - Italy
margins pastvote_IT if country==5
marginsplot, ///
    title("Predicted comfort with outgroup supporters – Italy") ///
    ylabel(1(0.5)4) ///
    ytitle("Predicted Social Distance Index") ///
    xtitle("Past Vote (Italy)") ///
    recast(bar) recastci(rcap) ///
    yline(2.38, lcolor(red) lpattern(dash) lwidth(medthick))



* UK (code = 8)
reg sdistance_index i.gndr c.age i.ISCED i.employment_status_harmonized i.urban_harmonized if country==8 [aw=wgt_excl_spe_incl_edu]
reg sdistance_index c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ib6.pastvote_UK if country==8 [aw=wgt_excl_spe_incl_edu]

reg sdistance_index i.gndr c.age i.ISCED i.employment_status_harmonized i.urban_harmonized c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 if country==8 [aw=wgt_excl_spe_incl_edu]
est store UK
* UK - Political model with Reform UK as baseline
* R2 = 0.218, showing strong explanatory power.
* Attitudes:
* - Populism (pop1) positively associated with comfort.
* - Democratic importance negatively associated with comfort (perceived threat).
* - Satisfaction with democracy increases comfort.
* - Ideology, social trust, economy, corruption are not significant.
* Past vote:
* - Reform UK baseline (constant ≈ 3.20).
* - Conservatives are not significantly different from Reform UK.
* - Labour, LibDems, SNP, Plaid, and Greens are all significantly less comfortable.
* Overall: Reform UK and Conservative voters are the most open, while progressive and regionalist voters exhibit much greater social distance.


drop if pastvote_FR == 999
drop if pastvote_FR == 996
drop if pastvote_FR == 994

* France (code = 2)
reg sdistance_index i.gndr c.age i.ISCED i.employment_status_harmonized i.urban_harmonized if country==2 [aw=wgt_excl_spe_incl_edu]
reg sdistance_index c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ib4.pastvote_FR if country==2 [aw=wgt_excl_spe_incl_edu]


reg sdistance_index i.gndr c.age i.ISCED i.employment_status_harmonized i.urban_harmonized c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1  if country==2 [aw=wgt_excl_spe_incl_edu]
est store FRA
* France - Results summary
* Sociodemographic model (R2=0.023): very low explanatory power.
* - Retired and student respondents are significantly less comfortable with outgroup supporters.
* - Disability shows a positive near-significant effect, suggesting higher comfort.
* - Gender, age, education, unemployment, and urban/rural residence are not significant.
* Overall: socio-demographics explain little variation in France.

* Political/attitudinal model (R2=0.061): slightly better, but still modest explanatory power.
* - Social trust is the strongest positive predictor of comfort.
* - Populism: pop1 null, pop6 weakly positive (near significance).
* - Democratic importance and satisfaction with democracy are not significant.
* - Economic satisfaction is weakly positive, while perceptions of corruption are surprisingly linked to greater comfort.
* Past vote (baseline = National Rally/RN):
* - Voters for the New Popular Front (left) are significantly less comfortable (strong negative effect).
* - Presidential majority (Ensemble) and Republicans do not differ significantly from RN.
* - Other/independent candidates also show no differences.
* Overall: in France, social distance is weakly associated with attitudes and mainly structured by partisan affiliation, with left-wing voters (NFP) being more exclusionary than RN voters.

drop if pastvote_DE == 555
drop if pastvote_DE == 7
drop if pastvote_DE == 8

* Germany (code = 3)
reg sdistance_index i.gndr c.age i.ISCED i.employment_status_harmonized i.urban_harmonized if country==3 [aw=wgt_excl_spe_incl_edu]
reg sdistance_index c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ib4.pastvote_DE if country==3 [aw=wgt_excl_spe_incl_edu]

reg sdistance_index i.gndr c.age i.ISCED i.employment_status_harmonized i.urban_harmonized c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1  if country==3 [aw=wgt_excl_spe_incl_edu]
est store DE
* Germany - Results summary
* Sociodemographic model (R2=0.055):
* - Older respondents, students, and rural residents are significantly less comfortable.
* - Other socio-demographics show no clear effects.
* Political/attitudinal model (R2=0.131):
* - Social trust strongly increases comfort with outgroups.
* - Populism (pop6) also shows a positive association, while democratic importance strongly reduces comfort.
* - Economic satisfaction is a weak but significant positive predictor.
* - Ideology, satisfaction with democracy, and perceptions of corruption are not significant.
* Past vote (baseline = AfD):
* - FDP voters are significantly more comfortable than AfD supporters.
* - CDU/CSU voters are also more comfortable, though effect is modest.
* - SPD, Greens, and Linke voters do not significantly differ from AfD.
* Overall: In Germany, trust and economic optimism reduce social distance, 
* while partisan divides are less pronounced—only FDP and CDU/CSU stand apart as more open compared to AfD.

drop if pastvote_HU == 998
drop if pastvote_HU == 999

* Hungary (code = 4)
reg sdistance_index i.gndr c.age i.ISCED i.employment_status_harmonized i.urban_harmonized if country==4 [aw=wgt_excl_spe_incl_edu]
reg sdistance_index c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ib1.pastvote_HU if country==4 [aw=wgt_excl_spe_incl_edu]


reg sdistance_index i.gndr c.age i.ISCED i.employment_status_harmonized i.urban_harmonized c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1   if country==4 [aw=wgt_excl_spe_incl_edu]
est store HU
* Hungary - Results summary
* Sociodemographic model (R2=0.011): very weak explanatory power.
* - Only part-time workers show lower comfort than full-time employed.
* - Retired respondents marginally less comfortable; all other socio-demographics are not significant.
* Overall: no clear socio-demographic divides in Hungary.

* Political/attitudinal model (R2=0.053): slight improvement but still weak explanatory power.
* - Social trust is the only robust positive predictor of comfort.
* - Ideology, populism, democratic importance, satisfaction with democracy, economic satisfaction, and perceptions of corruption are not significant.
* Past vote (baseline = Fidesz):
* - United for Hungary and Our Homeland voters do not significantly differ from Fidesz supporters.
* Overall: political social distance in Hungary is weakly structured, with trust emerging as the only consistent attitudinal factor.

drop if pastvote_PL == 997
drop if pastvote_PL == 999

* Poland (code = 6)
reg sdistance_index i.gndr c.age i.ISCED i.employment_status_harmonized i.urban_harmonized if country==6 [aw=wgt_excl_spe_incl_edu]
reg sdistance_index c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ib1.pastvote_PL if country==6 [aw=wgt_excl_spe_incl_edu]


reg sdistance_index i.gndr c.age i.ISCED i.employment_status_harmonized i.urban_harmonized c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1  if country==6 [aw=wgt_excl_spe_incl_edu]
est store POL
* Poland - Results summary
* Sociodemographic model (R2=0.041): low explanatory power.
* - Older respondents, temporarily unemployed, and students show greater social distance (less comfort).
* - Disability also trends negative, though marginal.
* - Gender, education, retirement, part-time, and urban/rural residence show no effects.
* Political/attitudinal model (R2=0.090): stronger but still modest explanatory power.
* - Social trust is a strong positive predictor of comfort.
* - Satisfaction with democracy also increases comfort.
* - Populism (pop1) trends negative, indicating greater distance, but only near-significant.
* - Other attitudinal predictors (ideology, pop6, demimp, economic satisfaction, corruption) are not significant.
* Past vote (baseline = Law and Justice / PiS):
* - Civic Coalition voters are significantly less comfortable than PiS supporters.
* - The Left, Third Way, and Confederation do not significantly differ from PiS.
* Overall: in Poland, social distance is shaped more by social trust and democratic satisfaction than by partisanship, with the main divide being between PiS (more open) and Civic Coalition (more exclusionary).


* Norway (code = 7)
reg sdistance_index i.gndr c.age i.ISCED i.employment_status_harmonized i.urban_harmonized if country==7 [aw=wgt_excl_spe_incl_edu]
reg sdistance_index c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 if country==7 [aw=wgt_excl_spe_incl_edu]


reg sdistance_index i.gndr c.age i.ISCED i.employment_status_harmonized i.urban_harmonized c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1  if country==7 [aw=wgt_excl_spe_incl_edu]
est store NOR
* Norway - Results summary
* Sociodemographic model (R2=0.053):
* - Medium and high education are associated with greater comfort (more open).
* - Retired and unemployed respondents are significantly less comfortable.
* - Students and part-time workers also trend less comfortable (marginal).
* - Gender, age, and urban/rural residence have no effect.
* Overall: education fosters openness, while exclusion from stable employment increases social distance.

* Political/attitudinal model (R2=0.127):
* - Social trust strongly increases comfort with outgroup supporters.
* - Populism (pop1) strongly decreases comfort, indicating exclusionary attitudes.
* - Pop6 trends negative but is not significant.
* - Democratic importance, satisfaction with democracy, economic satisfaction, and corruption perceptions are not significant.
* - Ideology is not significant.
* Overall: in Norway, social distance is shaped mainly by social trust (reducing distance) and populism (increasing distance), with no clear partisan structure available.


* Belgium (code = 1)
reg sdistance_index i.gndr c.age i.ISCED i.employment_status_harmonized i.urban_harmonized if country==1 [aw=wgt_excl_spe_incl_edu]
reg sdistance_index c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 if country==1 [aw=wgt_excl_spe_incl_edu]


reg sdistance_index i.gndr c.age i.ISCED i.employment_status_harmonized i.urban_harmonized c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1  if country==1 [aw=wgt_excl_spe_incl_edu]
est store BEL


* Belgium - Results summary
* Sociodemographic model (R2=0.035): modest explanatory power.
* - Older respondents are significantly less comfortable.
* - Medium education is associated with greater comfort (relative to low education).
* - Suburban and rural residents are more comfortable than urban residents.
* - Students trend less comfortable (marginal).
* - Gender, high education, retirement, and unemployment are not significant.
* Overall: social distance in Belgium is shaped more by age and territorial factors.

* Political/attitudinal model (R2=0.012): very weak explanatory power.
* - Social trust is the only significant predictor of greater comfort.
* - Ideology, populism, democratic importance, satisfaction with democracy, economic satisfaction, and corruption perceptions are not significant.
* Overall: in Belgium, political and attitudinal factors explain very little; 
* social distance is largely unrelated to partisanship and mainly reflects social trust and territorial cleavages.
esttab M1 UK FRA DE HU POL NOR BEL, ///
    b(%9.3f) se star(* 0.05 ** 0.01 *** 0.001) ///
    stats(N r2, fmt(%9.0g %9.3f)) ///
	
* 1. Stima della media per country
mean sdistance_index, over(country)

* 2. Grafico delle medie con CI al 95%
coefplot, vertical drop(_cons) ///
    ciopts(lwidth(medthick)) ///
    yline(2.25, lcolor(red) lpattern(dash)) ///
    ytitle("Mean Social Distance Index (1=Discomfort, 4=Comfort)") ///
    title("Average political social distance by country with 95% CI") ///
    xlabel(, angle(vertical))
	
//marginsplot lr per tutti i country
* Italy (5)
reg sdistance_index c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 if country==5 [aw=wgt_excl_spe_incl_edu]
margins, at(lr=(0(1)10))
marginsplot, recast(line) recastci(rcap) ///
    title("Italy") ///
    ytitle("Predicted Social Distance Index") ///
    xtitle("Left–Right self-placement") ///
    ylabel(1(0.5)4) ///
    name(it_lr, replace)

* UK (8)
reg sdistance_index c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 if country==8 [aw=wgt_excl_spe_incl_edu]
margins, at(lr=(0(1)10))
marginsplot, recast(line) recastci(rcap) ///
    title("UK") ///
    ylabel(1(0.5)4) ///
    xtitle("Left–Right self-placement") ///
    name(uk_lr, replace)

* France (2)
reg sdistance_index c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 if country==2 [aw=wgt_excl_spe_incl_edu]
margins, at(lr=(0(1)10))
marginsplot, recast(line) recastci(rcap) ///
    title("France") ///
    ylabel(1(0.5)4) ///
    xtitle("Left–Right self-placement") ///
    name(fr_lr, replace)

* Germany (3)
reg sdistance_index c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 if country==3 [aw=wgt_excl_spe_incl_edu]
margins, at(lr=(0(1)10))
marginsplot, recast(line) recastci(rcap) ///
    title("Germany") ///
    ylabel(1(0.5)4) ///
    xtitle("Left–Right self-placement") ///
    name(de_lr, replace)

* Hungary (4)
reg sdistance_index c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 if country==4 [aw=wgt_excl_spe_incl_edu]
margins, at(lr=(0(1)10))
marginsplot, recast(line) recastci(rcap) ///
    title("Hungary") ///
    ylabel(1(0.5)4) ///
    xtitle("Left–Right self-placement") ///
    name(hu_lr, replace)

* Poland (6)
reg sdistance_index c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 if country==6 [aw=wgt_excl_spe_incl_edu]
margins, at(lr=(0(1)10))
marginsplot, recast(line) recastci(rcap) ///
    title("Poland") ///
    ylabel(1(0.5)4) ///
    xtitle("Left–Right self-placement") ///
    name(pl_lr, replace)

* Norway (7)
reg sdistance_index c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 if country==7 [aw=wgt_excl_spe_incl_edu]
margins, at(lr=(0(1)10))
marginsplot, recast(line) recastci(rcap) ///
    title("Norway") ///
    ylabel(1(0.5)4) ///
    xtitle("Left–Right self-placement") ///
    name(no_lr, replace)

* Belgium (1)
reg sdistance_index c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 if country==1 [aw=wgt_excl_spe_incl_edu]
margins, at(lr=(0(1)10))
marginsplot, recast(line) recastci(rcap) ///
    title("Belgium") ///
    ylabel(1(0.5)4) ///
    xtitle("Left–Right self-placement") ///
    name(be_lr, replace)
graph combine it_lr uk_lr fr_lr de_lr hu_lr pl_lr no_lr be_lr, col(4) ///
    title("Predicted comfort across the left-right scale, by country")

	
//Robustness tests 
* Fixed Effects for country
reg sdistance_index i.gndr c.age i.ISCED i.employment_status_harmonized ///
    c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ///
    i.country [aw=wgt_excl_spe_incl_edu], robust
est store FE_country

* Random Effects (panel) treating country as panel
xtset country
xtreg sdistance_index i.gndr c.age i.ISCED i.employment_status_harmonized ///
    c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1, re
est store RE_country

* Multilevel / Mixed Effects with random intercept by country
mixed sdistance_index i.gndr c.age i.ISCED i.employment_status_harmonized ///
    c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ///
    || country:, variance
est store ML_country


//Rifare su singoli itemi di social distance
* Full model su ciascun item
reg sdistance1 i.gndr c.age i.ISCED i.employment_status_harmonized ///
    c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ///
    [aw=wgt_excl_spe_incl_edu]
est store m1

reg sdistance2 i.gndr c.age i.ISCED i.employment_status_harmonized ///
    c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ///
    [aw=wgt_excl_spe_incl_edu]
est store m2

reg sdistance3 i.gndr c.age i.ISCED i.employment_status_harmonized ///
    c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ///
    [aw=wgt_excl_spe_incl_edu]
est store m3

reg sdistance4 i.gndr c.age i.ISCED i.employment_status_harmonized ///
    c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ///
    [aw=wgt_excl_spe_incl_edu]
est store m4

* Esporta in LaTeX con esttab (pacchetto estout)
esttab m1 m2 m3 m4 using items.tex, replace label se star(* 0.05 ** 0.01 *** 0.001) ///
    title("OLS regressions on political social distance items") ///
    mtitles("Friends" "Neighbours" "Marriage" "Co-workers") ///
    alignment(D{.}{.}{-1}) b(3) se(3)



//Descrittive tab indep var e dep var
 sum sdistance_index gndr age ISCED employment_status_harmonized urban_harmonized lr socialtrust pop1 pop6 demimp satdem sateco corr1 

//Descrittive  histogram dep var
* Histogram with kernel density overlaid
histogram sdistance_index, ///
    width(0.2) percent ///
    xtitle("Social Distance Index (1 = Discomfort, 4 = Comfort)") ///
    ytitle("Percent") ///
    title("Distribution with kernel density") ///
    addplot(kdensity sdistance_index [aw=wgt_excl_spe_incl_edu], ///
            lcolor(red) lwidth(medthick))



	
* Quadratic term for age
reg sdistance_index i.gndr c.age c.age#c.age i.ISCED i.employment_status_harmonized ///
    c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ///
    [aw=wgt_excl_spe_incl_edu], robust
	
* Adding authoritarian values
reg sdistance_index i.gndr c.age i.ISCED i.employment_status_harmonized ///
    c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ///
    auth1 auth2 auth3 auth4 [aw=wgt_excl_spe_incl_edu], robust
	
* Test di affidabilità (già sai che alpha ≈ 0.94)
alpha sdistance1 sdistance2 sdistance3 sdistance4, item std

* Questo produce:
* - Cronbach's alpha
* - Alpha se un item viene eliminato
* - Correlazioni item-test
* Serve a mostrare che ogni item contribuisce in modo coerente.

* PCA sui 4 item di social distance
pca sdistance1 sdistance2 sdistance3 sdistance4

* Eigenvalues e varianza spiegata → ci si aspetta 1 fattore dominante
screeplot, yline(1)    // Scree plot con linea a eigenvalue = 1

* Estrazione fattore comune (ML o principal factor)
factor sdistance1 sdistance2 sdistance3 sdistance4, ml

* Rotazione non serve con 1 fattore, ma se vuoi forzare:
factor sdistance1 sdistance2 sdistance3 sdistance4, factors(1)

* Creiamo un indice alternativo dal fattore stimato
predict sdistance_factor if e(sample)

* Poi puoi confrontare regressioni con sdistance_index e sdistance_factor
reg sdistance_index c.lr c.socialtrust [aw=wgt_excl_spe_incl_edu]
reg sdistance_factor c.lr c.socialtrust [aw=wgt_excl_spe_incl_edu]

* Random slope per social trust
mixed sdistance_index i.gndr c.age i.ISCED i.employment_status_harmonized ///
      c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ///
      || country: c.socialtrust, variance

* Random slope per ideology (lr)
mixed sdistance_index i.gndr c.age i.ISCED i.employment_status_harmonized ///
      c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ///
      || country: c.lr, variance


* Item 1
ologit sdistance1 i.gndr c.age i.ISCED i.employment_status_harmonized ///
       c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 [aw=wgt_excl_spe_incl_edu]

* Item 2
ologit sdistance2 i.gndr c.age i.ISCED i.employment_status_harmonized ///
       c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 [aw=wgt_excl_spe_incl_edu]

* Item 3
ologit sdistance3 i.gndr c.age i.ISCED i.employment_status_harmonized ///
       c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 [aw=wgt_excl_spe_incl_edu]

* Item 4
ologit sdistance4 i.gndr c.age i.ISCED i.employment_status_harmonized ///
       c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 [aw=wgt_excl_spe_incl_edu]

* 2.1. Non pesati
eststo unw: reg sdistance_index i.gndr c.age i.ISCED i.employment_status_harmonized ///
    c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1

* 2.2. Con aw (come nel main text)
eststo aw: reg sdistance_index i.gndr c.age i.ISCED i.employment_status_harmonized ///
    c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 [aw=wgt_excl_spe_incl_edu]

* 2.3. Con pw + linearized SE (se i pesi sono di probabilità, preferire pw)
* Sostituisci psu/strata con le tue variabili se disponibili (altrimenti, usa country come strata e un id come psu)
gen psu_id = _n   if missing(psu_id)
svyset psu_id [pweight=wgt_excl_spe_incl_edu], strata(country)

svy: reg sdistance_index i.gndr c.age i.ISCED i.employment_status_harmonized ///
     c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1
eststo svy

* 2.4. Confronto diretto
esttab unw aw svy using "rob_weights_design.tex", replace label b(%9.3f) se(%9.3f) ///
    star(* 0.05 ** 0.01 *** 0.001) mtitles("Unweighted" "AW" "SVY (pw+linearized)") ///
    compress

	// Wild cluster bootstrap p-values (Rademacher weights)
ssc install boottest
boottest lr socialtrust, cluster(country) reps(9999) seed(12345)

* 4.1. MI setup
mi set wide
mi register imputed lr socialtrust pop1 pop6 demimp satdem sateco corr1 ISCED employment_status_harmonized urban_harmonized
mi register regular sdistance_index gndr age country wgt_excl_spe_incl_edu

* 4.2. Imputation (MICE)
mi impute chained (regress) lr socialtrust pop1 pop6 demimp satdem sateco corr1 ///
                   (mlogit) ISCED employment_status_harmonized urban_harmonized ///
                   = gndr age country, add(20) rseed(1234)

* 4.3. Stima sul dataset imputato (con pesi)
mi estimate, esampvaryok: reg sdistance_index i.gndr c.age i.ISCED i.employment_status_harmonized ///
    c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 [aw=wgt_excl_spe_incl_edu]

* 4.4. Salva tabella
eststo mi_full
esttab mi_full using "rob_mi.tex", replace label b(%9.3f) se(%9.3f) ///
    star(* 0.05 ** 0.01 *** 0.001) mtitles("MI (m=20)") compress

* Pulisci memoria dei modelli salvati
eststo clear

* Loop sui paesi
levelsof country, local(countries)

foreach c of local countries {
    reg sdistance_index i.gndr c.age i.ISCED i.employment_status_harmonized ///
        c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ///
        if country == `c' [aw=wgt_excl_spe_incl_edu], robust
    eststo country`c'
}

coefplot country1 country2 country3 country4 country5 country6 country7 country8, ///
    keep(socialtrust) xline(0) ///
    bylabel(, labsize(small)) ///
    ylabel(, labsize(small)) ///
    xlabel(, labsize(small)) ///
    legend(off) ///
    title("Effect of social trust on political social distance") ///
    xtitle("Coefficient estimate with 95% CI") ///
    vertical

	coefplot country1 country2 country3 country4 country5 country6 country7 country8, ///
    keep(socialtrust lr demimp) ///
    xline(0) ///
    bylabel(, labsize(small)) ///
    legend(on) ///
    title("Comparative effects by country") ///
    xtitle("Coefficient (95% CI)") ///
    vertical
coefplot (country1, label("France")) ///
         (country2, label("Germany")) ///
         (country3, label("Hungary")) ///
         (country4, label("Italy")) ///
         (country5, label("Poland")) ///
         (country6, label("Norway")) ///
         (country7, label("UK")), ///
    keep(socialtrust lr demimp) ///
    xline(0) ///
    legend(rows(1)) ///
    title("Key predictors of social distance across countries") ///
    xtitle("Coefficient estimate (95% CI)") ///
    vertical

//Marginsplot main text
reg sdistance_index i.gndr c.age i.ISCED i.employment_status_harmonized i.urban_harmonized c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 [aw=wgt_excl_spe_incl_edu]

margins, at(socialtrust=(0(1)10))

marginsplot, ///
    recast(line) recastci(rarea) ///
    plotopts(lcolor(blue) lwidth(medthick)) ///
    ciopts(color(blue%40)) ///
    ytitle("Predicted social distance") ///
    xtitle("Social trust (0–10)") ///
    title("Social trust") ///
    name(marg_socialtrust, replace)

margins, at(lr=(0(1)10))

marginsplot, ///
    recast(line) recastci(rarea) ///
    plotopts(lcolor(red) lwidth(medthick)) ///
    ciopts(color(red%40)) ///
    ytitle("Predicted social distance") ///
    xtitle("Left–Right (0=Left, 10=Right)") ///
    title("Ideology") ///
    name(marg_lr, replace)

margins, at(demimp=(0(1)10))

marginsplot, ///
    recast(line) recastci(rarea) ///
    plotopts(lcolor(green) lwidth(medthick)) ///
    ciopts(color(green%40)) ///
    ytitle("Predicted social distance") ///
    xtitle("Democracy importance (0–10)") ///
    title("Democracy importance") ///
    name(marg_demimp, replace)

graph combine marg_socialtrust marg_lr marg_demimp, ///
    col(3) ///
    title("Predicted comfort with outgroup supporters") ///
    imargin(tiny) ycommon

//pastvote ITA
reg sdistance_index c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ib2.pastvote_IT if country==5 [aw=wgt_excl_spe_incl_edu]
margins pastvote_IT if country==5
marginsplot, ///
    title("Predicted comfort with outgroup supporters – Italy") ///
    ylabel(1(0.5)4) ///
    ytitle("Predicted Social Distance Index") ///
    xtitle("Past Vote (Italy)") ///
    recast(bar) recastci(rcap) ///
    yline(2.38, lcolor(red) lpattern(dash) lwidth(medthick))

	//pastvote UK
reg sdistance_index c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ib6.pastvote_UK if country==8 [aw=wgt_excl_spe_incl_edu]
margins pastvote_UK if country==8
marginsplot, ///
    title("Predicted comfort with outgroup supporters – UK") ///
    ylabel(1(0.5)4) ///
    ytitle("Predicted Social Distance Index") ///
    xtitle("Past Vote (UK)") ///
    recast(bar) recastci(rcap) ///
    yline(2.53, lcolor(red) lpattern(dash) lwidth(medthick))
	

//pastvote FR
reg sdistance_index c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ib4.pastvote_FR if country==2 [aw=wgt_excl_spe_incl_edu]
margins pastvote_FR if country==2
marginsplot, ///
    title("Predicted comfort with outgroup supporters – FR") ///
    ylabel(1(0.5)4) ///
    ytitle("Predicted Social Distance Index") ///
    xtitle("Past Vote (FR)") ///
    recast(bar) recastci(rcap) ///
    yline(2.10, lcolor(red) lpattern(dash) lwidth(medthick))


//pastvote DE
reg sdistance_index c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ib4.pastvote_DE if country==3 [aw=wgt_excl_spe_incl_edu]
margins pastvote_DE if country==3
marginsplot, ///
    title("Predicted comfort with outgroup supporters – DE") ///
    ylabel(1(0.5)4) ///
    ytitle("Predicted Social Distance Index") ///
    xtitle("Past Vote (DE)") ///
    recast(bar) recastci(rcap) ///
    yline(1.70, lcolor(red) lpattern(dash) lwidth(medthick))


//pastvote HUN
reg sdistance_index c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ib1.pastvote_HU if country==4 [aw=wgt_excl_spe_incl_edu]
margins pastvote_HU if country==4
marginsplot, ///
    title("Predicted comfort with outgroup supporters – DE") ///
    ylabel(1(0.5)4) ///
    ytitle("Predicted Social Distance Index") ///
    xtitle("Past Vote (DE)") ///
    recast(bar) recastci(rcap) ///
    yline(2.07, lcolor(red) lpattern(dash) lwidth(medthick))


//pastvote PL
reg sdistance_index c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ib1.pastvote_PL if country==6 [aw=wgt_excl_spe_incl_edu]
margins pastvote_PL if country==6
marginsplot, ///
    title("Predicted comfort with outgroup supporters – DE") ///
    ylabel(1(0.5)4) ///
    ytitle("Predicted Social Distance Index") ///
    xtitle("Past Vote (DE)") ///
    recast(bar) recastci(rcap) ///
    yline(2.18, lcolor(red) lpattern(dash) lwidth(medthick))


// ITALY
reg sdistance_index c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ib2.pastvote_IT if country==5 [aw=wgt_excl_spe_incl_edu]
margins pastvote_IT if country==5
marginsplot, ///
    title("Italy") ///
    ylabel(1(0.5)4) ///
    ytitle("Predicted Social Distance Index") ///
    xtitle("Past Vote") ///
    recast(bar) recastci(rcap) ///
    yline(2.38, lcolor(red) lpattern(dash) lwidth(medthick)) ///
    name(it, replace)

// UK
reg sdistance_index c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ib6.pastvote_UK if country==8 [aw=wgt_excl_spe_incl_edu]
margins pastvote_UK if country==8
marginsplot, ///
    title("UK") ///
    ylabel(1(0.5)4) ///
    ytitle("Predicted Social Distance Index") ///
    xtitle("Past Vote") ///
    recast(bar) recastci(rcap) ///
    yline(2.53, lcolor(red) lpattern(dash) lwidth(medthick)) ///
    name(uk, replace)

// FRANCE
reg sdistance_index c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ib4.pastvote_FR if country==2 [aw=wgt_excl_spe_incl_edu]
margins pastvote_FR if country==2
marginsplot, ///
    title("France") ///
    ylabel(1(0.5)4) ///
    ytitle("Predicted Social Distance Index") ///
    xtitle("Past Vote") ///
    recast(bar) recastci(rcap) ///
    yline(2.10, lcolor(red) lpattern(dash) lwidth(medthick)) ///
    name(fr, replace)

// GERMANY
reg sdistance_index c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ib4.pastvote_DE if country==3 [aw=wgt_excl_spe_incl_edu]
margins pastvote_DE if country==3
marginsplot, ///
    title("Germany") ///
    ylabel(1(0.5)4) ///
    ytitle("Predicted Social Distance Index") ///
    xtitle("Past Vote") ///
    recast(bar) recastci(rcap) ///
    yline(1.70, lcolor(red) lpattern(dash) lwidth(medthick)) ///
    name(de, replace)

// HUNGARY
reg sdistance_index c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ib1.pastvote_HU if country==4 [aw=wgt_excl_spe_incl_edu]
margins pastvote_HU if country==4
marginsplot, ///
    title("Hungary") ///
    ylabel(1(0.5)4) ///
    ytitle("Predicted Social Distance Index") ///
    xtitle("Past Vote") ///
    recast(bar) recastci(rcap) ///
    yline(2.07, lcolor(red) lpattern(dash) lwidth(medthick)) ///
    name(hu, replace)

// POLAND
reg sdistance_index c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ib1.pastvote_PL if country==6 [aw=wgt_excl_spe_incl_edu]
margins pastvote_PL if country==6
marginsplot, ///
    title("Poland") ///
    ylabel(1(0.5)4) ///
    ytitle("Predicted Social Distance Index") ///
    xtitle("Past Vote") ///
    recast(bar) recastci(rcap) ///
    yline(2.18, lcolor(red) lpattern(dash) lwidth(medthick)) ///
    name(pl, replace)


// COMBINE ALL
graph combine it uk fr de hu pl, col(3) title("Predicted comfort with outgroup supporters – Past vote by country")

* Step 1. Seleziona le variabili di interesse
pwcorr lr socialtrust pop1 pop6 demimp satdem sateco corr1, sig star(0.05)

* Step 2. Crea una matrice di correlazioni
corr lr socialtrust pop1 pop6 demimp satdem sateco corr1, means
matrix C = r(C)

* Step 3. Trasforma la matrice in dataset
corrmatrix lr socialtrust pop1 pop6 demimp satdem sateco corr1, names clear

* Step 4. Crea la heatmap
heatplot r(value) if var1 != var2, ///
    by(var1 var2) ///
    color(blue white red) ///
    range(-1 1) ///
    scheme(s1mono) ///
    aspectratio(1) ///
    xtitle("") ytitle("") ///
    title("Correlation Heatmap of Attitudinal Variables") ///
    note("Pearson's r coefficients; blue = negative, red = positive") ///
    name(heat_corr, replace)
graph export "Correlation_Heatmap.png", replace width(2000)
ssc install heatplot
corrplot lr socialtrust pop1 pop6 demimp satdem sateco corr1, ///
    adjust half ///
    color(blue white red) ///
    title("Correlation Heatmap of Attitudinal Variables") ///
    note("Pearson's r coefficients; blue = negative, red = positive") ///
    scheme(s1mono)
graph matrix lr socialtrust pop1 pop6 demimp satdem sateco corr1, ///
    half ///
    title("Scatterplot matrix of attitudinal variables") ///
    scheme(s1mono)
	
	
//interaction lr demimp su sdistance
reg sdistance_index i.gndr c.age i.ISCED i.employment_status_harmonized i.urban_harmonized ///
    c.lr##c.demimp c.socialtrust c.pop1 c.pop6 c.satdem c.sateco c.corr1 [aw=wgt_excl_spe_incl_edu]
	margins, dydx(demimp) at(lr=(0(1)10))
marginsplot, x(lr) ytitle("Marginal effect of democratic importance") ///
    title("Interaction between ideology and democratic importance")
margins, dydx(lr) at(demimp=(0(1)10))
marginsplot, x(demimp) ytitle("Marginal effect of ideology")

margins, at(lr=(0(1)10) demimp=(0(1)10))
marginsplot, noci recast(contour) ///
    title("Predicted social distance across ideology and democratic importance") ///
    ytitle("Democratic importance") ///
    xtitle("Ideological self-placement") 
	
margins lr, at(demimp=(0 5 10))
marginsplot, recast(line) ciopts(recast(rline)) ///
    xlabel(0(1)10) ///
    ytitle("Predicted social distance index") ///
    xtitle("Ideological self-placement (0 = left, 10 = right)") ///
    title("Predicted social distance by ideology and democratic importance") ///
    legend(order(1 "Low demimp" 2 "Medium demimp" 3 "High demimp")) ///
    plotopts(lwidth(medthick))


margins, dydx(demimp) at(lr=(0(1)10))
marginsplot, recast(line) ciopts(recast(rline)) ///
    xlabel(0(1)10) ///
    ytitle("Marginal effect of democratic importance on social distance") ///
    xtitle("Ideological self-placement (0 = left, 10 = right)") ///
    title("Conditional effect of democratic importance by ideology") ///
    legend(off) ///
    plotopts(lwidth(medthick))
	
	
//interaction socialtrust e lr 
reg sdistance_index ///
    i.gndr age i.ISCED i.employment_status_harmonized i.urban_harmonized ///
    c.lr##c.socialtrust ///
    pop1 pop6 demimp satdem sateco corr1, robust

testparm c.lr#c.socialtrust

margins, at(lr=(0(2)10)) atmeans dydx(socialtrust)

margins, at(lr=(0(2)10) socialtrust=(0(0.2)1))
marginsplot, x(lr) byopts(yrescale) ///
    title("Interaction between Social Trust and Ideology") ///
    ytitle("Predicted Political Social Distance") ///
    xtitle("Left–Right Self-placement")

gen right = (lr >= 5)
reg sdistance_index i.gndr age i.ISCED i.employment_status_harmonized ///
    i.urban_harmonized c.socialtrust##i.right ///
    pop1 pop6 demimp satdem sateco corr1, robust

margins right, dydx(socialtrust)
marginsplot, title("Marginal Effect of Social Trust by Ideological Side")

gen lr4 = .
replace lr4 = 1 if lr <= 2.5
replace lr4 = 2 if lr > 2.5 & lr <= 4.5
replace lr4 = 3 if lr > 4.5 & lr <= 6.5
replace lr4 = 4 if lr > 6.5
label define lr4 1 "Left" 2 "Centre-left" 3 "Centre-right" 4 "Right"
label values lr4 lr4

reg sdistance_index ///
    i.gndr age i.ISCED i.employment_status_harmonized i.urban_harmonized ///
    c.socialtrust##i.lr4 ///
    pop1 pop6 demimp satdem sateco corr1, robust

testparm c.socialtrust#i.lr4

margins lr4, dydx(socialtrust)
marginsplot, recast(bar) ytitle("Marginal Effect of Social Trust") ///
    title("Effect of Social Trust across Ideological Groups") ///
    ylabel(, angle(0))
	
margins lr4, at(socialtrust=(0(.2)1))
marginsplot, x(socialtrust) by(lr4) ///
    title("Predicted Political Social Distance by Ideology and Social Trust") ///
    ytitle("Predicted Social Distance") ///
    xtitle("Social Trust")

//violinplot
	ssc install dstat

ssc install violinplot, replace
	
violinplot sdistance_index, over(country)

violinplot sdistance_index, over(country) box

//strust and sdistance
binscatter sdistance_index socialtrust, n(20) lcolor(black) mcolor(gs8) ///
title("Binned relationship between social trust and political comfort") ///
xtitle("Social trust") ytitle("Political comfort")

twoway (scatter sdistance_index socialtrust, msymbol(O) msize(vsmall) mcolor(gs12)) ///
       (lowess sdistance_index socialtrust, lcolor(black) lwidth(medthick)), ///
       title("Social trust and political comfort") ///
       xtitle("Social trust") ytitle("Political comfort")

reg sdistance_index c.socialtrust##i.lr c.age i.ISCED i.employment_status_harmonized i.urban_harmonized
margins lr, at(socialtrust=(0 2 4 6 8 10))
marginsplot, recast(line) ciopts(recast(rline)) ///
title("Marginal effect of social trust by ideology") ///
ytitle("Predicted political comfort") xtitle("Social trust")

xtile trust_q = socialtrust, n(4)
collapse (mean) mean_sdistance = sdistance_index, by(trust_q)
graph bar mean_sdistance, over(trust_q) ///
title("Political comfort across levels of social trust") ///
ylabel(, angle(0)) ytitle("Mean comfort")

twoway (lowess sdistance_index socialtrust if lr<=4, lcolor(blue)) ///
       (lowess sdistance_index socialtrust if lr>=7, lcolor(red)), ///
       title("Trust–comfort relationship by ideology") ///
       legend(order(1 "Left" 2 "Right")) ///
       xtitle("Social trust") ytitle("Political comfort")

twoway contour sdistance_index socialtrust lr, ///
title("Comfort levels by ideology and social trust") ///
xtitle("Social trust") ytitle("Ideology")

gen lr_group = .
replace lr_group = 1 if lr <= 2
replace lr_group = 2 if lr >= 3 & lr <= 4
replace lr_group = 3 if lr >= 6 & lr <= 7
replace lr_group = 4 if lr >= 8
label define lr_group 1 "Left" 2 "Centre-left" 3 "Centre-right" 4 "Right"
label values lr_group lr_group
reg sdistance_index c.socialtrust##i.lr_group c.age i.ISCED i.employment_status_harmonized i.urban_harmonized
margins lr_group, at(socialtrust=(0 2 4 6 8 10))
marginsplot, recast(line) ciopts(recast(rline)) ///
legend(order(1 "Left" 2 "Centre-left" 3 "Centre-right" 4 "Right") pos(6) ring(0)) ///
title("Marginal effect of social trust by ideological group") ///
ytitle("Predicted political comfort") xtitle("Social trust") ///
plotopts(lwidth(medthick))

//controllo modello principale with threat3 (weakining of democratic institutions)
reg sdistance_index threat3 i.gndr c.age i.ISCED i.employment_status_harmonized i.urban_harmonized c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 [aw=wgt_excl_spe_incl_edu]


//partynovote
* Grafici separati per ciascun paese (senza titoli)
graph hbar (count) if country == 1, ///
    over(partynovote, sort(1) descending label(labsize(small))) ///
    blabel(bar, format(%4.0f) position(outside)) ///
    ytitle("Frequency")

graph hbar (count) if country == 2, ///
    over(partynovote, sort(1) descending label(labsize(small))) ///
    blabel(bar, format(%4.0f) position(outside)) ///
    ytitle("Frequency")

graph hbar (count) if country == 3, ///
    over(partynovote, sort(1) descending label(labsize(small))) ///
    blabel(bar, format(%4.0f) position(outside)) ///
    ytitle("Frequency")

graph hbar (count) if country == 4, ///
    over(partynovote, sort(1) descending label(labsize(small))) ///
    blabel(bar, format(%4.0f) position(outside)) ///
    ytitle("Frequency")

graph hbar (count) if country == 5, ///
    over(partynovote, sort(1) descending label(labsize(small))) ///
    blabel(bar, format(%4.0f) position(outside)) ///
    ytitle("Frequency")

graph hbar (count) if country == 6, ///
    over(partynovote, sort(1) descending label(labsize(small))) ///
    blabel(bar, format(%4.0f) position(outside)) ///
    ytitle("Frequency")

graph hbar (count) if country == 7, ///
    over(partynovote, sort(1) descending label(labsize(small))) ///
    blabel(bar, format(%4.0f) position(outside)) ///
    ytitle("Frequency")

graph hbar (count) if country == 8, ///
    over(partynovote, sort(1) descending label(labsize(small))) ///
    blabel(bar, format(%4.0f) position(outside)) ///
    ytitle("Frequency")

* Oppure, versione compatta con loop
forvalues i = 1/8 {
    graph hbar (count) if country == `i', ///
        over(partynovote, sort(1) descending label(labsize(vsmall) angle(45))) ///
        blabel(bar, format(%4.0f) position(outside)) ///
        ytitle("Frequency") ///
        name(g`i', replace)
}

* Combina tutti i grafici in un unico output
graph combine g1 g2 g3 g4 g5 g6 g7 g8, ///
    col(2) ///
    iscale(0.8)
	
	
//quadratic left-right test

reg sdistance_index i.gndr c.age i.ISCED i.employment_status_harmonized ///
    i.urban_harmonized c.lr c.lr#c.lr c.socialtrust c.pop1 c.pop6 ///
    c.demimp c.satdem c.sateco c.corr1 [aw=wgt_excl_spe_incl_edu]
test c.lr#c.lr
margins, at(lr=(0(1)10))
marginsplot, noci title("Predicted social distance by ideology (quadratic fit)")


//testing the mechanism

drop if socialview==98
drop if socialview==99
drop if electview==98
drop if electview==99

tab lr_group

* 3. Crea variabile aggregata: Left bloc (1,2) vs Right bloc (3,4)
gen lr_side1 = .
replace lr_side1 = 0 if inlist(lr_group, 1, 2)
replace lr_side1 = 1 if inlist(lr_group, 3, 4)
label define lr_side1 0 "Left bloc" 1 "Right bloc"
label values lr_side1 lr_side1

* 4. Controlla che i gruppi siano corretti
tab lr_group lr_side1

* 5. Test t per differenze di media
ttest socialview, by(lr_side1)
ttest electview, by(lr_side1)

* 6. Statistiche descrittive per blocco
tabstat socialview electview, by(lr_side1) stats(mean sd n)

* 7. Grafico a barre delle medie
graph bar (mean) socialview electview, over(lr_side1) ///
blabel(bar, format(%4.2f)) ///
legend(label(1 "Social (poverty protection)") label(2 "Procedural (elections)")) ///
ytitle("Mean importance (0–10)") ///
title("Democratic conceptions by ideological bloc")

*--------------------------------------------------------------

*--------------------------------------------------------------------
* Marginal means of social distance by ideology
*--------------------------------------------------------------------

* 1. (Facoltativo) Controlla che lr_group sia categoriale con label
tab lr_group

* 2. Esegui una regressione OLS (puoi usare anche regressioni con pesi)
reg sdistance_index i.lr_group [aw=wgt_excl_spe_incl_edu]

* 3. Calcola le medie marginali previste per ciascun gruppo
margins lr_group

* 4. Visualizza le differenze con marginsplot
marginsplot, ///
    title("Predicted social distance by ideological group") ///
    ytitle("Predicted social distance") ///
    xtitle("Ideological group") ///
    recast(bar) ///
    plotopts(lcolor(black)) ///
    ciopts(recast(rcap) lwidth(thin)) ///
    scheme(s1color)
	
//demimp interaction distance by lr group

	reg sdistance_index c.demimp##i.lr_group ///
    i.gndr c.age i.ISCED i.employment_status_harmonized ///
    i.urban_harmonized c.socialtrust c.pop1 c.pop6 c.satdem c.sateco c.corr1 ///
    [aw=wgt_excl_spe_incl_edu]
	
	margins lr_group, at(demimp=(1(1)10))

marginsplot, noci recast(line) recastci(rarea) ///
    plot1opts(lpattern(solid)) plot2opts(lpattern(dash)) ///
    plot3opts(lpattern(dot)) plot4opts(lpattern(shortdash)) ///
    xlabel(1(1)10, labsize(small)) ///
    ylabel(, angle(horizontal)) ///
    ytitle("Predicted political social distance") ///
    xtitle("Importance of democracy") ///
    legend(order(1 "Left" 2 "Centre-left" 3 "Centre-right" 4 "Right") ///
           ring(0) pos(1) cols(1) region(lstyle(none))) ///
    scheme(s1mono)

reg sdistance_index c.demimp##i.lr_group ///
    i.gndr c.age i.ISCED i.employment_status_harmonized ///
    i.urban_harmonized c.socialtrust c.pop1 c.pop6 c.satdem c.sateco c.corr1 ///
    [aw=wgt_excl_spe_incl_edu]
margins lr_group, dydx(demimp)

margins, dydx(demimp) at(lr_group=(1/4))
marginsplot, recast(line) ///
    ytitle("Marginal effect of importance of democracy") ///
    xtitle("Ideological group") ///
    ciopts(recast(rline)) ///
    title("Marginal effect of democratic importance across ideology") ///
    scheme(s1mono)
marginsplot, recast(bar) ytitle("Marginal effect of importance of democracy") ///
    xtitle("Ideological group") ///
    ylabel(, angle(horizontal)) ///
    title("Effect of democratic importance on political comfort by ideology") ///
    plotopts(lcolor(black)) ///
    scheme(s1mono)

	
	
graph hbar (count) partynovote_str, over(partynovote_str, sort(1) descending) ///
    over(lr_group8, gap(10)) ///
    blabel(bar, format(%4.0f) position(outside) size(small)) ///
    ytitle("Number of respondents") ///
    title("Most 'unvotable' parties by ideological group") ///
    legend(off) scheme(s1mono)

graph bar (count) if !missing(party_ideology, lr_group), ///
    over(party_ideology, relabel(1 "Far left" 2 "Left" 3 "Center" 4 "Right" 5 "Far right")) ///
    by(lr_group, title("Ideology of 'unvotable' party by respondent ideology")) ///
    blabel(bar, size(small)) ///
    ytitle("Count") scheme(s1mono)

	
	graph bar (percent) if !missing(party_ideology, lr_group), ///
    over(party_ideology, relabel(1 "Far left" 2 "Left" 3 "Center" 4 "Right" 5 "Far right")) ///
    by(lr_group, title("Ideology of 'unvotable' party by respondent ideology")) ///
    blabel(bar, format(%4.1f)) ///
    ytitle("% within ideology group") scheme(s1mono)

	
//testing mechanism of radicality in nonvotable
tab2 partynovote lr_group
gen unvotable_lr = .

* ===== FAR LEFT (-2) =====
replace unvotable_lr = -2 if inlist(partynovote_str, "France Unbowed", "The Left", "The New Left", "PTB", "PVDA")
replace unvotable_lr = -2 if inlist(partynovote_str, "PTB/PVDA", "Left together", "BSW - Alliance Sahra", "Respect and Freedom P", "Red Party")

* ===== LEFT / CENTER-LEFT (-1) =====
replace unvotable_lr = -1 if inlist(partynovote_str, "Socialist Party", "PS", "PD", "Partito Democratico", "Labour Party")
replace unvotable_lr = -1 if inlist(partynovote_str, "Labour", "Vooruit", "Groen", "Ecolo", "Alliance Greens and L")
replace unvotable_lr = -1 if inlist(partynovote_str, "GPEW", "Green Party", "Socialist Left Party")

* ===== CENTER (0) =====
replace unvotable_lr = 0 if inlist(partynovote_str, "Renaissance", "Democratic Movement", "Italy Alive", "Italia Viva", "Azione")
replace unvotable_lr = 0 if inlist(partynovote_str, "MR", "CD&V", "Les Engagés", "Open VLD", "Liberal Party", "Centre Party")
replace unvotable_lr = 0 if inlist(partynovote_str, "Poland 2050", "Christian Democratic", "Dialogue – The Greens", "Polish People's Party")

* ===== CENTER-RIGHT (1) =====
replace unvotable_lr = 1 if inlist(partynovote_str, "The Republicans", "Civic Platform", "Go Italy!", "Forza Italia", "Les Républicains")
replace unvotable_lr = 1 if inlist(partynovote_str, "Democratic Coalition", "Christian Democratic", "Conservative Party", "Centre Party")

* ===== FAR RIGHT (2) =====
replace unvotable_lr = 2 if inlist(partynovote_str, "National Rally", "AfD", "Law and Justice", "PiS", "Fidesz – Hungarian Ci")
replace unvotable_lr = 2 if inlist(partynovote_str, "Vlaams Belang", "Brothers of Italy", "League", "Lega", "Reconquest")
replace unvotable_lr = 2 if inlist(partynovote_str, "Confederation", "Reform", "Progress Party", "Tories", "N-VA")
replace unvotable_lr = 2 if inlist(partynovote_str, "Our Homeland Movement", "Respect and Freedom P", "Alternative for Germa")

* ===== OTHER / UNKNOWN (missing) =====
replace unvotable_lr = . if inlist(partynovote_str, "Don't know", "I prefer not to answe", "Other", "WPB")

tab unvotable_lr

tab lr_group unvotable_lr, chi2 expected


ssc install catplot
catplot unvotable_lr lr_group, percent(lr_group) stack asyvars 
ytitle("Percent of 'unvotable' parties") 
    xtitle("Respondent ideology") 
    legend(order(1 "Far left" 2 "Left" 3 "Center" 4 "Right" 5 "Far right")) 
    title("Ideological direction of 'unvotable' parties by respondent ideology") 
    scheme(s1mono)

corr lr unvotable_lr


reg unvotable_lr lr

catplot unvotable_lr lr_group, percent(lr_group) stack asyvars ///
ytitle("Percent of 'unvotable' parties") xtitle("Respondent ideology") ///
legend(order(1 "Far left" 2 "Left" 3 "Center" 4 "Right" 5 "Far right")) ///
title("Ideological direction of 'unvotable' parties by respondent ideology") ///
scheme(s1mono)

catplot unvotable_lr lr_group, percent(lr_group) scheme(s1mono)


collapse (count) N=unvotable_lr, by(lr_group unvotable_lr)
bysort lr_group: egen tot = total(N)
gen perc = 100 * N / tot

graph bar (mean) perc, over(unvotable_lr, gap(0)) over(lr_group) ///
    blabel(bar, format(%4.1f)) ///
    ytitle("Percent of 'unvotable' parties") ///
    xtitle("Respondent ideology") ///
    title("Ideological direction of 'unvotable' parties by respondent ideology") ///
    legend(order(1 "Far left" 2 "Left" 3 "Center" 4 "Right" 5 "Far right")) ///
    scheme(s1mono)

	
	
twoway (scatter unvotable_lr lr, mcolor(gs12) msymbol(o) msize(vsmall)) ///
       (lfit unvotable_lr lr, lwidth(medthick) lcolor(black)), ///
       ytitle("Ideology of 'unvotable' party") ///
       xtitle("Respondent ideology (0=Left, 10=Right)") ///
       title("Relationship between respondent ideology and 'unvotable' party ideology") ///
       legend(off) scheme(s1mono)

	   
	   
collapse (mean) mean_unvote=unvotable_lr, by(lr)
twoway (scatter mean_unvote lr, mcolor(black) msymbol(o)) ///
       (lfit mean_unvote lr, lcolor(black) lwidth(medthick)), ///
       ytitle("Mean ideology of 'unvotable' party") ///
       xtitle("Respondent ideology (0=Left, 10=Right)") ///
       title("Average ideological position of 'unvotable' party by respondent ideology") ///
       legend(off) scheme(s1mono)

	   
margins, at(lr=(0(1)10))
marginsplot, recast(line) ciopts(recast(rline)) ///
    ytitle("Predicted ideology of 'unvotable' party") ///
    xtitle("Respondent ideology") ///
    title("Predicted relationship between respondent and 'unvotable' ideology") ///
    scheme(s1mono)
	

twoway (scatter unvotable_lr lr, msymbol(o) mcolor(gs10) msize(vsmall)) ///
       (lfit unvotable_lr lr, lcolor(black) lwidth(medthick)), ///
       ytitle("Ideology of 'unvotable' party") ///
       xtitle("Respondent ideology (0 = Left, 10 = Right)") ///
       title("Correlation between respondent ideology and 'unvotable' party ideology") ///
       note("r = -0.55, p < 0.001") ///
       legend(off) scheme(s1mono)

	   
collapse (mean) mean_unvotable=unvotable_lr, by(lr)
twoway (scatter mean_unvotable lr, msymbol(O) mcolor(black)) ///
       (lfit mean_unvotable lr, lcolor(black) lwidth(medthick)), ///
       ytitle("Average ideology of 'unvotable' party") ///
       xtitle("Respondent ideology") ///
       title("Average ideological position of 'unvotable' party by respondent ideology") ///
       note("r = -0.55") ///
       legend(off) scheme(s1mono)

collapse (mean) mean_unvotable=unvotable_lr, by(lr)
twoway (scatter mean_unvotable lr, msymbol(O) mcolor(black)) ///
       (lfit mean_unvotable lr, lcolor(black) lwidth(medthick)), ///
       ytitle("Average ideology of 'unvotable' party") ///
       xtitle("Respondent ideology") ///
       title("Average ideological position of 'unvotable' party by respondent ideology") ///
       note("r = -0.55") ///
       legend(off) scheme(s1mono)

gen unvotable_lr = .

* Far left
replace unvotable_lr = -2 if inlist(partynovote_str, "France Unbowed", "The Left", "The New Left", "PTB", "PVDA")
replace unvotable_lr = -2 if inlist(partynovote_str, "PTB/PVDA", "Left together", "BSW - Alliance Sahra", "Respect and Freedom P", "Red Party")

* Left / centre-left
replace unvotable_lr = -1 if inlist(partynovote_str, "Socialist Party", "PS", "PD", "Partito Democratico", "Labour Party")
replace unvotable_lr = -1 if inlist(partynovote_str, "Labour", "Vooruit", "Groen", "Ecolo", "Alliance Greens and L")
replace unvotable_lr = -1 if inlist(partynovote_str, "GPEW", "Green Party", "Socialist Left Party")

* Center
replace unvotable_lr = 0 if inlist(partynovote_str, "Renaissance", "Democratic Movement", "Italy Alive", "Italia Viva", "Azione")
replace unvotable_lr = 0 if inlist(partynovote_str, "MR", "CD&V", "Les Engagés", "Open VLD", "Liberal Party", "Centre Party")
replace unvotable_lr = 0 if inlist(partynovote_str, "Poland 2050", "Christian Democratic", "Dialogue – The Greens", "Polish People's Party")

* Center-right
replace unvotable_lr = 1 if inlist(partynovote_str, "The Republicans", "Civic Platform", "Go Italy!", "Forza Italia", "Les Républicains")
replace unvotable_lr = 1 if inlist(partynovote_str, "Democratic Coalition", "Christian Democratic", "Conservative Party", "Centre Party")

* Far right
replace unvotable_lr = 2 if inlist(partynovote_str, "National Rally", "AfD", "Law and Justice", "PiS", "Fidesz – Hungarian Ci")
replace unvotable_lr = 2 if inlist(partynovote_str, "Vlaams Belang", "Brothers of Italy", "League", "Lega", "Reconquest")
replace unvotable_lr = 2 if inlist(partynovote_str, "Confederation", "Reform", "Progress Party", "Tories", "N-VA")
replace unvotable_lr = 2 if inlist(partynovote_str, "Our Homeland Movement", "Respect and Freedom P", "Alternative for Germa")

* Other / missing
replace unvotable_lr = . if inlist(partynovote_str, "Don't know", "I prefer not to answe", "Other", "WPB")


twoway (scatter unvotable_lr lr, msymbol(o) mcolor(gs12) msize(vsmall)) ///
       (lfit unvotable_lr lr, lcolor(black) lwidth(medthick)), ///
       ytitle("Ideology of 'unvotable' party") ///
       xtitle("Respondent ideology (0=Left, 10=Right)") ///
       title("Correlation between respondent ideology and 'unvotable' party ideology") ///
       note("r = -0.55, p < 0.001") ///
       legend(off) scheme(s1mono)

	   

	   
//Relatedly, regarding the assumption that the party one would never vote for will be on the left for right-wing voters and on the right for left-wing voters: On average I'd expect the same, but I wonder whether there may be another asymmetry here. Moderate voters of each side may also think of an extreme party on their own side as categorically unsupportable. May we see more of this on one side than on the other, and what would be the implications for your findings?
//testiamo:

gen same_side = .
replace same_side = 1 if (lr<=5 & unvotable_lr<=0) | (lr>5 & unvotable_lr>=0)
replace same_side = 0 if (lr<=5 & unvotable_lr>0) | (lr>5 & unvotable_lr<0)

tab same_side lr_group, row

logit same_side i.lr_group

margins lr_group

marginsplot, recast(bar) ///
    ytitle("Predicted probability of intra-side rejection") ///
    xtitle("Respondent ideology") ///
    title("Predicted probability of rejecting an extreme party on one's own side") ///
    ylabel(0(0.2)0.8, angle(horizontal)) ///
    plotopts(barwidth(0.6) color(black%70)) ///
    ciopts(recast(rline)) ///
    scheme(s1mono)
	
	
//R&R Political Behavior
/***********************************************************/
preserve

foreach v in electview libview socialview directview popview {
    replace `v' = . if inlist(`v', 98, 99)
}

label define lr_side1 0 "Left bloc" 1 "Right bloc", replace
label values lr_side1 lr_side1

tabstat electview libview socialview directview popview, ///
    by(lr_side1) stats(n mean sd) columns(statistics)

ttest electview, by(lr_side1)
ttest libview, by(lr_side1)
ttest socialview, by(lr_side1)
ttest directview, by(lr_side1)
ttest popview, by(lr_side1)

tab demview lr_side1 if inlist(demview,1,2,3,4,5), col

restore

********************************************************************************
* FIGURE: Ideological differences in democratic conceptions
* Difference in means: Left bloc - Right bloc
********************************************************************************

preserve

* Make sure invalid values are treated as missing
foreach v in electview libview socialview directview popview {
    replace `v' = . if `v' > 10
}

* Create temporary file with mean differences and confidence intervals
tempfile diffresults
tempname memhold

postfile `memhold' byte dim double diff se lb ub using `diffresults', replace

local i = 1
foreach v in electview libview socialview directview popview {

    quietly ttest `v' if inlist(lr_side1,0,1), by(lr_side1)

    local diff = r(mu_1) - r(mu_2)
    local se   = r(se)
    local crit = invttail(r(df_t), 0.025)
    local lb   = `diff' - `crit' * `se'
    local ub   = `diff' + `crit' * `se'

    post `memhold' (`i') (`diff') (`se') (`lb') (`ub')

    local ++i
}

postclose `memhold'

use `diffresults', clear

label define dimlbl ///
    1 "Electoral" ///
    2 "Liberal" ///
    3 "Social" ///
    4 "Direct" ///
    5 "Populist", replace

label values dim dimlbl

gen difflab = string(diff, "%4.2f")

capture mkdir figures

twoway ///
    (rcap lb ub dim, horizontal) ///
    (scatter dim diff, mlabel(difflab) mlabposition(12)), ///
    xline(0, lpattern(dash)) ///
    ylabel(1 "Electoral" 2 "Liberal" 3 "Social" 4 "Direct" 5 "Populist", angle(0)) ///
    yscale(reverse) ///
    xtitle("Mean difference: Left bloc minus Right bloc") ///
    ytitle("") ///
    title("Ideological differences in democratic conceptions") ///
    subtitle("Positive values indicate greater importance among left-leaning respondents") ///
    note("Points report mean differences with 95% confidence intervals. Democratic conceptions measured on 0–10 scales.") ///
    legend(off) ///
    graphregion(color(white)) ///
    plotregion(color(white))

graph export "figures/democratic_conceptions_difference_plot.pdf", replace
graph export "figures/democratic_conceptions_difference_plot.png", replace width(2400)

restore
********************************************************************************

********************************************************************************
* ********************************************************************************
* MULTIDIMENSIONAL DEMOCRATIC CONCEPTIONS AND POLITICAL SOCIAL DISTANCE
********************************************************************************

preserve

* Treat invalid values as missing
foreach v in electview libview socialview directview popview {
    replace `v' = . if `v' > 10
}

* Standardize democratic conception items
foreach v in electview libview socialview directview popview {
    egen z_`v' = std(`v')
}

********************************************************************************
* 1. Direct association: all conceptions in the same model
********************************************************************************

reg sdistance_index ///
    c.lr c.socialtrust c.demimp ///
    c.z_electview c.z_libview c.z_socialview c.z_directview c.z_popview ///
    i.gndr c.age i.ISCED i.employment_status_harmonized i.urban_harmonized ///
    c.pop1 c.pop6 c.satdem c.sateco c.corr1 ///
    [aw=wgt_excl_spe_incl_edu], robust

estimates store conceptions_direct

********************************************************************************
* 2. Does democratic importance work differently depending on conceptions?
********************************************************************************

reg sdistance_index ///
    c.lr c.socialtrust ///
    c.demimp##c.z_electview ///
    c.demimp##c.z_libview ///
    c.demimp##c.z_socialview ///
    c.demimp##c.z_directview ///
    c.demimp##c.z_popview ///
    i.gndr c.age i.ISCED i.employment_status_harmonized i.urban_harmonized ///
    c.pop1 c.pop6 c.satdem c.sateco c.corr1 ///
    [aw=wgt_excl_spe_incl_edu], robust

estimates store demimp_conceptions_interactions

********************************************************************************
* 3. Does social trust work differently depending on conceptions?
********************************************************************************

reg sdistance_index ///
    c.lr c.demimp ///
    c.socialtrust##c.z_electview ///
    c.socialtrust##c.z_libview ///
    c.socialtrust##c.z_socialview ///
    c.socialtrust##c.z_directview ///
    c.socialtrust##c.z_popview ///
    i.gndr c.age i.ISCED i.employment_status_harmonized i.urban_harmonized ///
    c.pop1 c.pop6 c.satdem c.sateco c.corr1 ///
    [aw=wgt_excl_spe_incl_edu], robust

estimates store trust_conceptions_interactions

restore
********************************************************************************
********************************************************************************
* MECHANISM TEST WITH MULTIDIMENSIONAL DEMOCRATIC CONCEPTIONS
* Safe version: everything inside preserve/restore
********************************************************************************
********************************************************************************
* PREDICTED COMFORT BY EACH DEMOCRATIC CONCEPTION
* Outcome: sdistance_index
* Higher values = greater comfort toward political outgroups
********************************************************************************
********************************************************************************
* ONE FIGURE: PREDICTED COMFORT BY DEMOCRATIC CONCEPTION
* Five curves in the same graph
********************************************************************************

preserve

* Clean invalid values
foreach v in electview libview socialview directview popview {
    replace `v' = . if `v' > 10
}

********************************************************************************
* Full model including all democratic conceptions
********************************************************************************

reg sdistance_index ///
    c.lr c.socialtrust c.demimp ///
    c.electview c.libview c.socialview c.directview c.popview ///
    i.gndr c.age i.ISCED i.employment_status_harmonized i.urban_harmonized ///
    c.pop1 c.pop6 c.satdem c.sateco c.corr1 ///
    [aw=wgt_excl_spe_incl_edu], robust

********************************************************************************
* Create predicted values by varying each conception from 0 to 10
********************************************************************************

tempfile curves
tempname memhold

postfile `memhold' str25 conception double x pred using `curves', replace

foreach v in electview libview socialview directview popview {

    tempvar original
    gen double `original' = `v'

    forvalues x = 0/10 {

        replace `v' = `x' if e(sample)

        capture drop __xb
        predict double __xb if e(sample), xb

        quietly summarize __xb if e(sample) [aw=wgt_excl_spe_incl_edu], meanonly
        local pred = r(mean)

        if "`v'" == "electview" {
            post `memhold' ("Electoral") (`x') (`pred')
        }
        if "`v'" == "libview" {
            post `memhold' ("Liberal") (`x') (`pred')
        }
        if "`v'" == "socialview" {
            post `memhold' ("Social") (`x') (`pred')
        }
        if "`v'" == "directview" {
            post `memhold' ("Direct-democratic") (`x') (`pred')
        }
        if "`v'" == "popview" {
            post `memhold' ("Populist") (`x') (`pred')
        }
    }

    replace `v' = `original'
    drop `original'
}

postclose `memhold'

use `curves', clear

********************************************************************************
* Plot all curves in one graph
********************************************************************************
********************************************************************************
* ONE FIGURE: PREDICTED COMFORT BY DEMOCRATIC CONCEPTION
* Five curves in the same graph
* Safe version: uses numeric dimension variable, not string variable
********************************************************************************

preserve

* Clean invalid values
foreach v in electview libview socialview directview popview {
    replace `v' = . if `v' > 10
}

********************************************************************************
* Full model including all democratic conceptions
********************************************************************************

reg sdistance_index ///
    c.lr c.socialtrust c.demimp ///
    c.electview c.libview c.socialview c.directview c.popview ///
    i.gndr c.age i.ISCED i.employment_status_harmonized i.urban_harmonized ///
    c.pop1 c.pop6 c.satdem c.sateco c.corr1 ///
    [aw=wgt_excl_spe_incl_edu], robust

********************************************************************************
* Create predicted values by varying each conception from 0 to 10
********************************************************************************

tempfile curves
tempname memhold

postfile `memhold' byte dim double x pred using `curves', replace

local dim = 1

foreach v in electview libview socialview directview popview {

    tempvar original
    gen double `original' = `v'

    forvalues x = 0/10 {

        replace `v' = `x' if e(sample)

        capture drop __xb
        predict double __xb if e(sample), xb

        quietly summarize __xb if e(sample) [aw=wgt_excl_spe_incl_edu], meanonly
        local pred = r(mean)

        post `memhold' (`dim') (`x') (`pred')
    }

    replace `v' = `original'
    drop `original'

    local dim = `dim' + 1
}

postclose `memhold'

use `curves', clear

label define dimlbl ///
    1 "Electoral" ///
    2 "Liberal" ///
    3 "Social" ///
    4 "Direct-democratic" ///
    5 "Populist", replace

label values dim dimlbl

********************************************************************************
* Plot all curves in one graph
********************************************************************************
* ONE FIGURE: PREDICTED COMFORT BY DEMOCRATIC CONCEPTION
* Five curves in the same graph
* Safe: preserve/restore
********************************************************************************

preserve

* Clean invalid values
foreach v in electview libview socialview directview popview {
    replace `v' = . if `v' > 10
}

********************************************************************************
* Full model including all democratic conceptions
********************************************************************************

reg sdistance_index ///
    c.lr c.socialtrust c.demimp ///
    c.electview c.libview c.socialview c.directview c.popview ///
    i.gndr c.age i.ISCED i.employment_status_harmonized i.urban_harmonized ///
    c.pop1 c.pop6 c.satdem c.sateco c.corr1 ///
    [aw=wgt_excl_spe_incl_edu], robust

********************************************************************************
* Store average prediction and coefficients
********************************************************************************

predict double xb_full if e(sample), xb

quietly summarize xb_full if e(sample) [aw=wgt_excl_spe_incl_edu], meanonly
scalar xbbar = r(mean)

foreach v in electview libview socialview directview popview {
    quietly summarize `v' if e(sample) [aw=wgt_excl_spe_incl_edu], meanonly
    scalar mean_`v' = r(mean)
    scalar b_`v' = _b[`v']
}

********************************************************************************
* Build artificial dataset for the five predicted curves
********************************************************************************

clear
set obs 55

gen dim = ceil(_n/11)
bysort dim: gen x = _n - 1

gen pred = .

replace pred = xbbar + b_electview  * (x - mean_electview)  if dim == 1
replace pred = xbbar + b_libview    * (x - mean_libview)    if dim == 2
replace pred = xbbar + b_socialview * (x - mean_socialview) if dim == 3
replace pred = xbbar + b_directview * (x - mean_directview) if dim == 4
replace pred = xbbar + b_popview    * (x - mean_popview)    if dim == 5

label define dimlbl ///
    1 "Electoral" ///
    2 "Liberal" ///
    3 "Social" ///
    4 "Direct-democratic" ///
    5 "Populist", replace

label values dim dimlbl

********************************************************************************
* Plot all curves in one graph
********************************************************************************
* ONE FIGURE: PREDICTED COMFORT BY DEMOCRATIC CONCEPTION
* Five curves in the same graph
* Safe: preserve/restore
********************************************************************************

preserve

* Clean invalid values
foreach v in electview libview socialview directview popview {
    replace `v' = . if `v' > 10
}

********************************************************************************
* Full model including all democratic conceptions
********************************************************************************

reg sdistance_index ///
    c.lr c.socialtrust c.demimp ///
    c.electview c.libview c.socialview c.directview c.popview ///
    i.gndr c.age i.ISCED i.employment_status_harmonized i.urban_harmonized ///
    c.pop1 c.pop6 c.satdem c.sateco c.corr1 ///
    [aw=wgt_excl_spe_incl_edu], robust

********************************************************************************
* Store average prediction and coefficients
********************************************************************************

predict double xb_full if e(sample), xb

quietly summarize xb_full if e(sample) [aw=wgt_excl_spe_incl_edu], meanonly
scalar xbbar = r(mean)

foreach v in electview libview socialview directview popview {
    quietly summarize `v' if e(sample) [aw=wgt_excl_spe_incl_edu], meanonly
    scalar mean_`v' = r(mean)
    scalar b_`v' = _b[`v']
}

********************************************************************************
* Build artificial dataset for the five predicted curves
********************************************************************************

clear
set obs 55

gen dim = ceil(_n/11)
bysort dim: gen x = _n - 1

gen pred = .

replace pred = xbbar + b_electview  * (x - mean_electview)  if dim == 1
replace pred = xbbar + b_libview    * (x - mean_libview)    if dim == 2
replace pred = xbbar + b_socialview * (x - mean_socialview) if dim == 3
replace pred = xbbar + b_directview * (x - mean_directview) if dim == 4
replace pred = xbbar + b_popview    * (x - mean_popview)    if dim == 5

label define dimlbl ///
    1 "Electoral" ///
    2 "Liberal" ///
    3 "Social" ///
    4 "Direct-democratic" ///
    5 "Populist", replace

label values dim dimlbl

********************************************************************************
**************************************************************

********************************************************************************
********************************************************************************
************************************************************
* Multidimensional democratic conceptions:
* electoral, liberal, social, direct-democratic, populist
*****************************************************
* ROBUSTNESS OF MAIN INTERACTIONS AFTER ADDING DEMOCRATIC CONCEPTIONS
* Output: LaTeX table for Overleaf
********************************************************************************

set more off

preserve

********************************************************************************
* 0. If dataset is mi set, temporarily use observed data m=0
********************************************************************************

capture mi extract 0, clear

********************************************************************************
* 1. Clean democratic conception items
********************************************************************************

foreach v in electview libview socialview directview popview {
    replace `v' = . if `v' > 10
}

********************************************************************************
* 2. Standardize democratic conception items
********************************************************************************

foreach v in electview libview socialview directview popview {
    capture drop z_`v'
    egen z_`v' = std(`v')
}

********************************************************************************
* 3. Define controls and conception variables
********************************************************************************

local controls ///
    i.gndr c.age i.ISCED i.employment_status_harmonized i.urban_harmonized ///
    c.pop1 c.pop6 c.satdem c.sateco c.corr1

local conceptions ///
    c.z_electview c.z_libview c.z_socialview c.z_directview c.z_popview

********************************************************************************
* 4. Model 1: Democratic importance x ideology – baseline
********************************************************************************

reg sdistance_index ///
    c.lr##c.demimp ///
    c.socialtrust ///
    `controls' ///
    [aw=wgt_excl_spe_incl_edu], robust

estimates store M1_demimp_base

********************************************************************************
* 5. Model 2: Democratic importance x ideology – with democratic conceptions
********************************************************************************

reg sdistance_index ///
    c.lr##c.demimp ///
    c.socialtrust ///
    `conceptions' ///
    `controls' ///
    [aw=wgt_excl_spe_incl_edu], robust

estimates store M2_demimp_conceptions

********************************************************************************
* 6. Model 3: Social trust x ideology – baseline
********************************************************************************

reg sdistance_index ///
    c.lr##c.socialtrust ///
    c.demimp ///
    `controls' ///
    [aw=wgt_excl_spe_incl_edu], robust

estimates store M3_trust_base

********************************************************************************
* 7. Model 4: Social trust x ideology – with democratic conceptions
********************************************************************************

reg sdistance_index ///
    c.lr##c.socialtrust ///
    c.demimp ///
    `conceptions' ///
    `controls' ///
    [aw=wgt_excl_spe_incl_edu], robust

estimates store M4_trust_conceptions

********************************************************************************
* 8. Quick table in Stata window
********************************************************************************

estimates table ///
    M1_demimp_base M2_demimp_conceptions M3_trust_base M4_trust_conceptions, ///
    b(%9.3f) se(%9.3f) stats(N r2)

********************************************************************************
* 9. Export LaTeX table for Overleaf
********************************************************************************

capture mkdir tables

capture which esttab
if _rc {
    ssc install estout, replace
}

esttab M1_demimp_base M2_demimp_conceptions M3_trust_base M4_trust_conceptions ///
    using "tables/interaction_robustness_democratic_conceptions.tex", ///
    replace ///
    booktabs ///
    fragment ///
    se ///
    star(* 0.05 ** 0.01 *** 0.001) ///
    b(3) se(3) ///
    mtitles("Dem. imp. x ideology" ///
            "Dem. imp. x ideology + conceptions" ///
            "Trust x ideology" ///
            "Trust x ideology + conceptions") ///
    keep(lr demimp c.lr#c.demimp socialtrust c.lr#c.socialtrust ///
         z_electview z_libview z_socialview z_directview z_popview) ///
    order(lr demimp c.lr#c.demimp socialtrust c.lr#c.socialtrust ///
          z_electview z_libview z_socialview z_directview z_popview) ///
    coeflabels( ///
        lr "Left-right self-placement" ///
        demimp "Democracy importance" ///
        c.lr#c.demimp "Left-right $\times$ democracy importance" ///
        socialtrust "Social trust" ///
        c.lr#c.socialtrust "Left-right $\times$ social trust" ///
        z_electview "Electoral conception" ///
        z_libview "Liberal conception" ///
        z_socialview "Social conception" ///
        z_directview "Direct-democratic conception" ///
        z_popview "Populist conception" ///
    ) ///
    stats(N r2, labels("Observations" "R-squared") fmt(0 3)) ///
    label ///
    compress ///
    nonotes ///
    addnotes("Robust standard errors in parentheses.", ///
             "Models 2 and 4 include electoral, liberal, social, direct-democratic, and populist conceptions of democracy.", ///
             "Higher values of the dependent variable indicate greater comfort toward political outgroups and therefore lower political social distance.")

restore

********************************************************************************
* END
********************************************************************************
********************************************************************************
* FIGURE: Conditional effect of democracy importance across ideological groups
********************************************************************************

preserve

* Make sure ideological groups exist
capture drop lr_group
gen lr_group = .
replace lr_group = 1 if lr <= 2
replace lr_group = 2 if lr >= 3 & lr <= 4
replace lr_group = 3 if lr >= 6 & lr <= 7
replace lr_group = 4 if lr >= 8

label define lr_group_lbl ///
    1 "Left" ///
    2 "Centre-left" ///
    3 "Centre-right" ///
    4 "Right", replace

label values lr_group lr_group_lbl

* Interaction model
reg sdistance_index ///
    c.demimp##i.lr_group ///
    i.gndr c.age i.ISCED i.employment_status_harmonized ///
    i.urban_harmonized c.socialtrust c.pop1 c.pop6 c.satdem c.sateco c.corr1 ///
    [aw=wgt_excl_spe_incl_edu], robust

* Marginal effect of democracy importance by ideological group
margins lr_group, dydx(demimp)

* Clean marginsplot
marginsplot, ///
    recast(bar) ///
    recastci(rcap) ///
    yline(0, lpattern(dash)) ///
    ytitle("Marginal effect of democracy importance on political comfort") ///
    xtitle("Ideological group") ///
    title("Conditional effect of democracy importance across ideological groups") ///
    ylabel(-0.10(0.05)0.05, angle(horizontal)) ///
    legend(off) ///
    plotopts(lcolor(black)) ///
    ciopts(lcolor(black) lwidth(medthick)) ///
    graphregion(color(white)) ///
    plotregion(color(white)) ///
    scheme(s1mono)

graph export "figures/conditional_effect_demimp_ideological_groups.pdf", replace
graph export "figures/conditional_effect_demimp_ideological_groups.png", replace width(2400)

restore
********************************************************************************
********************************************************************************
* MAIN FIGURE: Focal predictors of political outgroup comfort
* Higher values = greater comfort = lower political social distance
********************************************************************************

preserve

* Full model
reg sdistance_index ///
    i.gndr c.age i.ISCED i.employment_status_harmonized i.urban_harmonized ///
    c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ///
    [aw=wgt_excl_spe_incl_edu], robust

********************************************************************************
* Panel 1: Social trust
********************************************************************************

margins, at(socialtrust=(0(1)10))

marginsplot, ///
    recast(line) recastci(rarea) ///
    plotopts(lcolor(black) lwidth(medthick)) ///
    ciopts(color(gs12%50) lcolor(gs12%0)) ///
    ytitle("Predicted outgroup comfort") ///
    xtitle("Social trust (0–10)") ///
    title("") ///
    ylabel(2.0(0.2)2.8, angle(horizontal)) ///
    yscale(range(1.95 2.85)) ///
    legend(off) ///
    graphregion(color(white)) ///
    plotregion(color(white)) ///
    name(marg_socialtrust, replace)

********************************************************************************
* Panel 2: Left-right self-placement
********************************************************************************

margins, at(lr=(0(1)10))

marginsplot, ///
    recast(line) recastci(rarea) ///
    plotopts(lcolor(black) lwidth(medthick)) ///
    ciopts(color(gs12%50) lcolor(gs12%0)) ///
    ytitle("") ///
    xtitle("Left–Right (0=Left, 10=Right)") ///
    title("") ///
    ylabel(2.0(0.2)2.8, angle(horizontal)) ///
    yscale(range(1.95 2.85)) ///
    legend(off) ///
    graphregion(color(white)) ///
    plotregion(color(white)) ///
    name(marg_lr, replace)

********************************************************************************
* Panel 3: Democracy importance
********************************************************************************

margins, at(demimp=(0(1)10))

marginsplot, ///
    recast(line) recastci(rarea) ///
    plotopts(lcolor(black) lwidth(medthick)) ///
    ciopts(color(gs12%50) lcolor(gs12%0)) ///
    ytitle("") ///
    xtitle("Democracy importance (0–10)") ///
    title("") ///
    ylabel(2.0(0.2)2.8, angle(horizontal)) ///
    yscale(range(1.95 2.85)) ///
    legend(off) ///
    graphregion(color(white)) ///
    plotregion(color(white)) ///
    name(marg_demimp, replace)

********************************************************************************
* Combine panels
********************************************************************************

graph combine marg_socialtrust marg_lr marg_demimp, ///
    col(3) ///
    ycommon ///
    imargin(tiny) ///
    graphregion(color(white)) ///
    title("")

capture mkdir figures

graph export "figures/focal_predictors_outgroup_comfort.pdf", replace
graph export "figures/focal_predictors_outgroup_comfort.png", replace width(3000)

restore

********************************************************************************
* END
********************************************************************************
********************************************************************************
* FIGURE: Predicted political comfort by ideological group
* Higher values = greater comfort = lower political social distance
********************************************************************************

preserve

* Recreate ideological groups
capture drop lr_group
gen lr_group = .
replace lr_group = 1 if lr <= 2
replace lr_group = 2 if lr >= 3 & lr <= 4
replace lr_group = 3 if lr >= 6 & lr <= 7
replace lr_group = 4 if lr >= 8

label define lr_group_lbl ///
    1 "Left" ///
    2 "Centre-left" ///
    3 "Centre-right" ///
    4 "Right", replace

label values lr_group lr_group_lbl

* Same model used for the ideological-group figure
reg sdistance_index i.lr_group [aw=wgt_excl_spe_incl_edu], robust

margins lr_group

marginsplot, ///
    recast(bar) ///
    recastci(rcap) ///
    plotopts(fcolor(gs12) lcolor(gs8) barwidth(.95)) ///
    ciopts(lcolor(black) lwidth(medthick)) ///
    ytitle("Predicted political comfort") ///
    xtitle("") ///
    title("") ///
    ylabel(1.8(0.2)2.6, angle(horizontal) nogrid) ///
    xlabel(, labsize(medlarge)) ///
    yscale(range(1.78 2.62)) ///
    legend(off) ///
    graphregion(color(white)) ///
    plotregion(color(white)) ///
    scheme(s1mono)

capture mkdir figures

graph export "figures/predicted_political_comfort_by_ideological_group.pdf", replace
graph export "figures/predicted_political_comfort_by_ideological_group.png", replace width(2400)

restore

********************************************************************************
********************************************************************************
* FIGURE: Quadratic relationship between ideology and political outgroup comfort
* Higher values = greater comfort = lower political social distance
********************************************************************************

preserve

* Quadratic model
reg sdistance_index ///
    i.gndr c.age i.ISCED i.employment_status_harmonized ///
    i.urban_harmonized ///
    c.lr##c.lr ///
    c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ///
    [aw=wgt_excl_spe_incl_edu], robust

* Test quadratic term
test c.lr#c.lr

* Predicted values across left-right scale
margins, at(lr=(0(1)10))

marginsplot, ///
    noci ///
    recast(line) ///
    plotopts(lcolor(black) lwidth(medthick) ///
             mcolor(black) msymbol(O) msize(medsmall)) ///
    ytitle("Predicted outgroup comfort") ///
    xtitle("Left-right self-placement") ///
    title("Quadratic relationship between ideology and outgroup comfort") ///
    xlabel(0 "0 Left" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" ///
           6 "6" 7 "7" 8 "8" 9 "9" 10 "10 Right", nogrid) ///
    ylabel(1.8(0.2)2.4, angle(horizontal) nogrid) ///
    yscale(range(1.78 2.42)) ///
    legend(off) ///
    graphregion(color(white)) ///
    plotregion(color(white)) ///
    scheme(s1mono)

capture mkdir figures

graph export "figures/quadratic_ideology_outgroup_comfort.pdf", replace
graph export "figures/quadratic_ideology_outgroup_comfort.png", replace width(2400)

restore

********************************************************************************
********************************************************************************
* FIGURE: Conditional effect of democracy importance by ideology
* Outcome: outgroup comfort
* Higher values = greater comfort = lower political social distance
********************************************************************************

preserve

reg sdistance_index ///
    i.gndr c.age i.ISCED i.employment_status_harmonized i.urban_harmonized ///
    c.lr##c.demimp ///
    c.socialtrust c.pop1 c.pop6 c.satdem c.sateco c.corr1 ///
    [aw=wgt_excl_spe_incl_edu], robust

* Marginal effect of democracy importance across ideology
margins, dydx(demimp) at(lr=(0(1)10))

marginsplot, ///
    recast(line) ///
    recastci(rarea) ///
    yline(0, lcolor(black) lpattern(dash) lwidth(thin)) ///
    plotopts(lcolor(black) lwidth(medthick)) ///
    ciopts(color(gs12%60) lcolor(gs12%0)) ///
    ytitle("Marginal effect of democracy importance on outgroup comfort") ///
    xtitle("Ideological self-placement (0 = Left, 10 = Right)") ///
    title("Conditional effect of democracy importance by ideology") ///
    xlabel(0(1)10, nogrid) ///
    ylabel(-0.15(0.05)0.05, angle(horizontal) nogrid) ///
    yscale(range(-0.155 0.065)) ///
    legend(off) ///
    graphregion(color(white)) ///
    plotregion(color(white)) ///
    scheme(s1mono)

capture mkdir figures

graph export "figures/conditional_effect_democracy_importance_ideology.pdf", replace
graph export "figures/conditional_effect_democracy_importance_ideology.png", replace width(2600)

restore

********************************************************************************
********************************************************************************
* FIGURE: Conditional effect of social trust across ideological groups
* Outcome: outgroup comfort
* Higher values = greater comfort = lower political social distance
********************************************************************************

preserve

********************************************************************************
* Recreate four ideological groups
********************************************************************************

capture drop lr4
gen lr4 = .
replace lr4 = 1 if lr <= 2.5
replace lr4 = 2 if lr > 2.5 & lr <= 4.5
replace lr4 = 3 if lr > 4.5 & lr <= 6.5
replace lr4 = 4 if lr > 6.5

label define lr4_lbl ///
    1 "Left" ///
    2 "Centre-left" ///
    3 "Centre-right" ///
    4 "Right", replace

label values lr4 lr4_lbl

********************************************************************************
* Interaction model
********************************************************************************

reg sdistance_index ///
    i.gndr c.age i.ISCED i.employment_status_harmonized i.urban_harmonized ///
    c.socialtrust##i.lr4 ///
    c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ///
    [aw=wgt_excl_spe_incl_edu], robust

testparm c.socialtrust#i.lr4

********************************************************************************
* Marginal effect of social trust by ideological group
********************************************************************************

margins lr4, dydx(socialtrust)

marginsplot, ///
    recast(scatter) ///
    recastci(rcap) ///
    yline(0, lcolor(black) lpattern(dash) lwidth(thin)) ///
    plotopts(mcolor(black) msymbol(O) msize(medium)) ///
    ciopts(lcolor(black) lwidth(medthick)) ///
    ytitle("Marginal effect of social trust on outgroup comfort") ///
    xtitle("") ///
    title("Conditional effect of social trust across ideological groups") ///
    xlabel(1 "Left" 2 "Centre-left" 3 "Centre-right" 4 "Right", nogrid) ///
    ylabel(0(0.02)0.10, angle(horizontal) nogrid) ///
    yscale(range(-0.003 0.103)) ///
    legend(off) ///
    graphregion(color(white)) ///
    plotregion(color(white)) ///
    scheme(s1mono)

capture mkdir figures

graph export "figures/conditional_effect_social_trust_ideological_groups.pdf", replace
graph export "figures/conditional_effect_social_trust_ideological_groups.png", replace width(2600)

restore

********************************************************************************
********************************************************************************
* Does the ideology effect change after adding democratic conceptions?
********************************************************************************

preserve

* Standardize democratic conception items
capture drop z_electview z_libview z_socialview z_directview z_popview

foreach var in electview libview socialview directview popview {
    egen z_`var' = std(`var')
}

********************************************************************************
* Baseline model: ideology and controls
********************************************************************************

reg sdistance_index ///
    c.lr ///
    i.gndr c.age i.ISCED i.employment_status_harmonized ///
    i.urban_harmonized ///
    c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ///
    [aw=wgt_excl_spe_incl_edu], robust

estimates store M1_baseline

********************************************************************************
* Extended model: adding democratic conceptions
********************************************************************************

reg sdistance_index ///
    c.lr ///
    z_electview z_libview z_socialview z_directview z_popview ///
    i.gndr c.age i.ISCED i.employment_status_harmonized ///
    i.urban_harmonized ///
    c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ///
    [aw=wgt_excl_spe_incl_edu], robust

estimates store M2_conceptions

********************************************************************************
* Optional: does the ideology effect vary by social-content conception?
********************************************************************************

reg sdistance_index ///
    c.lr##c.z_socialview ///
    z_electview z_libview z_directview z_popview ///
    i.gndr c.age i.ISCED i.employment_status_harmonized ///
    i.urban_harmonized ///
    c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ///
    [aw=wgt_excl_spe_incl_edu], robust

estimates store M3_lr_socialconception

restore


********************************************************************************
* LEFT-BLOC ONLY: comfort among left respondents who did NOT select PRR party
********************************************************************************

preserve

capture drop leftbloc
gen byte leftbloc = .
replace leftbloc = 1 if lr <= 4
replace leftbloc = 0 if lr >= 6

label define leftbloc_lbl ///
    0 "Right bloc" ///
    1 "Left bloc", replace
label values leftbloc leftbloc_lbl

capture drop prr_unvotable
gen byte prr_unvotable = 0 if !missing(partynovote_str)

replace prr_unvotable = 1 if strpos(partynovote_str, "National Rally") > 0
replace prr_unvotable = 1 if strpos(partynovote_str, "AfD") > 0
replace prr_unvotable = 1 if strpos(partynovote_str, "Alternative for Germa") > 0
replace prr_unvotable = 1 if strpos(partynovote_str, "Law and Justice") > 0
replace prr_unvotable = 1 if strpos(partynovote_str, "PiS") > 0
replace prr_unvotable = 1 if strpos(partynovote_str, "Fidesz") > 0
replace prr_unvotable = 1 if strpos(partynovote_str, "Vlaams Belang") > 0
replace prr_unvotable = 1 if strpos(partynovote_str, "Brothers of Italy") > 0
replace prr_unvotable = 1 if strpos(partynovote_str, "League") > 0
replace prr_unvotable = 1 if strpos(partynovote_str, "Lega") > 0
replace prr_unvotable = 1 if strpos(partynovote_str, "Reconquest") > 0
replace prr_unvotable = 1 if strpos(partynovote_str, "Confederation") > 0
replace prr_unvotable = 1 if strpos(partynovote_str, "Reform") > 0
replace prr_unvotable = 1 if strpos(partynovote_str, "Progress Party") > 0
replace prr_unvotable = 1 if strpos(partynovote_str, "Our Homeland") > 0

* Descriptive: mean comfort among left bloc, PRR vs non-PRR unvotable
tabstat sdistance_index [aw=wgt_excl_spe_incl_edu] if leftbloc == 1, ///
    by(prr_unvotable) stats(n mean sd)

ttest sdistance_index if leftbloc == 1, by(prr_unvotable)

* Regression among left-bloc respondents only
reg sdistance_index ///
    i.prr_unvotable ///
    i.gndr c.age i.ISCED i.employment_status_harmonized ///
    i.urban_harmonized ///
    c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ///
    [aw=wgt_excl_spe_incl_edu] ///
    if leftbloc == 1, robust

restore

********************************************************************************

********************************************************************************
* FULL SAMPLE: Does ideology still predict comfort after excluding PRR unvotable?
********************************************************************************

preserve

capture drop lr4
gen lr4 = .
replace lr4 = 1 if lr <= 2
replace lr4 = 2 if lr >= 3 & lr <= 4
replace lr4 = 3 if lr >= 6 & lr <= 7
replace lr4 = 4 if lr >= 8

label define lr4_lbl ///
    1 "Left" ///
    2 "Centre-left" ///
    3 "Centre-right" ///
    4 "Right", replace
label values lr4 lr4_lbl

capture drop prr_unvotable
gen byte prr_unvotable = 0 if !missing(partynovote_str)

replace prr_unvotable = 1 if strpos(partynovote_str, "National Rally") > 0
replace prr_unvotable = 1 if strpos(partynovote_str, "Alternative for Germa") > 0
replace prr_unvotable = 1 if strpos(partynovote_str, "Law and Justice") > 0
replace prr_unvotable = 1 if strpos(partynovote_str, "Fidesz") > 0
replace prr_unvotable = 1 if strpos(partynovote_str, "Vlaams Belang") > 0
replace prr_unvotable = 1 if strpos(partynovote_str, "Brothers of Italy") > 0
replace prr_unvotable = 1 if strpos(partynovote_str, "League") > 0
replace prr_unvotable = 1 if strpos(partynovote_str, "Reconquest") > 0
replace prr_unvotable = 1 if strpos(partynovote_str, "Confederation") > 0
replace prr_unvotable = 1 if strpos(partynovote_str, "Reform") > 0
replace prr_unvotable = 1 if strpos(partynovote_str, "Progress Party") > 0
replace prr_unvotable = 1 if strpos(partynovote_str, "Our Homeland") > 0

********************************************************************************
* Model A: full sample
********************************************************************************

reg sdistance_index ///
    i.lr4 ///
    i.gndr c.age i.ISCED i.employment_status_harmonized ///
    i.urban_harmonized ///
    c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ///
    [aw=wgt_excl_spe_incl_edu], robust

estimates store fullsample

********************************************************************************
* Model B: excluding PRR unvotable parties
********************************************************************************

reg sdistance_index ///
    i.lr4 ///
    i.gndr c.age i.ISCED i.employment_status_harmonized ///
    i.urban_harmonized ///
    c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ///
    [aw=wgt_excl_spe_incl_edu] ///
    if prr_unvotable == 0, robust

estimates store no_prr

********************************************************************************
* Model C: controlling for PRR unvotable
********************************************************************************

reg sdistance_index ///
    i.lr4 i.prr_unvotable ///
    i.gndr c.age i.ISCED i.employment_status_harmonized ///
    i.urban_harmonized ///
    c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ///
    [aw=wgt_excl_spe_incl_edu] ///
    if !missing(prr_unvotable), robust

estimates store control_prr

********************************************************************************
* Compare models
********************************************************************************

esttab fullsample no_prr control_prr, ///
    b(3) se(3) ///
    star(* 0.05 ** 0.01 *** 0.001) ///
    stats(N r2, labels("Observations" "R-squared") fmt(0 3))

restore



********************************************************************************
* APPENDIX FIGURES: Unvotable parties and PRR/radical-right rejection
********************************************************************************

preserve

capture mkdir figures

********************************************************************************
* 1. Ideological groups
********************************************************************************

capture drop lr4
gen lr4 = .
replace lr4 = 1 if lr <= 2
replace lr4 = 2 if lr >= 3 & lr <= 4
replace lr4 = 3 if lr >= 6 & lr <= 7
replace lr4 = 4 if lr >= 8

label define lr4_lbl ///
    1 "Left" ///
    2 "Centre-left" ///
    3 "Centre-right" ///
    4 "Right", replace
label values lr4 lr4_lbl

capture drop leftbloc
gen byte leftbloc = .
replace leftbloc = 1 if lr <= 4
replace leftbloc = 0 if lr >= 6

label define leftbloc_lbl ///
    0 "Right bloc" ///
    1 "Left bloc", replace
label values leftbloc leftbloc_lbl


********************************************************************************
* 2. PRR/radical-right unvotable party dummy
********************************************************************************

capture drop prr_unvotable
gen byte prr_unvotable = 0 if !missing(partynovote_str)

replace prr_unvotable = 1 if strpos(partynovote_str, "National Rally") > 0
replace prr_unvotable = 1 if strpos(partynovote_str, "AfD") > 0
replace prr_unvotable = 1 if strpos(partynovote_str, "Alternative for Germa") > 0
replace prr_unvotable = 1 if strpos(partynovote_str, "Law and Justice") > 0
replace prr_unvotable = 1 if strpos(partynovote_str, "PiS") > 0
replace prr_unvotable = 1 if strpos(partynovote_str, "Fidesz") > 0
replace prr_unvotable = 1 if strpos(partynovote_str, "Vlaams Belang") > 0
replace prr_unvotable = 1 if strpos(partynovote_str, "Brothers of Italy") > 0
replace prr_unvotable = 1 if strpos(partynovote_str, "League") > 0
replace prr_unvotable = 1 if strpos(partynovote_str, "Lega") > 0
replace prr_unvotable = 1 if strpos(partynovote_str, "Reconquest") > 0
replace prr_unvotable = 1 if strpos(partynovote_str, "Confederation") > 0
replace prr_unvotable = 1 if strpos(partynovote_str, "Reform") > 0
replace prr_unvotable = 1 if strpos(partynovote_str, "Progress Party") > 0
replace prr_unvotable = 1 if strpos(partynovote_str, "Our Homeland") > 0

label define prr_lbl ///
    0 "Other unvotable party" ///
    1 "PRR/radical-right unvotable party", replace
label values prr_unvotable prr_lbl


********************************************************************************
* FIGURE AE1: Share selecting a PRR/radical-right party as unvotable
********************************************************************************

capture drop prr_pct
gen prr_pct = 100 * prr_unvotable

graph bar (mean) prr_pct [aw=wgt_excl_spe_incl_edu] ///
    if !missing(lr4, prr_unvotable), ///
    over(lr4, label(labsize(medlarge))) ///
    blabel(bar, format(%4.1f) size(small)) ///
    ytitle("% selecting a PRR/radical-right unvotable party") ///
    title("PRR/radical-right unvotable parties by respondent ideology") ///
    ylabel(0(20)100, angle(horizontal) nogrid) ///
    graphregion(color(white)) ///
    plotregion(color(white)) ///
    scheme(s1mono)

graph export "figures/AE1_prr_unvotable_by_ideology.pdf", replace
graph export "figures/AE1_prr_unvotable_by_ideology.png", replace width(2400)


********************************************************************************
* FIGURE AE2: Left bloc only — adjusted comfort by PRR-unvotable status
********************************************************************************

reg sdistance_index ///
    i.prr_unvotable ///
    i.gndr c.age i.ISCED i.employment_status_harmonized ///
    i.urban_harmonized ///
    c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ///
    [aw=wgt_excl_spe_incl_edu] ///
    if leftbloc == 1, robust

margins prr_unvotable

marginsplot, ///
    recast(bar) ///
    recastci(rcap) ///
    plotopts(fcolor(gs12) lcolor(gs8) barwidth(.85)) ///
    ciopts(lcolor(black) lwidth(medthick)) ///
    ytitle("Predicted political outgroup comfort") ///
    xtitle("") ///
    title("Left bloc: comfort by type of unvotable party") ///
    xlabel(0 "Other unvotable party" 1 "PRR/radical-right party", nogrid) ///
    ylabel(1.6(0.2)2.8, angle(horizontal) nogrid) ///
    yscale(range(1.55 2.85)) ///
    legend(off) ///
    graphregion(color(white)) ///
    plotregion(color(white)) ///
    scheme(s1mono)

graph export "figures/AE2_leftbloc_comfort_by_prr_unvotable.pdf", replace
graph export "figures/AE2_leftbloc_comfort_by_prr_unvotable.png", replace width(2400)


********************************************************************************
* FIGURE AE3A: Predicted comfort by ideology — full sample
********************************************************************************

reg sdistance_index ///
    i.lr4 ///
    i.gndr c.age i.ISCED i.employment_status_harmonized ///
    i.urban_harmonized ///
    c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ///
    [aw=wgt_excl_spe_incl_edu], robust

margins lr4

marginsplot, ///
    recast(bar) ///
    recastci(rcap) ///
    plotopts(fcolor(gs12) lcolor(gs8) barwidth(.85)) ///
    ciopts(lcolor(black) lwidth(medthick)) ///
    ytitle("Predicted political outgroup comfort") ///
    xtitle("") ///
    title("Full sample") ///
    xlabel(1 "Left" 2 "Centre-left" 3 "Centre-right" 4 "Right", nogrid) ///
    ylabel(1.8(0.2)2.8, angle(horizontal) nogrid) ///
    yscale(range(1.75 2.85)) ///
    legend(off) ///
    graphregion(color(white)) ///
    plotregion(color(white)) ///
    scheme(s1mono) ///
    name(fig_full, replace)


********************************************************************************
* FIGURE AE3B: Predicted comfort by ideology — excluding PRR unvotable parties
********************************************************************************

reg sdistance_index ///
    i.lr4 ///
    i.gndr c.age i.ISCED i.employment_status_harmonized ///
    i.urban_harmonized ///
    c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ///
    [aw=wgt_excl_spe_incl_edu] ///
    if prr_unvotable == 0, robust

margins lr4

marginsplot, ///
    recast(bar) ///
    recastci(rcap) ///
    plotopts(fcolor(gs12) lcolor(gs8) barwidth(.85)) ///
    ciopts(lcolor(black) lwidth(medthick)) ///
    ytitle("") ///
    xtitle("") ///
    title("Excluding PRR/radical-right unvotable parties") ///
    xlabel(1 "Left" 2 "Centre-left" 3 "Centre-right" 4 "Right", nogrid) ///
    ylabel(1.8(0.2)2.8, angle(horizontal) nogrid) ///
    yscale(range(1.75 2.85)) ///
    legend(off) ///
    graphregion(color(white)) ///
    plotregion(color(white)) ///
    scheme(s1mono) ///
    name(fig_no_prr, replace)


********************************************************************************
* FIGURE AE3C: Predicted comfort by ideology — controlling for PRR unvotable
********************************************************************************

reg sdistance_index ///
    i.lr4 i.prr_unvotable ///
    i.gndr c.age i.ISCED i.employment_status_harmonized ///
    i.urban_harmonized ///
    c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ///
    [aw=wgt_excl_spe_incl_edu] ///
    if !missing(prr_unvotable), robust

margins lr4

marginsplot, ///
    recast(bar) ///
    recastci(rcap) ///
    plotopts(fcolor(gs12) lcolor(gs8) barwidth(.85)) ///
    ciopts(lcolor(black) lwidth(medthick)) ///
    ytitle("") ///
    xtitle("") ///
    title("Controlling for PRR/radical-right unvotable party") ///
    xlabel(1 "Left" 2 "Centre-left" 3 "Centre-right" 4 "Right", nogrid) ///
    ylabel(1.8(0.2)2.8, angle(horizontal) nogrid) ///
    yscale(range(1.75 2.85)) ///
    legend(off) ///
    graphregion(color(white)) ///
    plotregion(color(white)) ///
    scheme(s1mono) ///
    name(fig_control_prr, replace)


********************************************************************************
* COMBINED FIGURE AE3
********************************************************************************

graph combine fig_full fig_no_prr fig_control_prr, ///
    col(3) ///
    ycommon ///
    imargin(tiny) ///
    graphregion(color(white)) ///
    title("Political outgroup comfort by ideology and unvotable party type")

graph export "figures/AE3_ideology_comfort_prr_robustness_combined.pdf", replace
graph export "figures/AE3_ideology_comfort_prr_robustness_combined.png", replace width(3600)


********************************************************************************
* END
********************************************************************************

restore


********************************************************************************
* COMBINED POINT FIGURE: full / no PRR / control PRR
********************************************************************************

* Full sample
reg sdistance_index ///
    i.lr4 ///
    i.gndr c.age i.ISCED i.employment_status_harmonized ///
    i.urban_harmonized ///
    c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ///
    [aw=wgt_excl_spe_incl_edu], robust

margins lr4

marginsplot, ///
    recast(scatter) ///
    recastci(rcap) ///
    plotopts(msymbol(O) mcolor(black) msize(medium)) ///
    ciopts(lcolor(black) lwidth(medthick)) ///
    ytitle("Predicted political outgroup comfort") ///
    xtitle("") ///
    title("Full sample") ///
    xlabel(1 "Left" 2 "Centre-left" 3 "Centre-right" 4 "Right", nogrid) ///
    ylabel(1.8(0.2)2.8, angle(horizontal) nogrid) ///
    yscale(range(1.75 2.85)) ///
    legend(off) ///
    graphregion(color(white)) ///
    plotregion(color(white)) ///
    scheme(s1mono) ///
    name(fig_full_point, replace)


* Excluding PRR/radical-right unvotable parties
reg sdistance_index ///
    i.lr4 ///
    i.gndr c.age i.ISCED i.employment_status_harmonized ///
    i.urban_harmonized ///
    c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ///
    [aw=wgt_excl_spe_incl_edu] ///
    if prr_unvotable == 0, robust

margins lr4

marginsplot, ///
    recast(scatter) ///
    recastci(rcap) ///
    plotopts(msymbol(O) mcolor(black) msize(medium)) ///
    ciopts(lcolor(black) lwidth(medthick)) ///
    ytitle("") ///
    xtitle("") ///
    title("Excluding PRR/radical-right parties") ///
    xlabel(1 "Left" 2 "Centre-left" 3 "Centre-right" 4 "Right", nogrid) ///
    ylabel(1.8(0.2)2.8, angle(horizontal) nogrid) ///
    yscale(range(1.75 2.85)) ///
    legend(off) ///
    graphregion(color(white)) ///
    plotregion(color(white)) ///
    scheme(s1mono) ///
    name(fig_no_prr_point, replace)


* Controlling for PRR/radical-right unvotable party
reg sdistance_index ///
    i.lr4 i.prr_unvotable ///
    i.gndr c.age i.ISCED i.employment_status_harmonized ///
    i.urban_harmonized ///
    c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ///
    [aw=wgt_excl_spe_incl_edu] ///
    if !missing(prr_unvotable), robust

margins lr4

marginsplot, ///
    recast(scatter) ///
    recastci(rcap) ///
    plotopts(msymbol(O) mcolor(black) msize(medium)) ///
    ciopts(lcolor(black) lwidth(medthick)) ///
    ytitle("") ///
    xtitle("") ///
    title("Controlling for PRR/radical-right party") ///
    xlabel(1 "Left" 2 "Centre-left" 3 "Centre-right" 4 "Right", nogrid) ///
    ylabel(1.8(0.2)2.8, angle(horizontal) nogrid) ///
    yscale(range(1.75 2.85)) ///
    legend(off) ///
    graphregion(color(white)) ///
    plotregion(color(white)) ///
    scheme(s1mono) ///
    name(fig_control_prr_point, replace)


graph combine fig_full_point fig_no_prr_point fig_control_prr_point, ///
    col(3) ///
    ycommon ///
    imargin(tiny) ///
    graphregion(color(white)) ///
    title("Political outgroup comfort by ideology and unvotable party type")

graph export "figures/AE3_ideology_comfort_prr_robustness_combined_points.pdf", replace
graph export "figures/AE3_ideology_comfort_prr_robustness_combined_points.png", replace width(3600)




********************************************************************************
* APPENDIX AF: Country-specific patterns in political outgroup comfort
********************************************************************************

preserve

capture mkdir figures

********************************************************************************
* 1. Create numeric country variable if needed
********************************************************************************

capture drop country_id

capture confirm numeric variable country
if !_rc {
    clonevar country_id = country
}
else {
    encode country, gen(country_id)
}

********************************************************************************
* 2. FIGURE AF1: Adjusted political outgroup comfort by country
********************************************************************************

reg sdistance_index ///
    i.country_id ///
    i.gndr c.age i.ISCED i.employment_status_harmonized ///
    i.urban_harmonized ///
    c.lr c.socialtrust c.pop1 c.pop6 c.demimp c.satdem c.sateco c.corr1 ///
    [aw=wgt_excl_spe_incl_edu], robust

margins country_id

marginsplot, ///
    recast(scatter) ///
    recastci(rcap) ///
    plotopts(msymbol(O) mcolor(black) msize(medium)) ///
    ciopts(lcolor(black) lwidth(medthick)) ///
    ytitle("Predicted political outgroup comfort") ///
    xtitle("") ///
    title("Adjusted political outgroup comfort by country") ///
    xlabel(, angle(45) nogrid) ///
    ylabel(1.6(0.2)2.8, angle(horizontal) nogrid) ///
    yscale(range(1.55 2.85)) ///
    legend(off) ///
    graphregion(color(white)) ///
    plotregion(color(white)) ///
    scheme(s1mono)

graph export "figures/AF1_predicted_comfort_by_country.pdf", replace
graph export "figures/AF1_predicted_comfort_by_country.png", replace width(2800)


********************************************************************************
* 3. Country-specific effects of focal predictors
********************************************************************************

reg sdistance_index ///
    c.lr##i.country_id ///
    c.socialtrust##i.country_id ///
    c.demimp##i.country_id ///
    i.gndr c.age i.ISCED i.employment_status_harmonized ///
    i.urban_harmonized ///
    c.pop1 c.pop6 c.satdem c.sateco c.corr1 ///
    [aw=wgt_excl_spe_incl_edu], robust

********************************************************************************
* 4. Joint tests of cross-country heterogeneity
********************************************************************************

testparm c.lr#i.country_id
testparm c.socialtrust#i.country_id
testparm c.demimp#i.country_id


********************************************************************************
* 5. FIGURE AF2A: Country-specific marginal effect of ideology
********************************************************************************

margins country_id, dydx(lr)

marginsplot, ///
    recast(scatter) ///
    recastci(rcap) ///
    yline(0, lcolor(black) lpattern(dash) lwidth(thin)) ///
    plotopts(msymbol(O) mcolor(black) msize(medium)) ///
    ciopts(lcolor(black) lwidth(medthick)) ///
    ytitle("Marginal effect on outgroup comfort") ///
    xtitle("") ///
    title("Left-right self-placement") ///
    xlabel(, angle(45) nogrid) ///
    ylabel(-0.10(0.05)0.15, angle(horizontal) nogrid) ///
    yscale(range(-0.11 0.16)) ///
    legend(off) ///
    graphregion(color(white)) ///
    plotregion(color(white)) ///
    scheme(s1mono) ///
    name(fig_country_lr, replace)

graph export "figures/AF2A_country_effect_lr.pdf", replace
graph export "figures/AF2A_country_effect_lr.png", replace width(2800)


********************************************************************************
* 6. FIGURE AF2B: Country-specific marginal effect of social trust
********************************************************************************

margins country_id, dydx(socialtrust)

marginsplot, ///
    recast(scatter) ///
    recastci(rcap) ///
    yline(0, lcolor(black) lpattern(dash) lwidth(thin)) ///
    plotopts(msymbol(O) mcolor(black) msize(medium)) ///
    ciopts(lcolor(black) lwidth(medthick)) ///
    ytitle("") ///
    xtitle("") ///
    title("Social trust") ///
    xlabel(, angle(45) nogrid) ///
    ylabel(-0.10(0.05)0.15, angle(horizontal) nogrid) ///
    yscale(range(-0.11 0.16)) ///
    legend(off) ///
    graphregion(color(white)) ///
    plotregion(color(white)) ///
    scheme(s1mono) ///
    name(fig_country_trust, replace)

graph export "figures/AF2B_country_effect_socialtrust.pdf", replace
graph export "figures/AF2B_country_effect_socialtrust.png", replace width(2800)


********************************************************************************
* 7. FIGURE AF2C: Country-specific marginal effect of democracy importance
********************************************************************************

margins country_id, dydx(demimp)

marginsplot, ///
    recast(scatter) ///
    recastci(rcap) ///
    yline(0, lcolor(black) lpattern(dash) lwidth(thin)) ///
    plotopts(msymbol(O) mcolor(black) msize(medium)) ///
    ciopts(lcolor(black) lwidth(medthick)) ///
    ytitle("") ///
    xtitle("") ///
    title("Democracy importance") ///
    xlabel(, angle(45) nogrid) ///
    ylabel(-0.10(0.05)0.15, angle(horizontal) nogrid) ///
    yscale(range(-0.11 0.16)) ///
    legend(off) ///
    graphregion(color(white)) ///
    plotregion(color(white)) ///
    scheme(s1mono) ///
    name(fig_country_demimp, replace)

graph export "figures/AF2C_country_effect_demimp.pdf", replace
graph export "figures/AF2C_country_effect_demimp.png", replace width(2800)


********************************************************************************
* 8. COMBINED FIGURE AF2
********************************************************************************

graph combine fig_country_lr fig_country_trust fig_country_demimp, ///
    col(3) ///
    ycommon ///
    imargin(tiny) ///
    graphregion(color(white)) ///
    title("Country-specific marginal effects on political outgroup comfort")

graph export "figures/AF2_country_specific_marginal_effects.pdf", replace
graph export "figures/AF2_country_specific_marginal_effects.png", replace width(3800)

restore

********************************************************************************

********************************************************************************
* FIGURE F1: Weighted distribution of political outgroup comfort index
********************************************************************************

preserve

capture mkdir figures

* Keep only valid observations
keep if !missing(sdistance_index, wgt_excl_spe_incl_edu)

* The index is the mean of four 1-4 items, so possible values are spaced by .25
capture drop sdistance_cat
gen sdistance_cat = round(sdistance_index*4)/4

* Compute weighted distribution manually
collapse (sum) weight_sum = wgt_excl_spe_incl_edu, by(sdistance_cat)

egen total_weight = total(weight_sum)
gen pct = 100 * weight_sum / total_weight

twoway ///
    (bar pct sdistance_cat, barwidth(0.20) color(gs10) lcolor(gs8)), ///
    xlabel(1(0.5)4, nogrid) ///
    ylabel(0(5)20, angle(horizontal) nogrid) ///
    xtitle("Political outgroup comfort index (1 = discomfort, 4 = comfort)") ///
    ytitle("Percent") ///
    title("Distribution of political outgroup comfort index") ///
    graphregion(color(white)) ///
    plotregion(color(white)) ///
    scheme(s1mono) ///
    legend(off)

graph export "figures/F1_distribution_political_outgroup_comfort.pdf", replace
graph export "figures/F1_distribution_political_outgroup_comfort.png", replace width(2400)

restore

********************************************************************************
* Social trust robustness with unvotable-party type
********************************************************************************

preserve

capture drop ideological_extremity
gen ideological_extremity = abs(lr - 5)

* Use your already-created prr_unvotable variable if available

reg sdistance_index ///
    c.socialtrust ///
    c.lr c.ideological_extremity c.demimp ///
    i.prr_unvotable ///
    i.gndr c.age i.ISCED i.employment_status_harmonized i.urban_harmonized ///
    c.pop1 c.pop6 c.satdem c.sateco c.corr1 ///
    i.country ///
    [aw=wgt_excl_spe_incl_edu] ///
    if !missing(prr_unvotable), robust

restore

********************************************************************************
* FIGURE: Social trust and political outgroup comfort
* Robustness model controlling for ideological extremity, PRR target, and country FE
********************************************************************************

preserve

capture mkdir figures

* Ideological extremity
capture drop ideological_extremity
gen ideological_extremity = abs(lr - 5)

* Robustness model
reg sdistance_index ///
    c.socialtrust ///
    c.lr c.ideological_extremity c.demimp ///
    i.prr_unvotable ///
    i.gndr c.age i.ISCED i.employment_status_harmonized i.urban_harmonized ///
    c.pop1 c.pop6 c.satdem c.sateco c.corr1 ///
    i.country ///
    [aw=wgt_excl_spe_incl_edu] ///
    if !missing(prr_unvotable), robust

* Predicted values across social trust
margins, at(socialtrust=(0(1)10))

marginsplot, ///
    recast(line) ///
    recastci(rarea) ///
    plotopts(lwidth(medthick)) ///
    ciopts(fcolor(gs14) lcolor(gs12)) ///
    ytitle("Predicted political outgroup comfort") ///
    xtitle("Social trust") ///
    title("Social trust and political outgroup comfort") ///
    subtitle("Adjusted for ideological extremity, PRR/radical-right target, and country fixed effects") ///
    xlabel(0(1)10, nogrid) ///
    ylabel(2.0(0.1)2.7, angle(horizontal) nogrid) ///
    yscale(range(2.0 2.7)) ///
    graphregion(color(white)) ///
    plotregion(color(white)) ///
    legend(off) ///
    scheme(s1mono)

graph export "figures/social_trust_robustness_predicted_comfort.pdf", replace
graph export "figures/social_trust_robustness_predicted_comfort.png", replace width(2400)

restore


********************************************************************************
* Robustness: ideological extremity and strength of party closeness
********************************************************************************

preserve

capture mkdir figures

* Ideological extremity
capture drop ideological_extremity
gen ideological_extremity = abs(lr - 5)

* Decode party closeness variables if numeric
capture drop pid_label
capture decode pid, gen(pid_label)
if _rc != 0 {
    gen strL pid_label = pid
}

capture drop pidstrength_label
capture decode pidstrength, gen(pidstrength_label)
if _rc != 0 {
    gen strL pidstrength_label = pidstrength
}

* Construct inclusive party-closeness strength variable
capture drop partisan_strength
gen partisan_strength = .

replace partisan_strength = 0 if strpos(pid_label, "I do not feel close to any party") > 0

replace partisan_strength = 1 if strpos(pidstrength_label, "Not very close") > 0
replace partisan_strength = 2 if strpos(pidstrength_label, "Quite close") > 0
replace partisan_strength = 3 if strpos(pidstrength_label, "Very close") > 0

label define partisan_strength_lbl ///
    0 "No close party" ///
    1 "Not very close" ///
    2 "Quite close" ///
    3 "Very close", replace

label values partisan_strength partisan_strength_lbl

tab partisan_strength, missing

* Main robustness model
reg sdistance_index ///
    c.socialtrust ///
    c.lr c.ideological_extremity c.demimp ///
    i.partisan_strength ///
    i.prr_unvotable ///
    i.gndr c.age i.ISCED i.employment_status_harmonized i.urban_harmonized ///
    c.pop1 c.pop6 c.satdem c.sateco c.corr1 ///
    i.country ///
    [aw=wgt_excl_spe_incl_edu] ///
    if !missing(prr_unvotable), robust

restore


********************************************************************************
* FIGURE: Party closeness strength and political outgroup comfort
********************************************************************************

preserve

capture mkdir figures

* Ideological extremity
capture drop ideological_extremity
gen ideological_extremity = abs(lr - 5)

* Decode party closeness variables if numeric
capture drop pid_label
capture decode pid, gen(pid_label)
if _rc != 0 {
    gen strL pid_label = pid
}

capture drop pidstrength_label
capture decode pidstrength, gen(pidstrength_label)
if _rc != 0 {
    gen strL pidstrength_label = pidstrength
}

* Construct inclusive party-closeness strength variable
capture drop partisan_strength
gen partisan_strength = .

replace partisan_strength = 0 if strpos(pid_label, "I do not feel close to any party") > 0
replace partisan_strength = 1 if strpos(pidstrength_label, "Not very close") > 0
replace partisan_strength = 2 if strpos(pidstrength_label, "Quite close") > 0
replace partisan_strength = 3 if strpos(pidstrength_label, "Very close") > 0

label define partisan_strength_lbl ///
    0 "No close party" ///
    1 "Not very close" ///
    2 "Quite close" ///
    3 "Very close", replace

label values partisan_strength partisan_strength_lbl

* Robustness model
reg sdistance_index ///
    c.socialtrust ///
    c.lr c.ideological_extremity c.demimp ///
    i.partisan_strength ///
    i.prr_unvotable ///
    i.gndr c.age i.ISCED i.employment_status_harmonized i.urban_harmonized ///
    c.pop1 c.pop6 c.satdem c.sateco c.corr1 ///
    i.country ///
    [aw=wgt_excl_spe_incl_edu] ///
    if !missing(prr_unvotable), robust

* Adjusted predictions by party closeness strength
margins partisan_strength

marginsplot, ///
    recast(scatter) ///
    recastci(rcap) ///
    plotopts(msymbol(O) msize(medium)) ///
    ciopts(lcolor(gs8)) ///
    ytitle("Predicted political outgroup comfort") ///
    xtitle("Strength of party closeness") ///
    title("Party closeness and political outgroup comfort") ///
    subtitle("Adjusted for social trust, ideological extremity, PRR/radical-right target, and country fixed effects") ///
    xlabel(0 "No close party" 1 "Not very close" 2 "Quite close" 3 "Very close", angle(25)) ///
    ylabel(2.0(0.1)2.6, angle(horizontal) nogrid) ///
    yscale(range(2.0 2.6)) ///
    graphregion(color(white)) ///
    plotregion(color(white)) ///
    legend(off) ///
    scheme(s1mono)

graph export "figures/AH_party_closeness_predicted_comfort.pdf", replace
graph export "figures/AH_party_closeness_predicted_comfort.png", replace width(2400)

restore