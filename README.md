# Replication of the Gapminder World Health Chart

In this project I replicate the Gapminder World Health Chart using Shiny and Google Charts. The original chart can be found on Gapminder.org and in the book "Factfulness" by Hans Rosling.

A live version of the Shiny app is available [here](https://alexandermerdiantarko.shinyapps.io/replication-of-the-gapminder-world-health-chart/).

Source of inspiration: https://www.gapminder.org/whc/

Data: https://www.gapminder.org/data/

Visualization inspired by: https://shiny.rstudio.com/gallery/google-charts.html

***Note***: Currently the app is only running properly locally if you copy *bindings.js* from the googleCharts library directory to the www directory in the shiny library directory. There appears to be some compatibility/integration issue with shinyapps.io at the moment (https://github.com/jcheng5/googleCharts/issues/12). 
