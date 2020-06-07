#
# COVID-19 Dashboard - Indonesia: Server
#

# Import necessary libraries
library(shiny)
library(tidyverse)
library(magrittr)
library(plotly)

# Call script to load and clean data
suppressWarnings(source("helper_scripts/load_and_clean_data.R"))

# Define server logic required to create plots
shinyServer(function(input, output) {

    # Create line plot of totals
    output$line_totals <- renderPlotly({
        # Create tmp dataframe to hold processed covid_id_daily dataframe
        tmp <- covid_id_daily
        
        # Set some flags for determining how the plots are shown
        color <- T # Will there be multiple lines that need to be colored?
        group <- F # Has the data been summarized after being grouped?
        
        # Get radio button inputs
        gran <- input$granularity
        case_type <- input$case
        
        # In handling both the granularity and plotting, make use of quosures
        # (or symbols in this case) in order to play nice with tidyverse
        # functions

        # Handle granularity
        if (gran != "day") {
            group <- T
            tmp %<>% group_by(!!sym(gran), case) %>%
                summarize(totals = sum(totals, na.rm = T))
        }
        
        # Handle case type
        if (case_type != 'all') {
            color <- F
            tmp %<>% filter(case == case_type)
        }
        
        # Get plot title
        title_gran <- case_when(
            gran == "date" ~ "Daily",
            TRUE ~ paste0(str_to_title(gran), 'ly')
        )
        
        plt_title <- paste("Total", title_gran,
                           "COVID-19 Cases in Indonesia:",
                           case_type,
                           "Cases")
        
        # Get x-axis label
        x_lab <- case_when(
            gran == "week" ~ "Calendar week",
            TRUE ~ str_to_title(gran)
        )
        
        # Create the plot
        if (group) {
            if (color) {
                plt <- tmp %>% ggplot(aes(!!sym(gran), totals, group = case,
                                          color = case))
            } else {
                plt <- tmp %>% ggplot(aes(!!sym(gran), totals, group = case))
            }
        } else {
            plt <- tmp %>% ggplot(aes(!!sym(gran), totals, color = case))
        }
        
        # Add labels and make more tidy
        plt <- plt + geom_line() + geom_point() + theme_bw()
        
        if (color) {
            plt <- plt + labs(title = plt_title, x = x_lab,
                              y = "Total no. of cases",
                              color = "Case type")
        } else {
            plt <- plt + labs(title = plt_title, x = x_lab,
                              y = "Total no. of cases")
        }
        
        plt <- plt + theme(plot.title = element_text(hjust = 0.5))
        ggplotly(plt)
    })
    
    # Create histogram of totals per province
    output$hist_totals <- renderPlotly({
        # Create tmp dataframe to hold processed covid_id_province dataframe
        tmp <- covid_id_province
        
        # Set flag
        case_all <- T
        
        # Handle case type
        case_type <- input$case_prov
        if (case_type != "all") {
            case_all <- F
            tmp %<>% filter(case == case_type)
        }
        
        # Get plot title
        plt_title <- paste("COVID-19 Cases Per Province:", case_type, "Cases")
        
        # Create plot
        if (case_all) {
            plt <- tmp %>%
                ggplot(aes(totals, fct_reorder(province, grand_total),
                           fill = case)) +
                labs(title = plt_title, x = "Total no. of cases",
                     y = "Province", fill = "Case type")
        } else {
            plt <- tmp %>%
                ggplot(aes(totals, fct_reorder(province, totals))) +
                labs(title = plt_title, x = "Total no. of cases",
                     y = "Province")
        }
        
        # Tidy up plot
        plt <- plt + geom_col() + theme_bw() +
            theme(plot.title = element_text(hjust = 0.5))
        ggplotly(plt)
    })

})
