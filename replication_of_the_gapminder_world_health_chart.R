# load libraries
library(openxlsx)
library(tidyr)
library(dplyr)
library(ggplot2)
library(ggrepel)
library(grid)



# load data for regions, life expectancy and income 
# Note: Free data from Gapminder.org: gapm.io/ddatageov1 / CC BY-4: Creative Common Attribution Licence 4.0
regions.data.raw <- read.xlsx("regions_data.xlsx", sheet = 2, colNames = TRUE, detectDates = TRUE)
population.data.raw <- read.xlsx("population_data.xlsx", sheet = 1, colNames = TRUE)
life.expectancy.data_raw <- read.xlsx("life_expectancy_data.xlsx", sheet = 2, colNames = TRUE)
income.data.raw <- read.xlsx("income_data.xlsx", sheet = 2, colNames = TRUE)



# prepare data
regions <- regions.data.raw %>%
  rename(country = name, region = four_regions) %>% 
  select(country, region) 



population.2018 <- population.data.raw %>% 
  gather("year", "population", 2:220) %>% 
  filter(year == 2018) %>% 
  rename(country = geo) %>% 
  select(country, population)



life.expectancy.2018 <- life.expectancy.data_raw %>% 
  gather("year", "life.expectancy", 5:305) %>% 
  filter(year == 2018) %>% 
  rename(country = geo.name) %>% 
  select(country, life.expectancy)

life.expectancy.2018$life.expectancy <- as.numeric(life.expectancy.2018$life.expectancy)
life.expectancy.2018$life.expectancy <- round(life.expectancy.2018$life.expectancy, 2)



income.2018 <- income.data.raw %>%
  gather("year", "income", 5:245) %>% 
  filter(year == 2018) %>% 
  rename(country = geo.name) %>% 
  select(country, income)

income.2018$income <- as.numeric(income.2018$income)



# join data frames
join1 <- left_join(regions, population.2018, by = "country")
join2 <- left_join(join1, life.expectancy.2018, by = "country")
world.health.chart.2018 <- left_join(join2, income.2018, by = "country")



# drop all rows that contain NAs
world.health.chart.2018 <- world.health.chart.2018[complete.cases(world.health.chart.2018), ]



# checkout summary statistics of the final dataframe
summary(world.health.chart.2018)



# create plot and write it to a png file
png(file = "world_health_chart_2018.png", width = 700, height = 500)

world.health.chart.2018.viz <- ggplot(world.health.chart.2018,
                                      aes(y = life.expectancy, 
                                          x = income, 
                                          color = region, 
                                          size = population)) +
                                      geom_point() +
                                      geom_text_repel(aes(label = country)) +
                                      scale_x_continuous(name = "Income per person (GDP/capita, PPP$ inflation-adjusted") +
                                      scale_y_continuous(name = "Life expectancy (years)") +
                                      ggtitle("World Health Chart 2018") +
                                      labs(caption = "Source: Gapminder.org (https://www.gapminder.org/whc/)")

world.health.chart.2018.viz

dev.off()


