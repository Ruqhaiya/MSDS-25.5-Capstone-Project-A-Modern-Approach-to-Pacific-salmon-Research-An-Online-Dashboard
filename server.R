# nolint start

# Load required modules
source("global.R")
source("modules/filters.R", local = TRUE)
source("modules/pagination.R", local = TRUE)
source("modules/render_papers.R", local = TRUE)
source("modules/update_filters.R", local = TRUE) 
source("modules/toggle_filters.R", local = TRUE)
source("modules/reset_filters.R", local = TRUE)
source("modules/upload_server.R", local = TRUE)
source("modules/render_article_ui.R", local = TRUE)
source("modules/render_article_server.R", local = TRUE)
source("modules/downloads.R", local = TRUE)

server <- function(input, output, session) {
  
  # Connect to SQLite database
  db <- tryCatch(
    dbConnect(SQLite(), "data/stressor_responses.sqlite"),
    error = function(e) {
      stop("Error: Unable to connect to the database.")
    }
  )
  
  # Ensure the `stressor_responses` table exists
  if (!"stressor_responses" %in% dbListTables(db)) {
    stop("Error: Table `stressor_responses` does not exist in the database.")
  }
  
  # Filter data based on user input
  filtered_data <- filter_data_server(input, data, session)
  
  # Pagination logic
  pagination <- pagination_server(input, filtered_data)
  paginated_data <- pagination$paginated_data
  output$page_info <- renderText(pagination$page_info())
  
  # Update filters dynamically
  update_filters_server(input, session, filtered_data)
  toggle_filters_server(input, session)
  reset_filters_server(input, session)
  
  # Render articles (paper cards)
  render_papers_server(output, paginated_data, input, session)
  
  # Handle file uploads
  upload_server(input, output, session)
  
  # Generate comparable plots
  compare_plot_server(input, output, session, db)
  
  # Download feature
  download_json(output, paginated_data, input, session)
  
  # Handle article display logic
  observe({
    query <- parseQueryString(session$clientData$url_search)
    
    if (!is.null(query$article_id)) {
      article_id <- as.numeric(query$article_id)  # Convert ID to numeric
      
      # Ensure valid article data
      if (!is.na(article_id)) {
        render_article_ui(output, session)
        render_article_server(output, article_id, db) 
      } else {
        output$article_content <- renderUI(tags$p("Article not found.", style = "color: red; font-weight: bold;"))
      }
    }
  })
  
  # Toggle sections logic
  observeEvent(input$toggle_metadata, { toggle("metadata_section") })
  observeEvent(input$toggle_description, { toggle("description_section") })
  observeEvent(input$toggle_citations, { toggle("citations_section") })
  observeEvent(input$toggle_images, { toggle("images_section") })
  observeEvent(input$toggle_csv, { toggle("csv_section") })
  observeEvent(input$toggle_plot, { toggle("plot_section") })
  observeEvent(input$generate_plot, { show("compare_plot") })
  
  # Close the database connection when the session ends
  session$onSessionEnded(function() {
    dbDisconnect(db)
  })
}

# nolint end
