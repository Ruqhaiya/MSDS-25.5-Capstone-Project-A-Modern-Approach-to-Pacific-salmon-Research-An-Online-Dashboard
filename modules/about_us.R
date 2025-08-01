about_us <- function(id) {
    ns <- NS(id)
    tagList(
      h2("About the Salmonid Stressor-Response e-Library"),
      p("The Salmonid Stressor-Response e-Library is an open-source, centralized resource designed to support researchers and modelers working with life cycle models (LCMs). 
       It consolidates and organizes published quantitative relationships between environmental stressors and salmonid life stages, making it easier to access and apply relevant data."),
      
      p("This e-library serves as a decision-support tool, helping ensure that life cycle modeling efforts are built on a shared foundation of empirical data. 
       While the provided relationships are drawn from peer-reviewed literature and rigorously vetted studies, users should critically assess the data’s applicability to their specific models—considering factors such as regional differences, study limitations, and context-specific variables."),
      
      h3("How This Tool Supports Conservation Efforts"),
      tags$ul(
        tags$li(strong("Improve Model Accuracy – "), "Ensuring researchers and decision-makers have access to consistent, high-quality data reduces uncertainty in life cycle modeling."),
        tags$li(strong("Identify Knowledge Gaps – "), "Highlighting areas where data is lacking can guide future research and funding priorities."),
        tags$li(strong("Support Policy & Management Decisions – "), "Reliable data on stressor-response functions can inform habitat restoration, water management, and conservation policy."),
        tags$li(strong("Encourage Open Science – "), "By making key data easily accessible, the e-library fosters collaboration and transparency within the life cycle modeling community.")
      ),
      
      h3("Using the e-Library"),
      p("If relevant studies appear, review the metadata and study details to determine whether the findings align with your research needs."),
      p("If no studies are returned, this may indicate:"),
      tags$ul(
        tags$li("The topic has not yet been researched by our team, AND/OR"),
        tags$li("A gap exists in the scientific literature, highlighting an area for future study.")
      ),
      
      p("By providing a one-stop, transparent repository of stressor-response functions, this e-library supports informed decision-making and fosters an open-science approach within the LCM community.")
    )
  }

