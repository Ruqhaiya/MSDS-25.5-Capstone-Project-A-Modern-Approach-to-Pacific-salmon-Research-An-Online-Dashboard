# nolint start 

pagination_server <- function(input, filtered_data) {
  papers_per_page <- 10  
  current_page <- reactiveVal(1)
  
  # reactive expression to paginate data
  paginated_data <- reactive({
    data_to_display <- filtered_data()
    
    total_papers <- nrow(data_to_display)
    start_index <- (current_page() - 1) * papers_per_page + 1
    end_index <- min(start_index + papers_per_page - 1, total_papers)
    
    if (total_papers == 0) {
      return(NULL)
    }
    
    return(data_to_display[start_index:end_index, ])
  })
  
  # page navigation buttons
  observeEvent(input$next_page, {
    if ((current_page() * papers_per_page) < nrow(filtered_data())) {
      current_page(current_page() + 1)
    }
  })
  
  observeEvent(input$prev_page, {
    if (current_page() > 1) {
      current_page(current_page() - 1)
    }
  })
  
  # page info text
  page_info <- reactive({
    total_papers <- nrow(filtered_data())
    total_pages <- ceiling(total_papers / papers_per_page)
    paste("Page", current_page(), "of", max(total_pages, 1))
  })
  
  return(list(
    paginated_data = paginated_data,
    page_info = page_info
  ))
}



# nolint end