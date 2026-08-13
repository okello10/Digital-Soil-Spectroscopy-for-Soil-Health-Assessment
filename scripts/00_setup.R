# ======================================================================
# Digital Soil Spectroscopy for Soil Health Assessment
# Script: 00_setup.R
# Author: Gard Okello
# Purpose: Set up the R environment for the project
# ======================================================================


# ----------------------------------------------------------------------
# 1. Required Packages
# ----------------------------------------------------------------------

required_packages <- c(
  "tidyverse",
  "readr",
  "janitor",
  "skimr",
  "ggplot2",
  "corrplot",
  "GGally",
  "caret",
  "pls",
  "randomForest",
  "prospectr",
  "plotly",
  "patchwork"
)


# ----------------------------------------------------------------------
# 2. Identify Missing Packages
# ----------------------------------------------------------------------

installed_packages <- rownames(installed.packages())

missing_packages <- required_packages[
  !required_packages %in% installed_packages
]


# ----------------------------------------------------------------------
# 3. Install Missing Packages
# ----------------------------------------------------------------------

if (length(missing_packages) > 0) {
  
  install.packages(missing_packages)
  
}


# ----------------------------------------------------------------------
# 4. Load Required Packages
# ----------------------------------------------------------------------

invisible(
  lapply(
    required_packages,
    library,
    character.only = TRUE
  )
)


# ----------------------------------------------------------------------
# 5. Project Information
# ----------------------------------------------------------------------

cat("\n")
cat("Digital Soil Spectroscopy for Soil Health Assessment\n")
cat("R version:", R.version.string, "\n")
cat("Setup completed successfully.\n")
cat("\n")


# ----------------------------------------------------------------------
# End of Script
# ----------------------------------------------------------------------