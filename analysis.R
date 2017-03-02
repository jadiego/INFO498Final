library(dplyr)
library(foreign)
library(ggplot2)
library(survey)

d <- read.csv("prepped/nhis.csv")

# Variable HCSPENDY is coded 1-9
d$HCSPENDY <- factor(d$HCSPENDY,
                     levels = c(1:9),
                     labels = c("Zero","Less than $500",
                                "$500 to $1999", "$2000 to $2999",
                                "$3000 to $4999", "$5000 or more",
                                "Unknown-refused", "Unknown-not ascertained",
                                "Unknown-don't know"))

# Row value with valid money spent on health insurance info
wanted.rows <- c("Zero","Less than $500",
                 "$500 to $1999", "$2000 to $2999",
                 "$3000 to $4999", "$5000 or more")

# list labels
levels(d$HCSPENDY)

# Filter: take out rows with unknown expedenture in health insurance
d1 <- d %>% filter(HCSPENDY %in% wanted.rows)

# Variable HINOTCOVE is coded 0-9
d$HINOTCOVE <- factor(d$HINOTCOVE,
                      levels = c(0, 1, 2, 7, 8, 9),
                      labels = c("NIU","No, has coverage", "Yes, has no coverage", 
                      "Unknown-refused", "Unknown-not ascertained", 
                      "Unknown-don't know"))

# list labels
levels(d$HINOTCOVE)

# Subset of df who answered yes, no to has health insurance
hi.cover.status <- d %>% filter(HINOTCOVE %in% c("No, has coverage", "Yes, has no coverage"))

# Distribution of health insurance expend. from 05'-15' (not weighted)
ggplot(d1, aes(HCSPENDY)) + geom_histogram(stat = "count") +
  coord_flip() +
  facet_wrap(~ YEAR) +
  labs(x="Amount family spent for medical care, past 12 months", y="Count", title = "Not Weighted")

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

# Count of people who had health insurance grouped by year
d6 <- svyby(~factor(HINOTCOVE), ~YEAR, d4, svytotal, vartype = c("ci", "se"))

