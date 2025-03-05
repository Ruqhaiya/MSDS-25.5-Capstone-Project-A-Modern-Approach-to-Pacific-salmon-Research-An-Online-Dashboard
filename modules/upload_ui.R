
# nolint start
upload_ui <- function(id) {
  # Upload function UI elements

  ns <- NS(id)
  tagList(
    fluidRow(column(12, h3("(Under Construction)Submit New Research Data", style = "text-align: center; color: #6082B6;"))),
    
    fluidRow(
      column(6, textInput(ns("title"), "Title", placeholder = "Enter a short title")),
      column(6, selectInput(ns("stressor_name"), "Stressor Name", c("", stressor_names)))
    ),
    
    fluidRow(
      column(6, selectInput(ns("stressor_metric"), "Specific Stressor Metric", c("", stressor_metrics))),
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
    
    fluidRow(column(12, textAreaInput(ns("description"), "Detailed SR Function Description", "", width = "100%", height = "100px"))),
    
    fluidRow(
      column(6, textAreaInput(ns("function_derivation"), "Function Derivation", "", width = "100%", height = "80px")),
      column(6, textAreaInput(ns("transferability"), "Transferability of Function", "", width = "100%", height = "80px"))
    ),
    
    fluidRow(column(12, textAreaInput(ns("source"), "Source of Stressor Data", "", width = "100%", height = "100px"))),
    
    tabsetPanel(
      tabPanel("Response Details",
               textInput(ns("vital_rate"), "Vital Rate (Process)", placeholder = "Enter vital rate details"),
               textInput(ns("season"), "Season", placeholder = "Describe seasonal timing"),
               textInput(ns("activity_details"), "Activity", placeholder = "Describe activity (if applicable)")
      ),
      tabPanel("Stressor Details",
               textInput(ns("stressor_magnitude"), "Stressor Magnitude Data", placeholder = "Source of stressor magnitude data"),
               textInput(ns("poe_chain"), "PoE Chain", placeholder = "Describe PoE chain"),
               textInput(ns("key_covariates"), "Key Covariates and Dependencies", placeholder = "List key covariates")
      )
    ),
    
    tabsetPanel(
      tabPanel("Citations (as text)", 
               textAreaInput(ns("citation_text"), "Citation(s)", "", width = "100%", height = "100px")),
      tabPanel("Citations (as links)", 
               textInput(ns("citation_url"), "URL", placeholder = "Enter citation link"),
               textInput(ns("citation_link_text"), "Link text", placeholder = "Enter display text for the link")),
      tabPanel("Images", 
               fileInput(ns("citation_images"), "Upload Images", multiple = TRUE, accept = c("image/png", "image/jpg", "image/jpeg"))),
      tabPanel("Citations (upload file)", 
               fileInput(ns("citation_files"), "Upload Citation File", multiple = TRUE, accept = c(".txt", ".pdf", ".csv", ".xls", ".xlsx", ".doc", ".docx")))
    ),
    
    fluidRow(
      column(4, wellPanel(
        strong("Revision information"), br(),
        "No revision"
      )),
      column(8, textAreaInput(ns("revision_log"), "Revision log message", "", width = "100%", height = "100px"))
    ),
    
    fluidRow(
      column(6, actionButton(ns("save_sr_profile"), "Save SR Profile", style="background-color: #6082B6; color: white; font-size: 16px;")),
      column(6, actionButton(ns("preview"), "Preview", style="background-color: #6082B6; color: white; font-size: 16px;"))
    )
  )
}

# nolint end
