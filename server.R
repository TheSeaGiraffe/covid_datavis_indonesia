#
# Find out more about building applications with Shiny here:
#

# Import necessary libraries
library(shiny)
library(tidyverse)
library(magrittr)
library(plotly)

# Call script to load and clean data
suppressWarnings(source("helper_scripts/load_and_clean_data.R"))

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    # Create line plot of totals
    output$line_totals <- renderPlotly({
        # Create tmp dataframe to hold processed covid_id_daily dataframe
        tmp <- covid_id_daily
        
        # Set some flags
        color <- T
        group <- F
        
        # Get radio button inputs
        gran <- input$granularity
        case_type <- input$case
        
        # Handle granularity
        if (gran != "day") {
            group <- T
            tmp %<>% group_by(!!sym(gran), case) %>%
                summarize(totals = sum(totals, na.rm = T))
        }
        
        # Handle case type
        if (case_type != 'all') {
            color <- F
            tmp %<>% filter(case == input$case)
        }
        
        # Create the plot
        if (group & color) {
            plt <- tmp %>% ggplot(aes(!!sym(gran), totals, color = case,
                                      group = case))
        } else if (!group & color) {
            plt <- tmp %>% ggplot(aes(!!sym(gran), totals, color = case))
        } else {
            plt <- tmp %>% ggplot(aes(!!sym(gran), totals, group = case))
        }
        
        # Add labels and make more tidy
        plt <- plt + geom_line()
        ggplotly(plt)
    })

})
