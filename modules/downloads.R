# nolint start


library(shiny)
library(DBI)
library(RSQLite)
library(jsonlite)
library(purrr)

download_json <- function(output, paginated_data, input, session,
                          db_path = "data/stressor_responses.sqlite") {
  
  nest_fields <- function(row) {
    # Parse csv_data_json directly (already structured as array of objects)
    csv_data <- tryCatch({
      fromJSON(row$csv_data_json)
    }, error = function(e) {
      NULL
    })
    
    nested <- list(
      id                      = row$main_id,
      title                   = row$title,
      species_common_name     = row$species_common_name,
      genus_latin             = row$genus_latin,
      stressor_name           = row$stressor_name,
      specific_stressor_metric = row$specific_stressor_metric,
      stressor_units          = row$stressor_units,
      life_stages             = row$life_stages,
      csv_data_rows           = csv_data  # JSON-parsed data directly
    )
    
    # Add descriptions
    desc_keys <- grep("^description\\.", names(row), value = TRUE)
    if (length(desc_keys) > 0) {
      nested$description <- setNames(as.list(row[desc_keys]), sub("^description\\.", "", desc_keys))
    }

    # Add citations
    cit_keys <- grep("^citations\\.", names(row), value = TRUE)
    if (length(cit_keys) > 0) {
      nested$citations <- setNames(as.list(row[cit_keys]), sub("^citations\\.", "", cit_keys))
    }

    return(nested)
  }

  
  # ——— Download ALL JSON ———
  output$download_all_json <- downloadHandler(
    filename    = function() paste0("all_stressor_responses_", Sys.Date(), ".json"),
    contentType = "application/json",
    content     = function(file) {
      df <- paginated_data()
      if (nrow(df) == 0) {
        showNotification("No data available for download.", type = "warning")
        return()
      }
      out <- map(seq_len(nrow(df)), ~ nest_fields(df[.x, ]))
      writeLines(toJSON(out, pretty = TRUE, auto_unbox = TRUE), file)
    }
  )
  
  # ——— Download SELECTED JSON ———
  output$download_selected_json <- downloadHandler(
    filename    = function() paste0("selected_stressor_responses_", Sys.Date(), ".json"),
    contentType = "application/json",
    content     = function(file) {
      df <- paginated_data()
      sel <- sapply(df$main_id, function(id) {
        inp <- paste0("select_article_", id)
        !is.null(input[[inp]]) && input[[inp]]
      })
      df2 <- df[sel, , drop = FALSE]
      if (nrow(df2) == 0) {
        showNotification("No articles selected for download.", type = "warning")
        return()
      }
      out <- map(seq_len(nrow(df2)), ~ nest_fields(df2[.x, ]))
      writeLines(toJSON(out, pretty = TRUE, auto_unbox = TRUE), file)
    }
  )
}

download_csv <- function(output, paginated_data, input, session) {
  # ——— Download ALL CSV ———
  output$download_all_csv <- downloadHandler(
    filename    = function() paste0("all_stressor_responses_", Sys.Date(), ".csv"),
    contentType = "text/csv",
    content     = function(file) {
      df <- paginated_data()
      if (nrow(df) == 0) {
        showNotification("No data available for download.", type = "warning")
        return()
      }
      write.csv(df, file, row.names = FALSE)
    }
  )
  
  # ——— Download SELECTED CSV ———
  output$download_selected_csv <- downloadHandler(
    filename    = function() paste0("selected_stressor_responses_", Sys.Date(), ".csv"),
    contentType = "text/csv",
    content     = function(file) {
      df <- paginated_data()
      sel <- sapply(df$main_id, function(id) {
        inp <- paste0("select_article_", id)
        !is.null(input[[inp]]) && input[[inp]]
      })
      df2 <- df[sel, , drop = FALSE]
      if (nrow(df2) == 0) {
        showNotification("No articles selected for download.", type = "warning")
        return()
      }
      write.csv(df2, file, row.names = FALSE)
    }
  )
}

# nolint end