# nolint start

# Function to filter data based on user inputs
filter_data_server <- function(input, data, session) {
  filtered_data <- reactive({
    data_filtered <- data # starting with the full dataset

    # Applying filtering conditions for each selected filter
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
      data_filtered <- data_filtered[grepl(input$life_stage, data_filtered$life_stages), ]
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
    
    # enchancing the search logic so it searches across multiple fields
    # Made search more dynamic: updated the search logic so it shows all data when the search string is empty AND no filters are applied
    # And reduced the code by removing redundant calls to grepl and using lapply 
    
    search_term <- tolower(input$search)
    
    if (search_term != "") {
        search_cols <- c("title", "species_common_name", "genus_latin", "species_latin", 
                        "stressor_name", "specific_stressor_metric", "life_stages", 
                        "activity", "geography")

        data_filtered <- data_filtered[
          Reduce(`|`, lapply(search_cols, function(col) grepl(search_term, tolower(data_filtered[[col]]), ignore.case = TRUE))), 
        ]
      }
    

    
    return(data_filtered)
  })
}

# nolint end