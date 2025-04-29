# nolint start

library(DBI)
library(RSQLite)
library(jsonlite)
library(ggplot2)
library(zoo)
library(plotly)

render_article_server <- function(input, output, session, paper_id, db) {
  
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
  
  ## ←–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
  ## EXPAND/COLLAPSE BUTTONS HANDLERS HERE
  ## ←–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
  
  # vector of all section div IDs
  all_ids <- c(
    "metadata_section", "description_section", "citations_section",
    "images_section", "csv_section", "plot_section", "interactive_plot_section"
  )
  
  # expand all
  
  # a named vector of base labels:
  base_labels <- c(
    toggle_metadata       = "Article Metadata",
    toggle_description    = "Description & Function Details",
    toggle_citations      = "Citation(s)",
    toggle_images         = "Images",
    toggle_csv            = "Stressor Response Data",
    toggle_plot           = "Stressor Response Chart",
    toggle_interactive_plot = "Interactive Plot"
  )
  
  observeEvent(input$expand_all, {
    lapply(all_ids, show)
    for (id in names(base_labels)) {
      updateActionLink(
        session, id,
        label = paste0(base_labels[id], " ▲")
      )
    }
  })
  
  observeEvent(input$collapse_all, {
    lapply(all_ids, hide)
    for (id in names(base_labels)) {
      updateActionLink(
        session, id,
        label = paste0(base_labels[id], " ▼")
      )
    }
  })
  ## ←–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
  ##  End expand/collapse code
  ## ←–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
  
  
  # Function to safely parse JSON fields
  safe_fromJSON <- function(x) {
    if (!is.null(x) && nzchar(x) && x != "[]" && x != "NULL") {
      parsed <- tryCatch(fromJSON(x), error = function(e) NULL)
      return(if (!is.null(parsed) && !is.list(parsed)) as.list(parsed) else parsed)
    }
    return(NULL)
  }
  
  # Parse JSON fields
  paper$citations <- safe_fromJSON(paper$citations_citation_text)
  paper$citation_links <- safe_fromJSON(paper$citations_citation_links)
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
  output$description_overview <- renderText(safe_get(paper, "description_overview"))
  output$function_derivation <- renderText(safe_get(paper, "description_function_derivation"))
  
  # Render Citations
  output$citations <- renderUI({
    
    # Extract citation texts and ensure they are properly formatted
    citation_texts <- safe_get(paper, "citations_citation_text")
    
    if (!is.null(citation_texts) && is.character(citation_texts) && nzchar(citation_texts)) {
      citation_texts <- unlist(strsplit(citation_texts, "\\\\r\\\\n\\\\r\\\\n"))
    } else {
      citation_texts <- NULL
    }
    
    # Extract and parse citation links
    citation_links_raw <- safe_get(paper, "citations_citation_links")
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
  
  # Fetch stressor response data (already cleaned in long format)
  stressor_query <- paste0("SELECT * FROM csv_data_table WHERE id = ", paper_id)
  stressor_data <- dbGetQuery(db, stressor_query)
  
  # Render stressor response table
  output$csv_table <- renderTable({
    if (nrow(stressor_data) == 0) {
      return(data.frame(Message = "No data available for this article"))
    }
    
    display_cols <- c("stressor_value", "scaled_response_value", "sd", "low_limit", "up_limit", "article_stressor_label", "scaled_response_label")
    display_df <- stressor_data[, intersect(display_cols, colnames(stressor_data)), drop = FALSE]
    
    smart_round <- function(col) {
      col <- suppressWarnings(as.numeric(col))
      if (all(col %% 1 == 0, na.rm = TRUE)) return(as.integer(col))
      return(round(col, 2))
    }
    
    for (col in c("sd", "low_limit", "up_limit")) {
      if (col %in% names(display_df)) {
        display_df[[col]] <- smart_round(display_df[[col]])
      }
    }
    
    x_label <- if ("article_stressor_label" %in% names(stressor_data)) unique(na.omit(stressor_data$article_stressor_label))[1] else "X"
    y_label <- if ("scaled_response_label" %in% names(stressor_data)) unique(na.omit(stressor_data$scaled_response_label))[1] else "Y"
    
    colnames(display_df)[colnames(display_df) == "stressor_value"] <- x_label
    colnames(display_df)[colnames(display_df) == "scaled_response_value"] <- y_label
    colnames(display_df)[colnames(display_df) == "sd"] <- "Standard Deviation"
    colnames(display_df)[colnames(display_df) == "low_limit"] <- "Lower Limit"
    colnames(display_df)[colnames(display_df) == "up_limit"] <- "Upper Limit"
    
    display_df <- display_df[, !(names(display_df) %in% c("article_stressor_label", "scaled_response_label")), drop = FALSE]
    
    display_df
  })
  
  # Render static plot
  output$stressor_plot <- renderPlot({
    if (nrow(stressor_data) == 0) {
      plot(1, type = "n", axes = FALSE, xlab = "", ylab = "")
      text(1, 1, "No data available for this article", col = "black", cex = 1.5, font = 2)
      return()
    }
    
    stressor_data$stressor_value <- suppressWarnings(as.numeric(stressor_data$stressor_value))
    stressor_data$scaled_response_value <- suppressWarnings(as.numeric(stressor_data$scaled_response_value))
    clean_data <- stressor_data[complete.cases(stressor_data[, c("stressor_value", "scaled_response_value")]), ]
    
    if (nrow(clean_data) == 0) {
      plot(1, type = "n", axes = FALSE, xlab = "", ylab = "")
      text(1, 1, "No valid data points for plotting", col = "black", cex = 1.5, font = 2)
      return()
    }
    
    plot(
      clean_data$stressor_value, clean_data$scaled_response_value,
      type = "o", col = "blue", pch = 16, lwd = 2,
      xlab = clean_data$article_stressor_label[1],
      ylab = clean_data$scaled_response_label[1],
      main = paste("Stressor Response for", safe_get(paper, "stressor_name"))
    )
  })
  
  # Render interactive plot
  output$interactive_plot <- renderPlotly({
    stressor_data$stressor_value <- suppressWarnings(as.numeric(stressor_data$stressor_value))
    stressor_data$scaled_response_value <- suppressWarnings(as.numeric(stressor_data$scaled_response_value))
    clean_data <- stressor_data[complete.cases(stressor_data[, c("stressor_value", "scaled_response_value")]), ]
    
    if (nrow(clean_data) == 0) {
      return(plot_ly(type = "scatter", mode = "markers", height = 200) %>%
               layout(
                 margin = list(t = 20, b = 20),
                 xaxis = list(visible = FALSE), yaxis = list(visible = FALSE),
                 annotations = list(list(
                   text = "No data available for this article",
                   xref = "paper", yref = "paper",
                   x = 0.5, y = 0.5, showarrow = FALSE,
                   font = list(size = 16, color = "black")
                 ))
               ))
    }
    
    plot_ly(clean_data, x = ~stressor_value, y = ~scaled_response_value,
            type = "scatter", mode = "lines+markers",
            line = list(color = "blue"), marker = list(size = 6)) %>%
      layout(
        title = paste("Stressor Response Chart for", safe_get(paper, "stressor_name")),
        xaxis = list(title = clean_data$article_stressor_label[1]),
        yaxis = list(title = clean_data$scaled_response_label[1])
      )
  })
}

# nolint end
