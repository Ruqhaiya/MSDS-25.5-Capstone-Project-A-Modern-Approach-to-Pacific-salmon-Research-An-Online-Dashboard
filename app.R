library(shiny)
library(jsonlite)
library(shinyWidgets)

data <- fromJSON("merged_stressor_responses.json")

# flattening list fields to strings, some of them have inconsistent commas
data$species_common_name <- sapply(data$species_common_name, function(x) paste(unlist(x), collapse = ", "))
data$life_stages <- sapply(data$life_stages, function(x) paste(unlist(x), collapse = ", "))
data$activity <- sapply(data$activity, function(x) paste(unlist(x), collapse = ", "))
data$geography <- sapply(data$geography, function(x) paste(unlist(x), collapse = ", "))
data$genus_latin <- sapply(data$genus_latin, function(x) paste(unlist(x), collapse = ", "))
data$species_latin <- sapply(data$species_latin, function(x) paste(unlist(x), collapse = ", "))

# extracting unique values for dropdowns (purely from the data)
stressor_names <- unique(unlist(data$stressor_name))
stressor_metrics <- unique(unlist(data$specific_stressor_metric))
species_names <- unique(unlist(data$species_common_name))
geographies <- unique(unlist(data$geography))
life_stages <- unique(unlist(data$life_stages))
activities <- unique(unlist(data$activity))
genus_latin <- unique(unlist(data$genus_latin))
species_latin <- unique(unlist(data$species_latin))

ui <- fluidPage(
  
  h2("SRF Dashboard", style = "color: #6082B6; text-align: center; font-weight: bold;"),
  
  fluidRow(
    column(8, textInput("search", "Search All Text", placeholder = "Type keywords...")),
    column(4, actionButton("toggle_filters", "Show Filters", icon = icon("filter")))
  ),
  
  # instead of showing fiklters all the time, we can make that conditional 
  conditionalPanel(
    # the logic %2 is basically calcilating how many time the button has been clicked (even or odd), to decide whether filters should be shown or hidden. 
    condition = "input.toggle_filters % 2 == 1",
    fluidRow(
      column(3, selectInput("stressor", "Stressor Name", c("All", stressor_names))),
      column(3, selectInput("stressor_metric", "Stressor Metric", c("All", stressor_metrics))),
      column(3, selectInput("species", "Species Common Name", c("All", species_names))),
      column(3, selectInput("geography", "Geography (Region)", c("All", geographies)))
    ),
    
    fluidRow(
      column(3, selectInput("life_stage", "Life Stage", c("All", life_stages))),
      column(3, selectInput("activity", "Activity", c("All", activities))),
      column(3, selectInput("genus_latin", "Genus Latin", c("All", genus_latin))),
      column(3, selectInput("species_latin", "Species Latin", c("All", species_latin)))
    ),
    fluidRow(
      column(12, div(style = "text-align: right;", actionButton("apply_filters", "Apply Filters")))
    )
  ),
  
  fluidRow(
    column(4, offset = 4, 
           actionButton("prev_page", "<< Previous"), 
           textOutput("page_info", inline = TRUE), 
           actionButton("next_page", "Next >>"))
  ),
  
  fluidRow(
    column(6, offset = 3, uiOutput("paper_cards"))
  )
)

