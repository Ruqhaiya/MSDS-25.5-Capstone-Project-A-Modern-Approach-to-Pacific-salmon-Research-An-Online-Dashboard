#nolint start
update_filters_server <- function(input, session, filtered_data) {
  # reactive filtering by removing unnecessary filter options when searched or filtered
  observe({
    data_filtered <- filtered_data()
    
    updateSelectInput(session, "stressor", 
                      choices = c("All", unique(data_filtered$stressor_name)), 
                      selected = if (input$stressor %in% data_filtered$stressor_name) input$stressor else "All")
    
    updateSelectInput(session, "stressor_metric", 
                      choices = c("All", unique(data_filtered$specific_stressor_metric)), 
                      selected = if (input$stressor_metric %in% data_filtered$specific_stressor_metric) input$stressor_metric else "All")
    
    updateSelectInput(session, "species", 
                      choices = c("All", unique(data_filtered$species_common_name)), 
                      selected = if (input$species %in% data_filtered$species_common_name) input$species else "All")
    
    updateSelectInput(session, "geography", 
                      choices = c("All", unique(data_filtered$geography)), 
                      selected = if (input$geography %in% data_filtered$geography) input$geography else "All")
    
    updateSelectInput(session, "life_stage", 
                      choices = c("All", unique(data_filtered$life_stages)), 
                      selected = if (input$life_stage %in% data_filtered$life_stages) input$life_stage else "All")
    
    updateSelectInput(session, "activity", 
                      choices = c("All", unique(data_filtered$activity)), 
                      selected = if (input$activity %in% data_filtered$activity) input$activity else "All")
    
    updateSelectInput(session, "genus_latin", 
                      choices = c("All", unique(data_filtered$genus_latin)), 
                      selected = if (input$genus_latin %in% data_filtered$genus_latin) input$genus_latin else "All")
    
    updateSelectInput(session, "species_latin", 
                      choices = c("All", unique(data_filtered$species_latin)), 
                      selected = if (input$species_latin %in% data_filtered$species_latin) input$species_latin else "All")
  })
}

#nolint end