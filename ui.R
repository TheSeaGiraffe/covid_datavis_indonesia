#
# COVID-19 Dashboard - Indonesia: UI
#

library(shiny)

# UI setup for COVID-19 Dashboard
shinyUI(navbarPage("COVID-19 Dashboard - Indonesia",

    # Line graph showing daily, weekly, and monthly totals
    tabPanel("Total Cases",
             fluidRow(
                 column(12,
                        h1("Daily, Weekly, and Monthly Totals"))),
             hr(),
             fluidRow(
                 sidebarPanel(
                     h4("Select granularity and type of case to display"),
                     radioButtons("granularity", "Granularity:",
                                  c("Daily" = "date",
                                    "Weekly" = "week",
                                    "Monthly" = "month")),
                     radioButtons("case", "Type of case:",
                                  c("All" = "all",
                                    "New" = "new",
                                    "Recovered" = "recovered",
                                    "Death" = "death")),
                     submitButton("Create Plot")),
                 mainPanel(plotlyOutput("line_totals")))
             ),
    
    # Histogram showing totals in each province
    tabPanel("Totals per province")
                
))