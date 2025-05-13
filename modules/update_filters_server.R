update_filters_server <- function(input, output, session, data, db) {
  # 1) Define all filters in one place
  filter_specs <- list(
    stressor = list(input_id = "stressor",
                    column   = "stressor_name",
                    table    = "stressor_names",
                    regex    = FALSE),
    stressor_metric = list(input_id = "stressor_metric",
                           column   = "specific_stressor_metric",
                           table    = "stressor_metrics",
                           regex    = FALSE),
    species = list(input_id = "species",
                   column   = "species_common_name",
                   table    = "species_common_names",
                   regex    = FALSE),
    geography = list(input_id = "geography",
                     column   = "geography",
                     table    = "geographies",
                     regex    = FALSE),
    life_stage = list(input_id = "life_stage",
                      column   = "life_stages",
                      table    = "life_stages",
                      regex    = TRUE),       # use regex for filtering
    activity = list(input_id = "activity",
                    column   = "activity",
                    table    = "activities",
                    regex    = FALSE),
    genus_latin = list(input_id = "genus_latin",
                       column   = "genus_latin",
                       table    = "genus_latins",
                       regex    = FALSE),
    species_latin = list(input_id = "species_latin",
                         column   = "species_latin",
                         table    = "species_latins",
                         regex    = FALSE)
  )
  
  # helper: apply one filter to df
  apply_filter <- function(df, vals, col, regex) {
    if (is.null(vals) || length(vals) == 0) return(df)
    if (regex) {
      keep <- Reduce(`|`, lapply(vals, function(v) {
        grepl(v, df[[col]], ignore.case = TRUE)
      }), init = FALSE)
      df[keep, ]
    } else {
      df[df[[col]] %in% vals, ]
    }
  }
  
  # helper: clean and split life_stages if needed
  clean_life_stages <- function(vec) {
    parts <- unique(unlist(strsplit(vec, ","), use.names = FALSE))
    parts <- trimws(gsub('["\\[\\]]', "", parts))
    parts[parts != ""]
  }
  
  observe({
    # iterate over each filter
    for (name in names(filter_specs)) {
      spec <- filter_specs[[name]]
      
      # -- cascade-filter data by ALL OTHER filters --
      df_sub <- data
      for (other in filter_specs[names(filter_specs) != name]) {
        vals <- input[[ other$input_id ]]
        df_sub <- apply_filter(df_sub, vals, other$column, other$regex)
      }
      
      # -- get lookup-table values --
      lookup_vals <- dbGetQuery(db,
                                sprintf("SELECT name FROM %s ORDER BY name", spec$table)
      )$name
      
      # -- get dynamic values still present in the cascade --
      if (spec$input_id == "life_stage") {
        dynamic_vals <- clean_life_stages(df_sub[[ spec$column ]])
      } else {
        dynamic_vals <- unique(df_sub[[ spec$column ]])
        dynamic_vals <- dynamic_vals[!is.na(dynamic_vals)]
      }
      
      # -- union & sort --
      all_choices <- sort(unique(c(lookup_vals, dynamic_vals)))
      
      # -- push into the pickerInput --
      updatePickerInput(session, spec$input_id,
                        choices  = all_choices,
                        selected = intersect(input[[ spec$input_id ]], all_choices)
      )
    }
  })
}
