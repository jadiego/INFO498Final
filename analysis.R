install.packages("dplyr")
install.packages("foreign")
install.packages("ggplot2")
install.packages("survey")

library(dplyr)
library(foreign)
library(ggplot2)
library(survey)

d <- read.csv("prepped/nhis.csv")

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
summary(spending$HCSPENDY)


# Variable HINOTCOVE is coded 0-9
d$HINOTCOVE <- factor(d$HINOTCOVE,
                      levels = c(0, 1, 2, 7, 8, 9),
                      labels = c("NIU","No, has coverage", "Yes, has no coverage", 
                                 "Unknown-refused", "Unknown-not ascertained", 
                                 "Unknown-don't know"))
summary(d$HINOTCOVE)

# Variable HIPWORKR is coded 0-9
d$HIPWORKR <- factor(d$HIPWORKR,
                     levels = c(0, 1, 2, 9),
                     labels = c("NIU", "No", 
                                "Yes", "Unknown"))
summary(d$HIPWORKR)

############################################################
################### Subset Dataframes ######################
############################################################

# Row value with valid money spent on health insurance info
wanted.rows <- c("Zero","Less than $500",
                 "$500 to $1999", "$2000 to $2999",
                 "$3000 to $4999", "$5000 or more")
# Known expenditure for HI
d1 <- d %>% filter(HCSPENDY %in% wanted.rows)


# YES/NO to HI
hi.cover.status <- d %>% filter(HINOTCOVE %in% c("No, has coverage", "Yes, has no coverage"))

# sample random ten rows from master df
example <- d %>% sample_n(10)

# 2007 subset
d2007 <- d %>% filter(YEAR == 2007)
d2007example <- d2007 %>% sample_n(100)

# weighted population for each year
pop <- d %>% group_by(YEAR) %>% summarize(population = sum(as.numeric(PERWEIGHT)))

############################################################
################## Distribution Graphs #####################
############################################################

# Distribution of health insurance expend. from 05'-15' (not weighted)
ggplot(d1, aes(HCSPENDY)) + geom_histogram(stat = "count") +
  coord_flip() +
  facet_wrap(~ YEAR) +
  labs(x="Amount family spent for medical care, past 12 months", y="Count", title = "Not Weighted")

# Distribution of health insurance coverage from 05'-15' (not weighted)
ggplot(d, aes(HINOTCOVE)) + geom_histogram(stat = "count") +
  coord_flip() +
  facet_wrap(~ YEAR) +
  labs(x="Health Insurance coverage status", y="Count", title = "Not Weighted")


############################################################
################### Stratified Sample ######################
############################################################

# Survey design with unknown expend. in health insurance
d2 <- svydesign(id=~PSU, strata = ~STRATA, weights = ~PERWEIGHT, data=d, nest = T)

# Survey design WITHOUT unknown expend. in health insurance
d3 <- svydesign(id=~PSU, strata = ~STRATA, weights = ~PERWEIGHT, data=d1, nest = T)

# Survey design covering health insurance coverage
d4 <- svydesign(id=~PSU, strata = ~STRATA, weights = ~PERWEIGHT, data = hi.cover.status, nest = T)

# Count of people for each level of money spent on health insurance
svytotal(~HCSPENDY, d2)
svytotal(~HCSPENDY, d3)

# Count of people of money spenton health insurance groups by year
d5 <- svyby(~factor(HCSPENDY), ~YEAR, d3, svytotal, vartype = c("ci", "se"))

# Count of people who had health insurance grouped by year and got through employer
d6 <- svyby(~factor(HINOTCOVE), ~YEAR, d4, svytotal, vartype = c("ci", "se"))

# Comparing proportions of weighted vs unweighted (who had HI)
prop.table(table(d$HINOTCOVE))
prop.table(svytable(~HINOTCOVE, design = d2))


# print colnames
colnames(d6)

# rename col names of df:who has HI
d6 <- d6 %>% rename(YEAR = `YEAR`, no = `factor(HINOTCOVE)No, has coverage`,
              yes = `factor(HINOTCOVE)Yes, has no coverage`, no.se = `se.factor(HINOTCOVE)No, has coverage`,
              yes.se = `se.factor(HINOTCOVE)Yes, has no coverage`, no.cil = `ci_l.factor(HINOTCOVE)No, has coverage`,
              yes.cil = `ci_l.factor(HINOTCOVE)Yes, has no coverage`, no.ciu = `ci_u.factor(HINOTCOVE)No, has coverage`,
              yes.ciu = `ci_u.factor(HINOTCOVE)Yes, has no coverage`)


############################################################
#################### Final Dataframes ######################
############################################################

# No means, they do have coverage
hi.cover <- inner_join(pop, d6, by = "YEAR")
hi.cover <- hi.cover %>% transmute( year = YEAR, no = no/population, yes = yes/population, 
                                    no.se = no.se/population, yes.se = yes.se/population, 
                                    no.cil = no.cil/population, yes.cil = yes.cil/population,
                                    no.ciu = no.ciu/population, yes.ciu = yes.ciu/population)

# write to CSV
write.csv(hi.cover, "prepped/hicover.csv")


############################################################
################ Weighted Visualizations ###################
############################################################

#yes coverage
ggplot(hi.cover, aes(x=no, y=factor(year), xmin=no.cil, xmax=no.ciu)) +
  geom_point() +
  geom_errorbarh(height=0.2) + 
  coord_flip() + 
  labs(x="Has Health Insurance (%)", y="Year")

# no coverage
ggplot(hi.cover, aes(x=yes, y=factor(year), xmin=yes.cil, xmax=yes.ciu)) +
  geom_point() +
  geom_errorbarh(height=0.2) + 
  coord_flip() +
  labs(x="No Health Insurance (%)", y="Year")

#Both
ggplot(hi.cover, aes(y=factor(year))) +
  geom_point(data= hi.cover, aes(x=no)) +
  geom_errorbarh(data= hi.cover, aes(x=no, xmin=no.cil, xmax=no.ciu),height=0.2) +
  geom_point(data= hi.cover, aes(x=yes)) +
  geom_errorbarh(data= hi.cover, aes(x=yes, xmin=yes.cil, xmax=yes.ciu),height=0.2) + 
  coord_flip() + 
  labs(x="Has Health Insurance (%)", y="Year")
