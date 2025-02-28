# nolint start

# loading all modules that contains specific functions that filter data, and handle pagination
source("global.R")
source("modules/filters.R", local = TRUE)
source("modules/pagination.R", local = TRUE)
source("modules/render_papers.R", local = TRUE)
source("modules/update_filters.R", local = TRUE) 
source("modules/toggle_filters.R", local = TRUE)
source("modules/reset_filters.R", local = TRUE)


# nolint start

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
  
  # Detect article ID from the URL and display full details
  observe({
    query <- parseQueryString(session$clientData$url_search)
    
    if (!is.null(query$article_id)) {
      article_id <- as.numeric(query$article_id)  # Convert ID to numeric
      
      # Find article in the dataset
      paper <- data[data$id == article_id,]
      
      output$article_content <- renderUI({
        if (nrow(paper) == 0) return("Article not found.")
        
        tagList(
          # Article Title
          h1(paper$title, style = "color: #2C3E50; font-weight: bold; text-align: left; margin-bottom: 20px; padding: 10px;"),
          
          # Article Metadata
          div(style = "margin-bottom: 20px;",
              p(tags$strong("Species Common Name: "), paper$species_common_name),
              p(tags$strong("Genus Latin: "), paper$genus_latin),
              p(tags$strong("Stressor Name: "), paper$stressor_name),
              p(tags$strong("Specific Stressor Metric: "), paper$specific_stressor_metric),
              p(tags$strong("Stressor Units: "), paper$stressor_units),
              p(tags$strong("Life Stage: "), paper$life_stages),
              p(tags$strong("Geography: "), ifelse(is.null(paper$geography), "NA", paper$geography))
          ),
          
          # Description
          h3("Detailed Description"),
          p(paper$description$overview),
          
          # Citations
          h3("Citations"),
          p(paper$citations$citation_text),
          
          if (!is.null(paper$citations$citation_links[[1]]$url)) {
            tags$a(href = paper$citations$citation_links[[1]]$url, "Read More", target = "_blank")
          },
          
          # Image 
          if (!is.null(paper$images[[1]]$image_url)) {
            div(style = "text-align: center; margin-top: 20px;",
                img(src = paper$images[[1]]$image_url, width = "60%", alt = paper$images[[1]]$image_caption))
          },
          
          # CSV Data Table
          h3("Stressor Response Data"),
          tableOutput("csv_table")
        )
      })
      
      # Render CSV Data as a Table
      output$csv_table <- renderTable({
        if (!is.null(paper$csv_data)) {
          data.frame(matrix(unlist(paper$csv_data), ncol = 5, byrow = TRUE))
        } else {
          return(NULL)
        }
      }, striped = TRUE, bordered = TRUE, hover = TRUE)
    }
  })
}

# nolint end
