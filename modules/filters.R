# nolint start

# nolint start

# Function to filter data based on user inputs
filter_data_server <- function(input, data, session) {
  filtered_data <- reactive({
    
    # Ensure data is loaded and has rows before filtering
    req(!is.null(data), nrow(data) > 0)
    
    data_filtered <- data # starting with the full dataset
    
    # Applying filtering conditions for each selected filter
    
    # Filter: stressor name
    if (!is.null(input$stressor) && length(input$stressor) > 0) {
      data_filtered <- data_filtered[data_filtered$stressor_name %in% input$stressor, ]
    }
    
    # Filter: stressor metric
    if (!is.null(input$stressor_metric) && length(input$stressor_metric) > 0) {
      data_filtered <- data_filtered[data_filtered$specific_stressor_metric %in% input$stressor_metric, ]
    }
    
    # Filter: species common name
    if (!is.null(input$species) && length(input$species) > 0) {
      data_filtered <- data_filtered[data_filtered$species_common_name %in% input$species, ]
    }
    
    # Filter: geography
    if (!is.null(input$geography) && length(input$geography) > 0) {
      data_filtered <- data_filtered[data_filtered$geography %in% input$geography, ]
    }
    
    # Filter: life stage
    if (!is.null(input$life_stage) && length(input$life_stage) > 0) {
      data_filtered <- data_filtered[
        Reduce(`|`, lapply(input$life_stage, function(stage) {
          grepl(stage, data_filtered$life_stages, ignore.case = TRUE)
        })),
      ]
    }
    
    # Filter: activity
    if (!is.null(input$activity) && length(input$activity) > 0) {
      data_filtered <- data_filtered[data_filtered$activity %in% input$activity, ]
    }
    
    # Filter: genus latin
    if (!is.null(input$genus_latin) && length(input$genus_latin) > 0) {
      data_filtered <- data_filtered[data_filtered$genus_latin %in% input$genus_latin, ]
    }
    
    # Filter: species latin
    if (!is.null(input$species_latin) && length(input$species_latin) > 0) {
      data_filtered <- data_filtered[data_filtered$species_latin %in% input$species_latin, ]
    }
    
    # Search logic across multiple fields
    if (!is.null(input$search) && input$search != "") {
      search_term <- tolower(input$search)
      search_cols <- c("title", "species_common_name", "genus_latin", "species_latin",
                       "stressor_name", "specific_stressor_metric", "life_stages",
                       "activity", "geography")
      
      if (nrow(data_filtered) > 0 && length(search_cols) > 0) {
        matched_rows <- Reduce(`|`, lapply(search_cols, function(col) {
          grepl(search_term, tolower(data_filtered[[col]]), ignore.case = TRUE)
        }))
        data_filtered <- data_filtered[matched_rows, ]
      }
    }
    
    data_filtered
    
    
  })
  
  return(filtered_data)
}

# nolint end

