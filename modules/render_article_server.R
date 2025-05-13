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
  paper <- dbGetQuery(db,
                      "SELECT * FROM stressor_responses WHERE main_id = ?",
                      params = list(paper_id)
  )
  
  
  # Check if article data exists
  if (nrow(paper) == 0) {
    return(NULL)
  }
  
  paper <- paper[1, ]  # Ensure single-row data
  
  output$article_title <- renderText({
    # if you want a fallback when title is missing:
    if (is.na(paper$title) || paper$title == "") "Untitled Article"
    else paper$title
  })

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
  
  ##  End expand/collapse code

  
  # Function to safely parse JSON fields
  safe_fromJSON <- function(x) {
    # bail early on NULL, NA, empty, or literal "NULL"/"[]"
    if (is.null(x) ||
        (length(x)==1 && is.na(x)) ||
        !nzchar(x) ||
        x %in% c("NULL", "[]")) {
      return(NULL)
    }
    # else try to parse
    parsed <- tryCatch(jsonlite::fromJSON(x), error = function(e) NULL)
    # if it ends up being atomic, wrap as list
    if (!is.null(parsed) && !is.list(parsed)) {
      parsed <- list(parsed)
    }
    parsed
  }
  
  
  paper$citations <- safe_fromJSON(paper$citations_citation_text)
  paper$citation_links <- safe_fromJSON(paper$citations_citation_links)
  paper$images <- safe_fromJSON(paper$images)
  
  safe_get <- function(df, col) {
    if (col %in% names(df)) return(ifelse(is.na(df[[col]]), "Not provided", df[[col]]))
    return("Not provided")
  }
  
  smart_round <- function(col) {
    col <- suppressWarnings(as.numeric(col))
    if (all(col %% 1 == 0, na.rm = TRUE)) return(as.integer(col))
    return(round(col, 2))
  }
  
  # Render metadata fields
  output$species_name <- renderText(safe_get(paper, "species_common_name"))
  output$genus_latin <- renderText(safe_get(paper, "genus_latin"))
  output$stressor_name <- renderText(safe_get(paper, "stressor_name"))
  output$specific_stressor_metric <- renderText(safe_get(paper, "specific_stressor_metric"))
  output$stressor_units <- renderText(safe_get(paper, "stressor_units"))
  output$life_stage <- renderText(safe_get(paper, "life_stages"))
  output$description_overview <- renderText(safe_get(paper, "description_overview"))
  output$function_derivation <- renderText(safe_get(paper, "description_function_derivation"))
  
  # Render citations
  output$citations <- renderUI({
    citation_texts <- safe_get(paper, "citations_citation_text")
    if (!is.null(citation_texts) && is.character(citation_texts) && nzchar(citation_texts)) {
      citation_texts <- unlist(strsplit(citation_texts, "\\\r\\\n\\\r\\\n"))
    } else {
      citation_texts <- NULL
    }
    citation_links_raw <- safe_get(paper, "citations_citation_links")
    citation_links <- safe_fromJSON(citation_links_raw)
    if (!is.list(citation_links) || length(citation_links) == 0) {
      citation_links <- vector("list", length(citation_texts))
    }
    tagList(
      if (!is.null(citation_texts) && length(citation_texts) > 0) {
        lapply(seq_along(citation_texts), function(i) {
          citation_text <- citation_texts[i]
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
  
  # Render images
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
  
  # Fetch stressor response data from csv_numeric + csv_meta
  stressor_data <- dbGetQuery(db,
                              "SELECT n.*, m.article_stressor_label, m.scaled_response_label
     FROM csv_numeric n
     JOIN csv_meta    m ON n.csv_id = m.csv_id
    WHERE m.main_id = ?",
                              params = list(paper_id)
  )  

  
  # Get x_label and y_label
  x_label <- ifelse("article_stressor_label" %in% names(stressor_data) && nzchar(stressor_data$article_stressor_label[1]), stressor_data$article_stressor_label[1], "Stressor")
  y_label <- ifelse("scaled_response_label" %in% names(stressor_data) && nzchar(stressor_data$scaled_response_label[1]), stressor_data$scaled_response_label[1], "Response")
  
  # Render stressor response table
  output$csv_table <- renderTable({
    if (nrow(stressor_data) == 0) {
      return(data.frame(Message = "No data available for this article"))
    }
    
    display_cols <- c("stressor_value", "scaled_response_value", "sd", "low_limit", "up_limit")
    display_df <- stressor_data[, intersect(display_cols, names(stressor_data)), drop = FALSE]
    
    for (col in c("sd", "low_limit", "up_limit")) {
      if (col %in% names(display_df)) {
        display_df[[col]] <- smart_round(display_df[[col]])
      }
    }
    
    names(display_df)[names(display_df) == "stressor_value"] <- x_label
    names(display_df)[names(display_df) == "scaled_response_value"] <- y_label
    
    display_df
  })
  
  # Static plot
  output$stressor_plot <- renderPlot({
    if (nrow(stressor_data) == 0) {
      plot(1, type = "n", axes = FALSE, xlab = "", ylab = "")
      text(1, 1, "No data available for this article", col = "black", cex = 1.5, font = 2)
      return()
    }
    
    clean_data <- stressor_data[complete.cases(stressor_data[, c("stressor_value", "scaled_response_value")]), ]
    
    plot(
      clean_data$stressor_value, clean_data$scaled_response_value,
      type = "o", col = "blue", pch = 16, lwd = 2,
      xlab = x_label,
      ylab = y_label,
      main = paste("Stressor Response for", safe_get(paper, "stressor_name"))
    )
  })
  
  # Interactive plot
  output$interactive_plot <- renderPlotly({
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
        title = paste("Interactive Plot for", safe_get(paper, "stressor_name")),
        xaxis = list(title = x_label),
        yaxis = list(title = y_label)
      )
  })
}

# nolint end
