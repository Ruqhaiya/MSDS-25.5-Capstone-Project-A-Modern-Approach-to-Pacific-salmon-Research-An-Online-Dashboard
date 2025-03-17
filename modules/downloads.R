# nolint start
library(jsonlite)

download_json <- function(output, paginated_data, input, session) {
  
  # Download All Articles
  output$download_all <- downloadHandler(
    filename = function() paste0("all_stressor_responses_", Sys.Date(), ".json"),
    content = function(file) {
      all_data <- paginated_data()  # Get all paginated data
      if (nrow(all_data) == 0) {
        showNotification("No data available for download.", type = "warning")
        return()
      }
      writeLines(toJSON(all_data, pretty = TRUE, auto_unbox = TRUE), file)
    }
  )
  
  # Download Selected Articles
  output$download_selected <- downloadHandler(
    filename = function() paste0("selected_stressor_responses_", Sys.Date(), ".json"),
    content = function(file) {
      all_data <- paginated_data()
      
      # Ensure `input` is accessible
      if (is.null(input)) {
        showNotification("Error: Unable to access input values.", type = "error")
        return()
      }
      # Extract selected checkboxes
      selected_ids <- sapply(all_data$id, function(id) {
        input_id <- paste0("select_article_", id)
        if (!is.null(input[[input_id]])) {
          return(input[[input_id]])  # TRUE if checked, FALSE otherwise
        }
        return(FALSE)  # Default to FALSE if checkbox is missing
      })
      selected_data <- all_data[selected_ids, , drop = FALSE]
      
      # Prevent empty downloads with warning message
      if (nrow(selected_data) == 0) {
        showNotification("No articles selected for download.", type = "warning")
        return()
      }
      
      # Save as JSON
      writeLines(toJSON(selected_data, pretty = TRUE, auto_unbox = TRUE), file)
    }
  )
}

# nolint end
