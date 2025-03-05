# nolint start

library(shinyjs)
upload_server <- function(input, output, session) {
  
# Observe event for file uploads (Citations - Upload File)
observeEvent(input$citation_files, {
  req(input$citation_files) # checking if file is uploaded before proceeding
  
  uploaded_files <- input$citation_files
  file_paths <- uploaded_files$datapath
  
  showModal(modalDialog(
    title = "File Upload",
    paste("Uploaded files:", paste(uploaded_files$name, collapse = ", ")),
    easyClose = TRUE
  ))
})

# Observe event for image uploads
observeEvent(input$citation_images, {
  req(input$citation_images) # checking if image file is uploaded 
  
  uploaded_images <- input$citation_images
  image_paths <- uploaded_images$datapath
  
  showModal(modalDialog(
    title = "Image Upload",
    paste("Uploaded images:", paste(uploaded_images$name, collapse = ", ")),
    easyClose = TRUE
  ))
})

# Reactive list to store citation links
citation_links <- reactiveVal(data.frame(URL = character(), LinkText = character(), stringsAsFactors = FALSE))

# Observe event for adding a new citation link
observeEvent(input$add_citation_link, {
  new_citation <- data.frame(
    URL = input$citation_url,
    LinkText = input$citation_text,
    stringsAsFactors = FALSE
  )
  
  # Updating the reactive list
  citation_links(rbind(citation_links(), new_citation))
  
  # Clearing input fields once the link is added to the list
  updateTextInput(session, "citation_url", value = "")
  updateTextInput(session, "citation_text", value = "")
})

# # Debugging: Printing citation links in the console
# observe({
#   print(citation_links())
# })

# Showing success message when SR profile is saved
observeEvent(input$save_sr_profile, {
  showModal(modalDialog(
    title = "Success",
    "SR Profile has been saved successfully!",
    easyClose = TRUE
  ))
})

# This observe event shows the revision log message
observeEvent(input$save_sr_profile, {
  log_message <- input$revision_log
  
  if (nchar(log_message) > 0) {
    showModal(modalDialog(
      title = "Revision Saved",
      paste("Revision Log:", log_message),
      easyClose = TRUE
    ))
  }
})

# Enable/Disable the Preview button depending on the title (for now only title is mandatory for testing purposes.)
observe({
  shinyjs::toggleState("preview", condition = nchar(input$title) > 0)
})

# Show a warning if the user somehow bypasses the disable and clicks without a title
observeEvent(input$preview, {
    print("Preview button clicked")  # debugging

  if (nchar(input$title) == 0) {
    showModal(modalDialog(
      title = "Missing Required Field",
      "You must enter a title before previewing.",
      easyClose = TRUE
    ))
  } else {
    showModal(modalDialog(
      title = "Preview Submission",
      paste("Title:", input$title),
      paste("Stressor Name:", input$stressor_name),
      paste("Stressor Metric:", input$stressor_metric),
      paste("Stressor Units:", input$stressor_units),
      paste("Species Common Name:", input$species_common_name),
      paste("Genus Latin:", input$genus_latin),
      paste("Species Latin:", input$species_latin),
      paste("Geography:", input$geography),
      paste("Life Stage:", input$life_stage),
      paste("Activity:", input$activity),
      paste("Description:", input$description),
      paste("Function Derivation:", input$function_derivation),
      paste("Transferability:", input$transferability),
      paste("Source of Stressor Data:", input$source),
      paste("Stressor Scale:", input$stressor_scale),
      paste("Function Type:", input$function_type),
      easyClose = TRUE
    ))
  }
})

}
# nolint end