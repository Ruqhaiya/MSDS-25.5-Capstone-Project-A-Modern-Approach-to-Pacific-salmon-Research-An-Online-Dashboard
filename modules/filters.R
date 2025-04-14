# nolint start

filter_data_server <- function(input, data, session) {
  filtered_data <- reactive({
    data_filtered <- data  # Use full dataset
    
    # Ensure data types are correctly converted
    data_filtered$id <- as.integer(data_filtered$id)  
    data_filtered$stressor_name <- as.character(data_filtered$stressor_name)
    data_filtered$specific_stressor_metric <- as.character(data_filtered$specific_stressor_metric)
    data_filtered$species_common_name <- as.character(data_filtered$species_common_name)
    data_filtered$geography <- as.character(data_filtered$geography)
    data_filtered$activity <- as.character(data_filtered$activity)
    data_filtered$genus_latin <- as.character(data_filtered$genus_latin)
    data_filtered$species_latin <- as.character(data_filtered$species_latin)
    
    # Ensure life_stages is treated correctly (might be JSON-like)
    data_filtered$life_stages <- gsub('"', '', data_filtered$life_stages)  # Remove quotes if needed
    
    # Apply filtering logic
    if (input$stressor != "All") {
      data_filtered <- data_filtered[data_filtered$stressor_name == input$stressor, ]
    }
    if (input$stressor_metric != "All") {
      data_filtered <- data_filtered[data_filtered$specific_stressor_metric == input$stressor_metric, ]
    }
    if (input$species != "All") {
      data_filtered <- data_filtered[data_filtered$species_common_name == input$species, ]
    }
    if (input$geography != "All") {
      data_filtered <- data_filtered[data_filtered$geography == input$geography, ]
    }
    if (input$life_stage != "All") {
      data_filtered <- data_filtered[grepl(input$life_stage, data_filtered$life_stages, fixed = TRUE), ]
    }
    if (input$activity != "All") {
      data_filtered <- data_filtered[data_filtered$activity == input$activity, ]
    }
    if (input$genus_latin != "All") {
      data_filtered <- data_filtered[data_filtered$genus_latin == input$genus_latin, ]
    }
    if (input$species_latin != "All") {
      data_filtered <- data_filtered[data_filtered$species_latin == input$species_latin, ]
    }
    
    # Search functionality
    search_term <- tolower(input$search)
    if (search_term != "") {
      search_cols <- c("title", "species_common_name", "genus_latin", "species_latin", 
                       "stressor_name", "specific_stressor_metric", "life_stages", 
                       "activity", "geography")
      
      data_filtered <- data_filtered[
        Reduce(`|`, lapply(search_cols, function(col) grepl(search_term, tolower(data_filtered[[col]]), fixed = TRUE))), 
      ]
    }
    
    return(data_filtered)
  })
}

# nolint end