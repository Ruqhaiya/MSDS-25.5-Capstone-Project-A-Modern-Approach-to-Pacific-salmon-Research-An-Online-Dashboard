# nolint start
library(shinyjs)
library(shiny)
library(shinyWidgets)

# Source all necessary modules
source("modules/upload.R", local = TRUE)
source("modules/manage_categories.R", local = TRUE)
source("modules/about_us.R", local = TRUE)
source("modules/acknowledgement.R", local = TRUE)
source("modules/eda.R", local = TRUE)


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
          includeCSS("www/custom.css")
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

  tabPanel("Analyze Data", edaUI("eda")),
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
          column(12,
                div(style = "text-align: center; margin-bottom: 10px;",
                    actionButton("prev_page", "<< Previous", class = "btn btn-sm"),
                    span(textOutput("page_info", inline = TRUE), style = "margin: 0 10px; font-size: 13px;"),
                    actionButton("next_page", "Next >>", class = "btn btn-sm")
                )
          )
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