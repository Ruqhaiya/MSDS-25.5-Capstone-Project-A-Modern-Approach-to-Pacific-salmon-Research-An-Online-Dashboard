# nolint start

library(shinyjs)
library(shiny)
library(shinyWidgets)

ui <- navbarPage(
  id = "main_navbar",
  title = "NOAA",
  selected = "dashboard",
  
  # Dashboard Tab
  tabPanel(
    title = "SRF Dashboard",
    value = "dashboard",
    
    fluidPage(
      useShinyjs(),
      
      # Dashboard visible only when no article is selected
      conditionalPanel(
        condition = "!window.location.search.includes('article_id')",
        
        fluidRow(
          column(8, textInput("search", "Search All Text", placeholder = "Type keywords...")),
          column(4, actionButton("toggle_filters", "Show Filters", icon = icon("filter")))
        ),
        
        # Hidden numeric inputs
        shinyjs::hidden(
          fluidRow(
            column(6, numericInput("page", NULL, value = 1, min = 1)),
            column(6, numericInput("page_size", NULL, value = 10, min = 1))
          )
        ),
        
        conditionalPanel(
          condition = "input.toggle_filters % 2 == 1",
          
          fluidRow(
            column(3, pickerInput("stressor", "Stressor Name", choices = list(), multiple = TRUE,
                                  options = list(`actions-box` = TRUE, `live-search` = TRUE))),
            column(3, pickerInput("stressor_metric", "Stressor Metric", choices = list(), multiple = TRUE,
                                  options = list(`actions-box` = TRUE, `live-search` = TRUE))),
            column(3, pickerInput("species", "Species Common Name", choices = list(), multiple = TRUE,
                                  options = list(`actions-box` = TRUE, `live-search` = TRUE))),
            column(3, pickerInput("geography", "Geography (Region)", choices = list(), multiple = TRUE,
                                  options = list(`actions-box` = TRUE, `live-search` = TRUE)))
          ),
          
          fluidRow(
            column(3, pickerInput("life_stage", "Life Stage", choices = life_stages, multiple = TRUE,
                                  options = list(`actions-box` = TRUE, `live-search` = TRUE))),
            column(3, pickerInput("activity", "Activity", choices = list(), multiple = TRUE,
                                  options = list(`actions-box` = TRUE, `live-search` = TRUE))),
            column(3, pickerInput("genus_latin", "Genus Latin", choices = list(), multiple = TRUE,
                                  options = list(`actions-box` = TRUE, `live-search` = TRUE))),
            column(3, pickerInput("species_latin", "Species Latin", choices = list(), multiple = TRUE,
                                  options = list(`actions-box` = TRUE, `live-search` = TRUE)))
          ),
          
          fluidRow(
            column(12, div(style = "text-align: right;",
                           actionLink("reset_filters", "Reset Filters",
                                      style = "color: #0073e6; font-size: 14px; text-decoration: none; margin-right: 10px;")))
          )
        ),
        
        # Pagination
        fluidRow(
          column(4, offset = 4,
                 actionButton("prev_page", "<< Previous"),
                 textOutput("page_info", inline = TRUE),
                 actionButton("next_page", "Next >>"))
        ),
        
        # Select All & Download Row
        fluidRow(
          column(12,
                 div(
                   style = "display: flex; gap: 15px; flex-wrap: wrap; align-items: center; margin-bottom: 15px;",
                   
                   # Download All
                   dropdownButton(
                     circle = FALSE,
                     status = "primary",
                     label = "Download All",
                     icon = icon("download"),
                     tooltip = tooltipOptions(title = "Choose format"),
                     actionButton("trigger_json_all", "Download JSON", class = "btn-link"),
                     actionButton("trigger_csv_all", "Download CSV", class = "btn-link")
                   ),
                   
                   # Download Selected
                   dropdownButton(
                     circle = FALSE,
                     status = "success",
                     label = "Download Selected",
                     icon = icon("download"),
                     tooltip = tooltipOptions(title = "Choose format"),
                     actionButton("trigger_json_selected", "Download JSON", class = "btn-link"),
                     actionButton("trigger_csv_selected", "Download CSV", class = "btn-link")
                   ),
                   
                   # Select All Checkbox
                   checkboxInput("select_all", "Select All", value = FALSE)
                 )
          )
        ),
        
        # Paper Cards
        fluidRow(
          column(6, offset = 3, uiOutput("paper_cards"))
        )
      ),
      
      # Article View
      conditionalPanel(
        condition = "window.location.search.includes('article_id')",
        fluidRow(
          column(8, offset = 2, uiOutput("article_content"))
        )
      )
    )
  )
)

# nolint end
