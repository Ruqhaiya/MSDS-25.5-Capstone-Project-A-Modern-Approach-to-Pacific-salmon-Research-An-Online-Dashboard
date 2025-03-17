# nolint start

library(DBI)
library(RSQLite)
library(jsonlite)
library(ggplot2)

render_article_server <- function(output, paper_id, db) {
  
  # Ensure database connection is provided
  if (missing(db)) {
    stop("Database connection (db) is missing!")
  }
  
  # Fetch article data from SQLite
  query <- paste0("SELECT * FROM stressor_responses WHERE id = ", paper_id)
  paper <- dbGetQuery(db, query)
  
  # Check if article data exists
  if (nrow(paper) == 0) {
    return(NULL)
  }
  
  paper <- paper[1, ]  # Ensure single-row data
  
  # Function to safely parse JSON fields
  safe_fromJSON <- function(x) {
    if (!is.null(x) && nzchar(x) && x != "[]" && x != "NULL") {
      parsed <- tryCatch(fromJSON(x), error = function(e) NULL)
      return(if (!is.null(parsed) && !is.list(parsed)) as.list(parsed) else parsed)
    }
    return(NULL)
  }
  
  # Parse JSON fields
  paper$citations <- safe_fromJSON(paper$`citations.citation_text`)
  paper$citation_links <- safe_fromJSON(paper$`citations.citation_links`)
  paper$images <- safe_fromJSON(paper$images)
  
  # Function to safely retrieve values
  safe_get <- function(df, col) {
    if (col %in% names(df)) return(ifelse(is.na(df[[col]]), "Not provided", df[[col]]))
    return("Not provided")
  }
  
  # Rendering Metadata
  output$species_name <- renderText(safe_get(paper, "species_common_name"))
  output$genus_latin <- renderText(safe_get(paper, "genus_latin"))
  output$stressor_name <- renderText(safe_get(paper, "stressor_name"))
  output$specific_stressor_metric <- renderText(safe_get(paper, "specific_stressor_metric"))
  output$stressor_units <- renderText(safe_get(paper, "stressor_units"))
  output$life_stage <- renderText(safe_get(paper, "life_stages"))
  output$description_overview <- renderText(safe_get(paper, "description.overview"))
  output$function_derivation <- renderText(safe_get(paper, "description.function_derivation"))
  
  # Render Citations
  output$citations <- renderUI({
    
    # Extract citation texts and ensure they are properly formatted
    citation_texts <- safe_get(paper, "citations.citation_text")
    
    if (!is.null(citation_texts) && is.character(citation_texts) && nzchar(citation_texts)) {
      citation_texts <- unlist(strsplit(citation_texts, "\\\\r\\\\n\\\\r\\\\n"))
    } else {
      citation_texts <- NULL
    }
    
    # Extract and parse citation links
    citation_links_raw <- safe_get(paper, "citations.citation_links")
    citation_links <- safe_fromJSON(citation_links_raw)
    
    # Ensure citation links are structured correctly
    if (!is.list(citation_links) || length(citation_links) == 0) {
      citation_links <- vector("list", length(citation_texts))
    }
    
    # Generate citation UI
    tagList(
      if (!is.null(citation_texts) && length(citation_texts) > 0) {
        lapply(seq_along(citation_texts), function(i) {
          citation_text <- citation_texts[i]
          
          # Extract the corresponding link
          link <- if (i <= length(citation_links) && is.list(citation_links[[i]]) && "url" %in% names(citation_links[[i]])) {
            citation_links[[i]]$url
          } else {
            NULL
          }
          tags$div(
            tags$p(citation_text),
            if (!is.null(link) && nzchar(link)) {
              tags$a(href = link, "Read More", target = "_blank", class = "btn btn-primary btn-sm")
            }
          )
        })
      } else {
        tags$p("No citations available.")
      }
    )
  })
  

  
  # Render Images
  output$article_images <- renderUI({
    image_url <- if (is.data.frame(paper$images)) as.character(paper$images$image_url) else paper$images
    
    if (!is.null(image_url) && nzchar(image_url)) {
      tags$figure(
        tags$img(src = image_url, width = "60%", alt = "Article Image"),
        tags$figcaption("Figure extracted from the database.")
      )
    } else {
      tags$p("No images available.")
    }
  })
  
  # Fetch Stressor Response Data
  stressor_query <- paste0("SELECT * FROM csv_data_table WHERE id = ", paper_id)
  stressor_data <- dbGetQuery(db, stressor_query)
  
  # Render stressor response table
  output$csv_table <- renderTable({
    if (nrow(stressor_data) > 0) {
      stressor_data
    } else {
      data.frame(Message = "No data available for this article")
    }
  })
 
   # Render stressor response plot
  output$stressor_plot <- renderPlot({
    
    # Check for data and present error message if none
    if (nrow(stressor_data) == 0) {
      plot(1, type = "n", axes = FALSE, xlab = "", ylab = "")
      text(1, 1, "No data available for this article", col = "black", cex = 1.5, font = 2)
      return()
    }
    
    # Standardize column names
    colnames(stressor_data) <- c("stressor_x", "mean_system_capacity", "sd", "low_limit", "up_limit", "extra", "id")
    
    # Convert numeric columns
    num_cols <- c("stressor_x", "mean_system_capacity", "sd", "low_limit", "up_limit")
    stressor_data[num_cols] <- lapply(stressor_data[num_cols], function(x) suppressWarnings(as.numeric(x)))
    
    # Remove NA rows before plotting
    stressor_data <- stressor_data[complete.cases(stressor_data[num_cols]), ]
    
    # If all numeric values are NA, show an error message instead of a blank plot
    if (nrow(stressor_data) == 0) {
      plot(1, type = "n", axes = FALSE, xlab = "", ylab = "")
      text(1, 1, "No valid numeric data available for plotting", col = "black", cex = 1.5, font = 2)
      return()
    }
    
    # Plot stressor response data
    plot(
      stressor_data$stressor_x, stressor_data$mean_system_capacity,
      type = "o", col = "blue", pch = 16, lwd = 2,
      xlab = "Stressor (X)", ylab = "Mean System Capacity (%)",
      main = paste("Stressor Response for", safe_get(paper, "stressor_name"))
    )
  })
}

# nolint end
