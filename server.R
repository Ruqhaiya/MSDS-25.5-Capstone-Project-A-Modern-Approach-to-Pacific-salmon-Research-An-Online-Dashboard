# nolint start

# Load required modules
source("global.R")
source("modules/filters.R", local = TRUE)
source("modules/pagination.R", local = TRUE)
source("modules/render_papers.R", local = TRUE)
source("modules/update_filters_server.R", local = TRUE)
source("modules/toggle_filters.R", local = TRUE)
source("modules/reset_filters.R", local = TRUE)
source("modules/render_article_ui.R", local = TRUE)
source("modules/render_article_server.R", local = TRUE)
source("modules/downloads.R", local = TRUE)
source("modules/upload.R", local = TRUE)
source("modules/admin_auth.R",    local = TRUE)
source("modules/manage_categories.R", local = TRUE)


server <- function(input, output, session) {
  
  # 1) launch auth module
  admin_ok <- adminAuthServer("auth", correct_pw = "secret123")

  
  # 2) Single UI slot for login or category manager
  output$categories_auth_ui <- renderUI({
    if (!admin_ok()) {
      # show the password prompt
      adminAuthUI("auth")
    } else {
      manageCategoriesUI("manage_categories")
    }
  })
  
  # 3) Wire up the manageCategoriesServer when logged in
  observeEvent(admin_ok(), {
    if (admin_ok()) {
      manageCategoriesServer("manage_categories", db)
    }
  })
  
  # Connect to SQLite database
  db <- tryCatch(
    dbConnect(SQLite(), "data/stressor_responses.sqlite"),
    error = function(e) {
      stop("Error: Unable to connect to the database.")
    }
  )
  
  # Ensure the `stressor_responses` table exists
  if (!"stressor_responses" %in% dbListTables(db)) {
    stop("Error: Table `stressor_responses` does not exist in the database.")
  }
  
  # Read the table into a local data frame
  data <- dbReadTable(dbConnect(SQLite(), "data/stressor_responses.sqlite"), "stressor_responses")
  
  # Filter data based on user input
  filtered_data <- filter_data_server(input, data, session)
  
  progressive_data <- reactive({
    req(data)
    df <- data
    
    if (!is.null(input$stressor) && length(input$stressor) > 0) {
      df <- df[df$stressor_name %in% input$stressor, ]
    }
    if (!is.null(input$stressor_metric) && length(input$stressor_metric) > 0) {
      df <- df[df$specific_stressor_metric %in% input$stressor_metric, ]
    }
    if (!is.null(input$species) && length(input$species) > 0) {
      df <- df[df$species_common_name %in% input$species, ]
    }
    if (!is.null(input$geography) && length(input$geography) > 0) {
      df <- df[df$geography %in% input$geography, ]
    }
    if (!is.null(input$life_stage) && length(input$life_stage) > 0) {
      df <- df[Reduce(`|`, lapply(input$life_stage, function(stage) {
        grepl(stage, df$life_stages, ignore.case = TRUE)
      })), ]
    }
    if (!is.null(input$activity) && length(input$activity) > 0) {
      df <- df[df$activity %in% input$activity, ]
    }
    if (!is.null(input$genus_latin) && length(input$genus_latin) > 0) {
      df <- df[df$genus_latin %in% input$genus_latin, ]
    }
    if (!is.null(input$species_latin) && length(input$species_latin) > 0) {
      df <- df[df$species_latin %in% input$species_latin, ]
    }
    
    df
  })
  
  # Pagination logic
  pagination <- pagination_server(input, filtered_data)
  paginated_data <- pagination$paginated_data
  output$page_info <- renderText(pagination$page_info())
  
  #update_filters_server(input, output, session, data)
  update_filters_server(input, output, session, data, db)
  
  toggle_filters_server(input, session)
  reset_filters_server(input, session)
  
  #calling upload funtion
  upload_server("upload")

  # Render articles (paper cards)
  render_papers_server(output, paginated_data, input, session)
  
  
  # Download feature
  download_json(output, filtered_data, input, session)
  download_csv(output, filtered_data, input, session)
  
  # Download All JSON
  observeEvent(input$trigger_json_all, {
    showModal(modalDialog(
      title = span(icon("file-code"), "Download All - JSON"),
      div(
        style = "text-align: center; padding: 20px;",
        downloadButton("download_all_json", "Click to Download JSON", class = "btn btn-primary btn-lg")
      ),
      footer = modalButton("Close"),
      size = "m",
      easyClose = TRUE
    ))
  })
  observeEvent(input$download_all_json, { removeModal() })
  
  # Download All CSV
  observeEvent(input$trigger_csv_all, {
    showModal(modalDialog(
      title = span(icon("file-csv"), "Download All - CSV"),
      div(
        style = "text-align: center; padding: 20px;",
        downloadButton("download_all_csv", "Click to Download CSV", class = "btn btn-success btn-lg")
      ),
      footer = modalButton("Close"),
      size = "m",
      easyClose = TRUE
    ))
  })
  observeEvent(input$download_all_csv, { removeModal() })
  
  # Download Selected JSON
  observeEvent(input$trigger_json_selected, {
    showModal(modalDialog(
      title = span(icon("file-code"), "Download Selected - JSON"),
      div(
        style = "text-align: center; padding: 20px;",
        downloadButton("download_selected_json", "Click to Download JSON", class = "btn btn-primary btn-lg")
      ),
      footer = modalButton("Close"),
      size = "m",
      easyClose = TRUE
    ))
  })
  observeEvent(input$download_selected_json, { removeModal() })
  
  # Download Selected CSV
  observeEvent(input$trigger_csv_selected, {
    showModal(modalDialog(
      title = span(icon("file-csv"), "Download Selected - CSV"),
      div(
        style = "text-align: center; padding: 20px;",
        downloadButton("download_selected_csv", "Click to Download CSV", class = "btn btn-success btn-lg")
      ),
      footer = modalButton("Close"),
      size = "m",
      easyClose = TRUE
    ))
  })
  # Handle article display logic
  
  observeEvent(input$download_selected_csv, { removeModal() })
  observe({
    query <- parseQueryString(session$clientData$url_search)
    
    if (!is.null(query$main_id)) {
      main_id <- as.numeric(query$main_id)
      
      if (!is.na(main_id)) {
        tryCatch({
          render_article_ui(output, session)
          render_article_server(input, output, session, main_id, db)
        }, error = function(e) {
          output$article_content <- renderUI({
            tags$p(
              paste("Error rendering article:", e$message),
              style = "color: red; font-weight: bold;"
            )
          })
          print(e)
        })
      } else {
        output$article_content <- renderUI(
          tags$p("Article not found.", style = "color: red; font-weight: bold;")
        )
      }
    }
  })
  
  # Toggle sections logic
  observeEvent(input$toggle_metadata, { toggle("metadata_section") })
  observeEvent(input$toggle_description, { toggle("description_section") })
  observeEvent(input$toggle_citations, { toggle("citations_section") })
  observeEvent(input$toggle_images, { toggle("images_section") })
  observeEvent(input$toggle_csv, { toggle("csv_section") })
  observeEvent(input$toggle_plot, { toggle("plot_section") })
  observeEvent(input$generate_plot, { show("compare_plot") })
  observeEvent(filtered_data(), { updateNumericInput(session, "page", value = 1) })
  observeEvent(input$toggle_interactive_plot, { toggle("interactive_plot_section") })
  observeEvent(input$prev_page, { updateNumericInput(session, "page", value = max(1, input$page - 1)) })
  observeEvent(input$next_page, { updateNumericInput(session, "page", value = input$page + 1) })
  
  # Close the database connection when the session ends
  session$onSessionEnded(function() {
    dbDisconnect(db)
  })
  
  

}

# nolint end
