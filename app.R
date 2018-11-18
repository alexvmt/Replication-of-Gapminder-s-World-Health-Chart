### Gapminder World Health Chart with Shiny and Google Charts
# Inspired by: https://www.gapminder.org/whc/ and https://shiny.rstudio.com/gallery/google-charts.html



### set up

# load libraries
library(readr)
library(dplyr)
library(shiny)
library(googleCharts)

# load data
data <- suppressWarnings(read_csv("gapminder_world_health_chart_data_processed.csv"))

# set limits for x and y axis based on global min and max values of income and life_expectancy so that the size of the chart remains constant
xlim <- list(
  min = min(data$income) - 500,
  max = max(data$income) + 500
  )

ylim <- list(
  min = min(data$life_expectancy),
  max = max(data$life_expectancy) + 3
  )



### ui
ui <- fluidPage(
  
  # initiate Google Charts and set font and style
  googleChartsInit(),
  
  tags$link(
    href = paste0("http://fonts.googleapis.com/css?",
                "family=Source+Sans+Pro:300,600,300italic"),
    rel = "stylesheet", type = "text/css"),
  
  tags$style(type = "text/css",
             "body {font-family: 'Source Sans Pro'}"
             ),
  
  # set page title
  titlePanel("Replication of the Gapminder World Health Chart"),
  
  fluidRow(
    column(
      googleBubbleChart("chart",
                        width="100%", height = "475px",
                        options = list(
                          fontName = "Source Sans Pro",
                          fontSize = 13,
                          # set axis labels and ranges
                          hAxis = list(
                            title = "Income per person (GDP per capita, PPP$ inflation adjusted)",
                            viewWindow = xlim
                            ),
                          vAxis = list(
                            title = "Life expectancy (years)",
                            viewWindow = ylim
                            ),
                          # the default padding is a little too spaced out
                          chartArea = list(
                            top = 50, left = 75,
                            height = "75%", width = "75%"
                            ),
                          # allow pan/zoom
                          explorer = list(),
                          # set bubble visual props
                          bubble = list(
                            opacity = 0.4, stroke = "none",
                            # hide bubble label
                            textStyle = list(
                              color = "none"
                              )
                            ),
                          # set fonts
                          titleTextStyle = list(
                            fontSize = 16
                            ),
                          tooltip = list(
                            textStyle = list(
                              fontSize = 12
                              )
                            )
                          )
                        )
      )
    ),
  
  fluidRow(align = "center",
    # set up slider for year input
    column(
      sliderInput("year", h3("Select year or click play"),
                  min = 1800,
                       max = 2018,
                       value = 1900,
                       animate = TRUE)
           )
    )
  
  
  
  )



### server
server <- function(input, output) {

    defaultColors <- c("#3366cc", "#dc3912", "#ff9900", "#109618", "#990099", "#0099c6", "#dd4477")
    
    series <- structure(
      lapply(defaultColors, function(color) { list(color=color) }),
      names = levels(as.factor(data$region))
    )
    
    yearData <- reactive({
      data %>%
      filter(year==input$year) %>% 
      select(country_name, income, life_expectancy, region, population) %>% 
      arrange(region)
      })
    
    output$chart <- reactive({
      
      list(
        data = googleDataTable(yearData()),
        options = list(
          title = sprintf("Replication of the Gapminder World Health Chart, %s", input$year),
          series = series
          )
      )
      
    })
  
}



shinyApp(ui = ui, server  = server)