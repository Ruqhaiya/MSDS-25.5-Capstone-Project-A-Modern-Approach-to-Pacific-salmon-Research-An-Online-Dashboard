# nolint start
library(shinyjs)
library(shiny)
library(shinyWidgets)

# Source all necessary modules
source("modules/upload.R", local = TRUE)
source("modules/manage_categories.R", local = TRUE)
source("modules/about_us.R", local = TRUE)
source("modules/acknowledgement.R", local = TRUE)

# Static resource for team images
addResourcePath("teamimg", "modules/images")

# UI
ui <- navbarPage(
  id = "main_navbar",
  title = "NOAA",
  selected = "dashboard",
  
  # Welcome Tab
  tabPanel(
    title = "Welcome",
    value = "NOAA info",
    fluidPage(
      useShinyjs(),
      tags$head(
        tags$style(HTML("
    body {
      background-color: #FFFFFF!important;
      color: #1c1c1c;
      font-family: 'Segoe UI', 'Arial', sans-serif;
    }

    h1 {
      color: #0077b6;
      font-size: 32px;
      font-weight: bold;
    }

    h2 {
      color: #0077b6;
      font-size: 26px;
      font-weight: bold;
    }

    h3 {
      color: #0077b6;
      font-size: 22px;
      font-weight: bold;
    }

    label, .control-label, .shiny-input-container {
      color: #1c1c1c;
      font-size: 15px;
      font-family: 'Segoe UI', 'Arial', sans-serif;
    }

    .navbar-default {
      background-color: #ffffff;
      border-bottom: 3px solid #90e0ef;
    }

    .navbar-default .navbar-nav > li > a,
    .navbar-default .navbar-brand {
      color: #0077b6 !important;
    }

    .btn-primary, .btn-success {
      background-color: #00b4d8;
      border-color: #00b4d8;
      color: #ffffff;
    }

    .btn-primary:hover, .btn-success:hover {
      background-color: #0096c7;
    }

    .well, .panel {
      background-color: #ffffff;
      border-left: 4px solid #90e0ef;
      box-shadow: 0 1px 3px rgba(0,0,0,0.05);
    }

    .selectize-input {
      background-color: #ffffff !important;
      border: 1px solid #90e0ef !important;
    }

    .form-control:focus {
      border-color: #00b4d8;
      box-shadow: 0 0 5px rgba(0,180,216,0.5);
    }

    .checkbox label, .radio label {
      font-weight: 500;
      font-size: 15px;
    }

    .dropdown-menu {
      background-color: #f0fdff;
    }

    .dropdown-menu > li > a:hover {
      background-color: #90e0ef;
      color: #03045e;
    }

    #main_navbar {
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }

    .hover-highlight {
      background-color: #ffffff;
      border: 2px solid transparent;
      transition: background-color 0.2s ease, border-color 0.2s ease;
      font-family: 'Segoe UI', 'Arial', sans-serif;
    }

    .hover-highlight:hover {
      background-color: #DCEEFF;
      border-color: #4682b4;
      cursor: pointer;
    }

    *:focus {
      outline: 2px dashed #0077b6;
      outline-offset: 3px;
    }
  "))
      ),
      
      
      h1("Welcome to NOAA Dashboard"),
      tags$div(
        h2("About Us"),
        about_us("about_us")
      ),
      tags$hr(),
      tags$div(
        acknowledgement_ui("acknowledgement", n = 20)
      )
    )
  ),
  
  # Dashboard Tab
  tabPanel(
    title = "SRF Dashboard",
    value = "dashboard",
    fluidPage(
      useShinyjs(),
      
      conditionalPanel(
        condition = "!window.location.search.includes('main_id')",
        fluidRow(
          column(8, textInput("search", "Search All Text", placeholder = "Type keywords...")),
          column(4, actionButton("toggle_filters", "Show Filters", icon = icon("filter")))
        ),
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
                                  options = list('actions-box' = TRUE, 'live-search' = TRUE))),
            column(3, pickerInput("stressor_metric", "Stressor Metric", choices = list(), multiple = TRUE,
                                  options = list('actions-box' = TRUE, 'live-search' = TRUE))),
            column(3, pickerInput("species", "Species Common Name", choices = list(), multiple = TRUE,
                                  options = list('actions-box' = TRUE, 'live-search' = TRUE))),
            column(3, pickerInput("geography", "Geography (Region)", choices = list(), multiple = TRUE,
                                  options = list('actions-box' = TRUE, 'live-search' = TRUE)))
          ),
          fluidRow(
            column(3, pickerInput("life_stage", "Life Stage", choices = life_stages, multiple = TRUE,
                                  options = list('actions-box' = TRUE, 'live-search' = TRUE))),
            column(3, pickerInput("activity", "Activity", choices = list(), multiple = TRUE,
                                  options = list('actions-box' = TRUE, 'live-search' = TRUE))),
            column(3, pickerInput("genus_latin", "Genus Latin", choices = list(), multiple = TRUE,
                                  options = list('actions-box' = TRUE, 'live-search' = TRUE))),
            column(3, pickerInput("species_latin", "Species Latin", choices = list(), multiple = TRUE,
                                  options = list('actions-box' = TRUE, 'live-search' = TRUE)))
          ),
          fluidRow(
            column(3, pickerInput("research_article_type", "Research Article Type", choices = list(), multiple = TRUE,
                                  options = list('actions-box' = TRUE, 'live-search' = TRUE))),
            column(3, pickerInput("location_country", "Country", choices = list(), multiple = TRUE,
                                  options = list('actions-box' = TRUE, 'live-search' = TRUE))),
            column(3, pickerInput("location_state_province", "State / Province", choices = list(), multiple = TRUE,
                                  options = list('actions-box' = TRUE, 'live-search' = TRUE))),
            column(3, pickerInput("location_watershed_lab", "Watershed / Lab", choices = list(), multiple = TRUE,
                                  options = list('actions-box' = TRUE, 'live-search' = TRUE)))
          ),
          fluidRow(
            column(3, pickerInput("location_river_creek", "River / Creek", choices = list(), multiple = TRUE,
                                  options = list('actions-box' = TRUE, 'live-search' = TRUE))),
            column(3, pickerInput("broad_stressor_name", "Broad Stressor Name", choices = list(), multiple = TRUE,
                                  options = list('actions-box' = TRUE, 'live-search' = TRUE)))
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
          column(12,
                 div(
                   style = "display: flex; gap: 15px; flex-wrap: wrap; align-items: center; margin-bottom: 15px;",
                   dropdownButton(
                     circle = FALSE,
                     status = "primary",
                     label = "Download All",
                     icon = icon("download"),
                     tooltip = tooltipOptions(title = "Choose format"),
                     actionButton("trigger_json_all", "Download JSON", class = "btn-link"),
                     actionButton("trigger_csv_all", "Download CSV", class = "btn-link")
                   ),
                   dropdownButton(
                     circle = FALSE,
                     status = "success",
                     label = "Download Selected",
                     icon = icon("download"),
                     tooltip = tooltipOptions(title = "Choose format"),
                     actionButton("trigger_json_selected", "Download JSON", class = "btn-link"),
                     actionButton("trigger_csv_selected", "Download CSV", class = "btn-link")
                   ),
                   checkboxInput("select_all", "Select All", value = FALSE)
                 )
          )
        ),
        fluidRow(
          column(6, offset = 3, uiOutput("paper_cards"))
        )
      ),
      
      conditionalPanel(
        condition = "window.location.search.includes('main_id')",
        fluidRow(
          column(8, offset = 2, uiOutput("article_content"))
        )
      )
    )
  ),
  
  # Upload Tab
  tabPanel(
    title = "Upload Data",
    value = "upload_data",
    upload_ui("upload")
  ),
  
  # Admin Tab
  tabPanel(
    title = "Admin",
    value = "manage_categories",
    uiOutput("categories_auth_ui")
  )
)
# nolint end