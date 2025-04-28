
library(shiny)
library(DBI)
library(RSQLite)

# we have server code here but will separate it later. 
upload_ui <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(column(12, h3("(Under Construction) Submit New Research Data", style = "text-align: center; color: #6082B6;"))),
    fluidRow(
      column(6, textInput(ns("title"), "Title *", placeholder = "Enter a short title (required)")),
      column(6, selectInput(ns("stressor_name"), "Stressor Name", c("", stressor_names)))
    ),
    fluidRow(
      column(6, selectInput(ns("specific_stressor_metric"), "Specific Stressor Metric", c("", stressor_metrics))),
      column(6, textInput(ns("stressor_units"), "Stressor Units", placeholder = "Enter units (e.g., °C, mg/L)"))
    ),
    fluidRow(
      column(6, selectInput(ns("species_common_name"), "Species Common Name", c("", species_names))),
      column(6, selectInput(ns("genus_latin"), "Genus Latin", c("", genus_latin)))
    ),
    fluidRow(
      column(6, selectInput(ns("species_latin"), "Species Latin", c("", species_latin))),
      column(6, selectInput(ns("geography"), "Geography", c("", geographies)))
    ),
    fluidRow(
      column(6, selectInput(ns("life_stage"), "Life Stage", c("", life_stages))),
      column(6, selectInput(ns("activity"), "Activity", c("", activities)))
    ),
    fluidRow(column(12, textAreaInput(ns("description_overview"), "Detailed SR Function Description", "", width = "100%", height = "100px"))),
    fluidRow(
      column(6, textAreaInput(ns("description_function_derivation"), "Function Derivation", "", width = "100%", height = "80px")),
      column(6, textAreaInput(ns("description_transferability_of_function"), "Transferability of Function", "", width = "100%", height = "80px"))
    ),
    # csv data 
    fluidRow(column(12, textAreaInput(ns("description_source_of_stressor_data1"), "Source of Stressor Data", "", width = "100%", height = "100px"))),
    fluidRow(
      column(12,
             wellPanel(
               style = "background-color: #ffeef0; border-color: #ffeef0;",
               tags$strong("Use the SR curve tracing tool", style = "color: #003366;"),
               br(), br(),
               downloadLink(ns("download_sample_csv"), "Download Sample CSV"),
               tags$br(), tags$br(),
               tags$strong("Stressor Response csv data"),
               fileInput(ns("sr_csv_file"), NULL,
                         accept = c(".csv"),
                         buttonLabel = "Choose File",
                         placeholder = "No file chosen"),
               helpText("Upload a CSV data file for the SR relationship. Columns (with headings) should include stressor, response, SD, low.limit, and up.limit.",
                        "One file only.", "2 MB limit.", "Allowed types: csv.")
             )
      )
    ),
    
    tabsetPanel(
      tabPanel("Response Details",
               textInput(ns("vital_rate"), "Vital Rate (Process)", placeholder = "Enter vital rate details"),
               textInput(ns("season"), "Season", placeholder = "Describe seasonal timing"),
               textInput(ns("activity_details"), "Activity", placeholder = "Describe activity (if applicable)")
      ),
      tabPanel("Stressor Details",
               textInput(ns("stressor_magnitude"), "Stressor Magnitude Data", placeholder = "Source of stressor magnitude data"),
               textInput(ns("poe_chain"), "PoE Chain", placeholder = "Describe PoE chain"),
               textInput(ns("key_covariates"), "Key Covariates & Dependencies", placeholder = "List key covariates")
      )
    ),
    tabsetPanel(
      tabPanel("Citations (as text)", textAreaInput(ns("citation_text"), "Citations (text)", "", width = "100%", height = "100px")),
      tabPanel("Citations (as links)",
               textInput(ns("citation_url"), "URL", placeholder = "Enter citation link"),
               textInput(ns("citation_link_text"), "Link text", placeholder = "Enter display text for the link"))
    ),
    fluidRow(
      column(4, wellPanel(strong("Revision information"), br(), "No revision")),
      column(8, textAreaInput(ns("revision_log"), "Revision log message", "", width = "100%", height = "100px"))
    ),
    fluidRow(
      column(6, actionButton(ns("save"), "Save SR Profile", style = "background-color: #6082B6; color: white;")),
      column(6, actionButton(ns("preview"), "Preview", style = "background-color: #6082B6; color: white;"))
    )
  )
}

