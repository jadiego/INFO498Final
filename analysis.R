library(dplyr)
library(foreign)
library(ggplot2)
library(survey)

d <- read.csv("prepped/ngis.csv")

d$HCSPENDY <- factor()