# nolint start

pagination_server <- function(input, filtered_data) {
  papers_per_page <- 10
  current_page <- reactiveVal(1)
  
  paginated_data <- reactive({
    data <- filtered_data()
    
    if (is.null(data) || nrow(data) == 0) {
      return(data.frame())
    }
    
    page_size <- input$page_size
    current_page <- input$page
    
    req(!is.null(page_size), !is.null(current_page), page_size > 0, current_page > 0)
    
    start <- (current_page - 1) * page_size + 1
    end <- min(start + page_size - 1, nrow(data))
    
    data[start:end, , drop = FALSE]
  })
  
  page_info <- reactive({
    data <- filtered_data()
    
    if (is.null(data) || nrow(data) == 0) {
      return("0 results")
    }
    
    page_size <- input$page_size
    current_page <- input$page
    
    req(!is.null(page_size), !is.null(current_page), page_size > 0, current_page > 0)
    
    start <- (current_page - 1) * page_size + 1
    end <- min(start + page_size - 1, nrow(data))
    
    paste("Showing", start, "to", end, "of", nrow(data), "results")
  })
  
  return(list(
    paginated_data = paginated_data,
    page_info = page_info
  ))
}

# nolint end
