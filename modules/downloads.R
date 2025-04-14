# nolint start
library(jsonlite)
library(purrr)

download_json <- function(output, paginated_data, input, session) {
  
  nest_fields <- function(...) {
    row <- list(...)
    
    if (!is.null(row$csv_data_json) && !is.na(row$csv_data_json)) {
      row$csv_data <- fromJSON(row$csv_data_json)
    } else {
      row$csv_data <- list()
    }
    
    desc_keys <- grep("^description\\.", names(row), value = TRUE)
    row$description <- setNames(as.list(row[desc_keys]), sub("^description\\.", "", desc_keys))
    
    cit_keys <- grep("^citations\\.", names(row), value = TRUE)
    row$citations <- setNames(as.list(row[cit_keys]), sub("^citations\\.", "", cit_keys))
    
    for (field in c("species_latin", "activity", "season", "life_stages", "images")) {
      if (is.null(row[[field]]) || is.na(row[[field]])) {
        row[[field]] <- if (field %in% c("life_stages", "images")) list() else ""
      }
    }
    
    row <- row[!names(row) %in% c(desc_keys, cit_keys, "csv_data_json")]
    return(row)
  }
  
  output$download_all_json <- downloadHandler(
    filename = function() paste0("all_stressor_responses_", Sys.Date(), ".json"),
    content = function(file) {
      all_data <- paginated_data()
      if (nrow(all_data) == 0) {
        showNotification("No data available for download.", type = "warning")
        return()
      }
      
      nested <- pmap(all_data, nest_fields)
      writeLines(toJSON(nested, pretty = TRUE, auto_unbox = TRUE), file)
    }
  )
  
  output$download_selected_json <- downloadHandler(
    filename = function() paste0("selected_stressor_responses_", Sys.Date(), ".json"),
    content = function(file) {
      all_data <- paginated_data()
      selected_ids <- sapply(all_data$id, function(id) {
        input_id <- paste0("select_article_", id)
        !is.null(input[[input_id]]) && input[[input_id]]
      })
      selected_data <- all_data[selected_ids, , drop = FALSE]
      if (nrow(selected_data) == 0) {
        showNotification("No articles selected for download.", type = "warning")
        return()
      }
      
      nested <- pmap(selected_data, nest_fields)
      writeLines(toJSON(nested, pretty = TRUE, auto_unbox = TRUE), file)
    }
  )
}

download_csv <- function(output, paginated_data, input, session) {
  
  output$download_all_csv <- downloadHandler(
    filename = function() paste0("all_stressor_responses_", Sys.Date(), ".csv"),
    content = function(file) {
      all_data <- paginated_data()
      if (nrow(all_data) == 0) {
        showNotification("No data available for download.", type = "warning")
        return()
      }
      write.csv(all_data, file, row.names = FALSE)
    }
  )
  
  output$download_selected_csv <- downloadHandler(
    filename = function() paste0("selected_stressor_responses_", Sys.Date(), ".csv"),
    content = function(file) {
      all_data <- paginated_data()
      selected_ids <- sapply(all_data$id, function(id) {
        input_id <- paste0("select_article_", id)
        !is.null(input[[input_id]]) && input[[input_id]]
      })
      selected_data <- all_data[selected_ids, , drop = FALSE]
      if (nrow(selected_data) == 0) {
        showNotification("No articles selected for download.", type = "warning")
        return()
      }
      write.csv(selected_data, file, row.names = FALSE)
    }
  )
}

# nolint end