server <- function(input, output, session) {
  
  papers_per_page <- 10  
  current_page <- reactiveVal(1)
  
  filtered_data <- reactive({
    data_filtered <- data
    
    if (input$stressor != "All") {
      data_filtered <- data_filtered[data_filtered$stressor_name == input$stressor, ]
    }
    if (input$stressor_metric != "All") {
      data_filtered <- data_filtered[data_filtered$specific_stressor_metric == input$stressor_metric, ]
    }
    if (input$species != "All") {
      data_filtered <- data_filtered[data_filtered$species_common_name == input$species, ]
    }
    if (input$geography != "All") {
      data_filtered <- data_filtered[data_filtered$geography == input$geography, ]
    }
    if (input$life_stage != "All") {
      data_filtered <- data_filtered[grepl(input$life_stage, data_filtered$life_stages), ]
    }
    if (input$activity != "All") {
      data_filtered <- data_filtered[data_filtered$activity == input$activity, ]
    }
    if (input$genus_latin != "All") {
      data_filtered <- data_filtered[data_filtered$genus_latin == input$genus_latin, ]
    }
    if (input$species_latin != "All") {
      data_filtered <- data_filtered[data_filtered$species_latin == input$species_latin, ]
    }
    
    # enchancing the search logic, it searches across multiple fields
    if (input$search != "") {
      search_term <- tolower(input$search)
      data_filtered <- data_filtered[
        grepl(search_term, tolower(data_filtered$title), ignore.case = TRUE) |
          grepl(search_term, tolower(data_filtered$species_common_name), ignore.case = TRUE) |
          grepl(search_term, tolower(data_filtered$genus_latin), ignore.case = TRUE) |
          grepl(search_term, tolower(data_filtered$species_latin), ignore.case = TRUE) |
          grepl(search_term, tolower(data_filtered$stressor_name), ignore.case = TRUE) |
          grepl(search_term, tolower(data_filtered$specific_stressor_metric), ignore.case = TRUE) |
          grepl(search_term, tolower(data_filtered$life_stages), ignore.case = TRUE) |
          grepl(search_term, tolower(data_filtered$activity), ignore.case = TRUE) |
          grepl(search_term, tolower(data_filtered$geography), ignore.case = TRUE), 
      ]
    }
    
    return(data_filtered)
  })
  
  # added pagination because initially it was showing the whole list of articles if we scroll down
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
  # toogle should show "hide filters"
  observeEvent(input$toggle_filters, {
    new_label <- ifelse(input$toggle_filters %% 2 == 1, "Hide Filters", "Show Filters")
    updateActionButton(session, "toggle_filters", label = new_label)
  })
  
  output$page_info <- renderText({
    total_papers <- nrow(filtered_data())
    total_pages <- ceiling(total_papers / papers_per_page)
    paste("Page", current_page(), "of", max(total_pages, 1))
  })
  
  output$paper_cards <- renderUI({
    data_to_display <- paginated_data()
    
    #initially cards were static, now they'll disappear when there's no data to show
    if (nrow(data_to_display) == 0 || all(is.na(data_to_display)) || all(is.na(data_to_display$title))) {
      return(tags$p("No research papers found.", style = "font-size: 18px; font-weight: bold; color: red;"))
    }
    
    # removes rowsof cards  where all values are NA
    data_to_display <- data_to_display[rowSums(is.na(data_to_display)) != ncol(data_to_display), ]
    tagList(
      lapply(1:nrow(data_to_display), function(i) {
        paper <- data_to_display[i, ]
        
        div(style = "border: 1px solid #ddd; padding: 15px; margin: 10px auto; background-color: #fff; 
                     border-radius: 8px; width: 90%; height: auto; 
                     display: flex; flex-direction: column; align-items: center;",
            
            # paper's title
            tags$h5(strong(paste0(paper$id, ". ", paper$title)), 
                    style = "margin-bottom: 10px; text-align: center; color: #6082B6; font-weight: bold;"),
            
            div(style = "display: flex; width: 100%;",
                div(style = "flex: 1; padding-right: 10px;",
                    tags$p("Species Common Name: ", tags$strong(paper$species_common_name)),
                    tags$p("Stressor Name: ", tags$strong(paper$stressor_name)),
                    tags$p("Specific Stressor Metric: ", tags$strong(paper$specific_stressor_metric)),
                    tags$p("Stressor Units: ", tags$strong(ifelse(is.null(paper$stressor_units), "(see notes)", paper$stressor_units)))
                ),
                div(style = "flex: 1; padding-left: 10px;",
                    tags$p("Genus Latin: ", tags$strong(paper$genus_latin)),
                    tags$p("Species Latin: ", tags$strong(paper$species_latin)),
                    tags$p("Life Stage: ", tags$strong(paper$life_stages)),
                    tags$p("Activity: ", tags$strong(paper$activity)),
                    tags$p("Geography: ", tags$strong(paper$geography))
                )
            )
        )
      })
    )
  })
}

shinyApp(ui = ui, server = server)
