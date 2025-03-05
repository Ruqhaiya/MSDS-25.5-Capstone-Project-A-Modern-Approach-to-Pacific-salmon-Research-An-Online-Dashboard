# nolint start

# loading all modules that contain specific functions that filter data, and handle pagination
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


server <- function(input, output, session) {
  
  # Function that filters data based on user input
  filtered_data <- filter_data_server(input, data, session)
  
  # Pagination logic
  pagination <- pagination_server(input, filtered_data)
  paginated_data <- pagination$paginated_data
  output$page_info <- renderText(pagination$page_info())
  
  # Updating filters dynamically
  update_filters_server(input, session, filtered_data)
  toggle_filters_server(input, session)
  reset_filters_server(input, session)
  
  # Render articles (paper cards)
  render_papers_server(output, paginated_data)

  # Function for the upload tab 
  upload_server(input, output, session)

  # Handles article display logic
  observe({
    query <- parseQueryString(session$clientData$url_search)
    
    if (!is.null(query$article_id)) {
      article_id <- as.numeric(query$article_id)  # Convert ID to numeric
      
      # Find article in the dataset
      paper <- data[data$id == article_id,]
      
      # Ensuring valid article data
      if (nrow(paper) == 0) {
        output$article_content <- renderUI(tags$p("Article not found.", style = "color: red; font-weight: bold;"))
      } else {
        # Render Article UI
        render_article_ui(output, session)
        # Rendering Article Content (table & plot)
        render_article_server(output, paper)
      }
    }
  })

  observeEvent(input$toggle_metadata, { toggle("metadata_section") })
  observeEvent(input$toggle_description, { toggle("description_section") })
  observeEvent(input$toggle_citations, { toggle("citations_section") })
  observeEvent(input$toggle_images, { toggle("images_section") })
  observeEvent(input$toggle_csv, { toggle("csv_section") })
  observeEvent(input$toggle_plot, { toggle("plot_section") })

  
}

# nolint end
