render_papers_server <- function(output, paginated_data, input, session) {
  output$paper_cards <- renderUI({
    data_to_display <- paginated_data()
    
    format_field <- function(val, bold = FALSE) {
      display <- ifelse(is.na(val) || val == "NA", "", val)
      style <- if (bold) "metadata-bold" else "metadata-light"
      title_attr <- if (nzchar(display)) paste0("title='", htmltools::htmlEscape(display), "'") else ""
      sprintf("<div class='paper-meta-item %s' %s>%s</div>", style, title_attr, htmltools::htmlEscape(display))
    }


    if (is.null(data_to_display) || nrow(data_to_display) == 0) {
      return(tags$p(
        "No research papers found.",
        style = "font-size: 18px; font-weight: bold; color: red;"
      ))
    }
    
    # Remove rows where all values are NA
    data_to_display <- data_to_display[rowSums(is.na(data_to_display)) != ncol(data_to_display), ]
    
    tagList(
      lapply(seq_len(nrow(data_to_display)), function(i) {
        paper <- data_to_display[i, ]
        
        article_url <- paste0("?main_id=", paper$main_id)
        checkbox_id <- paste0("select_article_", paper$main_id)
        
      div(
        class = "hover-highlight",
        style = "padding: 8px 12px; margin: 6px auto; border-radius: 6px; width: 95%;
                display: flex; align-items: flex-start; justify-content: flex-start;
                border: 1px solid #ddd; background-color: #f9f9f9; min-height: 80px;",

        # Checkbox
        div(style = "margin-right: 10px; margin-top: 5px;",
            checkboxInput(inputId = checkbox_id, label = NULL, value = FALSE, width = "20px")
        ),

        # Title + Metadata block
        div(style = "flex-grow: 1; padding-left: 10px;",

            # Title
            tags$a(
              href = article_url,
              target = "_self",
              class = "paper-card-title",
              paste0(paper$main_id, ". ", paper$title)
            ),

            # Metadata rows
            div(class = "paper-meta-row",
              HTML(format_field(paper$species_common_name, TRUE)),
              HTML(format_field(paper$life_stages, TRUE)),
              HTML(format_field(paper$research_article_type)),
              HTML(format_field(paper$activity, TRUE))
            ),
            div(class = "paper-meta-row",
              HTML(format_field(paper$stressor_name, TRUE)),
              HTML(format_field(paper$specific_stressor_metric, TRUE)),
              HTML(format_field(paper$broad_stressor_name)),
              HTML(format_field(paper$genus_latin, TRUE))
            ),
            div(class = "paper-meta-row",
              HTML(format_field(paper$location_river_creek)),
              HTML(format_field(paper$location_watershed_lab)),
              HTML(format_field(paper$location_state_province)),
              HTML(format_field(paper$location_country))
            )

        )
      )

      })
    )
  })
  
  # Sync all checkboxes with "Select All"
  observeEvent(input$select_all, {
    ids <- paginated_data()$main_id
    for (mid in ids) {
      updateCheckboxInput(
        session,
        inputId = paste0("select_article_", mid),
        value = input$select_all
      )
    }
  })
}
