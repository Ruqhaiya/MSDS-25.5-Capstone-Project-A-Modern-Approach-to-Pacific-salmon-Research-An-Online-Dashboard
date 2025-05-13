# nolint start



update_filters_server <- function(input, output, session, data) {
  
  observe({
    
    # Build progressively filtered data (excluding the current input being updated)
    df <- data
    
    # Helper to apply filters except the one being updated
    apply_filter <- function(field, input_values, match_column, is_regex = FALSE) {
      if (!is.null(input_values) && length(input_values) > 0) {
        if (is_regex) {
          df <<- df[Reduce(`|`, lapply(input_values, function(val) grepl(val, df[[match_column]], ignore.case = TRUE))), ]
        } else {
          df <<- df[df[[match_column]] %in% input_values, ]
        }
      }
    }
    
    # STRESSOR
    df <- data
    apply_filter("stressor_metric", input$stressor_metric, "specific_stressor_metric")
    apply_filter("species", input$species, "species_common_name")
    apply_filter("geography", input$geography, "geography")
    apply_filter("life_stage", input$life_stage, "life_stages", is_regex = TRUE)
    apply_filter("activity", input$activity, "activity")
    apply_filter("genus_latin", input$genus_latin, "genus_latin")
    apply_filter("species_latin", input$species_latin, "species_latin")
    
    updatePickerInput(session, "stressor",
                      choices = sort(unique(df$stressor_name)),
                      selected = input$stressor[input$stressor %in% df$stressor_name])
    
    # STRESSOR METRIC
    df <- data
    apply_filter("stressor", input$stressor, "stressor_name")
    apply_filter("species", input$species, "species_common_name")
    apply_filter("geography", input$geography, "geography")
    apply_filter("life_stage", input$life_stage, "life_stages", is_regex = TRUE)
    apply_filter("activity", input$activity, "activity")
    apply_filter("genus_latin", input$genus_latin, "genus_latin")
    apply_filter("species_latin", input$species_latin, "species_latin")
    
    updatePickerInput(session, "stressor_metric",
                      choices = sort(unique(df$specific_stressor_metric)),
                      selected = input$stressor_metric[input$stressor_metric %in% df$specific_stressor_metric])
    
    # SPECIES
    df <- data
    apply_filter("stressor", input$stressor, "stressor_name")
    apply_filter("stressor_metric", input$stressor_metric, "specific_stressor_metric")
    apply_filter("geography", input$geography, "geography")
    apply_filter("life_stage", input$life_stage, "life_stages", is_regex = TRUE)
    apply_filter("activity", input$activity, "activity")
    apply_filter("genus_latin", input$genus_latin, "genus_latin")
    apply_filter("species_latin", input$species_latin, "species_latin")
    
    updatePickerInput(session, "species",
                      choices = sort(unique(df$species_common_name)),
                      selected = input$species[input$species %in% df$species_common_name])
    
    # GEOGRAPHY
    df <- data
    apply_filter("stressor", input$stressor, "stressor_name")
    apply_filter("stressor_metric", input$stressor_metric, "specific_stressor_metric")
    apply_filter("species", input$species, "species_common_name")
    apply_filter("life_stage", input$life_stage, "life_stages", is_regex = TRUE)
    apply_filter("activity", input$activity, "activity")
    apply_filter("genus_latin", input$genus_latin, "genus_latin")
    apply_filter("species_latin", input$species_latin, "species_latin")
    
    updatePickerInput(session, "geography",
                      choices = sort(unique(df$geography)),
                      selected = input$geography[input$geography %in% df$geography])
    
    # LIFE STAGE
    df <- data
    apply_filter("stressor", input$stressor, "stressor_name")
    apply_filter("stressor_metric", input$stressor_metric, "specific_stressor_metric")
    apply_filter("species", input$species, "species_common_name")
    apply_filter("geography", input$geography, "geography")
    apply_filter("activity", input$activity, "activity")
    apply_filter("genus_latin", input$genus_latin, "genus_latin")
    apply_filter("species_latin", input$species_latin, "species_latin")
    
    # Clean life stage values
    clean_life_stages <- unique(unlist(strsplit(df$life_stages, ",")))
    clean_life_stages <- trimws(gsub('["\\[\\]]', "", clean_life_stages))  # Remove quotes/brackets
    
    updatePickerInput(session, "life_stage",
                      choices = sort(unique(df$life_stages)),
                      selected = input$life_stage[input$life_stage %in% df$life_stages])
    
    # ACTIVITY
    df <- data
    apply_filter("stressor", input$stressor, "stressor_name")
    apply_filter("stressor_metric", input$stressor_metric, "specific_stressor_metric")
    apply_filter("species", input$species, "species_common_name")
    apply_filter("geography", input$geography, "geography")
    apply_filter("life_stage", input$life_stage, "life_stages", is_regex = TRUE)
    apply_filter("genus_latin", input$genus_latin, "genus_latin")
    apply_filter("species_latin", input$species_latin, "species_latin")
    
    updatePickerInput(session, "activity",
                      choices = sort(unique(df$activity)),
                      selected = input$activity[input$activity %in% df$activity])
    
    # GENUS LATIN
    df <- data
    apply_filter("stressor", input$stressor, "stressor_name")
    apply_filter("stressor_metric", input$stressor_metric, "specific_stressor_metric")
    apply_filter("species", input$species, "species_common_name")
    apply_filter("geography", input$geography, "geography")
    apply_filter("life_stage", input$life_stage, "life_stages", is_regex = TRUE)
    apply_filter("activity", input$activity, "activity")
    apply_filter("species_latin", input$species_latin, "species_latin")
    
    updatePickerInput(session, "genus_latin",
                      choices = sort(unique(df$genus_latin)),
                      selected = input$genus_latin[input$genus_latin %in% df$genus_latin])
    
    # SPECIES LATIN
    df <- data
    apply_filter("stressor", input$stressor, "stressor_name")
    apply_filter("stressor_metric", input$stressor_metric, "specific_stressor_metric")
    apply_filter("species", input$species, "species_common_name")
    apply_filter("geography", input$geography, "geography")
    apply_filter("life_stage", input$life_stage, "life_stages", is_regex = TRUE)
    apply_filter("activity", input$activity, "activity")
    apply_filter("genus_latin", input$genus_latin, "genus_latin")
    
    updatePickerInput(session, "species_latin",
                      choices = sort(unique(df$species_latin)),
                      selected = input$species_latin[input$species_latin %in% df$species_latin])
  })
}

# nolint end
