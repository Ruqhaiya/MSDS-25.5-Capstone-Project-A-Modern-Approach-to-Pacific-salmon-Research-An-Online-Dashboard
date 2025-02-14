# nolint start

ui <- fluidPage(
  h2("SRF Dashboard", style = "color: #6082B6; text-align: center; font-weight: bold;"),
  
  fluidRow(
    column(8, textInput("search", "Search All Text", placeholder = "Type keywords...")),
    column(4, actionButton("toggle_filters", "Show Filters", icon = icon("filter")))
  ),
  
  # Placing filters below the title
  conditionalPanel(
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
    # Reset filters option 
    fluidRow(
      column(12, div(style = "text-align: right;",
        actionLink("reset_filters", "Reset Filters", 
                  style = "color: #0073e6; font-size: 14px; text-decoration: none; margin-right: 10px;"))
      ))

  ),
  
  # Adding pagination to the UI for better navigation
  fluidRow(
    column(4, offset = 4, 
           actionButton("prev_page", "<< Previous"), 
           textOutput("page_info", inline = TRUE), 
           actionButton("next_page", "Next >>"))
  ),
  
  # Adding 'paper cards' - the articles that are displayed on the main page are called paper cards)
  fluidRow(
    column(6, offset = 3, uiOutput("paper_cards"))
  )
)

# nolint end