# nolint start

library(jsonlite)
library(dplyr)
library(tidyr)
library(DBI)
library(RSQLite)

# Load JSON file with UTF-8 encoding fix
json_text <- paste(readLines("data/merged_stressor_responses.json", warn = FALSE), collapse = "")
data <- fromJSON(json_text, flatten = TRUE)

# Convert list columns to JSON strings
main_table <- data %>%
  select(-csv_data) %>%
  mutate(across(where(is.list), ~ sapply(., toJSON, auto_unbox = TRUE))) %>%
  mutate(csv_data_json = sapply(data$csv_data, function(x) toJSON(x, auto_unbox = TRUE)))

# Extract csv_data as a separate table
csv_data_list <- data %>%
  select(id, csv_data) %>%
  filter(lengths(csv_data) > 0)

# Function to safely convert csv_data entries to data frames
safe_convert_to_df <- function(x) {
  if (is.null(x) || length(x) == 0) return(NULL)
  if (is.data.frame(x)) return(x)
  if (is.vector(x)) return(as.data.frame(t(x)))
  if (!is.list(x[[1]])) return(as.data.frame(x))
  return(as.data.frame(do.call(rbind, lapply(x, function(row) if (is.null(row)) rep(NA, length(all_columns)) else row))))
}

# Apply safe conversion function to all csv_data entries
csv_data_list$csv_data <- lapply(csv_data_list$csv_data, safe_convert_to_df)

# Define standard column names mapping
column_mappings <- list(
  "Stressor" = c("Stressor (X)", "Angling Effort (hours/km)", "Temperature (June 1-21 ADM)", "Raw Stressor Values"),
  "Mean_Percent" = c("Mean System Capacity (%)", "Scaled Response Values 0 to 100", "Juvenile Survival (%)")
)

# Function to rename columns based on mapping
rename_columns <- function(df) {
  if (is.null(df)) return(NULL)
  colnames(df) <- sapply(colnames(df), function(col) {
    matched_name <- unlist(lapply(column_mappings, function(aliases) {
      if (col %in% aliases) return(names(column_mappings)[which(sapply(column_mappings, function(x) col %in% x))])
    }))
    return(ifelse(length(matched_name) > 0, matched_name, col))
  })
  return(df)
}

# Apply renaming function to all csv_data entries
csv_data_list$csv_data <- lapply(csv_data_list$csv_data, rename_columns)

# Standardize csv_data column names
all_columns <- unique(unlist(lapply(csv_data_list$csv_data, function(x) if (!is.null(x)) names(x) else NULL))))

# Function to standardize each csv_data entry
standardize_csv_data <- function(df, id) {
  if (is.null(df)) return(NULL)
  missing_cols <- setdiff(all_columns, names(df))
  df[missing_cols] <- NA
  df$id <- id
  return(df)
}

# Apply function to all csv_data entries
csv_data_table <- bind_rows(mapply(standardize_csv_data, csv_data_list$csv_data, csv_data_list$id, SIMPLIFY = FALSE))

# Rename columns for SQLite compatibility
csv_data_table <- rename_with(csv_data_table, ~ gsub("[^A-Za-z0-9_]", "_", .))

# Create SQLite database
db_path <- "stressor_responses.sqlite"
conn <- dbConnect(SQLite(), db_path)

# Write tables to SQLite
dbWriteTable(conn, "stressor_responses", main_table, overwrite = TRUE)
dbWriteTable(conn, "csv_data_table", csv_data_table, overwrite = TRUE)

# Close connection
dbDisconnect(conn)

# nolint end
