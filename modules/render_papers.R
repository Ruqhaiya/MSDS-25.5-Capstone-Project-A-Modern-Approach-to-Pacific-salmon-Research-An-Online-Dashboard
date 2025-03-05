# nolint start

render_papers_server <- function(output, paginated_data) {
  output$paper_cards <- renderUI({
    data_to_display <- paginated_data()
    
    # If no papers are available
    if (is.null(data_to_display) || nrow(data_to_display) == 0) {
      return(tags$p("No research papers found.", style = "font-size: 18px; font-weight: bold; color: red;"))
    }
    
    # removes rows of cards where all values are NA (based on our paginated logic, 
    # it was showing 10 empty papers (NA values) even if there's no data for that search query)
    data_to_display <- data_to_display[rowSums(is.na(data_to_display)) != ncol(data_to_display), ]
    
    tagList(
      lapply(1:nrow(data_to_display), function(i) {
        paper <- data_to_display[i, ]
        article_url <- paste0("?article_id=", paper$id)
        
        div(
          style = "border: 1px solid #ddd; padding: 15px; margin: 10px auto; background-color: #fff; 
                   border-radius: 8px; width: 90%; height: auto; 
                   display: flex; flex-direction: column; align-items: center;",
          
          # Clickable article title
          tags$a(
            href = article_url, target = "_self", paste0(paper$id, ". ", paper$title),
            style = "margin-bottom: 10px; text-align: left; color: #6082B6; font-weight: bold; cursor: pointer;"
          ),
          
          div(
            style = "display: flex; width: 100%;",
            div(
              style = "flex: 1; padding-right: 10px;",
              tags$p("Species Common Name: ", tags$strong(paper$species_common_name)),
              tags$p("Stressor Name: ", tags$strong(paper$stressor_name)),
              tags$p("Specific Stressor Metric: ", tags$strong(paper$specific_stressor_metric)),
              tags$p("Stressor Units: ", tags$strong(ifelse(is.null(paper$stressor_units), "(see notes)", paper$stressor_units)))
            ),
            div(
              style = "flex: 1; padding-left: 10px;",
              tags$p("Genus Latin: ", tags$strong(paper$genus_latin)),
              tags$p("Species Latin: ", tags$strong(paper$species_latin)),
              tags$p("Life Stage: ", tags$strong(paper$life_stages)),
              tags$p("Activity: ", tags$strong(paper$activity)),
              tags$p("Geography: ", tags$strong(paper$geography))
            ),
           
          )
        )
      })
    )
  })
}

# nolint end