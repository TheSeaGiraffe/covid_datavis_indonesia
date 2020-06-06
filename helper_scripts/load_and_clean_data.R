#
#   load_and_clean_data.R - a script to load and clean the COVID-19 data for the
#   shiny app.
#

#=====
# Prep
#=====

# Load necessary libraries

library(tidyverse)
library(magrittr)
library(lubridate)
library(zeallot)

# Load data directly from website
urls <- c('https://docs.google.com/spreadsheets/d/e/2PACX-1vQpKBPFCNC85Hlh3dvogaaOCtUCK1GTQ1LTtYIhpZj0mG7N_8VdrUMgoz10Yj3zCTfp8aO89V-J6och/pub?gid=1013904549&single=true&output=csv',
          'https://docs.google.com/spreadsheets/d/e/2PACX-1vRzcBfpP9-wRY5tHDW1KOwvRXDKPwCvnZXds1wP9vfyWO6AOHFccID6Xya-2H_0U6Q-Cy-IguHMHhzT/pub?gid=1857994474&single=true&output=csv')
c(covid_id_daily, covid_id_province) %<-% map(urls, read_csv)

#=========
# Cleaning
#=========

# Daily COVID-19 data
#--------------------

# Clean covid_id_daily by:
#
# - Selecting only the date, new cases, deaths, and recovered cases
# - Omitting the first row containing meta-data from the original spreadsheet
# - Renaming each feature to something more appropriate
# - Converting the 'date' column to type datetime
covid_id_daily %<>%
    select(Date, ends_with('day') & ! starts_with('treatment')) %>%
    slice(-1) %>%
    rename(date = Date,
           new = New_case_per_day,
           recovered = `Recovered-cases_perDay`,
           death = Death_cases_perDay) %>%
    mutate(date = ymd(date))

# Add the following features:
#
# - Current calendar week as ordered factor
# - Current calendar month as ordered factor
covid_id_daily %<>%
    mutate(week = paste('Week', date %>% isoweek()) %>% ordered(),
           month = month(date, label = T))

# Convert covid_id_daily to long format
covid_id_daily %<>%
    pivot_longer(cols = new:death, names_to = 'case', values_to = 'totals') %>%
    mutate(case = as.factor(case))

# Provincial COVID-19 data
#-------------------------

# Clean covid_id_province by:
#
# - Selecting on only the province name, confirmed cases, recovered cases, and
#   deaths
# - Renaming each feature to something more appropriate
covid_id_province %<>%
    select(Province_name, ends_with('cases')) %>%
    rename(province = Province_name,
           confirmed = Confirmed_cases,
           recovered = Recovered_cases,
           death = Death_cases)

# Add feature 'grand_total' which is just the sum of the case columns. This
# feature is simply used for the purposes of properly ordering provinces based
# on the total number of cases
covid_id_province %<>% mutate(grand_total = confirmed + recovered + death)

# Convert covid_id_province to long format
covid_id_province %<>%
    pivot_longer(cols = confirmed:death,
                 names_to = 'case',
                 values_to = 'totals') %>%
    mutate(case = as.factor(case))