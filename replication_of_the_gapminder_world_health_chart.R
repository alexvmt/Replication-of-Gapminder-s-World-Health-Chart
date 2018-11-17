### Replication of the Gapminder World Health Chart
# Inspiration: https://www.gapminder.org/whc/
# Data note: free data from Gapminder.org: gapm.io/ddatageov1 / CC BY-4: Creative Common Attribution Licence 4.0



# load libraries

library(openxlsx)
library(tidyr)
library(dplyr)
library(ggplot2)
library(ggrepel)
library(grid)



### load data

# load region and income level data
region.income_level.data.raw <- read.xlsx("Data Geographies - v1 - by Gapminder.xlsx", sheet=2, colNames=TRUE, detectDates=TRUE)

# load population data
population.data.raw <- read.xlsx("population_total.xlsx", sheet=1, colNames=TRUE)

# load life expectancy data
life_expectancy.data.raw <- read.xlsx("life_expectancy_years.xlsx", sheet=1, colNames=TRUE)

# load income data
income.data.raw <- read.xlsx("income_per_person_gdppercapita_ppp_inflation_adjusted.xlsx", sheet=1, colNames=TRUE)



### clean data

# region and income level
region.income_level <- region.income_level.data.raw %>%
  rename(country_code=geo, country_name=name, region=World.bank.region, income_level=World.bank.income.group.2017) %>% 
  select(country_code, country_name, region, income_level) 

# population
population <- population.data.raw %>% 
  gather("year", "population", 2:220) %>% 
  rename(country_name=country) %>% 
  select(country_name, year, population)

# life expectancy
life_expectancy <- life_expectancy.data.raw %>% 
  gather("year", "life_expectancy", 2:220) %>% 
  rename(country_name=country) %>% 
  select(country_name, year, life_expectancy)

# income
income <- income.data.raw %>%
  gather("year", "income", 2:220) %>% 
  rename(country_name=country) %>% 
  select(country_name, year, income)

# convert year from chr to int
population$year <- as.numeric(population$year)
life_expectancy$year <- as.numeric(life_expectancy$year)
income$year <- as.numeric(income$year)

# join data frames
j1 <- right_join(region.income_level, population, by="country_name")
j2 <- left_join(j1, life_expectancy, by=c("country_name", "year"))
data.cleaned.joined <- left_join(j2, income, by=c("country_name", "year"))

# remove objects that are not needed anymore
rm(region.income_level.data.raw, population.data.raw, life_expectancy.data.raw, income.data.raw, region.income_level, population, life_expectancy, income, j1, j2)

# check out summary statistics
summary(data.cleaned.joined)



### create world health chart for a certain year

# set year
Year <- 2018

# set up png file
png(file=paste0("world_health_chart_",Year,".png"), width=1400, height=1000)

# select data for certain year
world_health_chart_data <- data.cleaned.joined %>% 
  filter(year==Year)

# create chart
world_health_chart <- ggplot(world_health_chart_data,
                             aes(y=life_expectancy, 
                                 x=income, 
                                 color=region, 
                                 size=population)) +
  geom_point() +
  geom_text_repel(aes(label=country_name)) +
  scale_x_continuous(name="Income per person (GDP per capita, PPP$ inflation adjusted") +
  scale_y_continuous(name="Life expectancy (years)") +
  ggtitle(paste("World Health Chart", Year)) +
  labs(caption="Source: Gapminder.org (https://www.gapminder.org/whc/)")

world_health_chart

dev.off()



