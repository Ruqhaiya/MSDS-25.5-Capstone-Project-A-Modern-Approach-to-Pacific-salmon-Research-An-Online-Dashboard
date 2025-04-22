# nolint start

library(shinyjs)
library(dygraphs)

render_article_ui <- function(output, session) {
  output$article_content <- renderUI({
    
    tagList(
      useShinyjs(),  # Enabling JavaScript for toggling sections

      # Back button to return to dashboard
      tags$a(
        href = "?",
        tags$div(id = "customArrow", class = "arrow-container")
      ),
      tags$style(HTML("
        .arrow-container {
          width: 30px;
          height: 30px;
          display: flex;
          align-items: center;
          justify-content: center;
          cursor: pointer;
        }
        
        .arrow-container::before {
          content: '\\2190'; /* Unicode for left arrow */
          font-size: 24px;
          color: #2C3E50;
        }
      ")),

      # Article Metadata Section 
      div(style = "border: 1px solid #ddd; padding: 15px; margin-bottom: 10px; background-color: #f8f9fa; border-radius: 8px;",
          actionLink("toggle_metadata", strong("Article Metadata ▼")),
          hidden(div(id = "metadata_section",
              strong("Species Common Name: "), textOutput("species_name"), br(),
              strong("Latin Name (Genus species): "), em(textOutput("genus_latin")), br(),
              strong("Stressor Name: "), textOutput("stressor_name"), br(),
              strong("Specific Stressor Metric: "), textOutput("specific_stressor_metric"), br(),
              strong("Stressor Units: "), textOutput("stressor_units"), br(),
              strong("Vital Rate (Process): "), textOutput("vital_rate"), br(),
              strong("Life Stage: "), textOutput("life_stage")
          ))
      ),

      # Description & Function Details 
      div(style = "border: 1px solid #ddd; padding: 15px; margin-bottom: 10px; background-color: #ffffff; border-radius: 8px;",
          actionLink("toggle_description", strong("Description & Function Details ▼")),
          hidden(div(id = "description_section",
              strong("Detailed SR Function Description"), br(), textOutput("description_overview"), br(), br(),
              strong("Function Derivation"), br(), textOutput("function_derivation")
          ))
      ),

      # Citations Section 
      div(style = "border: 1px solid #ddd; padding: 15px; margin-bottom: 10px; background-color: #ffffff; border-radius: 8px;",
          actionLink("toggle_citations", strong("Citation(s) ▼")),
          hidden(div(id = "citations_section", uiOutput("citations")))
      ),

      # Images Section 
      div(style = "border: 1px solid #ddd; padding: 15px; margin-bottom: 10px; background-color: #ffffff; border-radius: 8px;",
          actionLink("toggle_images", strong("Images ▼")),
          hidden(div(id = "images_section", uiOutput("article_images")))
      ),

      # CSV Data Table 
      div(style = "border: 1px solid #ddd; padding: 15px; margin-bottom: 10px; background-color: #ffffff; border-radius: 8px;",
          actionLink("toggle_csv", strong("Stressor Response Data ▼")),
          hidden(div(id = "csv_section", tableOutput("csv_table")))
      ),

      # Stressor Response Plot 
      div(style = "border: 1px solid #ddd; padding: 15px; margin-bottom: 10px; background-color: #ffffff; border-radius: 8px;",
          actionLink("toggle_plot", strong("Stressor Response Chart ▼")),
          hidden(div(id = "plot_section", plotOutput("stressor_plot")))
      ),
      
      # Interactive Plot Section using dygraphs
      # Interactive Plot Section using Plotly
      div(
        style = "border: 1px solid #ddd; padding: 15px; margin-bottom: 10px; background-color: #ffffff; border-radius: 8px;",
        actionLink("toggle_interactive_plot", strong("Interactive Plot ▼")),
        hidden(div(id = "interactive_plot_section", plotlyOutput("interactive_plot")))
      
      
          
          
      )
    )
  })
}

# nolint end
