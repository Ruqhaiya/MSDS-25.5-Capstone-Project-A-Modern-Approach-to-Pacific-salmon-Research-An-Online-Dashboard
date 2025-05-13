library(shiny)
library(DBI)
library(shinyWidgets)

#------------------------------------------------------------------
# UI function for Manage Categories module
#------------------------------------------------------------------
manageCategoriesUI <- function(id) {
  ns <- NS(id)
  
  # Shared lookup of human labels -> table names
  cat_choices <- list(
    "Stressor Name"        = "stressor_names",
    "Stressor Metric"      = "stressor_metrics",
    "Species Common Name"  = "species_common_names",
    "Geography"            = "geographies",
    "Life Stage"           = "life_stages",
    "Activity"             = "activities",
    "Genus Latin"          = "genus_latins",
    "Species Latin"        = "species_latins"
  )
  
  tagList(
    fluidRow(
      # Add panel
      column(6,
             wellPanel(
               h4("Add Category"),
               selectInput(ns("new_cat_type"), "Category Type", choices = cat_choices),
               textInput(  ns("new_cat_name"), "Category Name"),
               actionButton(ns("add_cat"), "Add Category", class = "btn-primary")
             )
      ),
      
      # Delete panel
      column(6,
             wellPanel(
               h4("Delete Category"),
               selectInput(ns("del_cat_type"), "Category Type", choices = cat_choices),
               pickerInput(ns("del_cat_items"), "Select to Remove",
                           choices = NULL, multiple = TRUE,
                           options = list(`actions-box` = TRUE, `live-search` = TRUE)
               ),
               actionButton(ns("del_cat_btn"), "Delete Selected", class = "btn-danger")
             )
      )
    )
  )
}

#------------------------------------------------------------------
# Server function for Manage Categories module
#------------------------------------------------------------------
manageCategoriesServer <- function(id, db) {
  moduleServer(id, function(input, output, session) {
    
    # 1) When the delete-type changes, fetch its names into the picker
    observeEvent(input$del_cat_type, {
      tbl <- input$del_cat_type
      names <- dbGetQuery(db,
                          sprintf("SELECT name FROM %s ORDER BY name", tbl)
      )$name
      updatePickerInput(session, "del_cat_items", choices = names, selected = NULL)
    }, ignoreInit = TRUE)
    
    # 2) Add new category
    observeEvent(input$add_cat, {
      req(input$new_cat_name)
      tbl  <- input$new_cat_type
      name <- trimws(input$new_cat_name)
      tryCatch({
        dbExecute(db,
                  sprintf("INSERT OR IGNORE INTO %s(name) VALUES (?)", tbl),
                  params = list(name)
        )
        showNotification(sprintf("✅ Added \"%s\"", name), type = "message")
        updateTextInput(session, "new_cat_name", value = "")
      }, error = function(e) {
        showNotification(e$message, type = "error")
      })
    })
    
    # 3) Delete selected categories
    observeEvent(input$del_cat_btn, {
      req(input$del_cat_items, input$del_cat_type)
      tbl <- input$del_cat_type
      to_delete <- input$del_cat_items
      placeholders <- paste(rep("?", length(to_delete)), collapse = ",")
      sql <- sprintf("DELETE FROM %s WHERE name IN (%s)", tbl, placeholders)
      tryCatch({
        dbExecute(db, sql, params = as.list(to_delete))
        showNotification(sprintf("🗑 Deleted %d entries from %s",
                                 length(to_delete), tbl),
                         type = "warning")
        # Refresh the picker
        updatePickerInput(session, "del_cat_items", choices = character(0))
      }, error = function(e) {
        showNotification(e$message, type = "error")
      })
    })
  })
}
