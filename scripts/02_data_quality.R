# ================================================================
# Digital Soil Spectroscopy for Soil Health Assessment
# Script: 02_data_quality.R
# Purpose: Assess structure and quality of Bungoma soil datasets
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
# 3. Select key datasets for initial assessment
# ----------------------------------------------------------------

soil_cn_file <- file.path(
  data_dir,
  "2017-2018 soil cn data with codes.csv"
)

spectra_file <- file.path(
  data_dir,
  "2017_2018 soil mir spectra.csv"
)

pxrf_file <- file.path(
  data_dir,
  "331_399 Bungoma soil pxrf data with codes.csv"
)

reference_file <- file.path(
  data_dir,
  "Bungoma 2017_2018 reference data.csv"
)


# ----------------------------------------------------------------
# 4. Import datasets
# ----------------------------------------------------------------

soil_cn <- readr::read_csv(
  soil_cn_file,
  show_col_types = FALSE
)

spectra <- readr::read_csv(
  spectra_file,
  show_col_types = FALSE
)

pxrf <- readr::read_csv(
  pxrf_file,
  show_col_types = FALSE
)

reference <- readr::read_csv(
  reference_file,
  show_col_types = FALSE
)


# ----------------------------------------------------------------
# 5. Dataset dimensions
# ----------------------------------------------------------------

cat("\n--- Dataset Dimensions ---\n")

cat("Soil C/N:", nrow(soil_cn), "rows x",
    ncol(soil_cn), "columns\n")

cat("MIR spectra:", nrow(spectra), "rows x",
    ncol(spectra), "columns\n")

cat("pXRF:", nrow(pxrf), "rows x",
    ncol(pxrf), "columns\n")

cat("Reference:", nrow(reference), "rows x",
    ncol(reference), "columns\n")


# ----------------------------------------------------------------
# 6. Column names
# ----------------------------------------------------------------

cat("\n--- Soil C/N Columns ---\n")
print(names(soil_cn))

cat("\n--- MIR Spectra Columns ---\n")
print(names(spectra))

cat("\n--- pXRF Columns ---\n")
print(names(pxrf))

cat("\n--- Reference Columns ---\n")
print(names(reference))


# ----------------------------------------------------------------
# 7. Missing values
# ----------------------------------------------------------------

cat("\n--- Missing Values ---\n")

cat("Soil C/N missing values:",
    sum(is.na(soil_cn)), "\n")

cat("MIR spectra missing values:",
    sum(is.na(spectra)), "\n")

cat("pXRF missing values:",
    sum(is.na(pxrf)), "\n")

cat("Reference missing values:",
    sum(is.na(reference)), "\n")


# ----------------------------------------------------------------
# 8. Duplicate rows
# ----------------------------------------------------------------

cat("\n--- Duplicate Rows ---\n")

cat("Soil C/N duplicates:",
    sum(duplicated(soil_cn)), "\n")

cat("MIR spectra duplicates:",
    sum(duplicated(spectra)), "\n")

cat("pXRF duplicates:",
    sum(duplicated(pxrf)), "\n")

cat("Reference duplicates:",
    sum(duplicated(reference)), "\n")


# ----------------------------------------------------------------
# 9. Basic summaries
# ----------------------------------------------------------------

cat("\n--- Soil C/N Summary ---\n")

print(
  skimr::skim(soil_cn)
)

# ----------------------------------------------------------------
# 10. Inspect sample identifiers
# ----------------------------------------------------------------

cat("\n--- Sample Identifiers ---\n")

cat("\nFirst 10 SSN values:\n")
print(head(soil_cn$SSN, 10))

cat("\nFirst 10 Plot.Code values:\n")
print(head(soil_cn$Plot.Code, 10))

cat("\nFirst 10 Plot.Name values:\n")
print(head(soil_cn$Plot.Name, 10))


# ----------------------------------------------------------------
# 11. Inspect the first rows of the main datasets
# ----------------------------------------------------------------

cat("\n--- Soil C/N First Rows ---\n")
print(head(soil_cn, 3))

cat("\n--- MIR Spectra First Rows ---\n")
print(
  spectra[, 1:min(10, ncol(spectra))]
  |> head(3)
)

cat("\n--- pXRF First Rows ---\n")
print(head(pxrf, 3))

cat("\n--- Reference First Rows ---\n")
print(head(reference, 3))


# ----------------------------------------------------------------
# 12. Check SSN matching between datasets
# ----------------------------------------------------------------

cat("\n--- SSN Matching ---\n")

# Number of unique SSNs
cat("Unique SSNs in soil C/N:",
    dplyr::n_distinct(soil_cn$SSN), "\n")

cat("Unique SSNs in MIR spectra:",
    dplyr::n_distinct(spectra$SSN), "\n")

cat("Unique SSNs in pXRF:",
    dplyr::n_distinct(pxrf$SSN), "\n")

cat("Unique SSNs in reference data:",
    dplyr::n_distinct(reference$SSN), "\n")


# ----------------------------------------------------------------
# 13. Match soil C/N with MIR spectra
# ----------------------------------------------------------------

soil_mir_match <- intersect(
  soil_cn$SSN,
  spectra$SSN
)

cat("\nSoil C/N SSNs also found in MIR spectra:",
    length(soil_mir_match), "\n")


# ----------------------------------------------------------------
# 14. Match reference data with MIR spectra
# ----------------------------------------------------------------

reference_mir_match <- intersect(
  reference$SSN,
  spectra$SSN
)

cat("Reference SSNs also found in MIR spectra:",
    length(reference_mir_match), "\n")


# ----------------------------------------------------------------
# 15. Match reference data with pXRF
# ----------------------------------------------------------------

reference_pxrf_match <- intersect(
  reference$SSN,
  pxrf$SSN
)

cat("Reference SSNs also found in pXRF:",
    length(reference_pxrf_match), "\n")


# ----------------------------------------------------------------
# 16. Check reference samples missing from MIR
# ----------------------------------------------------------------

reference_not_mir <- setdiff(
  reference$SSN,
  spectra$SSN
)

cat("\nReference samples NOT found in MIR spectra:",
    length(reference_not_mir), "\n")


# ----------------------------------------------------------------
# 17. Check MIR samples without reference data
# ----------------------------------------------------------------

mir_not_reference <- setdiff(
  spectra$SSN,
  reference$SSN
)

cat("MIR samples WITHOUT reference data:",
    length(mir_not_reference), "\n")

# ----------------------------------------------------------------
# End of script
# ----------------------------------------------------------------