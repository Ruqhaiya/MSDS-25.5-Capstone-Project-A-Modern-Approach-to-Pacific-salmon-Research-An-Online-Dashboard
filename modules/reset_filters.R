#nolint start
reset_filters_server <- function(input, session) {
  observeEvent(input$reset_filters, {
    updateTextInput(session, "search", value = "") 
    
    updateSelectInput(session, "stressor", selected = "All")
    updateSelectInput(session, "stressor_metric", selected = "All")
    updateSelectInput(session, "species", selected = "All")
    updateSelectInput(session, "geography", selected = "All")
    updateSelectInput(session, "life_stage", selected = "All")
    updateSelectInput(session, "activity", selected = "All")
    updateSelectInput(session, "genus_latin", selected = "All")
    updateSelectInput(session, "species_latin", selected = "All")
  })
}

#nolint end