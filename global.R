# nolint start 

library(shiny)
library(jsonlite)
library(shinyWidgets)

# loading data
data <- fromJSON("data/merged_stressor_responses.json")

# Flattening list fields to strings, some of them have inconsistent commas
data$species_common_name <- sapply(data$species_common_name, function(x) paste(unlist(x), collapse = ", "))
data$life_stages <- sapply(data$life_stages, function(x) paste(unlist(x), collapse = ", "))
data$activity <- sapply(data$activity, function(x) paste(unlist(x), collapse = ", "))
data$geography <- sapply(data$geography, function(x) paste(unlist(x), collapse = ", "))
data$genus_latin <- sapply(data$genus_latin, function(x) paste(unlist(x), collapse = ", "))
data$species_latin <- sapply(data$species_latin, function(x) paste(unlist(x), collapse = ", "))

# Extracting unique values for dropdowns (purely from the data)
stressor_names <- unique(unlist(data$stressor_name))
stressor_metrics <- unique(unlist(data$specific_stressor_metric))
species_names <- unique(unlist(data$species_common_name))
geographies <- unique(unlist(data$geography))
life_stages <- unique(unlist(data$life_stages))
activities <- unique(unlist(data$activity))
genus_latin <- unique(unlist(data$genus_latin))
species_latin <- unique(unlist(data$species_latin))

# nolint end