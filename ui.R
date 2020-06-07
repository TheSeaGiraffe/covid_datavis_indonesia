#
# COVID-19 Dashboard - Indonesia: UI
#

library(shiny)
library(plotly)

# UI setup for COVID-19 Dashboard
shinyUI(navbarPage("COVID-19 Dashboard - Indonesia",

    # Line graph showing daily, weekly, and monthly totals
    tabPanel("Total Cases",
             fluidRow(
                 column(12,
                        h1("Daily, Weekly, and Monthly Totals"))),
             hr(),
             fluidRow(
                 sidebarPanel(width = 3,
                     h4("Select granularity and type of case to display"),
                     radioButtons("granularity", "Granularity:",
                                  c("Daily" = "date",
                                    "Weekly" = "week",
                                    "Monthly" = "month")),
                     radioButtons("case", "Case type:",
                                  c("All" = "all",
                                    "New" = "New",
                                    "Recovered" = "Recovered",
                                    "Death" = "Death"))),
                     #submitButton("Create Plot")),
                 mainPanel(plotlyOutput("line_totals", height ="600px")))
             ),
    
    # Histogram showing totals in each province
    tabPanel("Totals per province",
             fluidRow(
                 column(12,
                        h1("Totals per Province"))),
             hr(),
             fluidRow(
                 sidebarPanel(width = 3,
                     h4("Select type of case to display"),
                     radioButtons("case_prov", "Case type:",
                                  c("All" = "all",
                                    "Confirmed" = "Confirmed",
                                    "Recovered" = "Recovered",
                                    "Death" = "Death"))),
                 mainPanel(plotlyOutput("hist_totals", height = "750px")))
             )
                
))