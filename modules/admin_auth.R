# nolint start
library(shiny)

# UI: shows a password box + login button
adminAuthUI <- function(id) {
  ns <- NS(id)
  tagList(
    passwordInput(ns("pwd"), "Admin password:"),
    actionButton(ns("login"), "Login", class = "btn-primary"),
    tags$hr()
  )
}

# Server: checks against a hard-coded password
# Returns a reactiveVal(TRUE/FALSE) for login status
adminAuthServer <- function(id, correct_pw = "secret123", updateStatus = NULL) {
  moduleServer(id, function(input, output, session) {
    logged_in <- reactiveVal(FALSE)
    
    # Actual login logic
    do_login <- function() {
      req(input$pwd)
      if (input$pwd == correct_pw) {
        if (!is.null(updateStatus)) updateStatus(TRUE)
        logged_in(TRUE)
        showNotification("🔓 Admin unlocked", type = "message")
      } else {
        showNotification("❌ Wrong password", type = "error")
      }
    }
    
    # Login on button click
    observeEvent(input$login, {
      do_login()
    })
    
    # Also login on pressing Enter (when typing password)
    observeEvent(input$pwd, {
      if (!logged_in()) {
        do_login()
      }
    })
  })
}

# nolint end
