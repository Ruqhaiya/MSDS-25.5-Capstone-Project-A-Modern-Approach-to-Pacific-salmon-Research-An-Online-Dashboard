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
  
  # Fetch and parse stressor response data 
  stressor_query <- paste0("SELECT * FROM csv_data_table WHERE id = ", paper_id)
  stressor_data <- dbGetQuery(db, stressor_query)
  stressor_data <- parse_csv_data_table(stressor_data)
  
  
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
    if (nrow(stressor_data) == 0) {
      plot(1, type = "n", axes = FALSE, xlab = "", ylab = "")
      text(1, 1, "No data available for this article", col = "black", cex = 1.5, font = 2)
      return()
    }
    
    # Identify first two numeric columns
    numeric_cols <- Filter(function(col) {
      vals <- suppressWarnings(as.numeric(stressor_data[[col]]))
      sum(!is.na(vals)) >= 2  # Only consider columns with 2+ usable numbers
    }, colnames(stressor_data))
    
    if (length(numeric_cols) < 2) {
      plot(1, type = "n", axes = FALSE, xlab = "", ylab = "")
      text(1, 1, "Insufficient numeric columns for plotting", col = "red", cex = 1.2)
      return()
    }
    
    x_col <- numeric_cols[1]
    y_col <- numeric_cols[2]
    
    stressor_data[[x_col]] <- suppressWarnings(as.numeric(stressor_data[[x_col]]))
    stressor_data[[y_col]] <- suppressWarnings(as.numeric(stressor_data[[y_col]]))
    
    clean_data <- stressor_data[complete.cases(stressor_data[, c(x_col, y_col)]), ]
    
    if (nrow(clean_data) == 0) {
      plot(1, type = "n", axes = FALSE, xlab = "", ylab = "")
      text(1, 1, "No valid data points for plotting", col = "black", cex = 1.5, font = 2)
      return()
    }
    
    plot(
      clean_data[[x_col]], clean_data[[y_col]],
      type = "o", col = "blue", pch = 16, lwd = 2,
      xlab = x_col, ylab = y_col,
      main = paste("Stressor Response for", safe_get(paper, "stressor_name"))
    )
  })
}

# nolint end
