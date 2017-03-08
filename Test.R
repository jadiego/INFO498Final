library(dplyr)
library(plotly)
library(ggplot2)

setwd("/Users/warrenykwaku/Desktop/INFO498_HW/INFO498Final/data") #Setting working directory

survey.data <- read.csv("personsx.csv") #Reading in survey data

my.data <- survey.data %>% 
  select(EDUC1, HIEMPOF, NOTCOV) %>% 
  filter(EDUC1 <= 21) #Read in survey data and use only ones I need

oddsratio.data <- survey.data %>% 
  select(EDUC1, NOTCOV) %>% 
  filter(NOTCOV != 9) #Dealing only with responses 1 and 2
  
HS.data <- oddsratio.data %>% 
  filter(EDUC1 == 14) #Narrowing to only High school graduate data
table(HS.data) 

BA.data <- oddsratio.data %>% 
  filter(EDUC1 == 18) #Narrowing to only Bachelors Degree data
table(BA.data) 

#Plotting histogram for Educational Attainment vs. Health Coverage
ggplot(my.data, aes(EDUC1)) + geom_histogram(stat='count') + facet_wrap(~NOTCOV) + 
  ggtitle('Education Level vs. Health Coverage') + labs(x='Education Level') 

#Plotting histogram for Educational Attainment vs. Workplace-offered Health Insurance
ggplot(my.data, aes(EDUC1)) + geom_histogram(stat='count') + facet_wrap(~HIEMPOF) +
  ggtitle('Education Level vs. Workplace-offered Health Insurance') + labs(x='Education Level')
