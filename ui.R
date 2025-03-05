# nolint start

source("modules/upload_ui.R", local = TRUE)
library(shinyjs)
library(shiny)  

ui <- navbarPage(
  id = "main_navbar",
  title = "NOAA",
  selected = "dashboard",  #Dashboard is selected by default

  # Dashboard Tab
  tabPanel(
    title = "SRF Dashboard",
    value = "dashboard",  # correct tab navigation

    fluidPage(
      useShinyjs(),

      # Ensure the dashboard content is only visible when no article is selected
      conditionalPanel(
        condition = "!window.location.search.includes('article_id')",
        
        fluidRow(
          column(8, textInput("search", "Search All Text", placeholder = "Type keywords...")),
          column(4, actionButton("toggle_filters", "Show Filters", icon = icon("filter")))
        ),

        conditionalPanel(
          condition = "input.toggle_filters % 2 == 1",
          fluidRow(
            column(3, selectInput("stressor", "Stressor Name", c("All", stressor_names))),
            column(3, selectInput("stressor_metric", "Stressor Metric", c("All", stressor_metrics))),
            column(3, selectInput("species", "Species Common Name", c("All", species_names))),
            column(3, selectInput("geography", "Geography (Region)", c("All", geographies)))
          ),
          fluidRow(
            column(3, selectInput("life_stage", "Life Stage", c("All", life_stages))),
            column(3, selectInput("activity", "Activity", c("All", activities))),
            column(3, selectInput("genus_latin", "Genus Latin", c("All", genus_latin))),
            column(3, selectInput("species_latin", "Species Latin", c("All", species_latin)))
          ),
          fluidRow(
            column(12, div(style = "text-align: right;",
                           actionLink("reset_filters", "Reset Filters", 
                                      style = "color: #0073e6; font-size: 14px; text-decoration: none; margin-right: 10px;")))
          )
        ),

        fluidRow(
          column(4, offset = 4, 
                 actionButton("prev_page", "<< Previous"), 
                 textOutput("page_info", inline = TRUE), 
                 actionButton("next_page", "Next >>"))
        ),

        fluidRow(
          column(6, offset = 3, uiOutput("paper_cards"))
        )
      ),

      # Article Display Section (Shows only when an article is selected)
      conditionalPanel(
        condition = "window.location.search.includes('article_id')",
        

        fluidRow(
          column(8, offset = 2, uiOutput("article_content"))
        )
      )
    )
  ),

  # Upload Data Tab
  tabPanel(
    title = "Upload Data",
    value = "upload_data",
    upload_ui("upload_ui")
  )
)

# nolint end
