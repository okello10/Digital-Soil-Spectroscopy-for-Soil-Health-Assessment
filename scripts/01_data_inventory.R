# ================================================================
# Digital Soil Spectroscopy for Soil Health Assessment
# Script: 01_data_inventory.R
# Purpose: Inspect and document available soil datasets
# Author: Gard Okello
# ================================================================


# ----------------------------------------------------------------
# 1. Project setup
# ----------------------------------------------------------------

source("scripts/00_setup.R")


# ----------------------------------------------------------------
# 2. Define data directory
# ----------------------------------------------------------------

data_dir <- "Data/SOIL"


# ----------------------------------------------------------------
# 3. List CSV datasets
# ----------------------------------------------------------------

csv_files <- list.files(
  data_dir,
  pattern = "\\.csv$",
  full.names = TRUE
)

csv_files


# ----------------------------------------------------------------
# 4. Create a simple dataset inventory
# ----------------------------------------------------------------

data_inventory <- data.frame(
  file_name = basename(csv_files),
  file_path = csv_files,
  stringsAsFactors = FALSE
)

data_inventory


# ----------------------------------------------------------------
# 5. Inspect dimensions of each CSV file
# ----------------------------------------------------------------

data_dimensions <- lapply(csv_files, function(file) {
  
  data <- readr::read_csv(
    file,
    show_col_types = FALSE
  )
  
  data.frame(
    file_name = basename(file),
    rows = nrow(data),
    columns = ncol(data)
  )
})

data_dimensions <- dplyr::bind_rows(data_dimensions)

data_dimensions


# ----------------------------------------------------------------
# 6. Display dataset dimensions
# ----------------------------------------------------------------

print(data_dimensions)


# ----------------------------------------------------------------
# End of script
# ----------------------------------------------------------------