# Server: currently writes only existing text fields into stressor_responses
upload_server <- function(id, db_path = "data/stressor_responses_test.sqlite") {
  moduleServer(id, function(input, output, session) {
    observeEvent(input$save, {
      req(input$title)
      con <- dbConnect(SQLite(), dbname = db_path)
      on.exit(dbDisconnect(con), add = TRUE)
      
      # Duplicate check
      exists_flag <- dbGetQuery(
        con,
        "SELECT EXISTS(SELECT 1 FROM stressor_responses WHERE title = ?) AS e;",
        params = list(input$title)
      )$e
      
      if (exists_flag) {
        showNotification("⚠️ That title already exists.", type = "warning")
        return()
      }
      
      # Insert mapping to DB schema 
      dbExecute(
        con,
        "INSERT INTO stressor_responses (
          id, title, stressor_name, stressor_units,
          specific_stressor_metric, species_common_name,
          species_latin, genus_latin, geography,
          activity, season, life_stages,
          citation_link, covariates_dependencies,
          description_overview, description_function_derivation,
          description_transferability_of_function, description_source_of_stressor_data1,
          citations_citation_text, citations_citation_links
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);",
        params = list(
          "2000",
          input$title,
          input$stressor_name,
          input$stressor_units,
          input$specific_stressor_metric,
          input$species_common_name,
          input$species_latin,
          input$genus_latin,
          input$geography,
          input$activity,
          input$season,
          input$life_stage,
          paste0(input$citation_link_text, " (", input$citation_url, ")"),
          input$key_covariates,
          input$description_overview,
          input$description_function_derivation,
          input$description_transferability_of_function,
          input$description_source_of_stressor_data1,
          input$citation_text,
          paste0(input$citation_link_text, " (", input$citation_url, ")")
        )
      )
      
      #showNotification("saved!", type = "message")
      showModal(modalDialog(
        title = "✅ Success!",
        paste("Your entry titled", input$title, "has been successfully saved to the database."),
        easyClose = TRUE,
        footer = modalButton("Close")
      ))
      
      updateTextInput(session, "title", value = "")
    })
    
    output$download_sample_csv <- downloadHandler(
      filename = function() {
        "demo_sr.csv"
      },
      content = function(file) {
        file.copy("data/demo_sr.csv", file)
      }
    )
    
    
    # Simple preview

    observeEvent(input$preview, {
      showModal(modalDialog(
        title = "Preview Submission",
        HTML(paste(
          "<b>Title:</b>", input$title, "<br>",
          "<b>Stressor Name:</b>", input$stressor_name, "<br>",
          "<b>Specific Stressor Metric:</b>", input$specific_stressor_metric, "<br>",
          "<b>Stressor Units:</b>", input$stressor_units, "<br>",
          "<b>Species Common Name:</b>", input$species_common_name, "<br>",
          "<b>Genus Latin:</b>", input$genus_latin, "<br>",
          "<b>Species Latin:</b>", input$species_latin, "<br>",
          "<b>Geography:</b>", input$geography, "<br>",
          "<b>Life Stage:</b>", input$life_stage, "<br>",
          "<b>Activity:</b>", input$activity, "<br>",
          "<b>Description Overview:</b>", input$description_overview, "<br>",
          "<b>Function Derivation:</b>", input$description_function_derivation, "<br>",
          "<b>Transferability of Function:</b>", input$description_transferability_of_function, "<br>",
          "<b>Source of Stressor Data:</b>", input$description_source_of_stressor_data1, "<br>",
          "<b>Vital Rate:</b>", input$vital_rate, "<br>",
          "<b>Season:</b>", input$season, "<br>",
          "<b>Activity Details:</b>", input$activity_details, "<br>",
          "<b>Stressor Magnitude Data:</b>", input$stressor_magnitude, "<br>",
          "<b>PoE Chain:</b>", input$poe_chain, "<br>",
          "<b>Key Covariates & Dependencies:</b>", input$key_covariates, "<br>",
          "<b>Citation Text:</b>", input$citation_text, "<br>",
          "<b>Citation URL:</b>", input$citation_url, "<br>",
          "<b>Citation Link Text:</b>", input$citation_link_text, "<br>",
          "<b>Revision Log:</b>", input$revision_log
        )),
        easyClose = TRUE,
        footer = modalButton("Close")
      ))
    })
  })
}
