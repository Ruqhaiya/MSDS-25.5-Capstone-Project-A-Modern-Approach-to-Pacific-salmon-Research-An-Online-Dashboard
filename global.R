# nolint start

library(shiny)
library(DBI)
library(RSQLite)

# Connect to SQLite database
db_path <- "data/stressor_responses.sqlite"
conn <- dbConnect(SQLite(), db_path)

# Check if the `stressor_responses` table exists before querying
if ("stressor_responses" %in% dbListTables(conn)) {
  
  # Load data from `stressor_responses`
  data <- dbGetQuery(conn, "SELECT * FROM stressor_responses")
  
  # Extract unique values for dropdowns
  stressor_names <- unique(data$stressor_name)
  stressor_metrics <- unique(data$specific_stressor_metric)
  species_names <- unique(data$species_common_name)
  geographies <- unique(data$geography)
  life_stages <- unique(data$life_stages)
  activities <- unique(data$activity)
  genus_latin <- unique(data$genus_latin)
  species_latin <- unique(data$species_latin)
  
  
} else {
  warning("Table `stressor_responses` does not exist in the database.")
}

# Close database connection to prevent memory leaks
dbDisconnect(conn)

# nolint end
