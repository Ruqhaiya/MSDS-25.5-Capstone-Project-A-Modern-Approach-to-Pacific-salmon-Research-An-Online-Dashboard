# nolint start

library(readr)

render_article_server <- function(output, paper) {
  
  # checking `paper` is not NULL or empty
  if (is.null(paper) || length(paper) == 0) {
    print("No valid article data available")
    return(NULL)
  }

  # loading extracted CSV dataset
  extracted_csv <- read_csv("data/extracted_stressor_responses.csv")

  # Find the CSV data for the selected article
  csv_entry <- extracted_csv[extracted_csv$id == paper$id, "csv_data"]

  # Rendering Metadata (From JSON)
  output$species_name <- renderText(ifelse(is.null(paper$species_common_name), "Not provided", paper$species_common_name))
  output$genus_latin <- renderText(ifelse(is.null(paper$genus_latin), "Not provided", paper$genus_latin))
  output$stressor_name <- renderText(paper$stressor_name)
  output$specific_stressor_metric <- renderText(paper$specific_stressor_metric)
  output$stressor_units <- renderText(ifelse(is.null(paper$stressor_units), "Not provided", paper$stressor_units))
  output$vital_rate <- renderText(ifelse(is.null(paper$vital_rate), "Not provided", paper$vital_rate))
  output$life_stage <- renderText(ifelse(is.null(paper$life_stages), "Not provided", paper$life_stages))
  output$description_overview <- renderText(ifelse(is.null(paper$description$overview), "Not provided", paper$description$overview))
  output$function_derivation <- renderText(ifelse(is.null(paper$description$function_derivation), "Not provided", paper$description$function_derivation))

  # Render Citations
  output$citations <- renderUI({
    tagList(
      if (!is.null(paper$citations$citation_text)) {
        lapply(paper$citations$citation_text, function(cite) p(cite))
      },
      if (!is.null(paper$citations$citation_links)) {
        lapply(paper$citations$citation_links, function(link) {
          tags$a(href = link$url, link$title, target = "_blank")
        })
      }
    )
  })

  # Render Images
  output$article_images <- renderUI({
    if (!is.null(paper$images) && length(paper$images) > 0) {
      img(src = paper$images[[1]]$image_url, width = "60%", alt = "Article Image")
    }
  })

}

# nolint end
