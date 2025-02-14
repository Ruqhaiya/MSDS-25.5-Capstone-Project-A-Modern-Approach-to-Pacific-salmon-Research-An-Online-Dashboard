# nolint start

# loading all modules that contains specific functions that filter data, and handle pagination
source("global.R")
source("modules/filters.R", local = TRUE)
source("modules/pagination.R", local = TRUE)
source("modules/render_papers.R", local = TRUE)
source("modules/update_filters.R", local = TRUE) 
source("modules/toggle_filters.R", local = TRUE)
source("modules/reset_filters.R", local = TRUE)


server <- function(input, output, session) {
  
  # This is the function that populates the options for each filter  
  filtered_data <- filter_data_server(input, data, session)
  
  # Function for pagination logic (returns list with `paginated_data` and `page_info`)
  pagination <- pagination_server(input, filtered_data)
  paginated_data <- pagination$paginated_data
  output$page_info <- renderText(pagination$page_info())

  # Function to update dropdowns dynamically based on filtered data
  update_filters_server(input, session, filtered_data)
  
  # Function to handle toggle button label
  toggle_filters_server(input, session)

  # Function to reset the filters
  reset_filters_server(input, session)

  # Function to render the paper cards (articles)
  render_papers_server(output, paginated_data)
}

# nolint end