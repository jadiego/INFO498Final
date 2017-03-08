library(dplyr)
library(tidyr)
library(foreign)
library(ggplot2)
library(survey)

d <- read.csv("../prepped/nhis.csv")

############################################################
################### Factoring Columns ######################
############################################################

# Variable HCSPENDY is coded 1-9
d$HCSPENDY <- factor(d$HCSPENDY,
                     levels = c(1:9),
                     labels = c("Zero","Less than $500",
                                "$500 to $1999", "$2000 to $2999",
                                "$3000 to $4999", "$5000 or more",
                                "Unknown-refused", "Unknown-not ascertained",
                                "Unknown-don't know"))
summary(d$HCSPENDY)

############################################################
################### Subset Dataframes ######################
############################################################

# weighted population * 100 for each year
pop <- d %>% group_by(YEAR) %>% summarize(population = sum(as.numeric(PERWEIGHT)))


# Row value with valid money spent on health insurance info
wanted.rows <- c("Zero","Less than $500",
                 "$500 to $1999", "$2000 to $2999",
                 "$3000 to $4999", "$5000 or more")

# Known expenditure for HI
d1 <- d %>% filter(HCSPENDY %in% wanted.rows)
spend.years <- d1 %>% group_by(HCSPENDY, YEAR) %>% summarise(count = n())

# NHIS survey data - 2015
d2015 <- read.csv("../prepped/personsx.csv")



# Odds ratio for healthcare access, educational attainment question
d2015.odds.ratio <- d2015 %>% select(EDUC1, NOTCOV) %>% filter(NOTCOV != 9)
d2015.hs.odds.ratio <- d2015.odds.ratio %>% filter(EDUC1 == 14)
d2015.ba.odds.ratio <- d2015.odds.ratio %>% filter(EDUC1 == 18)


############################################################
################## Distribution Graphs #####################
############################################################

# Line chart
# Change of expend over years (Not weighted)
ggplot(spend.years, aes(x=YEAR, y=count/1000, colour=HCSPENDY)) + geom_line() +
  geom_point(size=.7) +
  labs(x="Year", y="Sum of People (Thousands)", title = "Distribution of Health Expenditure")

# Histogram
# Educational Attainment vs Health Insurance
ggplot(d2015, aes(EDUC1)) + geom_histogram(stat='count') + facet_wrap(~NOTCOV) + 
  ggtitle('Education Level vs. Health Coverage') + labs(x='Education Level') 

# Histogram
# Educational Attainment vs. Workplace-offered Health Insurance
ggplot(d2015, aes(EDUC1)) + geom_histogram(stat='count') + facet_wrap(~HIEMPOF) +
  ggtitle('Education Level vs. Workplace-offered Health Insurance') + labs(x='Education Level')

############################################################
################### Stratified Sample ######################
############################################################

# Survey design with known expend. in health insurance
d2 <- svydesign(id=~PSU, strata = ~STRATA, weights = ~PERWEIGHT, data=d1, nest = T)

# Average of people for each level of money spent on health insurance
svymean(~HCSPENDY, d2)

# Count of people of money spent on health insurance groups by year
d5 <- svyby(~factor(HCSPENDY), ~YEAR, d2, svytotal, vartype = c("ci", "se"))
colnames(d5) <- c("YEAR","zero", "lessthan500",
                 "spend500to1999", "spend2000to2999",
                 "spend3000to4999", "spend5000ormore",
                 "se.zero", "se.lessthan500",
                 "se.spend500to1999", "se.spend2000to2999",
                 "se.spend3000to4999","se.spend5000ormore",
                 "ci_l.zero", "ci_l.lessthan500", 
                 "ci_l.spend500to1999", "ci_l.spend2000to2999", 
                 "ci_l.spend3000to4999", "ci_l.spend5000ormore",
                 "ci_u.zero", "ci_u.lessthan500",
                 "ci_u.spend500to1999", "ci_u.spend2000to2999",
                 "ci_u.spend3000to4999", "ci_u.spend5000ormore")

############################################################
#################### Final Dataframes ######################
############################################################

hi.spend <- inner_join(pop, d5, by = "YEAR")

############################################################
################ Weighted Visualizations ###################
############################################################

ggplot(hi.spend, aes(y=factor(YEAR))) +
  geom_point(data= hi.spend, aes(x=zero/population * 100, colour='red'), size=.9) +
  geom_errorbarh(data= hi.spend, aes(x=zero/population * 100, xmin=ci_u.zero/population * 100, 
                                     xmax=ci_l.zero/population * 100),height=0.1) +
  geom_point(data= hi.spend, aes(x=lessthan500/population * 100, colour='gold'), size=.9) +
  geom_errorbarh(data= hi.spend, aes(x=lessthan500/population * 100, xmin=ci_l.lessthan500/population * 100, 
                                     xmax=ci_u.lessthan500/population * 100),height=0.1) +
  geom_point(data= hi.spend, aes(x=spend3000to4999/population * 100, colour='blue'), size=.9) +
  geom_errorbarh(data= hi.spend, aes(x=spend3000to4999/population * 100, xmin=ci_l.spend3000to4999/population * 100, 
                                     xmax=ci_u.spend3000to4999/population * 100),height=0.1) +
  coord_flip() + 
  scale_color_discrete(name="Expenditure", labels = c("Zero", "Less than $500", "$3000 to $4999")) +
  labs(x="Weighted Proportion of People (%)", y="Year")
